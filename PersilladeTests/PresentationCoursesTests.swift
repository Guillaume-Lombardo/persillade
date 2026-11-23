import PersilladeCore
import PersilladePlateforme
import XCTest

@testable import Persillade

final class PresentationCoursesTests: XCTestCase {
    func testQuantiteIndisponibleDansLaPrecision() throws {
        var liste = ListeCourses()
        let quantite = try Quantite(numerateur: Int64.max - 2, denominateur: 3)
        try liste.ajouter(ArticleCourses(nom: "huile", quantite: quantite, unite: .cas))
        let ligne = try XCTUnwrap(liste.lignes.first)
        let presentation = PresentationQuantite(ligne: ligne)
        XCTAssertNil(presentation.nombre)
        XCTAssertNil(presentation.unite)
        XCTAssertEqual(presentation.precision, "Quantité indisponible")
    }

    func testUnitesCuillereAvecEspacesInsecables() throws {
        XCTAssertEqual(try PresentationQuantite(Quantite(2), .cas).libelle, "2 c.\u{00A0}à\u{00A0}s.")
        XCTAssertEqual(try PresentationQuantite(Quantite(1), .cac).libelle, "1 c.\u{00A0}à\u{00A0}c.")
    }

    @MainActor
    func testTitreDestinationSupprimeeRetrouveApresRelance() async throws {
        let nom = "CoursesPresentation-\(UUID().uuidString)"
        let dossier = URL.temporaryDirectory.appending(path: nom)
        let preferences = try XCTUnwrap(UserDefaults(suiteName: nom))
        defer { preferences.removePersistentDomain(forName: nom) }
        addTeardownBlock { try FileManager.default.removeItem(at: dossier) }

        let maison = DestinationRappels(id: "maison", titre: "Maison", compte: "Sur mon iPhone", modifiable: true)
        let rappels = MagasinRappelsMemoire(destinations: [maison])
        let session = SessionCourses(
            bibliotheque: BibliothequeRecettes(dossier: dossier, rappels: rappels), preferences: preferences)
        try await session.chargerDestinations()
        try await session.choisirDestination(maison.id)
        try await session.envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "huile"))
        }
        XCTAssertEqual(session.titreDestination, maison.titre)

        await rappels.supprimerDestination(maison.id)
        let relance = SessionCourses(
            bibliotheque: BibliothequeRecettes(dossier: dossier, rappels: rappels), preferences: preferences)
        await relance.actualiser()
        let rapport = try await relance.envoyer()
        XCTAssertEqual(rapport.causeGenerale, .listeIntrouvable)
        XCTAssertNil(relance.destination)
        XCTAssertEqual(relance.titreDestination, maison.titre)
    }
}
