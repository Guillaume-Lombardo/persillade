import Foundation

public struct ArticleCourses: Hashable, Sendable {
    public let nom: String
    public let quantite: Quantite?
    public let unite: Unite?

    public init(nom: String, quantite: Quantite? = nil, unite: Unite? = nil) throws {
        let nom = nom.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normaliserNom(nom).isEmpty else { throw Ingredient.Erreur.nomVide }
        if let quantite {
            guard quantite > Quantite(0) else { throw Ingredient.Erreur.quantiteNonPositive }
        } else if unite != nil {
            throw Ingredient.Erreur.uniteSansQuantite
        }
        guard unite?.nomAutreNormalise != "" else { throw Ingredient.Erreur.uniteSansLibelle }
        self.nom = nom
        self.quantite = quantite
        self.unite = unite
    }
}

extension Unite {
    var canoniqueCourses: Unite {
        switch self {
        case .kg: .g
        case .cl, .l: .ml
        default: self
        }
    }

    func comparablePourCourses(a autre: Unite) -> Bool {
        if let nom = nomAutreNormalise, let autreNom = autre.nomAutreNormalise {
            return nom == autreNom
        }
        return canoniqueCourses == autre.canoniqueCourses
    }

    fileprivate var symboleCourses: String {
        switch self {
        case .g: "g"
        case .kg: "kg"
        case .ml: "ml"
        case .cl: "cl"
        case .l: "l"
        case .cac: "cac"
        case .cas: "cas"
        case .piece: ""
        case .autre(let nom): nom
        }
    }
}

func arrondirPourCourses(_ quantite: Quantite, unite: Unite) throws -> Quantite {
    let numerateur = Int128(quantite.numerateur)
    let denominateur = Int128(quantite.denominateur)

    switch unite {
    case .piece:
        return Quantite(Int64((numerateur + denominateur - 1) / denominateur))
    case .g, .ml, .kg, .cl, .l:
        return Quantite(max(1, Int64((2 * numerateur + denominateur) / (2 * denominateur))))
    case .cas, .cac, .autre:
        let quarts = (4 * numerateur + denominateur - 1) / denominateur
        let diviseur: Int128 = quarts.isMultiple(of: 4) ? 4 : quarts.isMultiple(of: 2) ? 2 : 1
        guard let valeur = Int64(exactly: quarts / diviseur) else { throw Quantite.Erreur.depassement }
        return try Quantite(numerateur: valeur, denominateur: Int64(4 / diviseur))
    }
}

/// Formate une quantité telle quelle, y compris un complément de Rappels.
public func formaterQuantiteCourses(_ quantite: Quantite, unite: Unite) throws -> String {
    let canonique = unite.canoniqueCourses
    let valeur = try convertir(quantite, unite, canonique) ?? quantite

    // Trois décimales au plus dans l’unité supérieure équivalent à un entier dans l’unité de base.
    if canonique == .g || canonique == .ml, valeur >= Quantite(1_000), valeur.denominateur == 1 {
        let superieure = canonique == .g ? Unite.kg : .l
        let reduite = try Quantite(numerateur: valeur.numerateur, denominateur: 1_000)
        return "\(reduite.texteFrancais) \(superieure.symboleCourses)"
    }
    if canonique == .piece { return valeur.texteFrancais }
    return "\(valeur.texteFrancais) \(canonique.symboleCourses)"
}
