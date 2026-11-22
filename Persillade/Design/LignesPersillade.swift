import PersilladeCore
import SwiftUI

extension Unite {
    var libellePersillade: String {
        switch self {
        case .g: "g"
        case .kg: "kg"
        case .ml: "ml"
        case .cl: "cl"
        case .l: "l"
        case .cac: "c. à c."
        case .cas: "c. à s."
        case .piece: "pièce"
        case .autre(let libelle): libelle
        }
    }
}

private struct CadreColonnePesee: ViewModifier {
    let aligne: Bool
    @ScaledMetric(relativeTo: .title2) private var largeur = GrillePersillade.colonnePesee

    func body(content: Content) -> some View {
        content
            .frame(
                width: aligne ? largeur - GrillePersillade.marge - GrillePersillade.gouttiere : nil,
                alignment: aligne ? .trailing : .leading
            )
            .padding(.leading, aligne ? GrillePersillade.marge : 0)
    }
}

struct ColonnePesee: View {
    let quantite: String?
    let unite: String?
    var alignee = true

    @Environment(\.dynamicTypeSize) private var taille

    var body: some View {
        let aligne = alignee && !taille.isAccessibilitySize
        Group {
            if let quantite {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: GrillePersillade.pas) {
                        nombre(quantite)
                        libelleUnite
                    }
                    .fixedSize()
                    VStack(alignment: aligne ? .trailing : .leading, spacing: 0) {
                        nombre(quantite)
                        libelleUnite
                    }
                }
                .accessibilityElement(children: .combine)
            } else if aligne {
                Color.clear.frame(height: 0)
            }
        }
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .modifier(CadreColonnePesee(aligne: aligne))
    }

    private func nombre(_ texte: String) -> some View {
        Text(texte).typographie(.quantite)
    }

    @ViewBuilder private var libelleUnite: some View {
        if let unite { Text(unite).typographie(.unite) }
    }
}

struct BandeauRayon: View {
    let categorie: Categorie
    var nombre: Int?

    @Environment(\.dynamicTypeSize) private var taille

    var body: some View {
        HStack(spacing: GrillePersillade.gouttiere) {
            Image(systemName: categorie.symboleRayon)
                .foregroundStyle(categorie.teinteRayon)
                .modifier(CadreColonnePesee(aligne: !taille.isAccessibilitySize))
                .accessibilityHidden(true)
            Text(categorie.rawValue).typographie(.rayon)
            Spacer(minLength: 0)
            if let nombre {
                Text(nombre.formatted()).typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
            }
        }
        .padding(.trailing, GrillePersillade.marge)
        .padding(.leading, taille.isAccessibilitySize ? GrillePersillade.marge : 0)
        .padding(.vertical, GrillePersillade.pas)
        .frame(minHeight: GrillePersillade.rayon)
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .background(CouleurPersillade.page2.couleur)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct LigneArticle: View {
    let nom: String
    var quantite: String?
    var unite: String?
    var precision: String?
    var exclu = false
    var ouvrir: (() -> Void)?
    var basculerExclusion: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var taille

    var body: some View {
        HStack(spacing: GrillePersillade.pas) {
            if let ouvrir {
                Button(action: ouvrir) { contenu }
                    .buttonStyle(.plain)
            } else {
                contenu
            }

            if let basculerExclusion {
                let libelle = exclu ? "Remettre" : "Ne pas envoyer"
                Button(action: basculerExclusion) {
                    Image(systemName: exclu ? "arrow.uturn.backward.circle" : "minus.circle")
                        .font(.title3)
                        .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .foregroundStyle(CouleurPersillade.encre2.couleur)
                .accessibilityLabel("\(libelle) \(nom)")
                .accessibilityShowsLargeContentViewer { Label(libelle, systemImage: "minus.circle") }
            }
        }
        .padding(.trailing, GrillePersillade.marge)
        .padding(.leading, taille.isAccessibilitySize ? GrillePersillade.marge : 0)
        .background(CouleurPersillade.page.couleur)
        .overlay(alignment: .bottom) {
            CouleurPersillade.trait.couleur.frame(height: GrillePersillade.filet)
        }
    }

    private var contenu: some View {
        Group {
            if taille.isAccessibilitySize {
                contenuVertical
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        ColonnePesee(quantite: quantite, unite: unite)
                        libelle.fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, GrillePersillade.gouttiere)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    contenuVertical
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, GrillePersillade.pas * 2)
        .frame(minHeight: precision == nil ? GrillePersillade.article : GrillePersillade.ingredientAnnote)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var contenuVertical: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            ColonnePesee(quantite: quantite, unite: unite, alignee: false)
            libelle
        }
        .padding(.leading, taille.isAccessibilitySize ? 0 : GrillePersillade.marge)
    }

    private var libelle: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            Text(nom).typographie(.texte)
                .foregroundStyle(exclu ? CouleurPersillade.encre2.couleur : CouleurPersillade.encre.couleur)
            if let precision {
                Text(precision).typographie(.precision).foregroundStyle(CouleurPersillade.encre2.couleur)
            }
        }
    }
}

struct PastilleAVerifier: View {
    var libelle = "À vérifier"

    var body: some View {
        Label(libelle, systemImage: "exclamationmark.circle")
            .typographie(.alerte)
            .foregroundStyle(CouleurPersillade.surBeurre.couleur)
            .padding(.horizontal, GrillePersillade.pas * 2)
            .padding(.vertical, GrillePersillade.pas)
            .background(CouleurPersillade.beurre.couleur, in: .capsule)
    }
}
