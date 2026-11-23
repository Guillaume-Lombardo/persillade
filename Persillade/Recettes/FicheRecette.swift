import PersilladeCore
import SwiftUI

struct FicheRecette: View {
    let id: UUID
    let bibliotheque: BibliothequeRecettes
    let modifier: (Recette) -> Void

    @Environment(\.dismiss) private var fermer
    @Environment(\.colorScheme) private var apparence
    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @AppStorage private var positionCuisine: Int
    @State private var recette: Recette?
    @State private var planche: Planche?
    @State private var portionsLocales: Int?
    @State private var enteteVisible = true
    @State private var erreur = false
    @State private var confirmerSuppression = false
    @State private var cuisiner = false

    init(id: UUID, bibliotheque: BibliothequeRecettes, modifier: @escaping (Recette) -> Void) {
        self.id = id
        self.bibliotheque = bibliotheque
        self.modifier = modifier
        _positionCuisine = AppStorage(wrappedValue: 0, "cuisine.position.\(id.uuidString)")
    }

    private var choisie: Int? { bibliotheque.portionsChoisies(id) }

    var body: some View {
        Group {
            if let recette, let planche {
                contenu(recette, planche: planche)
            } else if erreur {
                ContentUnavailableView("Impossible d’ouvrir cette recette", systemImage: "exclamationmark.circle")
            } else {
                ProgressView("Lecture de la recette")
            }
        }
        .background(CouleurPersillade.page.couleur.ignoresSafeArea())
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: bibliotheque.revision) {
            do {
                let lue = try await bibliotheque.lire(id)
                try Task.checkCancellation()
                recette = lue
                planche = lue.map { Planche(recette: $0) }
                erreur = lue == nil
                if let lue, positionCuisine > lue.etapes.count {
                    positionCuisine = lue.etapes.count
                }
            } catch is CancellationError {
            } catch {
                if !Task.isCancelled { erreur = true }
            }
        }
    }

    private func contenu(_ recette: Recette, planche: Planche) -> some View {
        let portions = choisie ?? portionsLocales ?? recette.portions
        let sombre = apparence == .dark
        let couleurFond = Color(motif: planche.fond.couleur(sombre: sombre))
        let couleurTexte = Color(motif: planche.fond.encre(sombre: sombre))
        let couleurBarre: ColorScheme =
            sombre || planche.fond == .persil || planche.fond == .aubergine ? .dark : .light
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: GrillePersillade.pas) {
                        Text(recette.titre)
                            .typographie(.fiche)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("titre-fiche")
                        if let url = recette.urlSource {
                            Link(destination: url) {
                                Label(url.host(percentEncoded: false) ?? url.absoluteString, systemImage: "link")
                                    .typographie(.texte)
                            }
                            .accessibilityHint("Ouvre la source de la recette")
                        }
                    }
                    .foregroundStyle(couleurTexte)
                    .tint(couleurTexte)
                    .padding(.horizontal, GrillePersillade.marge)
                    EnTeteMotif(planche: planche).frame(height: 238)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(couleurFond)
                .onScrollVisibilityChange(threshold: 0.01) { enteteVisible = $0 }
                blocPortions(portions)
                if !recette.ingredients.isEmpty {
                    titreSection("Ingrédients")
                    IngredientsRecette(recette: recette, portions: portions)
                }
                if !recette.etapes.isEmpty {
                    titreSection("Étapes")
                    ForEach(Array(recette.etapes.enumerated()), id: \.offset) { index, texte in
                        ligneEtape(index + 1, texte: texte)
                    }
                }
            }
            .padding(.bottom, GrillePersillade.marge)
            .background(CouleurPersillade.page.couleur)
        }
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .background(alignment: .top) {
            if enteteVisible {
                couleurFond.frame(height: 128).ignoresSafeArea(edges: .top)
            }
        }
        .toolbarBackground(enteteVisible ? couleurFond : CouleurPersillade.page.couleur, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarColorScheme(enteteVisible ? couleurBarre : nil, for: .navigationBar)
        .tint(enteteVisible ? couleurTexte : CouleurPersillade.persil.couleur)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Modifier", systemImage: "pencil") { modifier(recette) }
                    Button("Supprimer", systemImage: "trash", role: .destructive) { confirmerSuppression = true }
                        .disabled(bibliotheque.operationSemaine)
                } label: {
                    Label("Options de la recette", systemImage: "ellipsis")
                }
            }
        }
        .alert("Supprimer cette recette ?", isPresented: $confirmerSuppression) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                Task {
                    if await bibliotheque.supprimer(id) {
                        positionCuisine = 0
                        fermer()
                    }
                }
            }
        } message: {
            if choisie != nil { Text("Retirée aussi de la semaine.") }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Group {
                if recette.etapes.isEmpty {
                    commandeSemaine(portions)
                } else {
                    ViewThatFits(in: .horizontal) {
                        CommandesFicheHorizontales {
                            commandeSemaine(portions).fixedSize()
                            commandeCuisine
                        }
                        VStack(spacing: GrillePersillade.pas * 2) {
                            commandeSemaine(portions)
                            commandeCuisine
                        }
                    }
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .tint(CouleurPersillade.persil.couleur)
            .padding(.horizontal, GrillePersillade.margeBarre)
            .padding(.vertical, GrillePersillade.marge)
            .background(alignment: .top) {
                CouleurPersillade.page.couleur.ignoresSafeArea(edges: .bottom)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [.clear, CouleurPersillade.page.couleur], startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: GrillePersillade.marge)
                        .offset(y: -GrillePersillade.marge)
                        .allowsHitTesting(false)
                    }
            }
        }
        .fullScreenCover(isPresented: $cuisiner) {
            if let session = SessionCuisine(recette: recette, position: positionCuisine) {
                PasAPas(recette: recette, portions: portions, fond: planche.fond, session: session) { position in
                    positionCuisine = position
                }
                .environment(\.dynamicTypeSize, taille)
            }
        }
        .sensoryFeedback(.selection, trigger: portions)
        .sensoryFeedback(.selection, trigger: choisie != nil)
        .animation(mouvementReduit ? .easeInOut(duration: 0.2) : .default, value: portions)
    }

    private func commandeSemaine(_ portions: Int) -> some View {
        let titre = choisie == nil ? "Ajouter à la semaine" : "Retirer de la semaine"
        return CommandeRecettes(titre: titre) {
            Task {
                if choisie != nil { portionsLocales = portions }
                await bibliotheque.choisir(id, portions: choisie == nil ? portions : nil)
            }
        }
        .disabled(!bibliotheque.selectionDisponible || bibliotheque.operationSemaine)
    }

    private var commandeCuisine: some View {
        CommandeRecettes(
            titre: positionCuisine > 0 ? "Reprendre à l’étape \(positionCuisine)" : "Cuisiner",
            symbole: taille < .xxxLarge ? "frying.pan.fill" : nil, principale: true
        ) {
            if positionCuisine == 0 { positionCuisine = 1 }
            cuisiner = true
        }
        .accessibilityIdentifier("ouvrir-cuisine")
    }

    private func blocPortions(_ portions: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                legendePortions(portions).fixedSize()
                Spacer(minLength: GrillePersillade.pas * 2)
                commandesPortions(portions)
            }
            VStack(alignment: .trailing, spacing: GrillePersillade.pas) {
                legendePortions(portions).frame(maxWidth: .infinity, alignment: .leading)
                commandesPortions(portions)
            }
        }
        .padding(GrillePersillade.marge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CouleurPersillade.page2.couleur)
    }

    private func legendePortions(_ portions: Int) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            Text(portions == 1 ? "1 portion" : "\(portions) portions")
                .typographie(.quantite)
                .contentTransition(mouvementReduit ? .opacity : .numericText())
                .accessibilityIdentifier("nombre-portions")
            Text(choisie == nil ? "Affichage seul, la recette ne change pas" : "Dans la semaine")
                .typographie(.precision)
                .foregroundStyle(CouleurPersillade.encre2.couleur)
                .accessibilityIdentifier("etat-portions")
        }
    }

    private func commandesPortions(_ portions: Int) -> some View {
        HStack(spacing: 0) {
            boutonPortions("Diminuer les portions", symbole: "minus", valeur: portions > 1 ? portions - 1 : nil)
            CouleurPersillade.trait.couleur
                .frame(width: GrillePersillade.filet, height: GrillePersillade.marge)
                .accessibilityHidden(true)
            boutonPortions("Augmenter les portions", symbole: "plus", valeur: portions < Int.max ? portions + 1 : nil)
        }
        .background(CouleurPersillade.page.couleur, in: .capsule)
    }

    private func boutonPortions(_ nom: String, symbole: String, valeur: Int?) -> some View {
        Button {
            guard let valeur else { return }
            if choisie != nil {
                Task { await bibliotheque.choisir(id, portions: valeur) }
            } else {
                portionsLocales = valeur
            }
        } label: {
            Image(systemName: symbole)
                .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(valeur == nil ? CouleurPersillade.encre2.couleur : CouleurPersillade.persil.couleur)
        .accessibilityLabel(nom)
        .accessibilityShowsLargeContentViewer { Label(nom, systemImage: symbole) }
        .disabled(valeur == nil || bibliotheque.operationSemaine)
    }

    private func ligneEtape(_ position: Int, texte: String) -> some View {
        let disposition =
            taille.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: GrillePersillade.pas))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: GrillePersillade.gouttiere))
        return disposition {
            ColonnePesee(quantite: position.formatted(), unite: nil)
            Text(texte).typographie(.texte)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, taille.isAccessibilitySize ? GrillePersillade.marge : 0)
        .padding(.trailing, GrillePersillade.marge)
        .padding(.vertical, GrillePersillade.pas * 3)
        .overlay(alignment: .bottom) {
            CouleurPersillade.trait.couleur.frame(height: GrillePersillade.filet)
        }
        .accessibilityElement(children: .combine)
    }

    private func titreSection(_ titre: String) -> some View {
        Text(titre)
            .typographie(.section)
            .accessibilityAddTraits(.isHeader)
            .padding(GrillePersillade.marge)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CommandesFicheHorizontales: Layout {
    private let espacement = GrillePersillade.pas * 2

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let minimum = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        let colonne = max(minimum, ((proposal.width ?? 0) - espacement) / 2)
        let taille = ProposedViewSize(width: colonne, height: nil)
        let hauteur = subviews.map { $0.sizeThatFits(taille).height }.max() ?? 0
        return CGSize(width: colonne * 2 + espacement, height: hauteur)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let colonne = (bounds.width - espacement) / 2
        for (index, bouton) in subviews.enumerated() {
            bouton.place(
                at: CGPoint(x: bounds.minX + CGFloat(index) * (colonne + espacement), y: bounds.midY),
                anchor: .leading, proposal: ProposedViewSize(width: colonne, height: nil)
            )
        }
    }
}

