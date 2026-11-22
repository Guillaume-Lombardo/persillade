import Foundation
import PersilladeCore

public actor MagasinRappelsMemoire: MagasinRappels {
    private let listes: [DestinationRappels]
    private let maintenant: @Sendable () -> Date
    private var contenu: [String: [RappelCourses]]
    private var accesAccorde = true
    private var ecrituresEnEchec: Set<String> = []
    private var listesSupprimees: Set<String> = []

    public init(
        destinations: [DestinationRappels], contenu: [String: [RappelCourses]] = [:],
        maintenant: @escaping @Sendable () -> Date = Date.init
    ) {
        listes = destinations
        self.contenu = contenu
        self.maintenant = maintenant
    }

    public func fixerAcces(_ accorde: Bool) {
        accesAccorde = accorde
    }

    public func fixerEcrituresEnEchec(_ titres: Set<String>) {
        ecrituresEnEchec = titres
    }

    public func supprimerDestination(_ id: String) {
        listesSupprimees.insert(id)
        contenu[id] = nil
    }

    public func remplacerRappels(_ rappels: [RappelCourses], destinationId: String) {
        contenu[destinationId] = rappels
    }

    public func destinations() throws -> [DestinationRappels] {
        guard accesAccorde else { throw CauseEchecEnvoi.accesRefuse }
        return listes.filter { !listesSupprimees.contains($0.id) }
    }

    public func lire(destinationId: String) throws -> [RappelCourses] {
        try verifierDestination(destinationId)
        return contenu[destinationId, default: []]
    }

    public func ajouter(titre: String, destinationId: String, identifiantEcriture: UUID) throws -> RappelCourses {
        try verifierDestination(destinationId)
        guard !ecrituresEnEchec.contains(titre) else { throw CauseEchecEnvoi.ecriture }
        let rappel = RappelCourses(
            id: UUID().uuidString, titre: titre, creeLe: maintenant(), identifiantEcriture: identifiantEcriture)
        contenu[destinationId, default: []].append(rappel)
        return rappel
    }

    private func verifierDestination(_ id: String) throws {
        guard let liste = try destinations().first(where: { $0.id == id }) else {
            throw CauseEchecEnvoi.listeIntrouvable
        }
        guard liste.modifiable else { throw CauseEchecEnvoi.listeNonModifiable }
    }
}
