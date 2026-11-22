import PersilladeCore
import SwiftUI

struct DetailArticleCourses: View {
    @Environment(\.dismiss) private var fermer
    @State private var modifierQuantite = false
    @State private var confirmerRetrait = false
    @State private var rappelsInchanges = false

    let id: UUID
    let session: SessionCourses

    var body: some View {
        if let ligne = session.etat?.liste.ligne(id: id) {
            FeuilleCourses(ligne.libelle) {
                Form {
                    Section {
                        Button {
                            modifierQuantite = true
                        } label: {
                            let quantite = PresentationQuantite(ligne: ligne)
                            let texte = [quantite.nombre, quantite.unite].compactMap { $0 }.joined(separator: " ")
                            LabeledContent("Quantité", value: texte.isEmpty ? "Sans quantité" : texte)
                        }
                        .accessibilityIdentifier("modifier-quantite-courses")
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
                    }
                    Section("Provenance") {
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
                    }
                    Section {
                        Button(ligne.cochee ? "Remettre" : "Ne pas envoyer") {
                            modifier("Impossible de modifier l’exclusion.", avertir: !ligne.cochee) { liste in
                                try liste.cocher(ligne.id, cochee: !ligne.cochee)
                            }
                        }
                        Button("Retirer", role: .destructive) {
                            if session.etat?.liste.envoyee == true {
                                confirmerRetrait = true
                            } else {
                                retirer(ligne.id)
                            }
                        }
                    }
                }
                .disabled(session.occupee)
                .sheet(isPresented: $modifierQuantite) {
                    FeuilleCourses("Modifier la quantité") {
                        ScrollView {
                            EditeurQuantite(quantite: ligne.quantite, unite: ligne.unite) { valeur, unite in
                                Task {
                                    await session.effectuer("Impossible de modifier la quantité. Réessayez.") {
                                        let effets = try await session.envoi.modifier { liste, _ in
                                            try liste.modifierQuantite(ligne.id, valeur: valeur, unite: unite)
                                        }
                                        try await session.relire()
                                        modifierQuantite = false
                                        rappelsInchanges = effets.rappelsInchanges
                                    }
                                }
                            }
                            .padding()
                        }
                        .disabled(session.occupee)
                        .erreurCourses(session)
                    }
                    .presentationDetents([.medium, .large])
                }
                .confirmationDialog(
                    "Retirer « \(ligne.libelle) » ?", isPresented: $confirmerRetrait, titleVisibility: .visible
                ) {
                    Button("Retirer", role: .destructive) { retirer(ligne.id) }
                } message: {
                    Text("Rappels ne change pas.")
                }
                .alert("Rappels ne change pas", isPresented: $rappelsInchanges) {
                    Button("OK", role: .cancel) {}
                }
                .erreurCourses(session)
            }
            .presentationDetents([.medium, .large])
        }
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
