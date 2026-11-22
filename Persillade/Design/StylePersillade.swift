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
        case .boulangerie: "oven.fill"
        case .cremerieEtOeufs: "oval.portrait.fill"
        case .viandesEtCharcuterie: "frying.pan.fill"
        case .poissons: "fish.fill"
        case .epicerieSalee: "cylinder.fill"
        case .epicerieSucree: "birthday.cake.fill"
        case .surgeles: "snowflake"
        case .boissons: "waterbottle.fill"
        case .hygieneEtMaison: "bubbles.and.sparkles.fill"
        case .autres: "tag.fill"
        }
    }

    var teinteRayon: Color {
        switch self {
        case .fruitsEtLegumes: Color("fruitsEtLegumes")
        case .boulangerie: Color("boulangerie")
        case .cremerieEtOeufs: Color("cremerieEtOeufs")
        case .viandesEtCharcuterie: Color("viandesEtCharcuterie")
        case .poissons: Color("poissons")
        case .epicerieSalee: Color("epicerieSalee")
        case .epicerieSucree: Color("epicerieSucree")
        case .surgeles: Color("surgeles")
        case .boissons: Color("boissons")
        case .hygieneEtMaison: Color("hygieneEtMaison")
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
    case fiche, etatVide, etape, nombreEtapes
    case consigne(Int)
    case recette, section, rayon, quantite, unite
    case texte, bouton, precision, alerte

    fileprivate var style: Font.TextStyle {
        switch self {
        case .fiche, .etatVide, .etape, .nombreEtapes: .largeTitle
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
        case .nombreEtapes: 24
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
        case .fiche, .etatVide, .etape, .nombreEtapes, .quantite: .compressed
        case .recette, .section, .rayon, .unite: .condensed
        default: .standard
        }
    }
}

private struct PolicePersillade: ViewModifier {
    let role: TypographiePersillade
    @Environment(\.dynamicTypeSize) private var tailleDynamique
    @Environment(\.legibilityWeight) private var lisibilite
    @ScaledMetric private var taille: CGFloat

    init(_ role: TypographiePersillade) {
        self.role = role
        _taille = ScaledMetric(wrappedValue: role.taille, relativeTo: role.style)
    }

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
        content.font(police).lineLimit(nil)
    }
}

extension View {
    func typographie(_ role: TypographiePersillade) -> some View {
        modifier(PolicePersillade(role))
    }
}
