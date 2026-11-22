import SwiftUI

struct VoletTexteRecu: View {
    let source: String
    let ingredients: [LigneIngredientCorrection]
    @Binding var ouvert: Bool
    let atteindre: (UUID) -> Void

    @ScaledMetric(relativeTo: .footnote) private var hauteurLigne = 18.0

    var body: some View {
        let lignes = source.components(separatedBy: .newlines)
        let hauteur = lignes.prefix(5).reduce(0.0) { hauteur, texte in
            let actif = ingredients.contains { Self.correspondance(texte, ligne: $0) }
            return hauteur + (actif ? max(hauteurLigne, GrillePersillade.cible) : hauteurLigne)
        }
        DisclosureGroup(isExpanded: $ouvert) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(lignes.enumerated()), id: \.offset) { _, texte in
                        if let ligne = ingredients.first(where: { Self.correspondance(texte, ligne: $0) }) {
                            Button {
                                atteindre(ligne.id)
                            } label: {
                                Text(Self.surligner(texte, ligne: ligne))
                                    .typographie(.precision)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, minHeight: GrillePersillade.cible, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Aller à l’ingrédient")
                        } else {
                            Text(texte.isEmpty ? " " : texte)
                                .typographie(.precision)
                                .frame(minHeight: hauteurLigne, alignment: .leading)
                                .accessibilityHidden(texte.isEmpty)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: min(hauteur, 240))
            .accessibilityIdentifier("texte-source")
        } label: {
            Text("Texte reçu").frame(minHeight: GrillePersillade.cible)
        }
        .typographie(.section)
        .foregroundStyle(CouleurPersillade.encre.couleur)
    }

    static func extrait(_ ligne: LigneIngredientCorrection, dans source: String) -> AttributedString? {
        guard correspondance(source, ligne: ligne) else { return nil }
        return surligner(ligne.origine, ligne: ligne)
    }

    private static func correspondance(_ texte: String, ligne: LigneIngredientCorrection) -> Bool {
        !ligne.origine.isEmpty && texte.range(of: ligne.origine, options: .literal) != nil
    }

    private static func surligner(_ texte: String, ligne: LigneIngredientCorrection) -> AttributedString {
        var attribue = AttributedString(texte)
        if let plage = attribue.range(of: ligne.origine, options: .literal) {
            attribue[plage].backgroundColor =
                ligne.aVerifier ? CouleurPersillade.beurre.couleur : CouleurPersillade.lu.couleur
        }
        return attribue
    }
}
