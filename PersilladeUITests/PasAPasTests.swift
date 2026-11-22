#if DEBUG
    import XCTest

    final class PasAPasTests: XCTestCase {
        @MainActor
        func testSuiviEtRepriseDUneRecetteDeCinqEtapes() {
            continueAfterFailure = false
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
            app.launchEnvironment = [
                "PERSILLADE_TEST_SESSION": UUID().uuidString,
                "PERSILLADE_TEST_PRESSE_PAPIERS": """
                Crêpes maison
                Ingrédients :
                2 œufs
                250 g de farine

                Préparation :
                1. Mélangez la farine et les œufs.
                2. Versez le lait progressivement.
                3. Laissez reposer la pâte.
                4. Chauffez une poêle.
                5. Faites cuire les crêpes.
                """,
            ]
            app.launch()
            toucher(app.buttons["Coller un lien ou un texte"])
            toucher(app.buttons["coller-presse-papiers"])
            let continuer = app.buttons["Continuer"]
            XCTAssertTrue(continuer.waitForExistence(timeout: 12))
            XCTAssertTrue(continuer.wait(for: \.isEnabled, toEqual: true, timeout: 12))
            continuer.tap()
            toucher(app.buttons["Recette"])
            toucher(app.navigationBars["Correction"].buttons["Enregistrer"])

            let ouvrir = app.buttons["ouvrir-cuisine"]
            toucher(ouvrir)
            let position = app.staticTexts["position-cuisine"]
            let suivante = app.buttons["suivante-cuisine"]
            let precedente = app.buttons["precedente-cuisine"]
            XCTAssertTrue(position.waitForExistence(timeout: 12))
            XCTAssertEqual(position.label, "Étape 1 sur 5")
            XCTAssertFalse(precedente.isEnabled)
            toucher(suivante)
            suivante.tap()
            toucher(precedente)
            XCTAssertTrue(position.wait(for: \.label, toEqual: "Étape 2 sur 5", timeout: 12))
            let consigne = app.staticTexts["consigne-cuisine"]
            XCTAssertTrue(consigne.waitForExistence(timeout: 12))
            XCTAssertEqual(consigne.label, "Versez le lait progressivement.")

            toucher(app.buttons["fermer-cuisine"])
            XCTAssertTrue(ouvrir.wait(for: \.label, toEqual: "Reprendre à l’étape 2", timeout: 12))
            toucher(ouvrir)
            XCTAssertTrue(position.wait(for: \.label, toEqual: "Étape 2 sur 5", timeout: 12))
        }

        @MainActor
        private func toucher(_ element: XCUIElement, fichier: StaticString = #filePath, ligne: UInt = #line) {
            XCTAssertTrue(element.waitForExistence(timeout: 12), file: fichier, line: ligne)
            element.tap()
        }
    }
#endif
