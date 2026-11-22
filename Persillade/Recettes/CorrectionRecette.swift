import PersilladeCore
import SwiftUI

struct CorrectionRecette: View {
    private enum Champ: Hashable {
        case titre, portions
        case ingredient(UUID)
        case quantite(UUID)
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

    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @FocusState private var saisie: Champ?
    @State private var donnees: DonneesCorrection
    @State private var initial: FormulaireRecette
    @State private var formulaire: FormulaireRecette
    @State private var ingredientOuvert: UUID?
    @State private var confirmerQuitter = false
    @State private var enregistrant = false
    @State private var enregistree = false
    @State private var erreurValidation: String?
    @State private var erreurEcriture = false
    @State private var sourceOuverte: Bool?
    @State private var suppression: Suppression?

    init(
        donnees: DonneesCorrection, fermer: @escaping () -> Void,
        enregistrer: @escaping (Recette) async throws -> Void
    ) {
        self.fermer = fermer
        self.enregistrer = enregistrer
        let formulaire = FormulaireRecette(donnees.brouillon, source: donnees.source)
        _donnees = State(initialValue: donnees)
        _initial = State(initialValue: formulaire)
        _formulaire = State(initialValue: formulaire)
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
                if erreurEcriture {
                    Section {
                        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
                            Text(
                                enregistree
                                    ? ErreurClotureImport.message
                                    : "La recette n’a pas été enregistrée. Rien n’est perdu."
                            )
                            .typographie(.alerte)
                            .foregroundStyle(CouleurPersillade.tomate.couleur)
                            BoutonActionPersillade("Réessayer") { sauvegarder(defilement) }
                                .disabled(enregistrant)
                        }
                    }
                    .id("erreur-ecriture")
                }
                if let erreurValidation {
                    Section {
                        Label(erreurValidation, systemImage: "exclamationmark.circle")
                            .typographie(.alerte)
                            .foregroundStyle(CouleurPersillade.tomate.couleur)
                    }
                }
                if donnees.cause != nil || !alertes.isEmpty {
                    Section { bandeau(defilement) }
                }
                if !donnees.source.isEmpty && saisie == nil {
                    Section { panneauSource(defilement) }
                }

