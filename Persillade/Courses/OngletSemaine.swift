import PersilladeCore
import SwiftUI

struct OngletSemaine: View {
    @Environment(\.dynamicTypeSize) private var taille

    @Environment(\.colorScheme) private var apparence
    @State private var remplacer = false
    @State private var vider = false

    let session: SessionCourses
    let voirRecettes: () -> Void
    let voirCourses: () -> Void
    let reglages: () -> Void
    let ouvrirFiche: (UUID) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let etat = session.etat {
                    contenu(etat)
                } else if session.occupee {
                    ProgressView("Lecture de la semaine")
                } else {
                    ScrollView {
                        EtatVide(titre: "Semaine indisponible.", message: "La semaine n’a pas pu être lue.") {
                            EmptyView()
                        } actions: {
                            BoutonActionPersillade("Réessayer", symbole: "arrow.clockwise") {
                                Task { await session.actualiser() }
                            }
                        }
                    }
                }
            }
            .background(CouleurPersillade.page.couleur)
            .navigationTitle("Semaine")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Voir les recettes", systemImage: "plus", action: voirRecettes)
                        .accessibilityShowsLargeContentViewer { Label("Voir les recettes", systemImage: "plus") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Plus d’options", systemImage: "ellipsis") {
                        Button("Vider la semaine", systemImage: "trash", role: .destructive) { vider = true }
                            .disabled(session.etat?.selection.choix.isEmpty != false || session.occupee)
                        Button("Réglages", systemImage: "gear", action: reglages)
                    }
                }
            }
            .confirmationDialog("Vider la semaine ?", isPresented: $vider, titleVisibility: .visible) {
                Button("Vider", role: .destructive) { viderSemaine() }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("La liste de courses ne change pas.")
            }
            .confirmationDialog("Remplacer la liste ?", isPresented: $remplacer, titleVisibility: .visible) {
                Button("Remplacer", role: .destructive) { faireListe(confirmee: true) }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text(
                    "Les \(session.etat?.liste.lignes.count ?? 0) lignes seront perdues et les articles déjà achetés seront redemandés."
                )
            }
        }
        .task { await session.actualiser() }
        .sensoryFeedback(.selection, trigger: session.etat?.selection)
    }

    @ViewBuilder
    private func contenu(_ etat: EtatCourses) -> some View {
        let bandes = etat.selection.choix.compactMap { choix in
            session.recettes[choix.recetteId].map { (choix: choix, recette: $0, planche: Planche(recette: $0)) }
        }
        List {
            if session.recettesAbsentes > 0 {
                Text("Des recettes supprimées ont été retirées de la semaine.")
                    .typographie(.precision)
            }
            if etat.selectionModifieeDepuisGeneration {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Liste faite avant ce changement").typographie(.rayon)
                        .accessibilityAddTraits(.isHeader)
                    Text(changement(etat)).typographie(.precision)
                }
                .listRowBackground(CouleurPersillade.page2.couleur)
            }
            if etat.selection.choix.isEmpty {
                EtatVide(titre: "Rien de choisi.", message: "Touchez + devant une recette pour l’ajouter à la semaine.")
                {
                    EmptyView()
                } actions: {
                    BoutonActionPersillade("Voir les recettes", symbole: "text.book.closed", action: voirRecettes)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            ForEach(Array(bandes.enumerated()), id: \.element.choix.recetteId) { index, element in
                bande(element.recette, choix: element.choix, planche: element.planche)
                    .overlay(alignment: .top) {
                        if index > 0, bandes[index - 1].planche.fond == element.planche.fond {
                            CouleurPersillade.page.couleur.frame(height: 2)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions {
                        Button("Retirer de la semaine", systemImage: "trash", role: .destructive) {
                            choisir(nil, choix: element.choix)
                        }
                        .disabled(session.occupee)
                    }
                    .accessibilityAction(named: "Retirer de la semaine") { choisir(nil, choix: element.choix) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .barreAction(tailleMax: .accessibility5) {
            if !etat.selection.choix.isEmpty {
                BoutonActionPersillade(
                    etat.selectionModifieeDepuisGeneration ? "Refaire la liste" : "Faire la liste",
                    symbole: "list.bullet"
                ) { faireListe() }
                .disabled(session.occupee)
            }
        }
    }

    private func changement(_ etat: EtatCourses) -> String {
        let ancienne = etat.liste.selectionALaGeneration?.choix ?? []
        let nouveaux = etat.selection.choix
        let idsAvant = Set(ancienne.map(\.recetteId))
        let idsApres = Set(nouveaux.map(\.recetteId))
        if idsAvant == idsApres { return "Les portions de la semaine ont changé." }
        if idsAvant.isSubset(of: idsApres) { return "Des recettes ont été ajoutées à la semaine." }
        if idsApres.isSubset(of: idsAvant) { return "Des recettes ont été retirées de la semaine." }
        return "Les recettes de la semaine ont changé."
    }

    private func bande(_ recette: Recette, choix: SelectionSemaine.Choix, planche: Planche) -> some View {
        ZStack {
            Button {
                ouvrirFiche(recette.id)
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(recette.titre)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recette.titre).typographie(.recette)
                        .frame(minHeight: GrillePersillade.cible, alignment: .leading)
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                    HStack(spacing: taille.isAccessibilitySize ? 12 : 4) {
                        boutonPortions("Diminuer les portions", symbole: "minus", choix: choix, variation: -1)
                        Text(libellePortions(choix.portions))
                            .font(.system(.subheadline, weight: .semibold))
                            .monospacedDigit()
                            .multilineTextAlignment(.center)
                            .contentTransition(.numericText())
                            .accessibilityHidden(true)
                            .allowsHitTesting(false)
                        boutonPortions("Augmenter les portions", symbole: "plus", choix: choix, variation: 1)
                    }
                }
                .padding(.horizontal, GrillePersillade.marge)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                if taille < .accessibility3 {
                    VignetteMotif(planche: planche, cadrage: .semaine)
                        .frame(width: taille.isAccessibilitySize ? 64 : 168, height: GrillePersillade.semaine)
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(minHeight: GrillePersillade.semaine)
        .foregroundStyle(Color(motif: planche.fond.encre(sombre: apparence == .dark)))
        .background(Color(motif: planche.fond.couleur(sombre: apparence == .dark)))
    }

    private func libellePortions(_ portions: Int) -> String {
        portions == 1 ? "1 portion" : "\(portions) portions"
    }

    private func boutonPortions(
        _ nom: String, symbole: String, choix: SelectionSemaine.Choix, variation: Int
    ) -> some View {
        Button {
            choisir(choix.portions + variation, choix: choix)
        } label: {
            Image(systemName: symbole)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 34, height: 34)
                .overlay { Circle().strokeBorder(lineWidth: 2) }
                .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(session.occupee || (variation < 0 ? choix.portions <= 1 : choix.portions == Int.max))
        .accessibilityLabel("\(nom) de \(session.recettes[choix.recetteId]?.titre ?? "la recette")")
        .accessibilityValue(libellePortions(choix.portions))
        .accessibilityShowsLargeContentViewer { Label(nom, systemImage: symbole) }
    }

    private func choisir(_ portions: Int?, choix: SelectionSemaine.Choix) {
        Task {
            await session.effectuer("La semaine n’a pas pu être mise à jour. Réessayez.") {
                try await session.portions(portions, pour: choix.recetteId)
            }
        }
    }

    private func viderSemaine() {
        Task {
            await session.effectuer("La semaine n’a pas pu être vidée. Réessayez.") {
                try await session.envoi.modifier { _, selection in selection = SelectionSemaine() }
                try await session.relire()
            }
        }
    }

    private func faireListe(confirmee: Bool = false) {
        Task {
            await session.effectuer("La liste n’a pas pu être générée. Vérifiez la semaine et réessayez.") {
                if case .confirmationRequise = try await session.generer(confirmee: confirmee) {
                    remplacer = true
                } else {
                    voirCourses()
                }
            }
        }
    }
}
