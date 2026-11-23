import PersilladeCore
import SwiftUI

struct EditeurAlternativeIngredient: View {
    @Environment(\.dismiss) private var fermer
    @State private var nom: String
    @State private var quantite: SaisieQuantite
    @State private var erreur: String?
    private let uniteLue: Unite?
    private let enregistrer: (AlternativeIngredient) -> Void

    init(_ alternative: AlternativeIngredient?, enregistrer: @escaping (AlternativeIngredient) -> Void) {
        _nom = State(initialValue: alternative?.nom ?? "")
        _quantite = State(initialValue: SaisieQuantite(quantite: alternative?.quantite, unite: alternative?.unite))
        uniteLue = alternative?.unite
        self.enregistrer = enregistrer
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nom de l’alternative", text: $nom)
                    .accessibilityIdentifier("nom-alternative")
                ChampQuantite(texte: $quantite.texte)
                ChoixUnite(saisie: $quantite, uniteLue: uniteLue)
                if case .autre = quantite.unite {
                    ChampNomUnite(nom: $quantite.autre)
                }
                if let erreur {
                    Text(erreur).typographie(.alerte)
                        .foregroundStyle(CouleurPersillade.tomate.couleur)
                }
            }
            .navigationTitle("Alternative")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { fermer() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider", action: valider)
                        .disabled(nom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .tint(CouleurPersillade.persil.couleur)
        }
    }

    private func valider() {
        do {
            let (nombre, unite) = try quantite.valider()
            enregistrer(try AlternativeIngredient(nom: nom, quantite: nombre, unite: unite))
            fermer()
        } catch {
            self.erreur = error.localizedDescription
        }
    }
}
