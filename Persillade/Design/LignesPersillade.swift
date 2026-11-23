import PersilladeCore
import SwiftUI

extension Unite {
    var libelleLecturePersillade: String? { self == .piece ? nil : libellePersillade }

    var libellePersillade: String {
        switch self {
        case .g: "g"
        case .kg: "kg"
        case .ml: "ml"
        case .cl: "cl"
        case .l: "l"
        case .cac: "c.\u{00A0}à\u{00A0}c."
        case .cas: "c.\u{00A0}à\u{00A0}s."
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
                    HStack(alignment: .firstTextBaseline, spacing: aligne ? 2 : GrillePersillade.pas * 2) {
                        nombre(quantite)
                        libelleUnite(enLigne: true)
                    }
                    .fixedSize()
                    VStack(alignment: aligne ? .trailing : .leading, spacing: 0) {
                        nombre(quantite)
                        libelleUnite(enLigne: false)
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

    @ViewBuilder private func libelleUnite(enLigne: Bool) -> some View {
        if let unite {
            Text(unite)
                .typographie(.unite)
                .fontWidth(taille.isAccessibilitySize ? .standard : alignee ? .compressed : .condensed)
                .fixedSize(horizontal: enLigne, vertical: !enLigne)
        }
    }
}

struct BandeauRayon: View {
    let categorie: Categorie
    var nombre: Int?

    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.colorSchemeContrast) private var contraste

    var body: some View {
        HStack(spacing: GrillePersillade.gouttiere) {
            Image(systemName: categorie.symboleRayon)
                .font(.system(size: 19, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(contraste == .increased ? CouleurPersillade.encre.couleur : categorie.teinteRayon)
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
    struct Marque {
        let libelle: String
        let symbole: String
        let couleur: CouleurPersillade
        var discrete = false
    }

    let nom: String
    var quantite: String?
    var unite: String?
    var precision: String?
    var precisionPleineLargeur: String?
    var exclu = false
    var marque: Marque?
    var afficherMarque = true
    var ouvrir: (() -> Void)?
    var identifiantOuverture: String?
    var basculerExclusion: (() -> Void)?
    var retirer: (() -> Void)?
    var hauteurSimple = GrillePersillade.article
    var fondEtFilet = true

    @Environment(\.dynamicTypeSize) private var taille

    var body: some View {
        HStack(spacing: GrillePersillade.pas) {
            if let ouvrir {
                Button(action: ouvrir) { contenu }
                    .buttonStyle(.plain)
                    .accessibilityLabel(nom)
                    .accessibilityValue(valeurAccessibilite)
                    .accessibilityActions {
                        if let retirer {
                            Button("Détail", action: ouvrir)
                            Button("Retirer", action: retirer)
                        }
                    }
                    .accessibilityIdentifier(identifiantOuverture ?? "", isEnabled: identifiantOuverture != nil)
            } else {
                contenu
            }

            if let basculerExclusion {
                let libelle = exclu ? "Remettre" : "Ne pas envoyer"
                let symbole = exclu ? "plus.circle" : "minus.circle"
                Button(action: basculerExclusion) {
                    Image(systemName: symbole)
                        .font(.title3)
                        .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .foregroundStyle((exclu ? CouleurPersillade.persil : .encre2).couleur)
                .accessibilityLabel("\(libelle) \(nom)")
                .accessibilityShowsLargeContentViewer { Label(libelle, systemImage: symbole) }
            }
        }
        .padding(.trailing, GrillePersillade.marge)
        .padding(.leading, taille.isAccessibilitySize ? GrillePersillade.marge : 0)
        .background(fondEtFilet ? CouleurPersillade.page.couleur : .clear)
        .overlay(alignment: .bottom) {
            if fondEtFilet {
                CouleurPersillade.trait.couleur.frame(height: GrillePersillade.filet)
            }
        }
    }

    private var valeurAccessibilite: String {
        let quantiteAffichee = [quantite, unite].compactMap { $0 }.joined(separator: " ")
        return [quantiteAffichee, precision, precisionPleineLargeur, exclu ? "Ne sera pas envoyé" : marque?.libelle]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private var contenu: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
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
            if let precisionPleineLargeur {
                Text(precisionPleineLargeur)
                    .typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
                    .padding(.leading, taille.isAccessibilitySize ? 0 : GrillePersillade.marge)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, taille.isAccessibilitySize ? 8 : 2)
        .frame(
            minHeight: precision == nil && precisionPleineLargeur == nil && !exclu
                ? hauteurSimple : GrillePersillade.ingredientAnnote
        )
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
            if exclu {
                Text("Ne sera pas envoyé")
                    .typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
                    .transition(.opacity)
            } else if let marque, afficherMarque {
                Label(marque.libelle, systemImage: marque.symbole)
                    .typographie(marque.discrete ? .precision : .alerte)
                    .foregroundStyle(marque.couleur.couleur)
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
