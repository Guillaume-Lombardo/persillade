import XCTest

final class PersilladeUITests: XCTestCase {
    @MainActor
    func testOngletsEtReglages() {
        let app = XCUIApplication()
        app.launch()

        let onglets = app.tabBars.firstMatch
        for titre in ["Recettes", "Semaine", "Courses"] {
            let onglet = onglets.buttons[titre]
            XCTAssertTrue(onglet.exists)
            onglet.tap()
            XCTAssertTrue(app.navigationBars[titre].exists)
        }
        app.navigationBars["Courses"].buttons["Plus d’options"].tap()
        let reglages = app.buttons["Réglages"]
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))
        reglages.tap()
        XCTAssertTrue(app.navigationBars["Réglages"].exists)
        app.navigationBars["Réglages"].buttons["Fermer"].tap()
        XCTAssertTrue(app.navigationBars["Courses"].exists)
    }
}

#if DEBUG
    extension PersilladeUITests {
        @MainActor
        func testGalerieClairSombreAX3EtAX5() {
            for (nom, arguments) in [
                ("clair", []), ("sombre", ["-galerie-sombre"]), ("AX3", ["-galerie-ax3"]), ("AX5", ["-galerie-ax5"]),
            ] {
                let app = XCUIApplication()
                app.launchArguments = ["-galerie"] + arguments
                app.launch()
                let action = app.buttons["Modifier la quantité"]
                XCTAssertTrue(action.waitForExistence(timeout: 5), nom)
                joindreCapture("Galerie-\(nom)")

                if nom == "clair" {
                    app.buttons["Ne pas envoyer Pommes de terre"].tap()
                    let articleExclu = app.buttons.matching(
                        NSPredicate(
                            format: "label == %@ AND value CONTAINS %@", "Pommes de terre", "Ne sera pas envoyé"))
                    XCTAssertTrue(articleExclu.firstMatch.waitForExistence(timeout: 5))
                    app.buttons["Remettre Pommes de terre"].tap()
                }

                if nom == "sombre" {
                    // Le verre en sombre fausse le signal isHittable de XCTest.
                    let cadre = action.frame
                    let fenetre = app.frame
                    app.coordinate(withNormalizedOffset: .zero)
                        .withOffset(CGVector(dx: cadre.midX - fenetre.minX, dy: cadre.midY - fenetre.minY))
                        .tap()
                    XCTAssertTrue(app.textFields["editeur-quantite"].waitForExistence(timeout: 5), app.debugDescription)
                    app.buttons["Fermer"].tap()
                }

                if nom == "AX5" {
                    XCTAssertTrue(action.isHittable)
                    action.tap()
                    XCTAssertTrue(app.textFields["editeur-quantite"].exists)
                    XCTAssertTrue(app.buttons["Valider"].isHittable)
                    joindreCapture("Éditeur-AX5")
                    app.buttons["Effacer la quantité"].tap()
                    XCTAssertTrue(action.waitForExistence(timeout: 5))
                } else if nom == "clair" || nom == "sombre" {
                    let defilement = app.scrollViews.firstMatch
                    defilement.swipeUp(velocity: .slow)
                    XCTAssertTrue(app.staticTexts["Quiche lorraine"].waitForExistence(timeout: 5))
                    joindreCapture("Motifs-\(nom)")
                }
                app.terminate()
            }
        }

        @MainActor
        private func joindreCapture(_ nom: String) {
            let piece = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            piece.name = nom
            piece.lifetime = .keepAlways
            add(piece)
        }
    }
#endif
