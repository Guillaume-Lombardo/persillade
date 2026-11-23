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
            XCTAssertTrue((farine.value as? String)?.contains("1,125") == true)
            let oeufs = bouton("article-oeuf", dans: app)
            XCTAssertEqual(oeufs.value as? String, "3, À envoyer")
            farine.tap()
            bouton("modifier-quantite-courses", dans: app).tap()
            let quantite = app.textFields["editeur-quantite"]
            XCTAssertTrue(quantite.waitForExistence(timeout: 10))
            quantite.tap()
            quantite.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4) + "1500")
            XCTAssertEqual(quantite.value as? String, "1500")
            bouton("Valider", dans: app).tap()
            let fermerDetail = app.navigationBars["Farine"].buttons["Fermer"]
            XCTAssertTrue(fermerDetail.waitForExistence(timeout: 10))
            fermerDetail.tap()
            XCTAssertTrue(farine.waitForExistence(timeout: 10))
            XCTAssertTrue((farine.value as? String)?.contains("1,5") == true)

            bouton("Ne pas envoyer œufs", dans: app).tap()
            let remettre = bouton("Remettre œufs", dans: app)
            XCTAssertTrue((oeufs.value as? String)?.contains("Ne sera pas envoyé") == true)
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
            XCTAssertTrue(app.staticTexts["2 articles envoyés"].waitForExistence(timeout: 10))
            bouton("Terminé", dans: app).tap()
            verifierDestinationVerrouillee(dans: app)
            let farine = bouton("article-farine", dans: app)
            XCTAssertEqual(farine.value as? String, "1,5 kg, Envoyé")
            XCTAssertFalse(app.staticTexts["Envoyé"].exists)

            bouton("Ajouter", dans: app).tap()
            bouton("Ajouter un article", dans: app).tap()
            let saisie = app.textFields["ajout-saisie-courses"]
            XCTAssertTrue(saisie.waitForExistence(timeout: 10))
            saisie.tap()
            saisie.typeText("2 bananes")
            bouton("ajout-valider-courses", dans: app).tap()
            XCTAssertTrue(app.staticTexts["Article ajouté"].waitForExistence(timeout: 10))
            let bananesEnvoyees = app.buttons.matching(
                NSPredicate(format: "label == %@ AND value CONTAINS %@", "bananes", "Envoyé")
            ).firstMatch
            XCTAssertTrue(bananesEnvoyees.waitForExistence(timeout: 10))
            bouton("Terminé", dans: app).tap()

            bouton("courses-renvoyer", dans: app).tap()
            XCTAssertTrue(app.staticTexts["Rien à ajouter"].waitForExistence(timeout: 10))
            XCTAssertTrue(
                app.descendants(matching: .any)["Aucun ajout nécessaire · 3"].firstMatch.waitForExistence(timeout: 10))
            bouton("Terminé", dans: app).tap()

            XCTAssertEqual(farine.value as? String, "1,5 kg, Rien à ajouter")

            ouvrirOnglet("Semaine", dans: app)
            bouton("Augmenter les portions de Crêpes", dans: app).tap()
            XCTAssertTrue(app.staticTexts["Liste faite avant ce changement"].waitForExistence(timeout: 10))
            bouton("Refaire la liste", dans: app).tap()
            bouton("Remplacer", dans: app).tap()
            XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.buttons["article-banane"].waitForNonExistence(timeout: 10))
            XCTAssertTrue((bouton("article-farine", dans: app).value as? String)?.contains("1,625") == true)
        }

        @MainActor
        func testRefusRappelsAfficheLeCheminEtOuvreReglages() {
            let app = refuserAccesRappels()
            joindreCapture("acces-clair")
            bouton("Ouvrir Réglages", dans: app).tap()
            let reglages = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
            XCTAssertTrue(reglages.wait(for: .runningForeground, timeout: 30))
        }

        @MainActor
        func testLibellesAccesRappelsEnSombreEtAX5() {
            for (nom, argument) in [("sombre", "-courses-sombre"), ("AX5", "-courses-ax5")] {
                let app = refuserAccesRappels([argument])
                let plusTard = bouton("Plus tard", dans: app)
                let reglages = bouton("Ouvrir Réglages", dans: app)
                XCTAssertTrue(plusTard.isHittable)
                XCTAssertTrue(reglages.isHittable)
                if nom == "AX5" {
                    XCTAssertLessThan(plusTard.frame.maxY, reglages.frame.minY)
                    XCTAssertEqual(plusTard.frame.width, reglages.frame.width, accuracy: 2)
                }
                joindreCapture("acces-\(nom)")
                plusTard.tap()
                XCTAssertTrue(reglages.waitForNonExistence(timeout: 5))
                app.terminate()
            }
        }

        @MainActor
        private func refuserAccesRappels(_ arguments: [String] = []) -> XCUIApplication {
            let app = lancer(["-courses-eventkit"] + arguments)
            ouvrirOnglet("Semaine", dans: app)
            faireListe(dans: app)
            bouton("Choisir une liste", dans: app).tap()
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let refuser = springboard.alerts.buttons.matching(
                NSPredicate(format: "label IN %@", ["Don’t Allow", "Don't Allow", "Ne pas autoriser"])
            ).firstMatch
            XCTAssertTrue(refuser.waitForExistence(timeout: 10), springboard.debugDescription)
            refuser.tap()
            let chemin = app.staticTexts[
                "Autorisez l’accès complet dans Réglages → Apps → Persillade → Rappels. "
                    + "Votre liste est conservée, rien n’a été envoyé."]
            XCTAssertTrue(chemin.waitForExistence(timeout: 10))
            return app
        }

        @MainActor
        func testCapturesSemaineEtCourses() {
            for (nom, arguments) in [
                ("clair", []), ("sombre", ["-courses-sombre"]), ("AX3", ["-courses-ax3"]), ("AX5", ["-courses-ax5"]),
            ] {
                let app = lancer(arguments)
                ouvrirOnglet("Semaine", dans: app)
                XCTAssertTrue(app.buttons["Faire la liste"].waitForExistence(timeout: 10), nom)
                if nom == "AX5" {
                    let moins = bouton("Diminuer les portions de Crêpes", dans: app)
                    let plus = bouton("Augmenter les portions de Crêpes", dans: app)
                    XCTAssertGreaterThanOrEqual(plus.frame.minX - moins.frame.maxX, 24)
                }
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
        func testCapturesActionsCourses() {
            for (nom, arguments) in [("clair", []), ("sombre", ["-courses-sombre"]), ("AX5", ["-courses-ax5"])] {
                let app = lancer(arguments)
                ouvrirOnglet("Courses", dans: app)
                let ajouter = bouton("Ajouter un article", dans: app)
                XCTAssertFalse(app.buttons["Ajouter"].exists)
                joindreCapture("vide-\(nom)")
                bouton("Plus d’options", dans: app).tap()
                bouton("Articles d’un message", dans: app).tap()
                let fermerImport = app.navigationBars["Articles d’un message"].buttons["Fermer"]
                XCTAssertTrue(fermerImport.wait(for: \.isHittable, toEqual: true, timeout: 5))
                fermerImport.tap()
                XCTAssertTrue(ajouter.wait(for: \.isHittable, toEqual: true, timeout: 5))
                ajouter.tap()
                let saisie = app.textFields["ajout-saisie-courses"]
                XCTAssertTrue(saisie.wait(for: \.isHittable, toEqual: true, timeout: 10))
                XCTAssertEqual(saisie.label, "Nom et quantité")
                XCTAssertEqual(saisie.placeholderValue, "2 pommes")
                XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 10))
                joindreCapture("ajout-initial-\(nom)")
                app.navigationBars["Ajouter un article"].buttons["Fermer"].tap()

                ouvrirOnglet("Semaine", dans: app)
                faireListe(dans: app)
                let oeufs = bouton("article-oeuf", dans: app)
                oeufs.tap()
                let moins = bouton("Diminuer la quantité", dans: app)
                let plus = bouton("Augmenter la quantité", dans: app)
                let valeur = bouton("modifier-quantite-courses", dans: app)
                XCTAssertGreaterThanOrEqual(plus.frame.minX - moins.frame.maxX, 24)
                XCTAssertLessThan(moins.frame.midX, valeur.frame.midX)
                XCTAssertLessThan(valeur.frame.midX, plus.frame.midX)
                XCTAssertTrue(bouton("Ne pas envoyer", dans: app).isHittable)
                XCTAssertTrue(bouton("Retirer", dans: app).isHittable)
                joindreCapture("detail-\(nom)")
                app.navigationBars["Œufs"].buttons["Fermer"].tap()

                bouton("Choisir une liste", dans: app).tap()
                bouton("destination-rappels-maison", dans: app).tap()
                bouton("courses-envoyer", dans: app).tap()
                XCTAssertTrue(app.staticTexts["2 articles envoyés"].waitForExistence(timeout: 10))
                let ouvrirRappels = app.buttons["rapport-ouvrir-rappels"]
                XCTAssertTrue(ouvrirRappels.wait(for: \.isHittable, toEqual: true, timeout: 10))
                joindreCapture("rapport-\(nom)")
                bouton("Terminé", dans: app).tap()
                verifierDestinationVerrouillee(dans: app)
                let renvoyer = bouton("courses-renvoyer", dans: app)
                let ajouterArticle = bouton("Ajouter", dans: app)
                joindreCapture("courses-envoyees-\(nom)")
                XCTAssertEqual(ajouterArticle.frame.midY, renvoyer.frame.midY, accuracy: 2, nom)
                XCTAssertTrue(oeufs.isHittable, nom)
                XCTAssertLessThanOrEqual(oeufs.frame.maxY, min(ajouterArticle.frame.minY, renvoyer.frame.minY), nom)
                renvoyer.tap()
                XCTAssertTrue(app.staticTexts["Rien à ajouter"].waitForExistence(timeout: 10))
                joindreCapture("rapport-renvoi-\(nom)")
                app.terminate()
            }
        }

        @MainActor
        func testRapportEchecMetEnAvantLeReessai() {
            for (nom, arguments) in [("clair", []), ("AX5", ["-courses-ax5"])] {
                let app = lancer(["-courses-envoi-echec"] + arguments)
                ouvrirOnglet("Semaine", dans: app)
                faireListe(dans: app)
                bouton("Choisir une liste", dans: app).tap()
                bouton("destination-rappels-maison", dans: app).tap()
                bouton("courses-envoyer", dans: app).tap()
                XCTAssertTrue(app.staticTexts["Échec de l’envoi"].waitForExistence(timeout: 10))
                let bandeau = app.descendants(matching: .any).matching(
                    NSPredicate(format: "label BEGINSWITH %@", "À réessayer")
                ).firstMatch
                XCTAssertTrue(bandeau.exists, nom)
                XCTAssertTrue(bandeau.label.contains("2"), bandeau.label)
                let reessayer = app.buttons["rapport-reessayer"]
                XCTAssertTrue(reessayer.wait(for: \.isHittable, toEqual: true, timeout: 10))
                XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label == %@", "Réessayer")).count, 1)
                let terminer = bouton("Terminé", dans: app)
                XCTAssertTrue(terminer.isHittable, nom)
                XCTAssertTrue(terminer.frame.midY < reessayer.frame.midY || terminer.frame.midX < reessayer.frame.midX)
                joindreCapture("rapport-echec-\(nom)")
                reessayer.tap()
                XCTAssertTrue(app.staticTexts["2 articles envoyés"].waitForExistence(timeout: 10))
                XCTAssertTrue(reessayer.waitForNonExistence(timeout: 5))
                bouton("Terminé", dans: app).tap()
                XCTAssertTrue(app.navigationBars["Rapport d’envoi"].waitForNonExistence(timeout: 5))
                XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 5))
                app.terminate()
            }
        }

        @MainActor
        func testReessaiPartielEnvoieUniquementLaLigneEnEchec() {
            let app = lancer(["-courses-envoi-echec-partiel"])
            ouvrirOnglet("Semaine", dans: app)
            faireListe(dans: app)
            bouton("Choisir une liste", dans: app).tap()
            bouton("destination-rappels-maison", dans: app).tap()
            bouton("courses-envoyer", dans: app).tap()
            XCTAssertTrue(app.staticTexts["1 envoyé, 1 échec"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.buttons["rapport-ouvrir-rappels"].isHittable)
            let reessayer = bouton("rapport-reessayer", dans: app)
            reessayer.tap()
            XCTAssertTrue(app.staticTexts["1 article envoyé"].waitForExistence(timeout: 10))
            XCTAssertTrue(reessayer.waitForNonExistence(timeout: 5))
            XCTAssertFalse(app.descendants(matching: .any)["Aucun ajout nécessaire · 1"].firstMatch.exists)
            bouton("Terminé", dans: app).tap()
            XCTAssertTrue(app.navigationBars["Rapport d’envoi"].waitForNonExistence(timeout: 5))
            XCTAssertTrue((bouton("article-farine", dans: app).value as? String)?.contains("Envoyé") == true)
            XCTAssertTrue((bouton("article-oeuf", dans: app).value as? String)?.contains("Envoyé") == true)
        }

        @MainActor
        private func verifierDestinationVerrouillee(dans app: XCUIApplication) {
            let id = "courses-liste-verrouillee"
            let destination = app.descendants(matching: .any)[id].firstMatch
            XCTAssertTrue(destination.waitForExistence(timeout: 10))
            XCTAssertEqual(destination.label, "Liste Rappels verrouillée")
            XCTAssertEqual(destination.value as? String, "Maison")
            XCTAssertFalse(app.buttons[id].exists)
        }

        @MainActor
        func testDerniereBandeSemaineAuDessusDeLaBarreEnPaysage() {
            let app = lancer()
            ouvrirOnglet("Semaine", dans: app)
            let appareil = XCUIDevice.shared
            appareil.orientation = .landscapeLeft
            let fenetre = app.windows.firstMatch
            defer {
                appareil.orientation = .portrait
                let portrait = NSPredicate { _, _ in fenetre.frame.height > fenetre.frame.width }
                wait(for: [XCTNSPredicateExpectation(predicate: portrait, object: fenetre)], timeout: 8)
            }
            let paysage = NSPredicate { _, _ in fenetre.frame.width > fenetre.frame.height }
            let rotation = XCTNSPredicateExpectation(predicate: paysage, object: fenetre)
            XCTAssertEqual(XCTWaiter.wait(for: [rotation], timeout: 8), .completed)
            joindreCapture("semaine-paysage")
            let faireListe = bouton("Faire la liste", dans: app)
            let bande = bouton("Gaufres", dans: app)
            let liste = app.collectionViews.firstMatch
            for _ in 0..<4 {
                if bande.isHittable, bande.frame.maxY <= faireListe.frame.minY { break }
                let depart = liste.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
                let arrivee = liste.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.27))
                depart.press(forDuration: 0.05, thenDragTo: arrivee)
            }
            XCTAssertTrue(bande.isHittable)
            XCTAssertLessThanOrEqual(bande.frame.maxY, faireListe.frame.minY)
            joindreCapture("semaine-paysage-bas")
            faireListe.tap()
            XCTAssertTrue(app.navigationBars["Courses"].waitForExistence(timeout: 5))
            joindreCapture("courses-paysage")
        }

        @MainActor
        func testAuditAccessibiliteSemaineEtCourses() throws {
            let app = lancer()
            ouvrirOnglet("Semaine", dans: app)
            XCTAssertTrue(app.buttons["Faire la liste"].waitForExistence(timeout: 10))
            XCTAssertEqual(bouton("Augmenter les portions de Crêpes", dans: app).value as? String, "4 portions")
            let recette = bouton("Crêpes", dans: app)
            recette.coordinate(withNormalizedOffset: CGVector(dx: 0.90, dy: 0.5)).tap()
            let titre = app.staticTexts["titre-fiche"]
            XCTAssertTrue(titre.waitForExistence(timeout: 5))
            XCTAssertEqual(titre.label, "Crêpes")
            app.navigationBars.firstMatch.buttons.firstMatch.tap()
            ouvrirOnglet("Semaine", dans: app)
            XCTAssertTrue(app.buttons["Faire la liste"].waitForExistence(timeout: 5))
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
            if arguments.contains("-courses-eventkit") { app.resetAuthorizationStatus(for: .reminders) }
            XCUIDevice.shared.orientation = .portrait
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
