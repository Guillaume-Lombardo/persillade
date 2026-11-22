import XCTest

final class ConsentementFournisseurUITests: XCTestCase {
    @MainActor
    func testConsentementFournisseurEtSuppression() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(fr)", "-AppleLocale", "fr_FR"]
        app.launchEnvironment["PERSILLADE_TEST_SESSION"] = UUID().uuidString
        let adresseInitiale = "https://api.exemple.test/v1"
        let autreAdresse = "https://autre.exemple.test/v1"
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
        XCTAssertEqual(actif.value as? String, "0")
        XCTAssertFalse(adresse.exists)
        XCTAssertFalse(modele.exists)
        XCTAssertFalse(cle.exists)
        XCTAssertFalse(images.exists)
        joindreCapture("reglages-clair")
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .trait])

        regler(actif, sur: true)
        regler(images, sur: false)
        remplacer(adresse, par: adresseInitiale)
        remplacer(modele, par: "exemple")
        cle.tap()
        cle.typeText("cle-fictive")
        enregistrer.tap()

        let consentement = app.navigationBars["Autoriser l’envoi"]
        let adresseConsentement = app.staticTexts["fournisseur-adresse-consentement"]
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        XCTAssertEqual(adresseConsentement.label, "Adresse du fournisseur : \(adresseInitiale)")
        XCTAssertTrue(app.staticTexts["Les frais éventuels du fournisseur sont à votre charge."].exists)
        XCTAssertTrue(
            app.staticTexts["Le texte des recettes et des messages, y compris le texte lu sur les photos."].exists)
        XCTAssertFalse(app.staticTexts["cle-fictive"].exists)
        let accepter = app.buttons["fournisseur-accepter"]
        let refuser = app.buttons["fournisseur-refuser"]
        XCTAssertEqual(accepter.frame.width, refuser.frame.width, accuracy: 1)
        XCTAssertEqual(accepter.frame.height, refuser.frame.height, accuracy: 1)
        joindreCapture("consentement-clair")
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .trait])
        app.buttons["fournisseur-refuser"].tap()
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))
        XCTAssertEqual(actif.value as? String, "0")
        XCTAssertFalse(supprimer.exists)

        regler(actif, sur: true)
        regler(images, sur: false)
        remplacer(adresse, par: adresseInitiale)
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

        remplacer(adresse, par: autreAdresse)
        cle.tap()
        cle.typeText("autre-cle-fictive")
        enregistrer.tap()
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        XCTAssertEqual(adresseConsentement.label, "Adresse du fournisseur : \(autreAdresse)")
        app.buttons["fournisseur-refuser"].tap()
        XCTAssertTrue(reglages.waitForExistence(timeout: 5))
        XCTAssertEqual(adresse.value as? String, adresseInitiale)

        if !images.isHittable { app.swipeUp() }
        regler(images, sur: true)
        enregistrer.tap()
        XCTAssertTrue(consentement.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts[
                "Le texte des recettes et des messages, ainsi que les photos et le texte lu sur ces photos."
            ]
            .exists)
        joindreCapture("consentement-photos-clair")
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
        XCTAssertTrue(interrupteur.waitForExistence(timeout: 5))
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
        champ.tap()
        if valeur != label {
            champ.typeKey("a", modifierFlags: .command)
        }
        champ.typeText(texte)
        XCTAssertEqual(champ.value as? String, texte)
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
