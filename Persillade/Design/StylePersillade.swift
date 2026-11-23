import CoreText
import PersilladeCore
import SwiftUI

enum CouleurPersillade: String {
    case page, page2, trait, encre, encre2, persil, surPersil, tomate, surTomate, beurre, surBeurre, beurreFond
    case beurreTexte, lu

    var couleur: Color { Color(rawValue) }
}

extension Categorie {
    var symboleRayon: String {
        switch self {
        case .fruitsEtLegumes: "carrot.fill"
        case .epicerie: "cylinder.fill"
        case .boucher: "frying.pan.fill"
        case .poissonnier: "fish.fill"
        case .cremier: "oval.portrait.fill"
        case .boulangeriePatisserie: "oven.fill"
        case .autres: "tag.fill"
        }
    }

    var teinteRayon: Color {
        switch self {
        case .fruitsEtLegumes: Color("fruitsEtLegumes")
        case .epicerie: Color("epicerie")
        case .boucher: Color("boucher")
        case .poissonnier: Color("poissonnier")
        case .cremier: Color("cremier")
        case .boulangeriePatisserie: Color("boulangeriePatisserie")
        case .autres: CouleurPersillade.encre2.couleur
        }
    }
}

enum GrillePersillade {
    static let pas: CGFloat = 4
    static let marge: CGFloat = 16
    static let margeBarre: CGFloat = 21
    static let colonnePesee: CGFloat = 92
    static let gouttiere: CGFloat = 14
    static let cible: CGFloat = 44
    static let cibleCuisine: CGFloat = 80
    static let ingredient: CGFloat = 46
    static let ingredientAnnote: CGFloat = 60
    static let article: CGFloat = 52
    static let rayon: CGFloat = 36
    static let recette: CGFloat = 96
    static let semaine: CGFloat = 104
    static let filet: CGFloat = 0.5
}

enum TypographiePersillade {
    case fiche, etatVide, etape
    case consigne(Int)
    case recette, section, rayon, quantite, unite
    case texte, bouton, precision, alerte

    fileprivate var style: Font.TextStyle {
        switch self {
        case .fiche, .etatVide, .etape: .largeTitle
        case .consigne(let longueur): longueur <= 110 ? .largeTitle : .title
        case .recette, .quantite: .title2
        case .section: .title3
        case .rayon, .bouton: .headline
        case .unite, .texte: .body
        case .precision, .alerte: .footnote
        }
    }

    fileprivate var taille: CGFloat {
        switch self {
        case .fiche: 46
        case .etatVide: 54
        case .etape: 44
        case .consigne(let longueur): longueur <= 110 ? 36 : longueur <= 180 ? 32 : 28
        case .recette, .quantite: 22
        case .section: 20
        case .rayon: 18
        case .unite, .texte, .bouton: 17
        case .precision, .alerte: 13
        }
    }

    fileprivate var graisse: Font.Weight {
        switch self {
        case .consigne, .bouton, .alerte: .semibold
        case .texte, .precision: .regular
        default: .heavy
        }
    }

    fileprivate var largeur: Font.Width {
        switch self {
        case .fiche, .etatVide, .etape, .quantite: .compressed
        case .recette, .section, .rayon, .unite: .condensed
        default: .standard
        }
    }

    fileprivate var interligne: CGFloat? {
        switch self {
        case .fiche: 46
        case .etatVide: 50
        case .recette: 23
        default: nil
        }
    }
}

private struct PolicePersillade: ViewModifier {
    let role: TypographiePersillade
    @Environment(\.dynamicTypeSize) private var tailleDynamique
    @Environment(\.fontResolutionContext) private var contextePolice
    @Environment(\.legibilityWeight) private var lisibilite
    @ScaledMetric private var taille: CGFloat

    init(_ role: TypographiePersillade) {
        self.role = role
        _taille = ScaledMetric(wrappedValue: role.taille, relativeTo: role.style)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        let graisse: Font.Weight = lisibilite == .bold && role.graisse == .regular ? .semibold : role.graisse
        let styleAX = if case .consigne = role { Font.TextStyle.title2 } else { role.style }
        let base: Font =
            if tailleDynamique.isAccessibilitySize { .system(styleAX, weight: graisse) } else {
                .system(size: taille, weight: graisse).width(role.largeur)
            }
        let police =
            switch role {
            case .etape, .quantite: base.monospacedDigit()
            default: base
            }
        if let interligne = role.interligne, !tailleDynamique.isAccessibilitySize {
            let hauteur = interligne * taille / role.taille
            let policeResolue = police.resolve(in: contextePolice).ctFont
            MargesAffiche(ascendante: CTFontGetAscent(policeResolue), descendante: CTFontGetDescent(policeResolue)) {
                content.font(police).lineHeight(.exact(points: hauteur))
            }
        } else {
            content.font(police)
        }
    }
}

private struct MargesAffiche: Layout {
    let ascendante: CGFloat
    let descendante: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let texte = subviews[0].dimensions(in: proposal)
        // Les lignes gardent leur écart, le bloc réserve la hauteur des glyphes aux extrémités.
        let haut = margeHaute(texte)
        let bas = max(0, texte[.lastTextBaseline] + descendante - texte.height)
        return CGSize(width: texte.width, height: haut + texte.height + bas)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let texte = subviews[0].dimensions(in: proposal)
        subviews[0].place(at: CGPoint(x: bounds.minX, y: bounds.minY + margeHaute(texte)), proposal: proposal)
    }

    private func margeHaute(_ texte: ViewDimensions) -> CGFloat {
        max(0, ascendante - texte[.firstTextBaseline])
    }
}

extension View {
    func typographie(_ role: TypographiePersillade) -> some View {
        modifier(PolicePersillade(role))
    }
}
