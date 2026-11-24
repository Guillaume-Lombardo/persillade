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

extension AlternativeIngredient {
    var mentionPersillade: String {
        let mesure = quantite?.composantesAffichage(unite: unite)
        let choix = [mesure?.nombre, mesure?.unite, nom].compactMap { $0 }.joined(separator: " ")
        return "ou \(choix)"
    }
}

struct ColonnesIngredient: DynamicProperty {
    static let espacement: CGFloat = GrillePersillade.pas

    @Environment(\.dynamicTypeSize) private var taille
    @ScaledMetric(relativeTo: .title2) private var largeurNombre: CGFloat = 68
    @ScaledMetric(relativeTo: .body) private var largeurUnite: CGFloat = 60

    var empilees: Bool { taille >= .accessibility3 }
    var nombre: CGFloat { min(largeurNombre, 98) }
    var unite: CGFloat { min(largeurUnite, 88) }
    var largeur: CGFloat { nombre + Self.espacement + unite }
    var debutNom: CGFloat {
        empilees ? GrillePersillade.marge : GrillePersillade.marge + largeur + GrillePersillade.gouttiere
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

    private var colonnes = ColonnesIngredient()
    @Environment(\.colorSchemeContrast) private var contraste

    var body: some View {
        HStack(spacing: GrillePersillade.gouttiere) {
            Image(systemName: categorie.symboleRayon)
                .font(.system(size: 19, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(contraste == .increased ? CouleurPersillade.encre.couleur : categorie.teinteRayon)
                .frame(width: colonnes.empilees ? nil : colonnes.largeur, alignment: .trailing)
                .accessibilityHidden(true)
            Text(categorie.rawValue).typographie(.rayon)
            Spacer(minLength: 0)
            if let nombre {
                Text(nombre.formatted()).typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
            }
        }
        .padding(.horizontal, GrillePersillade.marge)
        .padding(.vertical, GrillePersillade.pas)
        .frame(maxWidth: .infinity, minHeight: GrillePersillade.rayon)
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .background(CouleurPersillade.page2.couleur)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

struct LigneArticle: View {
    #if DEBUG
        private static let exposerTextes = ProcessInfo.processInfo.arguments.contains("-mesurer-textes-article")
    #else
        private static let exposerTextes = false
    #endif

    struct Marque {
        let libelle: String
        let symbole: String
        let couleur: CouleurPersillade
        var discrete = false
        var surUneLigne = false
    }

    let nom: String
    var quantite: String?
    var unite: String?
    var precision: String?
    var precisionPleineLargeur: String?
    var alternatives: [String] = []
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
    private var colonnes = ColonnesIngredient()

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
        .padding(.horizontal, GrillePersillade.marge)
        .background(fondEtFilet ? CouleurPersillade.page.couleur : .clear)
        .overlay(alignment: .bottom) {
            if fondEtFilet {
                CouleurPersillade.trait.couleur.frame(height: GrillePersillade.filet)
            }
        }
    }

    private var valeurAccessibilite: String {
        let quantiteAffichee = [quantite, unite].compactMap { $0 }.joined(separator: " ")
        let details = [quantiteAffichee, precision, precisionPleineLargeur].compactMap { $0 }
        let etat = exclu ? "Ne sera pas envoyé" : marque?.libelle
        return (details + alternatives + [etat].compactMap { $0 })
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private var contenu: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            if colonnes.empilees {
                ColonnePesee(quantite: quantite, unite: unite, alignee: false)
                libelle
            } else {
                HStack(alignment: .firstTextBaseline, spacing: GrillePersillade.gouttiere) {
                    HStack(alignment: .firstTextBaseline, spacing: ColonnesIngredient.espacement) {
                        Text(quantite ?? "")
                            .typographie(.quantite)
                            .fontWidth(.compressed)
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: colonnes.nombre, alignment: .trailing)
                        Text(unite ?? "")
                            .typographie(.unite)
                            .fontWidth(.compressed)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: colonnes.unite, alignment: .leading)
                    }
                    .foregroundStyle(CouleurPersillade.encre.couleur)
                    libelle.fixedSize(horizontal: false, vertical: true)
                }
            }
            if let precisionPleineLargeur {
                Text(precisionPleineLargeur)
                    .typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
            }
            if colonnes.empilees {
                mentionsAlternatives
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, taille.isAccessibilitySize ? 8 : 2)
        .frame(
            minHeight: precision == nil && precisionPleineLargeur == nil && alternatives.isEmpty && !exclu
                ? hauteurSimple : GrillePersillade.ingredientAnnote
        )
        .contentShape(.rect)
        .accessibilityElement(children: Self.exposerTextes ? .contain : .combine)
    }

    private var libelle: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            Text(nom).typographie(.texte)
                .foregroundStyle(exclu ? CouleurPersillade.encre2.couleur : CouleurPersillade.encre.couleur)
                .accessibilityIdentifier("nom-ligne-article", isEnabled: Self.exposerTextes)
            if let precision {
                Text(precision).typographie(.precision).foregroundStyle(CouleurPersillade.encre2.couleur)
            }
            if exclu {
                Text("Ne sera pas envoyé")
                    .typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
                    .transition(.opacity)
            } else if let marque, afficherMarque {
                Label {
                    Text(marque.libelle)
                        .fixedSize(horizontal: marque.surUneLigne, vertical: false)
                } icon: {
                    Image(systemName: marque.symbole)
                }
                .typographie(marque.discrete ? .precision : .alerte)
                .foregroundStyle(marque.couleur.couleur)
            }
            if !colonnes.empilees {
                mentionsAlternatives
            }
        }
    }

    private var mentionsAlternatives: some View {
        ForEach(alternatives.indices, id: \.self) { index in
            Text(alternatives[index])
                .typographie(.precision)
                .foregroundStyle(CouleurPersillade.encre2.couleur)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("alternative-ligne-article", isEnabled: Self.exposerTextes)
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
