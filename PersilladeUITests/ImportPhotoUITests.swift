#if DEBUG
    import XCTest

    final class ImportPhotoUITests: XCTestCase {
        @MainActor
        func testPhotothequeCorrectionRepriseEtEnregistrement() {
            continueAfterFailure = false
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
            app.launchEnvironment["PERSILLADE_TEST_SESSION"] = UUID().uuidString
            app.launch()

            toucher(app.buttons["import-ajouter-recette"])
            toucher(app.buttons["import-choisir-photo"])
            // Le simulateur est alimenté par le script de test avec une seule photo.
            toucher(app.cells.firstMatch)
            toucher(app.buttons["import-destination-recette"])
            verifierCorrection(app)
            joindre("Photo-correction")

            toucher(app.buttons["fermer-correction"])
            toucher(app.buttons["ouvrir-contenu-recu"])
            toucher(app.buttons["import-destination-recette"])
            verifierCorrection(app)
            toucher(app.buttons["enregistrer-correction"])

            let titre = app.staticTexts["titre-fiche"]
            XCTAssertTrue(titre.waitForExistence(timeout: 20))
            XCTAssertEqual(titre.label, "Soupe de courge")
            joindre("Photo-recette-enregistree")
        }

        @MainActor
        private func toucher(_ element: XCUIElement) {
            XCTAssertTrue(element.waitForExistence(timeout: 20), element.debugDescription)
            element.tap()
        }

        @MainActor
        private func verifierCorrection(_ app: XCUIApplication) {
            XCTAssertTrue(app.images["photo-correction"].waitForExistence(timeout: 30), app.debugDescription)
            let titre = app.textFields["titre-correction"]
            XCTAssertTrue(titre.waitForExistence(timeout: 10))
            XCTAssertEqual(titre.value as? String, "Soupe de courge")
        }

        @MainActor
        private func joindre(_ nom: String) {
            let capture = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            capture.name = nom
            capture.lifetime = .keepAlways
            add(capture)
        }
    }
#endif
