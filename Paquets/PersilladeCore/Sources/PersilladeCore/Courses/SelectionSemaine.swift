import Foundation

public struct SelectionSemaine: Codable, Equatable, Sendable {
    public enum Erreur: Error, Equatable, Sendable {
        case portionsNonPositives
    }

    public struct Choix: Codable, Equatable, Sendable {
        public let recetteId: UUID
        public let portions: Int

        public init(recetteId: UUID, portions: Int) throws {
            guard portions > 0 else { throw Erreur.portionsNonPositives }
            self.recetteId = recetteId
            self.portions = portions
        }

        private enum CodingKeys: String, CodingKey {
            case recetteId = "recette_id"
            case portions
        }

        public init(from decoder: any Decoder) throws {
            let champs = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                recetteId: champs.decode(UUID.self, forKey: .recetteId),
                portions: champs.decode(Int.self, forKey: .portions))
        }
    }

    public struct Contribution: Equatable, Sendable {
        public let recetteId: UUID
        public let article: ArticleCourses
        public let alternatives: [AlternativeIngredient]

        public var quantitePourRecette: Quantite? {
            get throws {
                guard let quantite = article.quantite else { return nil }
                guard article.unite == .piece else { return quantite }
                return try arrondirPourCourses(quantite, unite: .piece)
            }
        }
    }

    public struct Preparation: Equatable, Sendable {
        public let contributions: [Contribution]
        public let recettesAbsentes: [UUID]
        public let selection: SelectionSemaine
    }

    public static let versionSchemaCourante = 1
    public private(set) var choix: [Choix] = []

    public init() {}

    public mutating func selectionner(_ choix: Choix) {
        if let index = self.choix.firstIndex(where: { $0.recetteId == choix.recetteId }) {
            self.choix[index] = choix
        } else {
            self.choix.append(choix)
        }
    }

    public mutating func deselectionner(_ recetteId: UUID) {
        choix.removeAll { $0.recetteId == recetteId }
    }

    public mutating func preparer(recettes: [Recette]) throws -> Preparation {
        let parId = Dictionary(recettes.map { ($0.id, $0) }, uniquingKeysWith: { premiere, _ in premiere })
        var contributions: [Contribution] = []
        var absentes: [UUID] = []

        for entree in choix {
            guard let recette = parId[entree.recetteId] else {
                absentes.append(entree.recetteId)
                continue
            }
            let rapport = try Quantite(Int64(entree.portions)) / Quantite(Int64(recette.portions))
            for ingredient in recette.ingredients {
                let quantite = try ingredient.quantite.map { try $0 * rapport }
                let article = try ArticleCourses(nom: ingredient.nom, quantite: quantite, unite: ingredient.unite)
                let alternatives = try ingredient.alternatives.map { try $0.multiplierQuantite(par: rapport) }
                contributions.append(Contribution(recetteId: recette.id, article: article, alternatives: alternatives))
            }
        }
        let idsAbsents = Set(absentes)
        choix.removeAll { idsAbsents.contains($0.recetteId) }
        return Preparation(contributions: contributions, recettesAbsentes: absentes, selection: self)
    }

    private enum CodingKeys: String, CodingKey {
        case versionSchema = "version_schema"
        case choix
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        let version = try champs.decode(Int.self, forKey: .versionSchema)
        guard version == Self.versionSchemaCourante else { throw ErreurMagasinDocument.versionInconnue(version) }
        choix = try champs.decode([Choix].self, forKey: .choix)
        guard Set(choix.map(\.recetteId)).count == choix.count else {
            throw DecodingError.dataCorruptedError(forKey: .choix, in: champs, debugDescription: "Recette répétée")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var champs = encoder.container(keyedBy: CodingKeys.self)
        try champs.encode(Self.versionSchemaCourante, forKey: .versionSchema)
        try champs.encode(choix, forKey: .choix)
    }
}
