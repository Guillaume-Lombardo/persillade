import Foundation

public struct SelectionSemaine: Equatable, Sendable {
    public enum Erreur: Error, Equatable, Sendable {
        case portionsNonPositives
    }

    public struct Choix: Equatable, Sendable {
        public let recetteId: UUID
        public let portions: Int

        public init(recetteId: UUID, portions: Int) throws {
            guard portions > 0 else { throw Erreur.portionsNonPositives }
            self.recetteId = recetteId
            self.portions = portions
        }
    }

    public struct Contribution: Equatable, Sendable {
        public let recetteId: UUID
        public let article: ArticleCourses

        public var quantitePourRecette: Quantite? {
            get throws {
                guard let quantite = article.quantite else { return nil }
                guard (article.unite ?? .piece) == .piece else { return quantite }
                return try arrondirPourCourses(quantite, unite: .piece)
            }
        }
    }

    public struct Preparation: Equatable, Sendable {
        public let contributions: [Contribution]
        public let recettesAbsentes: [UUID]
    }

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
                contributions.append(Contribution(recetteId: recette.id, article: article))
            }
        }
        let idsAbsents = Set(absentes)
        choix.removeAll { idsAbsents.contains($0.recetteId) }
        return Preparation(contributions: contributions, recettesAbsentes: absentes)
    }
}