                Group {
                    Section {
                        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
                            TextField(
                                "Titre de la recette", text: $formulaire.titre,
                                prompt: Text("Titre de la recette").foregroundStyle(CouleurPersillade.encre2.couleur)
                            )
                            .typographie(.recette)
                            .frame(minHeight: GrillePersillade.cible)
                            .focused($saisie, equals: .titre)
                            .accessibilityIdentifier("titre-correction")
                        }
                        .id(Champ.titre)
                        champPortions(defilement).id(Champ.portions)
                    }
                    sectionIngredients(defilement)
                    sectionEtapes(defilement)
                    if suppression != nil {
                        Section {
                            Button("Annuler la suppression", action: restaurer)
                        }
                    }
                }
                .disabled(enregistree || enregistrant)
            }
            .listStyle(.plain)
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
                    Button("Fermer") {
                        if !enregistree && (formulaire != initial || erreurEcriture) {
                            confirmerQuitter = true
                        } else {
                            fermer()
                        }
                    }
                    .disabled(enregistrant)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(enregistree ? "Réessayer" : "Enregistrer") { sauvegarder(defilement) }
                        .disabled(enregistrant)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    commandesClavier(defilement)
                }
            }
            .confirmationDialog("Quitter sans enregistrer ?", isPresented: $confirmerQuitter, titleVisibility: .visible)
            {
                Button("Continuer", role: .cancel) {}
                Button("Quitter", role: .destructive, action: fermer)
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
        .interactiveDismissDisabled(formulaire != initial || enregistrant || erreurEcriture)
    }

    private func champPortions(_ defilement: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
            Text("Portions").typographie(.section)
            TextField(
                "Portions", text: $formulaire.portions,
                prompt: Text("4").foregroundStyle(CouleurPersillade.encre2.couleur)
            )
            .typographie(.quantite)
            .frame(minHeight: GrillePersillade.cible)
            .keyboardType(.numberPad)
            .focused($saisie, equals: .portions)
            .accessibilityIdentifier("portions-correction")
            if formulaire.portions.isEmpty {
                PastilleAVerifier(libelle: "Absent du texte, 4 par défaut")
                Button("Garder 4") {
                    withAnimation(.easeInOut(duration: mouvementReduit ? 0.2 : 0.25)) {
                        formulaire.portions = "4"
                    }
                    saisie = nil
                    if let suivant = alertes.first { montrer(suivant, dans: defilement) }
                }
                .frame(minHeight: GrillePersillade.cible)
            }
        }
        .listRowBackground(
            formulaire.portions.isEmpty ? CouleurPersillade.beurreFond.couleur : CouleurPersillade.page.couleur)
    }

    private func bandeau(_ defilement: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
            if let cause = donnees.cause {
                Label(libelle(cause), systemImage: "exclamationmark.circle")
                    .typographie(.alerte)
            }
            if !alertes.isEmpty {
                let nombre = alertes.count
                Text(nombre == 1 ? "1 point à vérifier" : "\(nombre) points à vérifier")
                    .typographie(.alerte)
            }
            if let premier = alertes.first {
                Button("Suivant") { montrer(premier, dans: defilement) }
                    .frame(minHeight: GrillePersillade.cible)
            } else if donnees.cause != nil {
                Button(donnees.cause == .contenuTropLong ? "Voir le texte" : "Suivant") {
                    if donnees.cause == .contenuTropLong {
                        sourceOuverte = true
                        defilement.scrollTo("texte-recu", anchor: .top)
                    } else if let ingredient = formulaire.ingredients.first {
                        montrer(.ingredient(ingredient.id), dans: defilement)
                    } else {
                        montrer(.titre, dans: defilement)
                    }
                }
                .frame(minHeight: GrillePersillade.cible)
            }
        }
        .foregroundStyle(CouleurPersillade.surBeurre.couleur)
        .tint(CouleurPersillade.surBeurre.couleur)
        .listRowBackground(CouleurPersillade.beurre.couleur)
    }

    private func libelle(_ cause: CauseExtraction) -> String {
        switch cause {
        case .iaIndisponible:
            "Apple Intelligence est indisponible. Les ingrédients ont été lus ligne par ligne, vérifiez les étapes."
        case .iaEnErreur:
            "La lecture s’est interrompue. Les ingrédients ont été lus ligne par ligne."
        case .contenuTropLong:
            "Le texte est trop long, la fin n’a pas été lue."
        default:
            "Une partie de la recette reste à vérifier."
        }
    }

    private func panneauSource(_ defilement: ScrollViewProxy) -> some View {
        VoletTexteRecu(
            source: donnees.source, ingredients: formulaire.ingredients,
            ouvert: Binding(get: { sourceOuverte ?? !taille.isAccessibilitySize }, set: { sourceOuverte = $0 })
        ) { id in
            montrer(.ingredient(id), dans: defilement)
        }
        .listRowBackground(CouleurPersillade.page2.couleur)
        .id("texte-recu")
    }

    private func sectionIngredients(_ defilement: ScrollViewProxy) -> some View {
        Section {
            ForEach($formulaire.ingredients) { $ligne in
                ligneIngredient($ligne, defilement: defilement)
            }
            .reorderable()
            Button("Ajouter un ingrédient", systemImage: "plus") {
                let ligne = LigneIngredientCorrection(.init(nom: "", texteOrigine: ""))
                formulaire.ingredients.append(ligne)
                montrer(.ingredient(ligne.id), dans: defilement)
            }
            .frame(minHeight: GrillePersillade.cible)
        } header: {
            Text("Ingrédients").typographie(.section)
        }
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
                        Button("Suivant") { terminerLigne(ligne.id, dans: defilement) }
                            .frame(minHeight: GrillePersillade.cible)
                        Spacer()
                        Button("Supprimer l’ingrédient", systemImage: "trash", role: .destructive) {
                            supprimer(champ)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                    }
                }
                .padding(.vertical, GrillePersillade.pas * 2)
            } else {
                HStack(spacing: GrillePersillade.pas) {
                    VStack(alignment: .leading, spacing: 0) {
                        LigneArticle(
                            nom: ligne.nomVide ? "Nom manquant" : ligne.nom,
                            quantite: ligne.quantite.texte.isEmpty ? nil : ligne.quantite.texte,
                            unite: ligne.quantite.texte.isEmpty ? nil : ligne.quantite.unite?.libellePersillade,
                            precision: ligne.note,
                            ouvrir: { montrer(champ, dans: defilement) })
                        if ligne.aVerifier {
                            Button {
                                montrer(champ, dans: defilement)
                            } label: {
                                PastilleAVerifier(
                                    libelle: ligne.nomVide ? "Corriger le nom" : "Ligne non comprise · Corriger")
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, GrillePersillade.marge)
                            .frame(minHeight: GrillePersillade.cible)
                        }
                    }
                    poignee(champ)
                }
            }
        }
        .id(champ)
        .listRowInsets(
            ingredientOuvert == ligne.id ? EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16) : .init()
        )
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
                        .lineLimit(1...6)
                        .focused($saisie, equals: champ)
                        .frame(minHeight: GrillePersillade.cible)
                    poignee(champ)
                }
                .id(champ)
                .swipeActions(allowsFullSwipe: false) {
                    Button("Supprimer", systemImage: "trash", role: .destructive) { supprimer(champ) }
                }
                .accessibilityActions { actionsOrdre(champ) }
            }
            .reorderable()
            Button("Ajouter une étape", systemImage: "plus") {
                let ligne = LigneEtapeCorrection(texte: "")
                formulaire.etapes.append(ligne)
                montrer(.etape(ligne.id), dans: defilement)
            }
            .frame(minHeight: GrillePersillade.cible)
        } header: {
            Text("Étapes").typographie(.section)
        }
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
                let recette = try Recette(
                    id: donnees.id, titre: formulaire.titre, portions: portions, ingredients: ingredients,
                    etapes: formulaire.etapes.map(\.texte).filter {
                        !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    },
                    texteSource: donnees.source, urlSource: donnees.url)
                try await enregistrer(recette)
            } catch {
                enregistree = error is ErreurClotureImport
                erreurEcriture = true
                let message =
                    enregistree ? ErreurClotureImport.message : "La recette n’a pas été enregistrée. Rien n’est perdu."
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
