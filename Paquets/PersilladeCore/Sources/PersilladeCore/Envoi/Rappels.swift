import Foundation

public enum CauseEchecEnvoi: String, Codable, Equatable, Error, Sendable {
    case accesRefuse = "acces_refuse"
    case listeIntrouvable = "liste_introuvable"
    case listeNonModifiable = "liste_non_modifiable"
    case ecriture
}

public struct DestinationRappels: Equatable, Identifiable, Sendable {
    public let id: String
    public let titre: String
    public let compte: String
    public let modifiable: Bool

    public init(id: String, titre: String, compte: String, modifiable: Bool) {
        self.id = id
        self.titre = titre
        self.compte = compte
        self.modifiable = modifiable
    }
}

public struct RappelCourses: Equatable, Identifiable, Sendable {
    public let id: String
    public let idExterne: String?
    public let titre: String
    public let creeLe: Date?
    public let coche: Bool
    public let cocheLe: Date?
    public let identifiantEcriture: UUID?

    public init(
        id: String, idExterne: String? = nil, titre: String, creeLe: Date? = nil,
        coche: Bool = false, cocheLe: Date? = nil, identifiantEcriture: UUID? = nil
    ) {
        self.id = id
        self.idExterne = idExterne
        self.titre = titre
        self.creeLe = creeLe
        self.coche = coche
        self.cocheLe = cocheLe
        self.identifiantEcriture = identifiantEcriture
    }
}

public protocol MagasinRappels: Sendable {
    func autoriser() async throws
    func destinations() async throws -> [DestinationRappels]
    func lire(destinationId: String) async throws -> [RappelCourses]
    /// Une erreur typée indique que l'écriture a été rejetée.
    /// L'identifiant d'écriture est enregistré avec le titre dans la même opération.
    func ajouter(titre: String, destinationId: String, identifiantEcriture: UUID) async throws -> RappelCourses
}

extension MagasinRappels {
    public func autoriser() async throws {}
}

public struct RapportEnvoi: Equatable, Sendable {
    public struct Echec: Equatable, Sendable {
        public let ligneId: UUID
        public let cause: CauseEchecEnvoi
    }

    public internal(set) var ajoutes: [UUID] = []
    public internal(set) var complements: [UUID] = []
    public internal(set) var ignores: [UUID] = []
    public internal(set) var echecs: [Echec] = []
    public internal(set) var causeGenerale: CauseEchecEnvoi?
}
