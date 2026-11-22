import SwiftUI

struct VoletTexteRecu: View {
    let source: String
    let ingredients: [LigneIngredientCorrection]
    @Binding var ouvert: Bool
    let atteindre: (UUID) -> Void

    @ScaledMetric(relativeTo: .footnote) private var hauteurLigne = 18.0

    var body: some View {
        let lignes = source.components(separatedBy: .newlines)
        let parIndice = Dictionary(
            uniqueKeysWithValues: ingredients.compactMap { ligne in
                ligne.indiceSource.map { ($0, ligne) }
            })
        let hauteur = lignes.indices.prefix(5).reduce(0.0) { hauteur, indice in
            hauteur + (parIndice[indice] != nil ? max(hauteurLigne, GrillePersillade.cible) : hauteurLigne)
        }
        DisclosureGroup(isExpanded: $ouvert) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(lignes.enumerated()), id: \.offset) { indice, texte in
                        if let ligne = parIndice[indice] {
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
                            .accessibilityIdentifier("extrait-source")
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

    static func extrait(_ ligne: LigneIngredientCorrection) -> AttributedString? {
        guard ligne.indiceSource != nil else { return nil }
        return surligner(ligne.origine, ligne: ligne)
    }

    private static func surligner(_ texte: String, ligne: LigneIngredientCorrection) -> AttributedString {
        var attribue = AttributedString(texte)
        if let plageTexte = CorrespondancesSource.plage(ligne.origine, dans: texte),
            let plage = Range(plageTexte, in: attribue)
        {
            attribue[plage].backgroundColor =
                ligne.aVerifier ? CouleurPersillade.beurre.couleur : CouleurPersillade.lu.couleur
        }
        return attribue
    }
}
