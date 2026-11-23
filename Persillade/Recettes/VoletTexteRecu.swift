import SwiftUI

struct VoletTexteRecu: View {
    let source: String
    var debut = 0
    let ingredients: [LigneIngredientCorrection]
    @Binding var ouvert: Bool
    let atteindre: (UUID) -> Void

    @ScaledMetric(relativeTo: .body) private var hauteurLigne = 23.0

    var body: some View {
        let lignes = source.components(separatedBy: .newlines)
        let parIndice = Dictionary(grouping: ingredients.filter { $0.citation != nil }) { $0.citation?.ligne }
        let plage = lignes.indices.dropFirst(max(0, debut))
        let hauteur = CGFloat(min(5, plage.count)) * hauteurLigne
        DisclosureGroup(isExpanded: $ouvert) {
            ScrollViewReader { defilement in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(plage, id: \.self) { indice in
                            let texte = lignes[indice]
                            Group {
                                if let citations = parIndice[indice] {
                                    Text(Self.surligner(texte, citations: citations))
                                        .accessibilityIdentifier("extrait-source")
                                } else {
                                    Text(texte.isEmpty ? " " : texte).accessibilityHidden(texte.isEmpty)
                                }
                            }
                            .typographie(.texte)
                            .frame(maxWidth: .infinity, minHeight: hauteurLigne, alignment: .leading)
                            .id(indice)
                        }
                    }
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
                    .tint(CouleurPersillade.encre.couleur)
                }
                .frame(maxHeight: min(hauteur, 240))
                .accessibilityIdentifier("texte-source")
                .onAppear {
                    if let premiere = plage.first(where: { parIndice[$0] != nil }) {
                        defilement.scrollTo(premiere, anchor: .top)
                    }
                }
            }
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
