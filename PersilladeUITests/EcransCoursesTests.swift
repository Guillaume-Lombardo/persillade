import XCTest

#if DEBUG
    final class EcransCoursesTests: XCTestCase {
        @MainActor
        func testGenerationRetoucheEtExclusion() {
            let app = lancer()
            ouvrirOnglet("Semaine", dans: app)
            bouton("Diminuer les portions de Crêpes", dans: app).tap()
            bouton("Diminuer les portions de Gaufres", dans: app).tap()
            faireListe(dans: app)

            let farine = bouton("article-farine", dans: app)
            XCTAssertTrue(farine.label.contains("1,125"))
            let oeufs = bouton("article-oeuf", dans: app)
            XCTAssertTrue(oeufs.label.contains("3"))
            farine.tap()
            bouton("modifier-quantite-courses", dans: app).tap()
            let quantite = app.textFields["editeur-quantite"]
            XCTAssertTrue(quantite.waitForExistence(timeout: 10))
            quantite.tap()
            quantite.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4) + "1500")
            XCTAssertEqual(quantite.value as? String, "1500")
            bouton("Valider", dans: app).tap()
            let fermerDetail = app.navigationBars["farine"].buttons["Fermer"]
            XCTAssertTrue(fermerDetail.waitForExistence(timeout: 10))
            fermerDetail.tap()
            XCTAssertTrue(farine.waitForExistence(timeout: 10))
            XCTAssertTrue(farine.label.contains("1,5"))

            bouton("Ne pas envoyer œufs", dans: app).tap()
            let remettre = bouton("Remettre œufs", dans: app)
            XCTAssertTrue(oeufs.label.contains("Ne sera pas envoyé"))
            remettre.tap()
            XCTAssertTrue(app.buttons["Ne pas envoyer œufs"].waitForExistence(timeout: 10))
        }

        @MainActor
        func testEnvoiAjoutRenvoiEtRemplacement() {
            let app = lancer()
            ouvrirOnglet("Semaine", dans: app)
            faireListe(dans: app)

            bouton("Choisir une liste", dans: app).tap()
            let maison = bouton("destination-rappels-maison", dans: app)
            let archives = bouton("destination-rappels-archive", dans: app)
            XCTAssertFalse(archives.isEnabled)
            maison.tap()
            bouton("courses-envoyer", dans: app).tap()
            XCTAssertTrue(app.staticTexts["2 rappels écrits"].waitForExistence(timeout: 10))
            bouton("Terminé", dans: app).tap()
            XCTAssertTrue(app.buttons["Liste Rappels verrouillée"].waitForExistence(timeout: 10))

            bouton("Ajouter", dans: app).tap()
            bouton("Ajouter un article", dans: app).tap()
            let saisie = app.textFields["ajout-saisie-courses"]
            XCTAssertTrue(saisie.waitForExistence(timeout: 10))
            saisie.tap()
            saisie.typeText("2 bananes")
            bouton("ajout-valider-courses", dans: app).tap()
            XCTAssertTrue(app.staticTexts["Envoyé"].waitForExistence(timeout: 10))
            let fermerAjout = app.navigationBars["Ajouter un article"].buttons["Fermer"]
            XCTAssertTrue(fermerAjout.waitForExistence(timeout: 10))
            fermerAjout.tap()

            bouton("courses-renvoyer", dans: app).tap()
            XCTAssertTrue(app.staticTexts["0 rappels écrits"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts["Aucun ajout nécessaire"].waitForExistence(timeout: 10))
            bouton("Terminé", dans: app).tap()

            ouvrirOnglet("Semaine", dans: app)
            bouton("Augmenter les portions de Crêpes", dans: app).tap()
            XCTAssertTrue(app.staticTexts["Liste faite avant ce changement"].waitForExistence(timeout: 10))
            bouton("Refaire la liste", dans: app).tap()
            bouton("Remplacer", dans: app).tap()
            XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.buttons["article-banane"].waitForNonExistence(timeout: 10))
            XCTAssertTrue(bouton("article-farine", dans: app).label.contains("1,625"))
        }

        @MainActor
        func testCapturesSemaineEtCourses() {
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
                    XCTAssertTrue(derniere.waitForExistence(timeout: 10))
                    XCTAssertTrue(derniere.isHittable, nom)
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
            XCTAssertEqual(bouton("Augmenter les portions de Crêpes", dans: app).value as? String, "4 portions")
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
            continueAfterFailure = false
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
        private func bouton(_ identifiant: String, dans app: XCUIApplication) -> XCUIElement {
            let element = app.buttons[identifiant]
            XCTAssertTrue(element.waitForExistence(timeout: 10), "Bouton introuvable : \(identifiant)")
            return element
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