struct IngredientsRecette: View {
    let recette: Recette
    let portions: Int

    var body: some View {
        let miseAEchelle = Result {
            var selection = SelectionSemaine()
            selection.selectionner(try .init(recetteId: recette.id, portions: portions))
            return try selection.preparer(recettes: [recette]).contributions.map { try $0.quantitePourRecette }
        }
        switch miseAEchelle {
        case .success(let quantites):
            ForEach(recette.ingredients.indices, id: \.self) { index in
                let ingredient = recette.ingredients[index]
                LigneArticle(
                    nom: ingredient.nom, quantite: quantites[index]?.texteFrancais,
                    unite: ingredient.unite?.libelleLecturePersillade, precision: mention(ingredient))
            }
        case .failure:
            Text("Impossible de calculer les quantités pour ces portions.")
                .foregroundStyle(CouleurPersillade.tomate.couleur)
                .padding(GrillePersillade.marge)
            ForEach(recette.ingredients.indices, id: \.self) { index in
                let ingredient = recette.ingredients[index]
                LigneArticle(nom: ingredient.nom, precision: mention(ingredient))
            }
        }
    }

    private func mention(_ ingredient: Ingredient) -> String? {
        let mentions =
            #/
            (?i)\b(?: au\h+go[uû]t | selon\h+(?:le\h+)?go[uû]t | [aà]\h+discr[eé]tion |
                (?:une|1)\h+pinc[eé]e | quantit[ée]\h+suffisante )\b | \bq\.?\h*s\b\.?
            /#
        guard ingredient.quantite == nil, let match = ingredient.texteOrigine.firstMatch(of: mentions) else {
            return nil
        }
        let libelle = String(match.output)
        return ingredient.nom.localizedCaseInsensitiveContains(libelle) ? nil : libelle
    }
}
