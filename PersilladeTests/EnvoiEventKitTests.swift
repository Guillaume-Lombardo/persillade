#if targetEnvironment(simulator)
    import EventKit
    import Foundation
    import PersilladeCore
    import PersilladePlateforme
    import XCTest

    final class EnvoiEventKitTests: XCTestCase {
        @MainActor
        func testEnvoiReprisCocheEtRenvoiDansUneVraieListe() async throws {
            guard EKEventStore.authorizationStatus(for: .reminder) == .fullAccess else {
                throw XCTSkip("Accès complet à Rappels non accordé au simulateur.")
            }

            let magasin = EKEventStore()
            let source = try XCTUnwrap(magasin.sources.first { $0.sourceType == .local })
            let calendrier = EKCalendar(for: .reminder, eventStore: magasin)
            calendrier.title = "Persillade Test " + UUID().uuidString
            calendrier.source = source
            try magasin.saveCalendar(calendrier, commit: true)
            let dossier = URL.temporaryDirectory.appending(path: UUID().uuidString)
            defer {
                do {
                    try magasin.removeCalendar(calendrier, commit: true)
                    if FileManager.default.fileExists(atPath: dossier.path()) {
                        try FileManager.default.removeItem(at: dossier)
                    }
                } catch {
                    XCTFail("Le nettoyage de la liste Rappels de test a échoué : \(error)")
                }
            }

            let rappels = MagasinRappelsEventKit()
            let documents = MagasinDocumentFichiers(dossier: dossier)
            let envoi = EnvoiCourses(documents: DocumentsSansJournal(documents), rappels: rappels)
            let listeId = calendrier.calendarIdentifier
            try await envoi.choisirDestination(listeId)
            try await envoi.modifier { liste, _ in
                try liste.ajouter(ArticleCourses(nom: "lait", quantite: Quantite(1), unite: .l))
            }
            do {
                _ = try await envoi.renvoyer()
                XCTFail("La coupure doit survenir après l’écriture EventKit.")
            } catch DocumentsSansJournal.Coupure.apresEcriture {
                // Le rappel est écrit et la sauvegarde du journal a échoué.
            }
            let articles = try await rappels.lire(destinationId: listeId)
            let article = try XCTUnwrap(articles.first)
            XCTAssertEqual(articles.count, 1)
            XCTAssertEqual(article.titre, "lait 1 l")

            let rappel = try XCTUnwrap(magasin.calendarItem(withIdentifier: article.id) as? EKReminder)
            XCTAssertNil(rappel.notes)
            XCTAssertNil(rappel.url)
            XCTAssertNotNil(rappel.creationDate)

            let reprise = EnvoiCourses(documents: documents, rappels: MagasinRappelsEventKit())
            let premier = try await reprise.renvoyer()
            XCTAssertEqual(premier.ignores.count, 1)
            XCTAssertTrue(premier.ajoutes.isEmpty)
            let repris = try await reprise.lire()
            XCTAssertEqual(repris.journal.entrees.map(\.rappelId), [article.id])

            rappel.isCompleted = true
            try magasin.save(rappel, commit: true)

            let relance = EnvoiCourses(documents: documents, rappels: MagasinRappelsEventKit())
            let etat = try await relance.lire()
            let seuil = try XCTUnwrap(etat.liste.premierEnvoiLe)
            let coche = try await rappels.lire(destinationId: listeId)
            XCTAssertEqual(coche.count, 1)
            let cocheLe = try XCTUnwrap(coche.first?.cocheLe)
            XCTAssertGreaterThanOrEqual(
                cocheLe.timeIntervalSinceReferenceDate, seuil.timeIntervalSinceReferenceDate.rounded(.down))
            let second = try await relance.renvoyer()
            XCTAssertEqual(second.ignores, premier.ignores)
            XCTAssertTrue(second.ajoutes.isEmpty)
            let apres = try await rappels.lire(destinationId: listeId)
            XCTAssertEqual(apres.map(\.id), [article.id])
            XCTAssertTrue(apres.first?.coche == true)
            XCTAssertNotNil(apres.first?.cocheLe)
        }
    }

    private struct DocumentsSansJournal: MagasinDocument {
        enum Coupure: Error {
            case apresEcriture
        }

        let documents: MagasinDocumentFichiers

        init(_ documents: MagasinDocumentFichiers) {
            self.documents = documents
        }

        func lire<Document: Codable & Sendable>(_ type: Document.Type, cle: String, version: Int) async throws
            -> Document
        {
            try await documents.lire(type, cle: cle, version: version)
        }

        func ecrire<Document: Codable & Sendable>(_ document: Document, cle: String, version: Int) async throws {
            if let etat = document as? EtatCourses, etat.destinationVerrouillee { throw Coupure.apresEcriture }
            try await documents.ecrire(document, cle: cle, version: version)
        }
    }

#endif
