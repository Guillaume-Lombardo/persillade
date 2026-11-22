import Foundation

public protocol Bibliotheque: Sendable {
    func enregistrer(_ recette: Recette) async throws -> UUID
    func lire(id: UUID) async throws -> Recette?
    func modifier(_ recette: Recette) async throws
    func lister() async throws -> [ResumeRecette]
    func rechercherParTitre(_ texte: String) async throws -> [ResumeRecette]
    func supprimer(id: UUID) async throws
}

public enum ErreurBibliotheque: Error, Equatable, Sendable {
    case recetteDejaEnregistree(UUID)
    case recetteIntrouvable(UUID)
}

public struct ResumeRecette: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let titre: String
    public let nombreIngredients: Int
    public let nombreEtapes: Int
    public let creeLe: Date
    public let modifieLe: Date

    public init(
        id: UUID, titre: String, nombreIngredients: Int, nombreEtapes: Int, creeLe: Date, modifieLe: Date
    ) {
        self.id = id
        self.titre = titre
        self.nombreIngredients = nombreIngredients
        self.nombreEtapes = nombreEtapes
        self.creeLe = creeLe
        self.modifieLe = modifieLe
    }
}
