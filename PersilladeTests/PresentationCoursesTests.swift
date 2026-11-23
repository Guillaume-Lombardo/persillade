import PersilladeCore
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
}
