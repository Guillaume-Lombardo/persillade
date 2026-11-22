import XCTest

#if DEBUG
    final class EcransCoursesTests: XCTestCase {
        @MainActor
        func testSemaineRetoucheEnvoiAjoutEtRenvoi() {
            continueAfterFailure = false
            let app = lancer()
            ouvrirOnglet("Semaine", dans: app)
            XCTAssertTrue(app.staticTexts["Crêpes"].waitForExistence(timeout: 10))
            app.buttons["Diminuer les portions de Crêpes"].tap()
            app.buttons["Diminuer les portions de Gaufres"].tap()
            faireListe(dans: app)

            let farine = article("farine", dans: app)
            XCTAssertTrue(farine.waitForExistence(timeout: 10))
            XCTAssertTrue(farine.buttons.matching(NSPredicate(format: "label CONTAINS %@", "1,125")).firstMatch.exists)
            let oeufs = article("oeuf", dans: app)
            XCTAssertTrue(oeufs.buttons.matching(NSPredicate(format: "label CONTAINS %@", "3")).firstMatch.exists)
            farine.buttons.firstMatch.tap()
            app.buttons["modifier-quantite-courses"].tap()
            let quantite = app.textFields["editeur-quantite"]
            XCTAssertTrue(quantite.waitForExistence(timeout: 5))
            quantite.tap()
            quantite.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4) + "1500")
            XCTAssertEqual(quantite.value as? String, "1500")
            app.buttons["Valider"].tap()
            let fermerDetail = app.navigationBars["farine"].buttons["Fermer"]
            XCTAssertTrue(fermerDetail.waitForExistence(timeout: 10), app.debugDescription)
            fermerDetail.tap()
            XCTAssertTrue(farine.buttons.matching(NSPredicate(format: "label CONTAINS %@", "1,5")).firstMatch.exists)

            app.buttons["Ne pas envoyer œufs"].tap()
            XCTAssertTrue(
                oeufs.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Ne sera pas envoyé")).firstMatch.exists
            )
            app.buttons["Remettre œufs"].tap()

            app.buttons["Choisir une liste"].tap()
            let maison = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Maison")).firstMatch
            XCTAssertTrue(maison.waitForExistence(timeout: 5))
            let archives = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Archives")).firstMatch
            XCTAssertTrue(archives.exists)
            XCTAssertFalse(archives.isEnabled)
            maison.tap()
            app.buttons["courses-envoyer"].tap()
            XCTAssertTrue(app.staticTexts["2 rappels écrits"].waitForExistence(timeout: 5))
            app.buttons["Terminé"].tap()
            XCTAssertTrue(app.buttons["Liste Rappels verrouillée"].exists)

            app.buttons["Ajouter"].tap()
            app.buttons["Ajouter un article"].tap()
            let saisie = app.descendants(matching: .any)["ajout-saisie-courses"].firstMatch
            XCTAssertTrue(saisie.waitForExistence(timeout: 5))
            saisie.tap()
            saisie.typeText("2 bananes")
            app.buttons["ajout-valider-courses"].tap()
            XCTAssertTrue(app.staticTexts["Envoyé"].waitForExistence(timeout: 5))
            app.navigationBars["Ajouter un article"].buttons["Fermer"].tap()

            app.buttons["courses-renvoyer"].tap()
            XCTAssertTrue(app.staticTexts["0 rappels écrits"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["Aucun ajout nécessaire"].exists)
            app.buttons["Terminé"].tap()

            ouvrirOnglet("Semaine", dans: app)
            app.buttons["Augmenter les portions de Crêpes"].tap()
            XCTAssertTrue(app.staticTexts["Liste faite avant ce changement"].waitForExistence(timeout: 5))
            app.buttons["Refaire la liste"].tap()
            let remplacer = app.buttons["Remplacer"]
            XCTAssertTrue(remplacer.waitForExistence(timeout: 5))
            remplacer.tap()
            XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 5))
            XCTAssertFalse(app.buttons["Ne pas envoyer bananes"].exists)
            XCTAssertTrue(
                article("farine", dans: app).buttons
                    .matching(NSPredicate(format: "label CONTAINS %@", "1,25")).firstMatch.exists)
        }

        @MainActor
        func testCapturesSemaineEtCourses() {
            continueAfterFailure = false
            for (nom, arguments) in [
                ("clair", []), ("sombre", ["-courses-sombre"]), ("AX3", ["-courses-ax3"]), ("AX5", ["-courses-ax5"]),
            ] {
                let app = lancer(arguments)
                ouvrirOnglet("Semaine", dans: app)
                XCTAssertTrue(app.buttons["Faire la liste"].waitForExistence(timeout: 10), nom)
                joindreCapture("Semaine-\(nom)")
                faireListe(dans: app)
                XCTAssertTrue(app.buttons["Choisir une liste"].waitForExistence(timeout: 5), nom)
                XCTAssertTrue(app.buttons["Choisir une liste"].isHittable, nom)
                if nom == "AX5" {
                    app.swipeUp(velocity: .slow)
                    let derniere = app.buttons["Ne pas envoyer farine"]
                    XCTAssertTrue(derniere.isHittable, app.debugDescription)
                    XCTAssertLessThan(derniere.frame.midY, app.buttons["Choisir une liste"].frame.minY)
                }
                joindreCapture("Courses-\(nom)")
                app.terminate()
            }
        }

        @MainActor
        func testAuditAccessibiliteSemaineEtCourses() throws {
            let app = lancer()
            ouvrirOnglet("Semaine", dans: app)
            XCTAssertTrue(app.buttons["Faire la liste"].waitForExistence(timeout: 10))
            XCTAssertEqual(app.buttons["Augmenter les portions de Crêpes"].value as? String, "4 portions")
            let audits: XCUIAccessibilityAuditType = [
                .contrast, .elementDetection, .hitRegion, .sufficientElementDescription,
            ]
            try app.performAccessibilityAudit(for: audits)
            faireListe(dans: app)
            XCTAssertTrue(app.buttons["Choisir une liste"].waitForExistence(timeout: 5))
            try app.performAccessibilityAudit(for: audits)
        }

        @MainActor
        private func lancer(_ arguments: [String] = []) -> XCUIApplication {
            let app = XCUIApplication()
            app.launchArguments = ["-courses-recettes", "-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"] + arguments
            app.launch()
            return app
        }

        @MainActor
        private func ouvrirOnglet(_ titre: String, dans app: XCUIApplication) {
            let onglet = app.tabBars.firstMatch.buttons[titre]
            XCTAssertTrue(onglet.waitForExistence(timeout: 5))
            onglet.tap()
        }

        @MainActor
        private func faireListe(dans app: XCUIApplication) {
            let bouton = app.buttons["Faire la liste"]
            XCTAssertTrue(bouton.waitForExistence(timeout: 5))
            bouton.tap()
            XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 5))
        }

        @MainActor
        private func article(_ nom: String, dans app: XCUIApplication) -> XCUIElement {
            app.descendants(matching: .any).matching(identifier: "article-\(nom)").firstMatch
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
