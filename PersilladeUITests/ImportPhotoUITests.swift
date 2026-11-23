#if DEBUG
    import XCTest

    final class ImportPhotoUITests: XCTestCase {
        @MainActor
        func testRepliQuandAppareilPhotoIndisponibleOuRefuse() throws {
            continueAfterFailure = false
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
            app.launchEnvironment["PERSILLADE_TEST_SESSION"] = UUID().uuidString
            app.resetAuthorizationStatus(for: .camera)
            app.launch()

            toucher(app.buttons["Prendre une photo"])
            let erreur = app.descendants(matching: .any)["photo-erreur"].firstMatch
            if !erreur.waitForExistence(timeout: 3) {
                let libelles = NSPredicate(format: "label IN %@", ["Ne pas autoriser", "Don’t Allow", "Don't Allow"])
                let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
                let refus = springboard.buttons.matching(libelles).firstMatch
                if refus.waitForExistence(timeout: 3) {
                    refus.tap()
                } else {
                    toucher(app.alerts.buttons.matching(libelles).firstMatch)
                }
            }
            XCTAssertTrue(erreur.waitForExistence(timeout: 5))
            let choix = app.buttons["Choisir une photo"]
            XCTAssertTrue(choix.isHittable)
            XCTAssertGreaterThanOrEqual(choix.frame.height, 44)
            if erreur.label == "Persillade n’a pas accès à l’appareil photo." {
                let reglages = app.buttons["Ouvrir Réglages"]
                XCTAssertTrue(reglages.isHittable)
                XCTAssertLessThan(choix.frame.minY, reglages.frame.minY)
                joindre("photo-camera-refusee-clair")
            } else {
                XCTAssertEqual(erreur.label, "L’appareil photo est indisponible.")
                joindre("photo-appareil-indisponible-clair")
            }
            try app.performAccessibilityAudit(for: [.sufficientElementDescription, .trait])
        }

        @MainActor
        func testPhotothequeCorrectionRepriseEtEnregistrement() throws {
            continueAfterFailure = false
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
            app.launchEnvironment["PERSILLADE_TEST_SESSION"] = UUID().uuidString
            app.launch()

            toucher(app.buttons["import-ajouter-recette"])
            toucher(app.buttons["import-choisir-photo"])
            // La photo générée est plus récente que les exemples de la photothèque iOS.
            let grille = app.scrollViews["photosView_content_scroll_view"]
            toucher(grille.images.matching(identifier: "PXGGridLayout-Info").firstMatch)
            let recette = app.buttons["import-destination-recette"]
            let abandonner = app.buttons["import-destination-abandonner"]
            XCTAssertTrue(recette.wait(for: \.isHittable, toEqual: true, timeout: 20))
            XCTAssertTrue(abandonner.isHittable)
            XCTAssertEqual(recette.frame.width, abandonner.frame.width, accuracy: 1)
            XCTAssertFalse(app.buttons["Articles de courses"].exists)
            joindre("Destination-photo-clair")
            recette.tap()
            verifierCorrection(app)
            joindre("Photo-correction")
            let photo = app.buttons["photo-correction"]
            toucher(photo)
            XCTAssertTrue(app.images["photo-correction-agrandie"].waitForExistence(timeout: 5))
            joindre("Correction-photo-agrandie")
            try app.performAccessibilityAudit(for: [.sufficientElementDescription, .trait])
            toucher(app.navigationBars["Photo de la recette"].buttons["Fermer"])
            XCTAssertTrue(photo.wait(for: \.isHittable, toEqual: true, timeout: 5))

            toucher(app.buttons["fermer-correction"])
            toucher(app.buttons["ouvrir-contenu-recu"])
            toucher(app.buttons["import-destination-recette"])
            verifierCorrection(app)
            app.terminate()
            app.launch()
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
            XCTAssertTrue(app.buttons["photo-correction"].waitForExistence(timeout: 30), app.debugDescription)
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
