#if DEBUG
    import XCTest

    final class EcransRecettesTests: XCTestCase {
        private static let recette = """
            Crêpes maison
            Ingrédients :
            2 œufs
            250 g de farine
            Lait, au goût

            Préparation :
            1. Mélangez les œufs et la farine.
            2. Versez le lait et cuisez les crêpes.
            """

        @MainActor
        func testCollageCorrectionPortionsEtRelance() throws {
            let app = lancer()
            coller(app)
            XCTAssertTrue(app.navigationBars["Destination"].exists)
            app.navigationBars["Destination"].buttons["Fermer"].tap()
            XCTAssertTrue(app.buttons["Ouvrir"].waitForExistence(timeout: 5))
            app.tabBars.firstMatch.buttons["Semaine"].tap()
            XCTAssertFalse(app.buttons["Ouvrir"].exists)
            app.tabBars.firstMatch.buttons["Recettes"].tap()
            app.buttons["Ouvrir"].tap()
            ouvrirCorrection(app)

            XCTAssertEqual(app.textFields["titre-correction"].value as? String, "Crêpes maison")
            XCTAssertTrue(app.staticTexts["Absent du texte, 4 par défaut"].exists)
            XCTAssertTrue(app.buttons["Texte reçu"].exists)
            joindre("Correction-clair")
            try auditer(app)

            enregistrer(app)
            XCTAssertEqual(app.staticTexts["titre-fiche"].label, "Crêpes maison")
            XCTAssertEqual(app.staticTexts["nombre-portions"].label, "4 portions")
            joindre("Fiche-clair")
            try auditer(app)

            app.buttons["Diminuer les portions"].tap()
            XCTAssertEqual(app.staticTexts["nombre-portions"].label, "3 portions")
            XCTAssertTrue(app.staticTexts["Affichage seul, la recette ne change pas"].exists)
            let deuxOeufs = app.staticTexts.matching(
                NSPredicate(format: "label == %@ OR label CONTAINS[cd] %@", "2", "2 œufs")
            ).firstMatch
            XCTAssertTrue(deuxOeufs.exists)
            app.buttons["Ajouter à la semaine"].tap()
            XCTAssertTrue(app.buttons["Retirer de la semaine"].waitForExistence(timeout: 5))
            app.buttons["Augmenter les portions"].tap()
            XCTAssertTrue(app.staticTexts["4 portions"].waitForExistence(timeout: 5))

            app.terminate()
            app.launch()
            let entree = app.descendants(matching: .any).matching(identifier: "ouvrir-recette").firstMatch
            XCTAssertTrue(entree.waitForExistence(timeout: 5))
            entree.tap()
            XCTAssertTrue(app.staticTexts["Dans la semaine"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.staticTexts["nombre-portions"].label, "4 portions")
        }

        @MainActor
        func testEchecEcritureConserveBrouillonEtContenu() {
            let app = lancer(arguments: ["-recettes-echec-ecriture"])
            coller(app)
            ouvrirCorrection(app)
            let titre = app.textFields["titre-correction"]
            XCTAssertTrue(titre.waitForExistence(timeout: 5))
            titre.tap()
            titre.typeText(" du dimanche")
            app.navigationBars["Correction"].buttons["Enregistrer"].tap()
            XCTAssertTrue(
                app.staticTexts["La recette n’a pas été enregistrée. Rien n’est perdu."].waitForExistence(timeout: 5))
            XCTAssertEqual(titre.value as? String, "Crêpes maison du dimanche")
            app.navigationBars["Correction"].buttons["Fermer"].tap()
            app.buttons["Quitter"].tap()
            XCTAssertTrue(app.buttons["Ouvrir"].waitForExistence(timeout: 5))
            app.buttons["Ouvrir"].tap()
            ouvrirCorrection(app)
            enregistrer(app)
            XCTAssertEqual(app.staticTexts["titre-fiche"].label, "Crêpes maison")
        }

        @MainActor
        func testCapturesSombreAX3EtAX5() {
            for (nom, argument) in [("sombre", "-recettes-sombre"), ("AX3", "-recettes-ax3"), ("AX5", "-recettes-ax5")]
            {
                let app = lancer(arguments: [argument])
                joindre("Bibliothèque-vide-\(nom)")
                coller(app)
                ouvrirCorrection(app)
                if nom.hasPrefix("AX") {
                    XCTAssertFalse(app.buttons.matching(identifier: "extrait-source").firstMatch.exists, nom)
                }
                joindre("Correction-\(nom)")
                enregistrer(app)
                joindre("Fiche-\(nom)")
                let action = app.buttons["Ajouter à la semaine"]
                XCTAssertTrue(action.exists, nom)
                XCTAssertGreaterThanOrEqual(action.frame.height, 44, nom)
                let derniere = app.staticTexts.containing(
                    NSPredicate(format: "label CONTAINS %@", "cuisez les crêpes")
                ).firstMatch
                for _ in 0..<7 {
                    if derniere.isHittable, derniere.frame.maxY <= action.frame.minY { break }
                    app.scrollViews.firstMatch.swipeUp(velocity: .slow)
                }
                XCTAssertTrue(derniere.isHittable, nom)
                XCTAssertLessThanOrEqual(derniere.frame.maxY, action.frame.minY, nom)
                XCTAssertEqual(action.frame.minX - app.frame.minX, 21, accuracy: 2, nom)
                XCTAssertEqual(app.frame.maxX - action.frame.maxX, 21, accuracy: 2, nom)
                joindre("Fiche-dernière-ligne-\(nom)")
                app.terminate()
            }
        }

        @MainActor
        private func lancer(arguments: [String] = []) -> XCUIApplication {
            continueAfterFailure = false
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"] + arguments
            app.launchEnvironment = [
                "PERSILLADE_TEST_SESSION": UUID().uuidString,
                "PERSILLADE_TEST_PRESSE_PAPIERS": Self.recette,
            ]
            app.launch()
            XCTAssertTrue(app.buttons["Coller un lien ou un texte"].waitForExistence(timeout: 8), app.debugDescription)
            return app
        }

        @MainActor
        private func coller(_ app: XCUIApplication) {
            app.buttons["Coller un lien ou un texte"].tap()
            let coller = app.buttons["coller-presse-papiers"]
            XCTAssertTrue(coller.waitForExistence(timeout: 5), app.debugDescription)
            coller.tap()
            app.buttons["Continuer"].tap()
            XCTAssertTrue(app.navigationBars["Destination"].waitForExistence(timeout: 5), app.debugDescription)
        }

        @MainActor
        private func ouvrirCorrection(_ app: XCUIApplication) {
            app.buttons["Recette"].tap()
            XCTAssertTrue(app.navigationBars["Correction"].waitForExistence(timeout: 8), app.debugDescription)
        }

        @MainActor
        private func enregistrer(_ app: XCUIApplication) {
            app.navigationBars["Correction"].buttons["Enregistrer"].tap()
            XCTAssertTrue(app.staticTexts["titre-fiche"].waitForExistence(timeout: 8), app.debugDescription)
        }

        @MainActor
        private func joindre(_ nom: String) {
            let capture = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            capture.name = nom
            capture.lifetime = .keepAlways
            add(capture)
        }

        @MainActor
        private func auditer(_ app: XCUIApplication) throws {
            try app.performAccessibilityAudit(for: [.sufficientElementDescription, .trait])
        }
    }
#endif
