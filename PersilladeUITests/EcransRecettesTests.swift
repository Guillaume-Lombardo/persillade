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

            app.navigationBars.firstMatch.buttons.firstMatch.tap()
            app.tabBars.firstMatch.buttons["Semaine"].tap()
            let diminuer = app.buttons["Diminuer les portions de Crêpes maison"]
            XCTAssertTrue(diminuer.waitForExistence(timeout: 5))
            XCTAssertEqual(diminuer.value as? String, "4 portions")
            diminuer.tap()
            app.buttons["Crêpes maison"].tap()
            XCTAssertTrue(app.staticTexts["titre-fiche"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.staticTexts["nombre-portions"].label, "3 portions")
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
        func testReprendCorrectionApresTerminaisonPuisEffaceApresEnregistrement() {
            let app = lancer(arguments: ["-test-observer-brouillon"])
            coller(app)
            ouvrirCorrection(app)
            let titre = app.textFields["titre-correction"]
            titre.tap()
            titre.typeText(" du dimanche")
            let portions = app.textFields["portions-correction"]
            portions.tap()
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 8))
            portions.typeText("6")
            attendreBrouillon("6", dans: app)
            XCTAssertEqual(portions.value as? String, "6")
            XCTAssertTrue(app.keyboards.firstMatch.exists)

            app.terminate()
            app.launch()
            XCTAssertTrue(titre.waitForExistence(timeout: 8))
            XCTAssertEqual(titre.value as? String, "Crêpes maison du dimanche")
            XCTAssertEqual(portions.value as? String, "6")
            let oeufs = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[cd] %@ AND value BEGINSWITH %@", "œufs", "2")
            ).firstMatch
            XCTAssertTrue(oeufs.exists)
            XCTAssertEqual((oeufs.value as? String)?.components(separatedBy: ", ").first, "2")
            joindre("Correction-reprise")
            enregistrer(app)
            XCTAssertEqual(app.staticTexts["titre-fiche"].label, "Crêpes maison du dimanche")

            app.terminate()
            app.launch()
            XCTAssertTrue(
                app.descendants(matching: .any).matching(identifier: "ouvrir-recette").firstMatch.waitForExistence(
                    timeout: 8))
            XCTAssertFalse(titre.exists)
            XCTAssertFalse(app.buttons["ouvrir-contenu-recu"].exists)
        }

        @MainActor
        func testReprendUneModificationApresArrierePlanPuisAbandonne() {
            let app = lancer()
            coller(app)
            ouvrirCorrection(app)
            enregistrer(app)
            app.buttons["Options de la recette"].tap()
            app.buttons["Modifier"].tap()
            let titre = app.textFields["titre-correction"]
            XCTAssertTrue(titre.waitForExistence(timeout: 8))
            titre.tap()
            titre.typeText(" en cours")

            XCUIDevice.shared.press(.home)
            app.terminate()
            app.launch()
            XCTAssertTrue(app.navigationBars["Modifier la recette"].waitForExistence(timeout: 8))
            XCTAssertEqual(titre.value as? String, "Crêpes maison en cours")
            app.buttons["fermer-correction"].tap()
            app.buttons["Quitter"].tap()
            XCTAssertTrue(app.buttons["fermer-correction"].waitForNonExistence(timeout: 10))

            app.terminate()
            app.launch()
            let recette = app.descendants(matching: .any).matching(identifier: "ouvrir-recette").firstMatch
            XCTAssertTrue(recette.waitForExistence(timeout: 8))
            recette.tap()
            XCTAssertTrue(app.staticTexts["titre-fiche"].waitForExistence(timeout: 8))
            XCTAssertEqual(app.staticTexts["titre-fiche"].label, "Crêpes maison")
        }

        @MainActor
        func testDestinationLongueGardeLesActionsVisibles() {
            let texte = String(repeating: "Un long extrait de texte qui occupe plusieurs lignes. ", count: 40)
            for (nom, arguments) in [("Standard", []), ("AX3", ["-recettes-ax3"])] {
                let app = lancer(arguments: arguments, texte: texte)
                coller(app)
                let apercu = app.staticTexts["apercu-destination"]
                XCTAssertTrue(apercu.exists, nom)
                XCTAssertLessThan(apercu.frame.height, nom == "AX3" ? 145 : 115, nom)
                XCTAssertTrue(app.buttons["import-destination-recette"].isHittable, nom)
                XCTAssertTrue(app.buttons["Articles de courses"].isHittable, nom)
                joindre("Destination-longue-\(nom)")
                app.terminate()
            }
        }

        @MainActor
        func testReprendLaValidationDuMessageEtLaQuantiteEnCoursDeSaisie() {
            let app = lancer(arguments: ["-test-observer-brouillon"], texte: "2 bananes\n500 g de farine")
            coller(app)
            app.buttons["Articles de courses"].tap()
            let exclure = app.buttons["Ne pas envoyer farine"]
            XCTAssertTrue(exclure.waitForExistence(timeout: 8))
            exclure.tap()
            let bananes = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[cd] %@ AND value BEGINSWITH %@", "bananes", "2")
            ).firstMatch
            XCTAssertTrue(bananes.exists)
            XCTAssertEqual((bananes.value as? String)?.components(separatedBy: ", ").first, "2")
            bananes.tap()
            let quantite = app.textFields["editeur-quantite"]
            XCTAssertTrue(quantite.waitForExistence(timeout: 8))
            quantite.tap()
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 8))
            quantite.typeText(XCUIKeyboardKey.delete.rawValue + "3")
            attendreBrouillon("3", dans: app)
            XCTAssertEqual(quantite.value as? String, "3")
            XCTAssertTrue(app.keyboards.firstMatch.exists)

            app.terminate()
            app.launch()
            XCTAssertTrue(quantite.waitForExistence(timeout: 10))
            XCTAssertEqual(quantite.value as? String, "3")
            app.buttons["Valider"].tap()
            XCTAssertTrue(app.buttons["Remettre farine"].waitForExistence(timeout: 8))
            app.buttons["Ajouter 1 article"].tap()
            let terminer = app.buttons["Terminé"]
            XCTAssertTrue(terminer.waitForExistence(timeout: 8))
            terminer.tap()
            XCTAssertTrue(app.buttons["article-banane"].waitForExistence(timeout: 8))
            XCTAssertEqual((app.buttons["article-banane"].value as? String)?.components(separatedBy: ", ").first, "3")
            XCTAssertFalse(app.buttons["article-farine"].exists)
        }

        @MainActor
        func testMessageDepuisDestination() {
            let app = lancer(texte: "2 bananes\n500 g de farine")
            coller(app)
            app.buttons["Articles de courses"].tap()
            let ajouter = app.buttons["Ajouter 2 articles"]
            XCTAssertTrue(ajouter.waitForExistence(timeout: 10))
            ajouter.tap()
            let terminer = app.buttons["Terminé"]
            XCTAssertTrue(terminer.waitForExistence(timeout: 5))
            terminer.tap()

            XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.buttons["Ne pas envoyer bananes"].exists)
            XCTAssertTrue(app.buttons["Ne pas envoyer farine"].exists)
            app.tabBars.firstMatch.buttons["Recettes"].tap()
            XCTAssertTrue(app.navigationBars["Recettes"].waitForExistence(timeout: 5))
            XCTAssertFalse(app.buttons["Ouvrir"].exists)
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
                    XCTAssertFalse(
                        app.descendants(matching: .any).matching(identifier: "extrait-source").firstMatch.exists, nom)
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
        private func attendreBrouillon(_ valeur: String, dans app: XCUIApplication) {
            let temoin = app.staticTexts["brouillon-ecrit"]
            let ecrit = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "label == %@", "Brouillon écrit \(valeur)"),
                object: temoin)
            XCTAssertEqual(XCTWaiter.wait(for: [ecrit], timeout: 10), .completed)
        }

        @MainActor
        private func lancer(arguments: [String] = [], texte: String? = nil) -> XCUIApplication {
            continueAfterFailure = false
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"] + arguments
            app.launchEnvironment = [
                "PERSILLADE_TEST_SESSION": UUID().uuidString,
                "PERSILLADE_TEST_PRESSE_PAPIERS": texte ?? Self.recette,
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
            let continuer = app.buttons["Continuer"]
            let prete = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: continuer)
            XCTAssertEqual(XCTWaiter.wait(for: [prete], timeout: 5), .completed, app.debugDescription)
            continuer.tap()
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
