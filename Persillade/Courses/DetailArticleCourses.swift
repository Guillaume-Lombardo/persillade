import PersilladeCore
import SwiftUI

struct DetailArticleCourses: View {
    @Environment(\.dismiss) private var fermer
    @Environment(\.dynamicTypeSize) private var taille
    @State private var editerQuantite = false
    @State private var confirmerRetrait = false
    @State private var rappelsInchanges = false

    let id: UUID
    let session: SessionCourses

    var body: some View {
        if let ligne = session.etat?.liste.ligne(id: id) {
            let nom = ligne.libelle.lowercased()
            FeuilleCourses(nom.prefix(1).uppercased() + String(nom.dropFirst())) {
                List {
                    HStack(spacing: GrillePersillade.pas) {
                        Button {
                            editerQuantite = true
                        } label: {
                            let quantite = PresentationQuantite(ligne: ligne)
                            let texte = [quantite.nombre, quantite.unite].compactMap { $0 }.joined(separator: " ")
                            Text(texte.isEmpty ? "Sans quantité" : texte).typographie(.fiche)
                                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Modifier la quantité")
                        .accessibilityIdentifier("modifier-quantite-courses")
                        boutonQuantite("Diminuer la quantité", symbole: "minus", ligne: ligne, variation: -1)
                            .disabled((ligne.quantite ?? Quantite(0)) <= Quantite(1))
                        boutonQuantite("Augmenter la quantité", symbole: "plus", ligne: ligne, variation: 1)
                    }
                    .listRowBackground(CouleurPersillade.page.couleur)

                    Picker(
                        "Rayon",
                        selection: Binding(
                            get: { ligne.categorie },
                            set: { categorie in
                                modifier("Impossible de changer le rayon.") { liste in
                                    try liste.changerCategorie(ligne.id, categorie: categorie)
                                }
                            }
                        )
                    ) {
                        ForEach(Categorie.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(CouleurPersillade.encre.couleur)
                    .listRowBackground(CouleurPersillade.page.couleur)

                    Section {
                        ForEach(ligne.origines, id: \.self) { origine in
                            switch origine.type {
                            case .recette:
                                if let recette = session.recettes[origine.ref] {
                                    HStack {
                                        VignetteMotif(planche: Planche(recette: recette), cadrage: .miniature)
                                            .frame(width: 22, height: 22)
                                        Text(recette.titre)
                                    }
                                } else {
                                    Label("Recette supprimée", systemImage: "book.closed")
                                }
                            case .message:
                                Label("Message reçu", systemImage: "text.bubble")
                            case .manuel:
                                Label("Ajout manuel", systemImage: "plus.circle")
                            }
                        }
                        .listRowBackground(CouleurPersillade.page.couleur)
                    } header: {
                        Text("Demandé par").typographie(.rayon)
                            .frame(maxWidth: .infinity, minHeight: GrillePersillade.rayon, alignment: .leading)
                            .padding(.horizontal, GrillePersillade.marge)
                            .background(CouleurPersillade.page2.couleur)
                            .listRowInsets(EdgeInsets())
                            .accessibilityAddTraits(.isHeader)
                    }
                }
                .listStyle(.plain)
                .listSectionSpacing(0)
                .scrollContentBackground(.hidden)
                .foregroundStyle(CouleurPersillade.encre.couleur)
                .barreAction(tailleMax: .accessibility5) {
                    HStack {
                        ActionSecondaireCourses(
                            libelle: ligne.cochee ? "Remettre" : "Ne pas envoyer",
                            symbole: ligne.cochee ? "plus.circle" : "minus.circle"
                        ) {
                            modifier("Impossible de modifier l’exclusion.", avertir: !ligne.cochee) { liste in
                                try liste.cocher(ligne.id, cochee: !ligne.cochee)
                            }
                        }
                        ActionSecondaireCourses(libelle: "Retirer", symbole: "trash", couleur: .tomate) {
                            if session.etat?.liste.envoyee == true {
                                confirmerRetrait = true
                            } else {
                                retirer(ligne.id)
                            }
                        }
                    }
                }
                .disabled(session.occupee)
                .sheet(isPresented: $editerQuantite) {
                    FeuilleCourses("Modifier la quantité") {
                        ScrollView {
                            EditeurQuantite(quantite: ligne.quantite, unite: ligne.unite) { valeur, unite in
                                Task {
                                    await session.effectuer("Impossible de modifier la quantité. Réessayez.") {
                                        try await modifierQuantite(ligne, valeur: valeur, unite: unite)
                                        editerQuantite = false
                                    }
                                }
                            }
                            .padding()
                        }
                        .disabled(session.occupee)
                        .erreurCourses(session)
                    }
                    .environment(\.dynamicTypeSize, taille)
                    .presentationDetents([.large])
                }
                .confirmationDialog(
                    "Retirer « \(nom) » ?", isPresented: $confirmerRetrait, titleVisibility: .visible
                ) {
                    Button("Retirer", role: .destructive) { retirer(ligne.id) }
                    Button("Annuler", role: .cancel) {}
                } message: {
                    Text("Rappels ne change pas.")
                }
                .alert("Rappels ne change pas", isPresented: $rappelsInchanges) {
                    Button("OK", role: .cancel) {}
                }
                .erreurCourses(session)
            }
            .presentationDetents(taille.isAccessibilitySize ? [.large] : [.medium, .large])
        }
    }

    private func boutonQuantite(
        _ libelle: String, symbole: String, ligne: LigneCourses, variation: Int64
    ) -> some View {
        Button {
            Task {
                await session.effectuer("Impossible de modifier la quantité. Réessayez.") {
                    let quantite = try (ligne.quantite ?? Quantite(0)) + Quantite(variation)
                    try await modifierQuantite(ligne, valeur: quantite, unite: ligne.unite)
                }
            }
        } label: {
            Image(systemName: symbole)
                .frame(width: 44, height: 44)
                .background(CouleurPersillade.page2.couleur, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(libelle)
    }

    private func modifierQuantite(_ ligne: LigneCourses, valeur: Quantite?, unite: Unite?) async throws {
        let effets = try await session.envoi.modifier { liste, _ in
            try liste.modifierQuantite(ligne.id, valeur: valeur, unite: unite)
        }
        try await session.relire()
        rappelsInchanges = effets.rappelsInchanges
    }

    private func retirer(_ id: UUID) {
        Task {
            await session.effectuer("Impossible de retirer cet article. Réessayez.") {
                _ = try await session.envoi.modifier { liste, _ in try liste.retirer(id) }
                fermer()
                try await session.relire()
            }
        }
    }

    private func modifier(
        _ message: String, avertir: Bool = false, action: @escaping @Sendable (inout ListeCourses) throws -> Void
    ) {
        Task {
            await session.effectuer(message) {
                let avertir = avertir && session.etat?.liste.envoyee == true
                try await session.envoi.modifier { liste, _ in try action(&liste) }
                try await session.relire()
                rappelsInchanges = avertir
            }
        }
    }
}
