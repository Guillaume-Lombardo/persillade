import XCTest

final class ConsentementFournisseurUITests: XCTestCase {
    @MainActor
    func testConsentementFournisseurEtSuppression() {
        let app = XCUIApplication()
        app.launch()
        ouvrirReglages(app)
        let reglages = app.navigationBars["Réglages"]
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))

        let actif = app.switches["fournisseur-actif"]
        let adresse = app.textFields["fournisseur-adresse"]
        let modele = app.textFields["fournisseur-modele"]
        let cle = app.secureTextFields["fournisseur-cle"]
        let images = app.switches["fournisseur-images"]
        let enregistrer = reglages.buttons["Enregistrer"]
        let supprimer = app.buttons["Supprimer la clé enregistrée"]
        if supprimer.exists { supprimerCle(app) }
        regler(actif, sur: false)
        regler(images, sur: false)
        remplacer(adresse, par: "")
        remplacer(modele, par: "")
        if enregistrer.isEnabled { enregistrer.tap() }
        XCTAssertEqual(actif.value as? String, "0")
        if !actif.isHittable { app.swipeDown() }
        joindreCapture("819-Réglages-désactivés")

        regler(actif, sur: true)
        remplacer(adresse, par: "https://api.exemple.test/v1")
        remplacer(modele, par: "exemple")
        cle.tap()
        cle.typeText("cle-fictive")
        enregistrer.tap()

        let consentement = app.navigationBars["Autoriser l’envoi"]
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["https://api.exemple.test/v1"].exists)
        XCTAssertTrue(app.staticTexts["Les frais éventuels du fournisseur sont à votre charge."].exists)
        XCTAssertTrue(
            app.staticTexts["Le texte des recettes et des messages, y compris le texte lu sur les photos."].exists)
        XCTAssertFalse(app.staticTexts["cle-fictive"].exists)
        joindreCapture("819-Consentement-texte")
        app.buttons["fournisseur-refuser"].tap()
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))
        XCTAssertEqual(actif.value as? String, "0")
        XCTAssertFalse(supprimer.exists)

        regler(actif, sur: true)
        remplacer(adresse, par: "https://api.exemple.test/v1")
        remplacer(modele, par: "exemple")
        cle.tap()
        cle.typeText("cle-fictive")
        enregistrer.tap()
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        app.buttons["fournisseur-accepter"].tap()
        XCTAssertTrue(supprimer.waitForExistence(timeout: 5))
        XCTAssertEqual(actif.value as? String, "1")

        remplacer(modele, par: "exemple-2")
        enregistrer.tap()
        XCTAssertFalse(consentement.exists)

        remplacer(adresse, par: "https://autre.exemple.test/v1")
        cle.tap()
        cle.typeText("autre-cle-fictive")
        enregistrer.tap()
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["https://autre.exemple.test/v1"].exists)
        app.buttons["fournisseur-refuser"].tap()
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))
        XCTAssertEqual(adresse.value as? String, "https://api.exemple.test/v1")

        if !images.isHittable { app.swipeUp() }
        regler(images, sur: true)
        enregistrer.tap()
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts[
                "Le texte des recettes et des messages, ainsi que les photos et le texte lu sur ces photos."
            ]
            .exists)
        joindreCapture("819-Consentement-photos")
        app.buttons["fournisseur-accepter"].tap()
        XCTAssertTrue(supprimer.waitForExistence(timeout: 5))
        regler(actif, sur: false)
        reglages.buttons["Fermer"].tap()
        ouvrirReglages(app)
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))
        XCTAssertEqual(actif.value as? String, "0")
        supprimerCle(app)
        XCTAssertEqual(actif.value as? String, "0")
        XCTAssertFalse(supprimer.exists)
    }

    @MainActor
    private func ouvrirReglages(_ app: XCUIApplication) {
        app.navigationBars["Recettes"].buttons["Plus d’options"].tap()
        app.buttons["Réglages"].tap()
    }

    @MainActor
    private func regler(_ interrupteur: XCUIElement, sur active: Bool) {
        let valeur = active ? "1" : "0"
        if interrupteur.value as? String != valeur {
            interrupteur.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        }
        XCTAssertEqual(interrupteur.value as? String, valeur)
    }

    @MainActor
    private func remplacer(_ champ: XCUIElement, par texte: String) {
        guard let valeur = champ.value as? String, let label = champ.placeholderValue else {
            XCTFail("Champ de configuration absent.")
            return
        }
        if valeur == label && texte.isEmpty { return }
        champ.coordinate(withNormalizedOffset: CGVector(dx: 0.99, dy: 0.5)).tap()
        if valeur != label {
            champ.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: valeur.count))
            XCTAssertEqual(champ.value as? String, label)
        }
        if !texte.isEmpty { champ.typeText(texte) }
    }

    @MainActor
    private func supprimerCle(_ app: XCUIApplication) {
        app.buttons["Supprimer la clé enregistrée"].tap()
        app.buttons["Supprimer la clé"].tap()
    }

    @MainActor
    private func joindreCapture(_ nom: String) {
        let piece = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        piece.name = nom
        piece.lifetime = .keepAlways
        add(piece)
    }
}
