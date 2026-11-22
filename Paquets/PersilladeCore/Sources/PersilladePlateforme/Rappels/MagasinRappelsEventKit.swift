import EventKit
import Foundation
import PersilladeCore

@MainActor
public final class MagasinRappelsEventKit: MagasinRappels {
    private let magasin = EKEventStore()

    public init() {}

    public func destinations() async throws -> [DestinationRappels] {
        try await autoriser()
        return magasin.calendars(for: .reminder).map {
            DestinationRappels(
                id: $0.calendarIdentifier, titre: $0.title, compte: $0.source.title,
                modifiable: $0.allowsContentModifications)
        }
    }

    public func lire(destinationId: String) async throws -> [RappelCourses] {
        try await autoriser()
        let calendrier = try calendrierModifiable(destinationId)
        let predicat = magasin.predicateForReminders(in: [calendrier])
        let rappels: [RappelCourses]? = await withCheckedContinuation { continuation in
            magasin.fetchReminders(matching: predicat) { rappels in
                continuation.resume(returning: rappels?.map(Self.convertir))
            }
        }
        guard EKEventStore.authorizationStatus(for: .reminder) == .fullAccess else {
            throw CauseEchecEnvoi.accesRefuse
        }
        _ = try calendrierModifiable(destinationId)
        guard let rappels else { throw CauseEchecEnvoi.ecriture }
        return rappels
    }

    public func ajouter(titre: String, destinationId: String) async throws -> RappelCourses {
        try await autoriser()
        let rappel = EKReminder(eventStore: magasin)
        rappel.calendar = try calendrierModifiable(destinationId)
        rappel.title = titre
        do {
            try magasin.save(rappel, commit: true)
        } catch {
            if let erreur = error as? EKError {
                switch erreur.code {
                case .eventStoreNotAuthorized:
                    throw CauseEchecEnvoi.accesRefuse
                case .calendarReadOnly:
                    throw CauseEchecEnvoi.listeNonModifiable
                case .noCalendar, .calendarDoesNotAllowReminders:
                    throw CauseEchecEnvoi.listeIntrouvable
                default:
                    break
                }
            }
            guard EKEventStore.authorizationStatus(for: .reminder) == .fullAccess else {
                throw CauseEchecEnvoi.accesRefuse
            }
            _ = try calendrierModifiable(destinationId)
            throw CauseEchecEnvoi.ecriture
        }
        return Self.convertir(rappel)
    }

    public func autoriser() async throws {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .fullAccess:
            return
        case .notDetermined:
            do {
                if try await magasin.requestFullAccessToReminders() {
                    magasin.reset()
                    return
                }
            } catch {
                throw CauseEchecEnvoi.accesRefuse
            }
        default:
            break
        }
        throw CauseEchecEnvoi.accesRefuse
    }

    private func calendrierModifiable(_ id: String) throws -> EKCalendar {
        guard let calendrier = magasin.calendar(withIdentifier: id),
            calendrier.allowedEntityTypes.contains(.reminder)
        else {
            throw CauseEchecEnvoi.listeIntrouvable
        }
        guard calendrier.allowsContentModifications else { throw CauseEchecEnvoi.listeNonModifiable }
        return calendrier
    }

    private nonisolated static func convertir(_ rappel: EKReminder) -> RappelCourses {
        return RappelCourses(
            id: rappel.calendarItemIdentifier, idExterne: rappel.calendarItemExternalIdentifier,
            titre: rappel.title ?? "", creeLe: rappel.creationDate, coche: rappel.isCompleted,
            cocheLe: rappel.completionDate)
    }
}
