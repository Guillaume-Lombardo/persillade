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
    var ouvrirFiche: ((UUID) -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if let etat = session.etat {
                    contenu(etat)
                } else if session.occupee {
                    ProgressView("Lecture de la semaine")
                } else {
                    ContentUnavailableView {
                        Label("Semaine indisponible", systemImage: "calendar")
                    } actions: {
                        Button("Réessayer") { Task { await session.actualiser(semaine: true) } }
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
        .task { await session.actualiser(semaine: true) }
        .sensoryFeedback(.selection, trigger: session.etat?.selection)
    }

    @ViewBuilder
    private func contenu(_ etat: EtatCourses) -> some View {
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
                    ActionPrincipaleCourses("Voir les recettes", action: voirRecettes)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            ForEach(etat.selection.choix, id: \.recetteId) { choix in
                if let recette = session.recettes[choix.recetteId] {
                    bande(recette, choix: choix)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .swipeActions {
                            Button("Retirer de la semaine", systemImage: "trash", role: .destructive) {
                                choisir(nil, choix: choix)
                            }
                            .disabled(session.occupee)
                        }
                        .accessibilityAction(named: "Retirer de la semaine") { choisir(nil, choix: choix) }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .barreAction {
            if !etat.selection.choix.isEmpty {
                ActionPrincipaleCourses(etat.selectionModifieeDepuisGeneration ? "Refaire la liste" : "Faire la liste")
                {
                    faireListe()
                }
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

    private func bande(_ recette: Recette, choix: SelectionSemaine.Choix) -> some View {
        let planche = Planche(recette: recette)
        return HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                if let ouvrirFiche {
                    Button(recette.titre) { ouvrirFiche(recette.id) }.buttonStyle(.plain)
                        .typographie(.rayon)
                } else {
                    Text(recette.titre).typographie(.rayon).accessibilityAddTraits(.isHeader)
                }
                let controles = HStack(spacing: 4) {
                    boutonPortions("Diminuer les portions", symbole: "minus", choix: choix, variation: -1)
                    Text("\(choix.portions)").typographie(.texte).monospacedDigit()
                        .contentTransition(.numericText())
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("\(choix.portions) portions")
                    boutonPortions("Augmenter les portions", symbole: "plus", choix: choix, variation: 1)
                }
                if taille >= .accessibility3 {
                    Text("\(choix.portions) portions").typographie(.texte).contentTransition(.numericText())
                    HStack {
                        boutonPortions("Diminuer les portions", symbole: "minus", choix: choix, variation: -1)
                        boutonPortions("Augmenter les portions", symbole: "plus", choix: choix, variation: 1)
                    }
                } else {
                    controles
                }
            }
            .padding(.leading, GrillePersillade.marge)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            if taille < .accessibility3 {
                VignetteMotif(planche: planche, cadrage: .semaine)
                    .frame(width: taille.isAccessibilitySize ? 64 : 128, height: 104)
            }
        }
        .frame(minHeight: 104)
        .foregroundStyle(Color(motif: planche.fond.encre(sombre: apparence == .dark)))
        .background(Color(motif: planche.fond.couleur(sombre: apparence == .dark)))
    }

    private func boutonPortions(
        _ nom: String, symbole: String, choix: SelectionSemaine.Choix, variation: Int
    ) -> some View {
        Button {
            choisir(choix.portions + variation, choix: choix)
        } label: {
            Image(systemName: symbole).frame(minWidth: 44, minHeight: 44).contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(session.occupee || (variation < 0 ? choix.portions <= 1 : choix.portions == Int.max))
        .accessibilityLabel("\(nom) de \(session.recettes[choix.recetteId]?.titre ?? "la recette")")
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
