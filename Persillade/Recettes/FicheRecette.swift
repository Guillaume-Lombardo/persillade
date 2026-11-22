import PersilladeCore
import SwiftUI

struct FicheRecette: View {
    let id: UUID
    let bibliotheque: BibliothequeRecettes
    let modifier: (Recette) -> Void

    @Environment(\.dismiss) private var fermer
    @Environment(\.colorScheme) private var apparence
    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @State private var recette: Recette?
    @State private var planche: Planche?
    @State private var portionsLocales: Int?
    @State private var enteteVisible = true
    @State private var erreur = false
    @State private var confirmerSuppression = false

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
        .toolbarVisibility(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: bibliotheque.revision) {
            do {
                let lue = try await bibliotheque.lire(id)
                try Task.checkCancellation()
                recette = lue
                planche = lue.map { Planche(recette: $0) }
                erreur = lue == nil
            } catch is CancellationError {
            } catch {
                if !Task.isCancelled { erreur = true }
            }
        }
    }

    private func contenu(_ recette: Recette, planche: Planche) -> some View {
        let portions = choisie ?? portionsLocales ?? recette.portions
        let sombre = apparence == .dark
        let couleurBarre: ColorScheme =
            sombre || planche.fond == .persil || planche.fond == .aubergine ? .dark : .light
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    EnTeteMotif(planche: planche).frame(height: 210)
                    Text(recette.titre)
                        .typographie(.fiche)
                        .foregroundStyle(Color(motif: planche.fond.encre(sombre: sombre)))
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("titre-fiche")
                        .padding(GrillePersillade.marge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(motif: planche.fond.couleur(sombre: sombre)))
                .onScrollVisibilityChange(threshold: 0.1) { enteteVisible = $0 }
                blocPortions(portions)
                if !recette.ingredients.isEmpty {
                    titreSection("Ingrédients")
                    ingredients(recette, portions: portions)
                }
                if !recette.etapes.isEmpty {
                    titreSection("Étapes")
                    ForEach(Array(recette.etapes.enumerated()), id: \.offset) { index, texte in
                        Text("\(index + 1). \(texte)")
                            .typographie(.texte)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(GrillePersillade.marge)
                    }
                }
                if let url = recette.urlSource {
                    Link(destination: url) { Label("Ouvrir la source", systemImage: "link") }
                        .padding(GrillePersillade.marge)
                }
            }
        }
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .background(CouleurPersillade.page.couleur)
        .toolbarColorScheme(enteteVisible ? couleurBarre : nil, for: .navigationBar)
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
        .confirmationDialog("Supprimer cette recette ?", isPresented: $confirmerSuppression, titleVisibility: .visible)
        {
            Button("Supprimer", role: .destructive) {
                Task { if await bibliotheque.supprimer(id) { fermer() } }
            }
        } message: {
            Text("Retirée aussi de la semaine.")
        }
        .barreAction {
            BoutonActionPersillade(choisie == nil ? "Ajouter à la semaine" : "Retirer de la semaine") {
                Task {
                    if choisie != nil { portionsLocales = portions }
                    await bibliotheque.choisir(id, portions: choisie == nil ? portions : nil)
                }
            }
            .disabled(!bibliotheque.selectionDisponible || bibliotheque.operationSemaine)
        }
        .sensoryFeedback(.selection, trigger: portions)
        .sensoryFeedback(.selection, trigger: choisie != nil)
        .animation(mouvementReduit ? .easeInOut(duration: 0.2) : .default, value: portions)
    }

    private func blocPortions(_ portions: Int) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            ViewThatFits(in: .horizontal) {
                HStack { commandesPortions(portions) }.fixedSize()
                VStack(alignment: .leading) { commandesPortions(portions) }
            }
            Text(choisie == nil ? "Affichage seul, la recette ne change pas" : "Dans la semaine")
                .typographie(.precision)
                .foregroundStyle(CouleurPersillade.encre2.couleur)
                .accessibilityIdentifier("etat-portions")
        }
        .padding(GrillePersillade.marge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CouleurPersillade.page2.couleur)
    }

    @ViewBuilder private func commandesPortions(_ portions: Int) -> some View {
        Text(portions == 1 ? "1 portion" : "\(portions) portions")
            .typographie(.quantite)
            .contentTransition(mouvementReduit ? .opacity : .numericText())
            .accessibilityIdentifier("nombre-portions")
        HStack {
            boutonPortions("Diminuer les portions", symbole: "minus", valeur: portions > 1 ? portions - 1 : nil)
            boutonPortions("Augmenter les portions", symbole: "plus", valeur: portions < Int.max ? portions + 1 : nil)
        }
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
        .foregroundStyle(CouleurPersillade.persil.couleur)
        .accessibilityLabel(nom)
        .accessibilityShowsLargeContentViewer { Label(nom, systemImage: symbole) }
        .disabled(valeur == nil || bibliotheque.operationSemaine)
    }

    @ViewBuilder private func ingredients(_ recette: Recette, portions: Int) -> some View {
        let miseAEchelle = Result {
            var selection = SelectionSemaine()
            selection.selectionner(try .init(recetteId: id, portions: portions))
            return try selection.preparer(recettes: [recette]).contributions.map { try $0.quantitePourRecette }
        }
        switch miseAEchelle {
        case .success(let quantites):
            ForEach(recette.ingredients.indices, id: \.self) { index in
                let ingredient = recette.ingredients[index]
                LigneArticle(
                    nom: ingredient.nom, quantite: quantites[index]?.texteFrancais,
                    unite: ingredient.unite == .piece ? nil : ingredient.unite?.libellePersillade)
            }
        case .failure:
            Text("Impossible de calculer les quantités pour ces portions.")
                .foregroundStyle(CouleurPersillade.tomate.couleur)
                .padding(GrillePersillade.marge)
            ForEach(recette.ingredients.indices, id: \.self) { index in
                LigneArticle(nom: recette.ingredients[index].nom)
            }
        }
    }

    private func titreSection(_ titre: String) -> some View {
        Text(titre)
            .typographie(.section)
            .accessibilityAddTraits(.isHeader)
            .padding(GrillePersillade.marge)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
