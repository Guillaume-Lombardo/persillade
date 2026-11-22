import SwiftUI

struct VoletTexteRecu: View {
    let source: String
    let ingredients: [LigneIngredientCorrection]
    @Binding var ouvert: Bool
    let atteindre: (UUID) -> Void

    @ScaledMetric(relativeTo: .footnote) private var hauteurLigne = 18.0

    var body: some View {
        let lignes = source.components(separatedBy: .newlines)
        let parIndice = Dictionary(grouping: ingredients.filter { $0.citation != nil }) { $0.citation?.ligne }
        let hauteur = lignes.indices.prefix(5).reduce(0.0) { hauteur, indice in
            hauteur + (parIndice[indice] != nil ? max(hauteurLigne, GrillePersillade.cible) : hauteurLigne)
        }
        DisclosureGroup(isExpanded: $ouvert) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(lignes.enumerated()), id: \.offset) { indice, texte in
                        if let citations = parIndice[indice] {
                            Text(Self.surligner(texte, citations: citations))
                                .typographie(.precision)
                                .tint(CouleurPersillade.encre.couleur)
                                .frame(maxWidth: .infinity, minHeight: GrillePersillade.cible, alignment: .leading)
                                .environment(
                                    \.openURL,
                                    OpenURLAction { url in
                                        guard url.scheme == "persillade-extrait",
                                            let id = url.host().flatMap(UUID.init(uuidString:))
                                        else { return .discarded }
                                        atteindre(id)
                                        return .handled
                                    }
                                )
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
        guard ligne.citation != nil else { return nil }
        var texte = AttributedString(ligne.origine)
        texte.backgroundColor = couleur(ligne)
        return texte
    }

    private static func surligner(_ texte: String, citations: [LigneIngredientCorrection]) -> AttributedString {
        var attribue = AttributedString(texte)
        for ligne in citations {
            if let citation = ligne.citation, let plageTexte = Range(citation.plage, in: texte),
                let plage = Range(plageTexte, in: attribue)
            {
                attribue[plage].backgroundColor = couleur(ligne)
                attribue[plage].link = URL(string: "persillade-extrait://\(ligne.id.uuidString)")
            }
        }
        return attribue
    }

    private static func couleur(_ ligne: LigneIngredientCorrection) -> Color {
        ligne.aVerifier ? CouleurPersillade.beurre.couleur : CouleurPersillade.lu.couleur
    }
}
