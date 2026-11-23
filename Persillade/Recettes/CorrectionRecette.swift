import PersilladeCore
import SwiftUI
import UIKit

struct CorrectionRecette: View {
    private enum Champ: Hashable {
        case titre, portions
        case ingredient(UUID)
        case quantite(UUID)
        case unite(UUID)
        case etape(UUID)

        var ingredient: UUID? {
            switch self {
            case .ingredient(let id), .quantite(let id), .unite(let id): id
            default: nil
            }
        }

        var ancre: Self {
            if let ingredient { return .ingredient(ingredient) }
            return self
        }
    }

    private enum Suppression {
        case ingredient(Int, LigneIngredientCorrection)
        case etape(Int, LigneEtapeCorrection)
    }

    let fermer: () -> Void
    let enregistrer: (Recette) async throws -> Void
    let retirerSource: () async throws -> Void
    let terminer: (UUID) -> Void

    static let messageCloture = "La recette est enregistrée. La correction n’a pas pu être clôturée."

    private let donnees: ContexteCorrection
    private let source: String
    private let photo: Data?
    private let repris: Bool
    @State private var initial: FormulaireRecette

    @Environment(SuiviBrouillonCorrection.self) private var suivi
    @Environment(\.scenePhase) private var phase
    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.colorSchemeContrast) private var contraste
    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @FocusState private var saisie: Champ?
    @ScaledMetric(relativeTo: .title2) private var colonnePesee = GrillePersillade.colonnePesee
    @State private var formulaire: FormulaireRecette
    @State private var ingredientOuvert: UUID?
    @State private var confirmerQuitter = false
    @State private var enregistrant = false
    @State private var enregistree = false
    @State private var erreurValidation: String?
    @State private var erreurEcriture = false
    @State private var erreurAbandon = false
    @State private var sourceOuverte: Bool?
    @State private var photoAgrandie = false
    @State private var suppression: Suppression?

    init(
        donnees: DonneesCorrection, photo: Data? = nil, repris: Bool = false, enregistree: Bool = false,
        fermer: @escaping () -> Void, enregistrer: @escaping (Recette) async throws -> Void,
        retirerSource: @escaping () async throws -> Void = {}, terminer: @escaping (UUID) -> Void
    ) {
        self.fermer = fermer
        self.enregistrer = enregistrer
        self.retirerSource = retirerSource
        self.terminer = terminer
        self.donnees = donnees.contexte
        source = donnees.source
        self.photo = photo
        self.repris = repris
        _initial = State(initialValue: donnees.formulaire)
        _formulaire = State(initialValue: donnees.formulaire)
        _enregistree = State(initialValue: enregistree)
        _erreurEcriture = State(initialValue: enregistree)
    }

    private var brouillon: BrouillonCorrection { .recette(donnees, formulaire, validation: false) }

    private var brouillonNecessaire: Bool {
        repris || donnees.sourceId != nil || formulaire != initial || suivi.aUnBrouillon
    }

    private var alertes: [Champ] {
        var champs: [Champ] = []
        if formulaire.portions.isEmpty { champs.append(.portions) }
        champs += formulaire.ingredients.filter(\.aVerifier).map { .ingredient($0.id) }
        return champs
    }

    var body: some View {
        ScrollViewReader { defilement in
            List {
                if suivi.erreurEcriture {
                    Section {
                        Label(
                            "Impossible de garder le brouillon sur l’iPhone.",
                            systemImage: "exclamationmark.circle"
                        )
                        .foregroundStyle(CouleurPersillade.tomate.couleur)
                        .ligneDeCorrection()
                        Button("Réessayer") { suivi.programmer(brouillon) }
                            .disabled(enregistrant || enregistree)
                            .ligneDeCorrection()
                    }
                }
                if erreurEcriture {
                    Section {
                        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
                            Text(
                                enregistree
                                    ? Self.messageCloture
                                    : "La recette n’a pas été enregistrée. Rien n’est perdu."
                            )
                            .typographie(.alerte)
                            .foregroundStyle(CouleurPersillade.tomate.couleur)
                            BoutonActionPersillade("Réessayer") { sauvegarder(defilement) }
                                .disabled(enregistrant)
                        }
                    }
                    .id("erreur-ecriture")
                    .ligneDeCorrection()
                }
                if let erreurValidation {
                    Section {
                        Label(erreurValidation, systemImage: "exclamationmark.circle")
                            .typographie(.alerte)
                            .foregroundStyle(CouleurPersillade.tomate.couleur)
                            .ligneDeCorrection()
                    }
                }
                if donnees.photoSansTexte {
                    Section {
                        Label(
                            "Aucun texte n’a été lu sur cette photo. Vous pouvez saisir la recette.",
                            systemImage: "text.viewfinder"
                        )
                        .typographie(.alerte)
                        .foregroundStyle(CouleurPersillade.tomate.couleur)
                        .accessibilityIdentifier("photo-sans-texte")
                        .ligneDeCorrection()
                    }
                    .listRowBackground(CouleurPersillade.page2.couleur)
                }
                if let photo, let image = UIImage(data: photo) {
                    Section {
                        Button {
                            photoAgrandie = true
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 136)
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .padding(GrillePersillade.pas * 2)
                                        .background(CouleurPersillade.page.couleur, in: .circle)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Agrandir la photo de la recette")
                        .accessibilityIdentifier("photo-correction")
                        .ligneDeCorrection()
                    }
                    .listRowBackground(CouleurPersillade.page2.couleur)
                }
                if !source.isEmpty && saisie == nil {
                    Section { panneauSource(defilement) }
                }
                if donnees.cause != nil || !alertes.isEmpty {
                    Section { bandeau(defilement) }
                }

                Group {
                    Section {
                        champTitre.id(Champ.titre)
                        champPortions(defilement).id(Champ.portions)
                    }
                    sectionIngredients(defilement)
                    sectionEtapes(defilement)
                    if suppression != nil {
                        Section {
                            Button("Annuler la suppression", action: restaurer)
                                .ligneDeCorrection()
                        }
                    }
                }
                .disabled(enregistree || enregistrant)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, GrillePersillade.ingredient)
            .scrollContentBackground(.hidden)
            .foregroundStyle(CouleurPersillade.encre.couleur)
            .background(CouleurPersillade.page.couleur)
            .scrollDismissesKeyboard(.interactively)
            .reorderContainer(for: LigneIngredientCorrection.self, isEnabled: !enregistrant && !enregistree) {
                difference in
                appliquerReordre(&formulaire.ingredients, selon: difference)
            }
            .reorderContainer(for: LigneEtapeCorrection.self, isEnabled: !enregistrant && !enregistree) { difference in
                appliquerReordre(&formulaire.etapes, selon: difference)
            }
            .navigationTitle(donnees.modification ? "Modifier la recette" : "Correction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") {
                        if enregistree {
                            fermer()
                        } else if repris || formulaire != initial || erreurEcriture {
                            confirmerQuitter = true
                        } else {
                            abandonner()
                        }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(enregistrant)
                    .accessibilityIdentifier("fermer-correction")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(enregistree ? "Réessayer" : "Enregistrer") { sauvegarder(defilement) }
                        .buttonStyle(.glassProminent)
                        .disabled(enregistrant)
                        .accessibilityIdentifier("enregistrer-correction")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    commandesClavier(defilement)
                }
            }
            .confirmationDialog("Quitter sans enregistrer ?", isPresented: $confirmerQuitter, titleVisibility: .visible)
            {
                Button("Continuer", role: .cancel) {}
                Button("Quitter", role: .destructive, action: abandonner)
            } message: {
                Text("Les corrections seront perdues.")
            }
            .onChange(of: alertes) { precedentes, courantes in
                if !precedentes.isEmpty && courantes.isEmpty && !mouvementReduit {
                    AccessibilityNotification.Announcement("Toutes les alertes sont corrigées.").post()
                }
            }
            .sensoryFeedback(.success, trigger: alertes.isEmpty) { _, vide in vide }
        }
        .tint(CouleurPersillade.persil.couleur)
        .sheet(isPresented: $photoAgrandie) {
            if let photo, let image = UIImage(data: photo) {
                NavigationStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Photo de la recette")
                        .accessibilityIdentifier("photo-correction-agrandie")
                        .navigationTitle("Photo de la recette")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fermer", systemImage: "xmark") { photoAgrandie = false }
                                    .labelStyle(.iconOnly)
                            }
                        }
                }
                .presentationBackground(CouleurPersillade.page.couleur)
            }
        }
        .interactiveDismissDisabled()
        .onChange(of: formulaire, initial: true) { precedent, _ in
            if (brouillonNecessaire || precedent != initial) && !enregistrant && !enregistree {
                suivi.programmer(brouillon)
            }
        }
        .onChange(of: phase) { _, phase in
            if phase != .active && brouillonNecessaire && !enregistrant && !enregistree {
                suivi.enArrierePlan(brouillon)
            }
        }
        #if DEBUG
            .overlay(alignment: .topTrailing) { suivi.temoinEcriturePourEssai }
        #endif
        .alert("Impossible d’abandonner le brouillon.", isPresented: $erreurAbandon) {
            Button("OK", role: .cancel) {}
        }
    }

    private func abandonner() {
        enregistrant = true
        Task {
            defer { enregistrant = false }
            do {
                try await suivi.effacer()
                fermer()
            } catch {
                erreurAbandon = true
            }
        }
    }

    private var champTitre: some View {
        let afficherSurPlusieursLignes = taille.isAccessibilitySize && saisie != .titre && !formulaire.titreVide
        return VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            Text("Titre").typographie(.precision)
                .foregroundStyle(CouleurPersillade.encre2.couleur)
                .accessibilityHidden(true)
            ZStack(alignment: .leading) {
                if afficherSurPlusieursLignes {
                    Text(formulaire.titre).typographie(.recette)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                }
                TextField(
                    "Titre de la recette", text: $formulaire.titre,
                    prompt: Text("Titre de la recette").foregroundStyle(CouleurPersillade.encre2.couleur)
                )
                .typographie(.recette)
                .foregroundStyle(afficherSurPlusieursLignes ? .clear : CouleurPersillade.encre.couleur)
                .frame(minHeight: GrillePersillade.cible)
                .focused($saisie, equals: .titre)
                .accessibilityIdentifier("titre-correction")
            }
            .cadreChampCorrection()
            .contentShape(.rect)
            .simultaneousGesture(TapGesture().onEnded { saisie = .titre })
        }
        .padding(.vertical, GrillePersillade.pas * 2)
        .ligneDeCorrection()
    }

    private func champPortions(_ defilement: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
            HStack(spacing: GrillePersillade.gouttiere) {
                Text("Portions").typographie(.section)
                    .fixedSize(horizontal: true, vertical: false)
                    .accessibilityHidden(true)
                TextField(
                    "Portions", text: $formulaire.portions,
                    prompt: Text("4").foregroundStyle(CouleurPersillade.encre2.couleur)
                )
                .typographie(.quantite)
                .multilineTextAlignment(.trailing)
                .frame(minHeight: GrillePersillade.cible)
                .cadreChampCorrection()
                .keyboardType(.numberPad)
                .focused($saisie, equals: .portions)
                .accessibilityIdentifier("portions-correction")
            }
            if formulaire.portions.isEmpty {
                let disposition =
                    taille.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: GrillePersillade.pas * 2))
                    : AnyLayout(HStackLayout(spacing: GrillePersillade.pas * 2))
                disposition {
                    PastilleAVerifier(libelle: "Absent du texte, 4 par défaut")
                        .labelStyle(StylePastilleCorrection())
                    boutonVerification("Garder 4") {
                        withAnimation(.easeInOut(duration: mouvementReduit ? 0.2 : 0.25)) {
                            formulaire.portions = "4"
                        }
                        saisie = nil
                        if let suivant = alertes.first { montrer(suivant, dans: defilement) }
                    }
                }
            }
        }
        .padding(.vertical, GrillePersillade.pas * 2)
        .ligneDeCorrection()
        .listRowBackground(
            formulaire.portions.isEmpty ? CouleurPersillade.beurreFond.couleur : CouleurPersillade.page.couleur)
    }

    private func bandeau(_ defilement: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
            if let cause = donnees.cause {
                Label(libelle(cause), systemImage: "exclamationmark.circle")
                    .typographie(.alerte)
            }
            if let premier = alertes.first {
                let nombre = alertes.count
                let disposition =
                    taille.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: GrillePersillade.pas))
                    : AnyLayout(HStackLayout(spacing: GrillePersillade.pas * 2))
                disposition {
                    Label(
                        nombre == 1 ? "1 point à vérifier" : "\(nombre) points à vérifier",
                        systemImage: "exclamationmark.circle.fill"
                    )
                    .typographie(.alerte)
                    .labelStyle(StylePastilleCorrection())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    boutonVerification("Suivant") { montrer(premier, dans: defilement) }
                }
            } else if donnees.cause != nil {
                boutonVerification(donnees.cause == .contenuTropLong ? "Voir le texte" : "Suivant") {
                    if donnees.cause == .contenuTropLong {
                        sourceOuverte = true
                        defilement.scrollTo("texte-recu", anchor: .top)
                    } else if let ingredient = formulaire.ingredients.first {
                        montrer(.ingredient(ingredient.id), dans: defilement)
                    } else {
                        montrer(.titre, dans: defilement)
                    }
                }
            }
        }
        .padding(.vertical, GrillePersillade.pas)
        .ligneDeCorrection()
        .foregroundStyle(CouleurPersillade.surBeurre.couleur)
        .tint(CouleurPersillade.surBeurre.couleur)
        .listRowBackground(CouleurPersillade.beurre.couleur)
    }

    private func boutonVerification(_ libelle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(libelle).typographie(.bouton)
                .multilineTextAlignment(.center)
                .padding(.horizontal, GrillePersillade.marge)
                .padding(.vertical, GrillePersillade.pas)
                .frame(minHeight: GrillePersillade.cible)
                .foregroundStyle(CouleurPersillade.surBeurre.couleur)
                .background(CouleurPersillade.beurre.couleur, in: .capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(CouleurPersillade.surBeurre.couleur, lineWidth: contraste == .increased ? 2 : 1)
                }
                .contentShape(.capsule)
        }
        .buttonStyle(StyleBoutonPersillade())
    }

    private func libelle(_ cause: CauseExtraction) -> String {
        switch cause {
        case .iaIndisponible:
            "Apple Intelligence est indisponible. Les ingrédients ont été lus ligne par ligne, vérifiez les étapes."
        case .iaEnErreur:
            "La lecture s’est interrompue. Les ingrédients ont été lus ligne par ligne."
        case .contenuTropLong:
            "Le texte est trop long, la fin n’a pas été lue."
        case .fournisseurEnErreur:
            "Le fournisseur externe n’a pas pu compléter la lecture. Vérifiez les champs préremplis."
        default:
            "Une partie de la recette reste à vérifier."
        }
    }

    private func panneauSource(_ defilement: ScrollViewProxy) -> some View {
        VoletTexteRecu(
            source: source, debut: donnees.debutExtrait, ingredients: formulaire.ingredients,
            ouvert: Binding(
                get: {
                    sourceOuverte
                        ?? (!taille.isAccessibilitySize && formulaire.ingredients.contains { $0.citation != nil })
                },
                set: { sourceOuverte = $0 })
        ) { id in
            montrer(.ingredient(id), dans: defilement)
        }
        .ligneDeCorrection()
        .listRowBackground(CouleurPersillade.page2.couleur)
        .id("texte-recu")
    }

    private func sectionIngredients(_ defilement: ScrollViewProxy) -> some View {
        Section {
            ForEach($formulaire.ingredients) { $ligne in
                ligneIngredient($ligne, defilement: defilement)
            }
            .reorderable()
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            Button("Ajouter un ingrédient", systemImage: "plus") {
                let ligne = LigneIngredientCorrection(.init(nom: "", texteOrigine: ""))
                formulaire.ingredients.append(ligne)
                montrer(.ingredient(ligne.id), dans: defilement)
            }
            .frame(minHeight: GrillePersillade.cible)
            .ligneDeCorrection()
        } header: {
            Text("Ingrédients").typographie(.section)
        }
        .listSectionSeparator(.hidden)
    }

    private func ligneIngredient(
        _ liaison: Binding<LigneIngredientCorrection>, defilement: ScrollViewProxy
    ) -> some View {
        let ligne = liaison.wrappedValue
        let champ = Champ.ingredient(ligne.id)
        return Group {
            if ingredientOuvert == ligne.id {
                VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
                    if saisie?.ingredient == ligne.id,
                        let extrait = VoletTexteRecu.extrait(ligne)
                    {
                        Text(extrait)
                            .typographie(.precision)
                            .lineLimit(2)
                            .padding(GrillePersillade.pas)
                            .background(CouleurPersillade.page2.couleur)
                    }
                    TextField("Nom de l’ingrédient", text: liaison.nom)
                        .frame(minHeight: GrillePersillade.cible)
                        .cadreChampCorrection()
                        .focused($saisie, equals: champ)
                        .submitLabel(.next)
                        .onSubmit { terminerLigne(ligne.id, dans: defilement) }
                        .accessibilityIdentifier("nom-ingredient")
                    ChampQuantite(texte: liaison.quantite.texte).focused($saisie, equals: .quantite(ligne.id))
                    ChoixUnite(saisie: liaison.quantite, uniteLue: ligne.uniteLue)
                    if case .autre = ligne.quantite.unite {
                        ChampNomUnite(nom: liaison.quantite.autre).focused($saisie, equals: .unite(ligne.id))
                    }
                    HStack {
                        boutonVerification("Suivant") { terminerLigne(ligne.id, dans: defilement) }
                        Spacer()
                        Button("Supprimer l’ingrédient", systemImage: "trash", role: .destructive) {
                            supprimer(champ)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                    }
                }
                .padding(.horizontal, GrillePersillade.marge)
                .padding(.vertical, GrillePersillade.pas * 2)
            } else {
                HStack(spacing: GrillePersillade.pas) {
                    VStack(alignment: .leading, spacing: 0) {
                        LigneArticle(
                            nom: ligne.nomVide ? "Nom manquant" : ligne.nom,
                            quantite: ligne.quantite.texte.isEmpty ? nil : ligne.quantite.texte,
                            unite: ligne.quantite.texte.isEmpty ? nil : ligne.quantite.unite?.libelleLecturePersillade,
                            precision: ligne.note,
                            ouvrir: { montrer(champ, dans: defilement) },
                            hauteurSimple: GrillePersillade.ingredient, fondEtFilet: false)
                        if ligne.aVerifier {
                            Button {
                                montrer(champ, dans: defilement)
                            } label: {
                                PastilleAVerifier(
                                    libelle: ligne.nomVide ? "Corriger le nom" : "Ligne non comprise · Corriger"
                                )
                                .labelStyle(StylePastilleCorrection())
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, taille.isAccessibilitySize ? GrillePersillade.marge : colonnePesee)
                            .frame(minHeight: GrillePersillade.cible)
                        }
                    }
                    poignee(champ)
                }
            }
        }
        .overlay(alignment: .bottom) { filetCorrection }
        .id(champ)
        .listRowBackground(ligne.aVerifier ? CouleurPersillade.beurreFond.couleur : CouleurPersillade.page.couleur)
        .swipeActions(allowsFullSwipe: false) {
            Button("Supprimer", systemImage: "trash", role: .destructive) { supprimer(champ) }
        }
        .accessibilityActions { actionsOrdre(champ) }
    }

    private func sectionEtapes(_ defilement: ScrollViewProxy) -> some View {
        Section {
            ForEach($formulaire.etapes) { $ligne in
                let champ = Champ.etape(ligne.id)
                HStack {
                    TextField("Étape", text: $ligne.texte, axis: .vertical)
                        .lineLimit(taille.isAccessibilitySize ? nil : 6)
                        .focused($saisie, equals: champ)
                        .frame(minHeight: GrillePersillade.cible)
                        .cadreChampCorrection()
                        .accessibilityIdentifier("texte-etape-correction")
                    poignee(champ)
                }
                .padding(.horizontal, GrillePersillade.marge)
                .overlay(alignment: .bottom) { filetCorrection }
                .id(champ)
                .swipeActions(allowsFullSwipe: false) {
                    Button("Supprimer", systemImage: "trash", role: .destructive) { supprimer(champ) }
                }
                .accessibilityActions { actionsOrdre(champ) }
            }
            .reorderable()
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            Button("Ajouter une étape", systemImage: "plus") {
                let ligne = LigneEtapeCorrection(texte: "")
                formulaire.etapes.append(ligne)
                montrer(.etape(ligne.id), dans: defilement)
            }
            .frame(minHeight: GrillePersillade.cible)
            .ligneDeCorrection()
        } header: {
            Text("Étapes").typographie(.section)
        }
        .listSectionSeparator(.hidden)
    }

    private var filetCorrection: some View {
        CouleurPersillade.trait.couleur.frame(height: GrillePersillade.filet)
    }

    private func poignee(_ champ: Champ) -> some View {
        Menu {
            actionsOrdre(champ)
        } label: {
            Image(systemName: "line.3.horizontal")
                .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(CouleurPersillade.encre2.couleur)
        .accessibilityLabel("Réordonner")
        .accessibilityShowsLargeContentViewer { Label("Réordonner", systemImage: "line.3.horizontal") }
    }

    @ViewBuilder private func actionsOrdre(_ champ: Champ) -> some View {
        Button("Monter") { deplacer(champ, de: -1) }.disabled(!peutDeplacer(champ, de: -1))
        Button("Descendre") { deplacer(champ, de: 1) }.disabled(!peutDeplacer(champ, de: 1))
        Button("Supprimer", role: .destructive) { supprimer(champ) }
    }

    @ViewBuilder private func commandesClavier(_ defilement: ScrollViewProxy) -> some View {
        if let id = saisie?.ingredient, let index = formulaire.ingredients.firstIndex(where: { $0.id == id }) {
            let lue = formulaire.ingredients[index].uniteLue
            let standards = SaisieQuantite.standards
            let unites = lue.map { unite in [unite] + standards.filter { $0 != unite } } ?? standards
            ScrollView(.horizontal) {
                HStack {
                    ForEach(unites, id: \.self) { unite in
                        Button(unite.libellePersillade) {
                            formulaire.ingredients[index].quantite.unite = unite
                        }
                        .buttonStyle(.bordered)
                    }
                    Button("Autre…") {
                        formulaire.ingredients[index].quantite.unite = .autre("")
                    }
                    .buttonStyle(.bordered)
                }
            }
            Button("Suivant") { terminerLigne(id, dans: defilement) }
        } else {
            Spacer()
            Button("Terminé") { saisie = nil }
        }
    }

    private func montrer(_ champ: Champ, dans defilement: ScrollViewProxy) {
        ingredientOuvert = champ.ingredient
        if champ.ancre != .titre || saisie != .titre {
            defilement.scrollTo(champ.ancre, anchor: .center)
        }
        saisie = champ
    }

    private func terminerLigne(_ id: UUID, dans defilement: ScrollViewProxy) {
        guard let index = formulaire.ingredients.firstIndex(where: { $0.id == id }) else { return }
        do {
            _ = try formulaire.ingredients[index].valider()
            withAnimation(.easeInOut(duration: mouvementReduit ? 0.2 : 0.25)) {
                formulaire.ingredients[index].nonComprise = false
            }
            erreurValidation = nil
            saisie = nil
            ingredientOuvert = nil
            if let suivant = alertes.first { montrer(suivant, dans: defilement) }
        } catch {
            signalerErreur(error, ligne: formulaire.ingredients[index], dans: defilement)
        }
    }

    private func sauvegarder(_ defilement: ScrollViewProxy) {
        guard !enregistrant else { return }
        if formulaire.titreVide {
            signaler("Indiquez le titre de la recette.", champ: .titre, dans: defilement)
            return
        }
        guard let portions = formulaire.portionsEffectives else {
            signaler("Indiquez un nombre de portions supérieur à zéro.", champ: .portions, dans: defilement)
            return
        }
        var ingredients: [Ingredient] = []
        for ligne in formulaire.ingredients {
            if ligne.nomVide {
                signaler("Indiquez le nom de l’ingrédient.", champ: .ingredient(ligne.id), dans: defilement)
                return
            }
            do {
                ingredients.append(try ligne.valider())
            } catch {
                signalerErreur(error, ligne: ligne, dans: defilement)
                return
            }
        }
        erreurValidation = nil
        saisie = nil
        enregistrant = true
        Task {
            defer { enregistrant = false }
            do {
                if !enregistree {
                    let recette = try formulaire.recette(
                        donnees, source: source, portions: portions, ingredients: ingredients)
                    try await suivi.forcer(.recette(donnees, formulaire, validation: true))
                    try await enregistrer(recette)
                    enregistree = true
                }
                try await retirerSource()
                try await suivi.effacer()
                terminer(donnees.id)
            } catch {
                erreurEcriture = true
                let message =
                    enregistree ? Self.messageCloture : "La recette n’a pas été enregistrée. Rien n’est perdu."
                AccessibilityNotification.Announcement(message).post()
                await Task.yield()
                defilement.scrollTo("erreur-ecriture", anchor: .top)
            }
        }
    }

    private func signalerErreur(_ erreur: Error, ligne: LigneIngredientCorrection, dans defilement: ScrollViewProxy) {
        if ligne.nomVide {
            signaler("Indiquez le nom de l’ingrédient.", champ: .ingredient(ligne.id), dans: defilement)
        } else if case SaisieQuantite.Erreur.unite = erreur {
            signaler(erreur.localizedDescription, champ: .unite(ligne.id), dans: defilement)
        } else {
            signaler(erreur.localizedDescription, champ: .quantite(ligne.id), dans: defilement)
        }
    }

    private func signaler(_ message: String, champ: Champ, dans defilement: ScrollViewProxy) {
        erreurValidation = message
        montrer(champ, dans: defilement)
        AccessibilityNotification.Announcement(message).post()
    }

    private func peutDeplacer(_ champ: Champ, de pas: Int) -> Bool {
        switch champ {
        case .ingredient(let id):
            guard let index = formulaire.ingredients.firstIndex(where: { $0.id == id }) else { return false }
            return formulaire.ingredients.indices.contains(index + pas)
        case .etape(let id):
            guard let index = formulaire.etapes.firstIndex(where: { $0.id == id }) else { return false }
            return formulaire.etapes.indices.contains(index + pas)
        default:
            return false
        }
    }

    private func deplacer(_ champ: Champ, de pas: Int) {
        guard peutDeplacer(champ, de: pas) else { return }
        switch champ {
        case .ingredient(let id):
            if let index = formulaire.ingredients.firstIndex(where: { $0.id == id }) {
                formulaire.ingredients.swapAt(index, index + pas)
            }
        case .etape(let id):
            if let index = formulaire.etapes.firstIndex(where: { $0.id == id }) {
                formulaire.etapes.swapAt(index, index + pas)
            }
        default:
            break
        }
    }

    private func supprimer(_ champ: Champ) {
        saisie = nil
        switch champ {
        case .ingredient(let id):
            guard let index = formulaire.ingredients.firstIndex(where: { $0.id == id }) else { return }
            suppression = .ingredient(index, formulaire.ingredients.remove(at: index))
            ingredientOuvert = nil
        case .etape(let id):
            guard let index = formulaire.etapes.firstIndex(where: { $0.id == id }) else { return }
            suppression = .etape(index, formulaire.etapes.remove(at: index))
        default:
            break
        }
    }

    private func restaurer() {
        switch suppression {
        case .ingredient(let index, let ligne):
            formulaire.ingredients.insert(ligne, at: min(index, formulaire.ingredients.count))
        case .etape(let index, let ligne):
            formulaire.etapes.insert(ligne, at: min(index, formulaire.etapes.count))
        case nil:
            break
        }
        suppression = nil
    }
}

private struct StylePastilleCorrection: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: GrillePersillade.pas * 2) {
            configuration.icon.accessibilityHidden(true)
            configuration.title
        }
    }
}

extension View {
    fileprivate func ligneDeCorrection() -> some View {
        padding(.horizontal, GrillePersillade.marge)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }

    fileprivate func cadreChampCorrection() -> some View {
        padding(.horizontal, GrillePersillade.pas * 3)
            .padding(.vertical, GrillePersillade.pas)
            .background(CouleurPersillade.page2.couleur, in: .rect(cornerRadius: 8))
    }
}

private func appliquerReordre<Ligne: Identifiable>(
    _ lignes: inout [Ligne], selon difference: ReorderDifference<Ligne.ID, ReorderableSingleCollectionIdentifier>
) {
    let ids = Set(difference.sources)
    let deplacees = lignes.filter { ids.contains($0.id) }
    var autres = lignes.filter { !ids.contains($0.id) }
    let index: Int
    switch difference.destination.position {
    case .before(let id):
        guard let position = autres.firstIndex(where: { $0.id == id }) else { return }
        index = position
    case .end:
        index = autres.endIndex
    }
    autres.insert(contentsOf: deplacees, at: index)
    lignes = autres
}
