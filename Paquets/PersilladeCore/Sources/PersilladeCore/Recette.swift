import Foundation

public enum Unite: Codable, Hashable, Sendable {
    case g, kg, ml, cl, l, cac, cas, piece
    case autre(String)

    public init(from decoder: any Decoder) throws {
        let champ = try decoder.singleValueContainer()
        let valeur = try champ.decode(String.self)
        switch valeur {
        case "g": self = .g
        case "kg": self = .kg
        case "ml": self = .ml
        case "cl": self = .cl
        case "l": self = .l
        case "cac": self = .cac
        case "cas": self = .cas
        case "piece": self = .piece
        default:
            guard valeur.hasPrefix("autre:") else {
                throw DecodingError.dataCorruptedError(in: champ, debugDescription: "Unité inconnue")
            }
            self = .autre(String(valeur.dropFirst("autre:".count)))
            guard nomAutreNormalise != "" else {
                throw DecodingError.dataCorruptedError(in: champ, debugDescription: "Libellé d’unité vide")
            }
        }
    }

    public func encode(to encoder: any Encoder) throws {
        guard nomAutreNormalise != "" else {
            throw EncodingError.invalidValue(
                self, .init(codingPath: encoder.codingPath, debugDescription: "Libellé d’unité vide"))
        }
        let valeur: String =
            switch self {
            case .g: "g"
            case .kg: "kg"
            case .ml: "ml"
            case .cl: "cl"
            case .l: "l"
            case .cac: "cac"
            case .cas: "cas"
            case .piece: "piece"
            case .autre(let texte): "autre:" + texte
            }
        var champ = encoder.singleValueContainer()
        try champ.encode(valeur)
    }

    var nomAutreNormalise: String? {
        guard case .autre(let nom) = self else { return nil }
        return normaliserNom(nom)
    }
}

public struct Ingredient: Codable, Hashable, Sendable {
    public enum Erreur: Error, Equatable, Sendable {
        case nomVide
        case quantiteNonPositive
        case uniteSansQuantite
        case uniteSansLibelle
    }

    public let nom: String
    public let quantite: Quantite?
    public let unite: Unite?
    public let texteOrigine: String
    public let alternatives: [AlternativeIngredient]

    public var aLUnite: Bool { unite == .piece }

    public init(
        nom: String, quantite: Quantite? = nil, unite: Unite? = nil, texteOrigine: String,
        alternatives: [AlternativeIngredient] = []
    ) throws {
        try Self.verifier(nom: nom, quantite: quantite, unite: unite)
        self.nom = nom
        self.quantite = quantite
        self.unite = unite
        self.texteOrigine = texteOrigine
        self.alternatives = alternatives
    }

    fileprivate static func verifier(nom: String, quantite: Quantite?, unite: Unite?) throws {
        guard !nom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Erreur.nomVide
        }
        if let quantite {
            guard quantite > Quantite(0) else { throw Erreur.quantiteNonPositive }
        } else if unite != nil {
            throw Erreur.uniteSansQuantite
        }
        guard unite?.nomAutreNormalise != "" else { throw Erreur.uniteSansLibelle }
    }

    private enum CodingKeys: String, CodingKey {
        case nom, quantite, unite, alternatives
        case texteOrigine = "texte_origine"
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            nom: champs.decode(String.self, forKey: .nom),
            quantite: champs.decodeIfPresent(Quantite.self, forKey: .quantite),
            unite: champs.decodeIfPresent(Unite.self, forKey: .unite),
            texteOrigine: champs.decode(String.self, forKey: .texteOrigine),
            alternatives: champs.decodeIfPresent([AlternativeIngredient].self, forKey: .alternatives) ?? [])
    }
}

public struct AlternativeIngredient: Codable, Hashable, Sendable {
    public let nom: String
    public let quantite: Quantite?
    public let unite: Unite?

    public init(nom: String, quantite: Quantite? = nil, unite: Unite? = nil) throws {
        try Ingredient.verifier(nom: nom, quantite: quantite, unite: unite)
        self.nom = nom
        self.quantite = quantite
        self.unite = unite
    }

    func multiplierQuantite(par rapport: Quantite) throws -> Self {
        try Self(nom: nom, quantite: quantite.map { try $0 * rapport }, unite: unite)
    }

    private enum CodingKeys: String, CodingKey {
        case nom, quantite, unite
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            nom: champs.decode(String.self, forKey: .nom),
            quantite: champs.decodeIfPresent(Quantite.self, forKey: .quantite),
            unite: champs.decodeIfPresent(Unite.self, forKey: .unite))
    }
}

public struct Recette: Codable, Hashable, Identifiable, Sendable {
    public enum Erreur: Error, Equatable, Sendable {
        case titreVide
        case portionsNonPositives
        case versionNonPriseEnCharge(Int)
    }

    public static let versionSchemaCourante = 2

    public let versionSchema: Int
    public let id: UUID
    public let titre: String
    public let portions: Int
    public let ingredients: [Ingredient]
    public let etapes: [String]
    public let texteSource: String
    public let urlSource: URL?

    public init(
        id: UUID = UUID(), titre: String, portions: Int, ingredients: [Ingredient],
        etapes: [String], texteSource: String, urlSource: URL? = nil
    ) throws {
        guard !titre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Erreur.titreVide
        }
        guard portions > 0 else { throw Erreur.portionsNonPositives }
        self.versionSchema = Self.versionSchemaCourante
        self.id = id
        self.titre = titre
        self.portions = portions
        self.ingredients = ingredients
        self.etapes = etapes
        self.texteSource = texteSource
        self.urlSource = urlSource
    }

    public static func portionsImportees(_ portions: Int?) -> (portions: Int, aCorriger: Bool) {
        (portions ?? 4, portions == nil)
    }

    private enum CodingKeys: String, CodingKey {
        case id, titre, portions, ingredients, etapes
        case versionSchema = "version_schema"
        case texteSource = "texte_source"
        case urlSource = "url_source"
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        let version = try champs.decode(Int.self, forKey: .versionSchema)
        guard (1...Self.versionSchemaCourante).contains(version) else { throw Erreur.versionNonPriseEnCharge(version) }
        try self.init(
            id: champs.decode(UUID.self, forKey: .id),
            titre: champs.decode(String.self, forKey: .titre),
            portions: champs.decode(Int.self, forKey: .portions),
            ingredients: champs.decode([Ingredient].self, forKey: .ingredients),
            etapes: champs.decode([String].self, forKey: .etapes),
            texteSource: champs.decode(String.self, forKey: .texteSource),
            urlSource: champs.decodeIfPresent(URL.self, forKey: .urlSource))
    }

    public func encoderJSON() throws -> Data {
        let encodeur = JSONEncoder()
        encodeur.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encodeur.encode(self)
    }
}
