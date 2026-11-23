#if DEBUG
    import XCTest

    final class EcransRecettesTests: XCTestCase {
        private static let recetteAvecAlternative = """
            Clafoutis aux abricots
            Pour 4 personnes
            Ingrédients :
            6 abricots ou 12 oreillons d’abricots au sirop
            Préparation :
            Coupez les abricots et faites-les cuire.
            """

        private static let recette = """
            Crêpes maison
            Ingrédients :
            2 œufs
            250 g de farine
            Lait, au goût

            Préparation :
            1. Mélangez les œufs et la farine.
            2. Versez le lait et cuisez les crêpes.
            3. Retournez chaque crêpe après une minute.
            4. Réservez les crêpes cuites sur une assiette.
            5. Servez les crêpes encore chaudes.
            """

        @MainActor
        func testInstructionsRecettesVidesVisiblesEtDefilables() throws {
            let explication = "Importez une première recette. Depuis Safari ou Messages : Partager, puis Persillade."
            for (nom, arguments) in [("clair", []), ("sombre", ["-recettes-sombre"])] {
                let app = lancer(arguments: arguments)
                let message = app.staticTexts[explication]
                let coller = app.buttons["Coller un lien ou un texte"]
                XCTAssertTrue(message.waitForExistence(timeout: 5))
                XCTAssertLessThanOrEqual(message.frame.maxY, coller.frame.minY - 4, nom)
                joindre("recettes-vide-\(nom)")
                try auditer(app)
                app.terminate()
            }

            let app = lancer(arguments: ["-recettes-ax5"])
            let message = app.staticTexts[explication]
            let coller = app.buttons["Coller un lien ou un texte"]
            XCTAssertTrue(message.waitForExistence(timeout: 5))
            let bordActions = coller.frame.minY - 4
            for _ in 0..<4 {
                if message.frame.maxY <= bordActions + 0.5 { break }
                app.scrollViews.firstMatch.swipeUp(velocity: .slow)
            }
            XCTAssertTrue(message.isHittable)
            XCTAssertLessThanOrEqual(message.frame.maxY, bordActions + 0.5)
            try auditer(app)
        }

        @MainActor
        func testCollageCorrectionPortionsEtRelance() throws {
            let app = lancer()
            joindre("recettes-vide-clair")
            try auditer(app)
            coller(app)
            joindre("destination-clair")
            try auditer(app)
            verifierActionsDestination(app)
            app.navigationBars["Contenu reçu"].buttons["Fermer"].tap()
            verifierPlancheAvecReception(app, doitDefiler: false)
            joindre("contenu-recu-clair")
            app.tabBars.firstMatch.buttons["Semaine"].tap()
            XCTAssertFalse(app.buttons["Ouvrir"].exists)
            app.tabBars.firstMatch.buttons["Recettes"].tap()
            app.buttons["Ouvrir"].tap()
            ouvrirCorrection(app)

            XCTAssertEqual(app.textFields["titre-correction"].value as? String, "Crêpes maison")
            XCTAssertTrue(app.staticTexts["Absent du texte, 4 par défaut"].exists)
            XCTAssertTrue(app.buttons["Texte reçu"].exists)
            let oeufs = app.buttons["œufs"]
            let farine = app.buttons["farine"]
            XCTAssertTrue(oeufs.exists && farine.exists)
            XCTAssertEqual(farine.frame.midY - oeufs.frame.midY, 46, accuracy: 2)
            joindre("Correction-clair")
            try auditer(app)

            enregistrer(app)
            XCTAssertEqual(app.staticTexts["titre-fiche"].label, "Crêpes maison")
            XCTAssertEqual(app.staticTexts["nombre-portions"].label, "4 portions")
            XCTAssertTrue(
                app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "au goût")).firstMatch.exists)
            verifierLargeurActionCuisine(app)
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
            joindre("recettes-clair")
            try auditer(app)
            entree.tap()
            XCTAssertTrue(app.staticTexts["Dans la semaine"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.staticTexts["nombre-portions"].label, "4 portions")

            app.buttons["Options de la recette"].tap()
            app.buttons["Supprimer"].tap()
            let confirmation = app.alerts["Supprimer cette recette ?"]
            XCTAssertTrue(confirmation.waitForExistence(timeout: 5))
            XCTAssertTrue(confirmation.staticTexts["Retirée aussi de la semaine."].exists)
            joindre("fiche-suppression-clair")
            confirmation.buttons["Annuler"].tap()

            app.buttons["Retirer de la semaine"].tap()
            XCTAssertTrue(app.buttons["Ajouter à la semaine"].waitForExistence(timeout: 5))
            app.buttons["Options de la recette"].tap()
            app.buttons["Supprimer"].tap()
            XCTAssertTrue(confirmation.waitForExistence(timeout: 5))
            XCTAssertFalse(confirmation.staticTexts["Retirée aussi de la semaine."].exists)
            confirmation.buttons["Supprimer"].tap()
            XCTAssertTrue(app.buttons["Coller un lien ou un texte"].waitForExistence(timeout: 5))
        }

        @MainActor
        func testNomEtQuantiteVisiblesALOuvertureDeLIngredient() {
            let app = lancer()
            coller(app)
            ouvrirCorrection(app)
            app.buttons["farine"].tap()

            let clavier = app.keyboards.firstMatch
            XCTAssertTrue(clavier.waitForExistence(timeout: 8))
            let nom = app.textFields["nom-ingredient"]
            let quantite = app.textFields["editeur-quantite"]
            verifierChampsAuDessusDuClavier([nom, quantite], clavier: clavier)
            joindre("Correction-quantite-visible")

            let depart = app.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.45))
            let arrivee = clavier.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.55))
            depart.press(forDuration: 0.05, thenDragTo: arrivee)
            XCTAssertTrue(clavier.waitForNonExistence(timeout: 5))
            quantite.tap()
            XCTAssertTrue(clavier.waitForExistence(timeout: 8))
            verifierChampsAuDessusDuClavier([nom, quantite], clavier: clavier)
            joindre("Correction-quantite-focus")
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
                verifierActionsDestination(app)
                joindre("Destination-longue-\(nom)")
                app.terminate()
            }
        }

        @MainActor
        func testDestinationLienPresenteHoteAvantApercu() throws {
            let lien = "https://cuisine.exemple.test/recettes/crepes-maison"
            let app = lancer(texte: lien)
            coller(app)
            let hote = app.staticTexts["hote-destination"]
            let apercu = app.staticTexts["apercu-destination"]
            XCTAssertTrue(hote.exists)
            XCTAssertEqual(hote.label, "Site source : cuisine.exemple.test")
            XCTAssertEqual(apercu.label, "Adresse du lien : \(lien)")
            XCTAssertLessThan(hote.frame.maxY, apercu.frame.minY)
            verifierActionsDestination(app)
            joindre("Destination-lien-clair")
            try auditer(app)
            app.buttons["import-destination-abandonner"].tap()
            XCTAssertTrue(app.staticTexts["Abandonner ce contenu ?"].waitForExistence(timeout: 5))
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
        func testCapturesSombreAX3EtAX5() throws {
            for (nom, argument) in [("sombre", "-recettes-sombre"), ("AX3", "-recettes-ax3"), ("AX5", "-recettes-ax5")]
            {
                let app = lancer(arguments: [argument])
                joindre("recettes-vide-\(nom)")
                try auditer(app)
                coller(app)
                verifierActionsDestination(app)
                joindre("destination-\(nom)")
                try auditer(app)
                app.navigationBars["Contenu reçu"].buttons["Fermer"].tap()
                let ouvrir = app.buttons["ouvrir-contenu-recu"]
                XCTAssertTrue(ouvrir.wait(for: \.isHittable, toEqual: true, timeout: 5))
                joindre("contenu-recu-\(nom)")
                verifierPlancheAvecReception(app, doitDefiler: nom.hasPrefix("AX"))
                if nom == "AX5" { joindre("contenu-recu-defile-AX5") }
                ouvrir.tap()
                ouvrirCorrection(app)
                if nom.hasPrefix("AX") {
                    XCTAssertFalse(
                        app.descendants(matching: .any).matching(identifier: "extrait-source").firstMatch.exists, nom)
                }
                joindre("Correction-\(nom)")
                try auditer(app)
                enregistrer(app)
                joindre("Fiche-\(nom)")
                let action = app.buttons["Ajouter à la semaine"]
                let cuisiner = app.buttons["ouvrir-cuisine"]
                XCTAssertTrue(action.exists, nom)
                XCTAssertTrue(cuisiner.exists, nom)
                XCTAssertGreaterThanOrEqual(action.frame.height, 44, nom)
                verifierLargeurActionCuisine(app)
                let derniere = app.staticTexts.containing(
                    NSPredicate(format: "label CONTAINS %@", "Servez les crêpes")
                ).firstMatch
                for _ in 0..<7 {
                    if derniere.isHittable, derniere.frame.maxY <= action.frame.minY { break }
                    app.scrollViews.firstMatch.swipeUp(velocity: .slow)
                }
                XCTAssertTrue(derniere.isHittable, nom)
                XCTAssertLessThanOrEqual(derniere.frame.maxY, action.frame.minY, nom)
                XCTAssertEqual(action.frame.minX - app.frame.minX, 21, accuracy: 2, nom)
                XCTAssertEqual(app.frame.maxX - cuisiner.frame.maxX, 21, accuracy: 2, nom)
                if cuisiner.frame.minY >= action.frame.maxY {
                    XCTAssertEqual(action.frame.width, cuisiner.frame.width, accuracy: 2, nom)
                } else {
                    XCTAssertEqual(action.frame.midY, cuisiner.frame.midY, accuracy: 2, nom)
                    XCTAssertGreaterThanOrEqual(cuisiner.frame.width, 100, nom)
                }
                joindre("Fiche-dernière-ligne-\(nom)")
                try auditer(app)

                cuisiner.tap()
                let suivante = app.buttons["suivante-cuisine"]
                XCTAssertTrue(suivante.waitForExistence(timeout: 5))
                XCTAssertEqual(suivante.label, "Suivante")
                let ingredients = app.buttons["ingredients-cuisine"]
                XCTAssertTrue(ingredients.isHittable)
                if nom == "AX5" {
                    XCTAssertGreaterThan(ingredients.frame.width, app.buttons["precedente-cuisine"].frame.width)
                }
                joindre("cuisine-\(nom)")
                try auditer(app)
                ingredients.tap()
                let mention = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "au goût")).firstMatch
                for _ in 0..<4 {
                    if mention.isHittable { break }
                    app.scrollViews.firstMatch.swipeUp(velocity: .slow)
                }
                XCTAssertTrue(mention.isHittable, nom)
                joindre("cuisine-ingredients-\(nom)")
                app.buttons["fermer-ingredients-cuisine"].tap()
                XCTAssertTrue(suivante.wait(for: \.isHittable, toEqual: true, timeout: 5))
                if nom == "AX5" {
                    for _ in 1..<5 { suivante.tap() }
                    XCTAssertTrue(suivante.wait(for: \.label, toEqual: "Terminer", timeout: 5))
                    joindre("cuisine-fin-AX5")
                }
                app.terminate()
            }
        }

        @MainActor
        func testAlternativesDeLaCorrectionAuxCourses() {
            let mention = "ou 12 oreillons d’abricots au sirop"
            for (nom, arguments) in [("clair", []), ("sombre", ["-recettes-sombre"]), ("AX5", ["-recettes-ax5"])] {
                let app = lancer(arguments: arguments, texte: Self.recetteAvecAlternative)
                coller(app)
                ouvrirCorrection(app)
                let correction = app.buttons["abricots"]
                defilerPourVoir(correction, dans: app)
                XCTAssertTrue((correction.value as? String)?.contains(mention) == true, nom)
                joindre("alternatives-correction-\(nom)")

                enregistrer(app)
                let fiche = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", mention)).firstMatch
                defilerPourVoir(fiche, dans: app)
                joindre("alternatives-fiche-\(nom)")
                app.buttons["Ajouter à la semaine"].tap()
                XCTAssertTrue(app.buttons["Retirer de la semaine"].waitForExistence(timeout: 5))
                app.navigationBars.firstMatch.buttons.firstMatch.tap()
                app.tabBars.firstMatch.buttons["Semaine"].tap()
                app.buttons["Faire la liste"].tap()
                let course = app.buttons["article-abricot"]
                defilerPourVoir(course, dans: app)
                XCTAssertTrue((course.value as? String)?.contains(mention) == true, nom)
                XCTAssertFalse(
                    app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "article-oreillon"))
                        .firstMatch.exists)
                joindre("alternatives-courses-\(nom)")
                app.terminate()
            }
        }

        @MainActor
        func testCorrectionDesAlternatives() {
            let app = lancer(texte: Self.recetteAvecAlternative)
            coller(app)
            ouvrirCorrection(app)
            let principal = app.buttons["abricots"]
            defilerPourVoir(principal, dans: app)
            principal.tap()
            let ajouter = app.buttons["Ajouter une alternative"]
            defilerPourVoir(ajouter, dans: app)
            ajouter.tap()
            let champ = app.textFields["nom-alternative"]
            XCTAssertTrue(champ.waitForExistence(timeout: 5))
            champ.tap()
            champ.typeText("compote")
            app.navigationBars["Alternative"].buttons["Valider"].tap()

            let compote = app.buttons["ou compote"]
            defilerPourVoir(compote, dans: app)
            compote.tap()
            app.buttons["Modifier"].tap()
            XCTAssertTrue(champ.waitForExistence(timeout: 5))
            champ.tap()
            champ.typeText(" nature")
            app.navigationBars["Alternative"].buttons["Valider"].tap()
            let compoteNature = app.buttons["ou compote nature"]
            defilerPourVoir(compoteNature, dans: app)
            compoteNature.tap()
            app.buttons["Utiliser comme ingrédient principal"].tap()
            XCTAssertEqual(app.textFields["nom-ingredient"].value as? String, "compote nature")

            let abricots = app.buttons["ou 6 abricots"]
            defilerPourVoir(abricots, dans: app)
            abricots.tap()
            app.buttons["Supprimer l’alternative"].tap()
            XCTAssertFalse(abricots.exists)
            enregistrer(app)
            let plat = app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "ou 12 oreillons d’abricots au sirop")
            ).firstMatch
            defilerPourVoir(plat, dans: app)
            XCTAssertTrue(plat.label.contains("compote nature"))
        }

        @MainActor
        private func defilerPourVoir(_ element: XCUIElement, dans app: XCUIApplication) {
            let debut = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.77))
            let fin = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.35))
            for _ in 0..<8 where !element.isHittable {
                debut.press(forDuration: 0.05, thenDragTo: fin, withVelocity: .slow, thenHoldForDuration: 0.05)
            }
            XCTAssertTrue(element.isHittable, app.debugDescription)
        }

        @MainActor
        func testCorrectionTitreLongEtDerniereActionAX5() throws {
            let titre = "Çà, gâteau façon pâtissière à l'œuf poché"
            let etapeLongue = String(
                repeating: "Servez les crêpes encore chaudes avec la garniture de votre choix. ", count: 3
            ).trimmingCharacters(in: .whitespaces)
            let texte = Self.recette
                .replacingOccurrences(of: "Crêpes maison", with: titre)
                .replacingOccurrences(of: "Servez les crêpes encore chaudes.", with: etapeLongue)
            let app = lancer(arguments: ["-recettes-ax5"], texte: texte)
            coller(app)
            ouvrirCorrection(app)
            let champ = app.textFields["titre-correction"]
            XCTAssertTrue(champ.waitForExistence(timeout: 5))
            XCTAssertEqual(champ.value as? String, titre)
            joindre("Correction-titre-long-AX5")

            let ajouter = app.buttons["Ajouter une étape"]
            let etape = app.descendants(matching: .any).matching(identifier: "texte-etape-correction").matching(
                NSPredicate(format: "value == %@", etapeLongue)
            ).firstMatch
            let debut = app.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.86))
            let fin = app.coordinate(withNormalizedOffset: CGVector(dx: 0.98, dy: 0.25))
            var hauteur: CGFloat = 0
            for _ in 0..<12 {
                if etape.exists { hauteur = max(hauteur, etape.frame.height) }
                if ajouter.isHittable { break }
                debut.press(forDuration: 0.05, thenDragTo: fin, withVelocity: .fast, thenHoldForDuration: 0.1)
            }
            XCTAssertTrue(ajouter.isHittable)
            XCTAssertGreaterThan(hauteur, app.frame.height / 2)
            XCTAssertTrue(app.buttons["enregistrer-correction"].isHittable)
            joindre("Correction-derniere-action-AX5")
            try auditer(app)
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
        func testRecettesEtCuisineEnPaysage() throws {
            let app = lancer()
            coller(app)
            ouvrirCorrection(app)
            enregistrer(app)

            let appareil = XCUIDevice.shared
            appareil.orientation = .landscapeLeft
            let fenetre = app.windows.firstMatch
            defer {
                appareil.orientation = .portrait
                let portrait = NSPredicate { _, _ in fenetre.frame.height > fenetre.frame.width }
                wait(for: [XCTNSPredicateExpectation(predicate: portrait, object: fenetre)], timeout: 8)
            }
            let paysage = NSPredicate { _, _ in fenetre.frame.width > fenetre.frame.height }
            wait(for: [XCTNSPredicateExpectation(predicate: paysage, object: fenetre)], timeout: 8)
            let cuisiner = app.buttons["ouvrir-cuisine"]
            XCTAssertTrue(cuisiner.isHittable)
            joindre("fiche-paysage")
            cuisiner.tap()
            let fermer = app.buttons["fermer-cuisine"]
            XCTAssertTrue(fermer.waitForExistence(timeout: 5))
            XCTAssertTrue(app.buttons["suivante-cuisine"].isHittable)
            joindre("cuisine-paysage")
            try auditer(app)
            fermer.tap()
            XCTAssertTrue(cuisiner.wait(for: \.isHittable, toEqual: true, timeout: 5))
            app.navigationBars.buttons.firstMatch.tap()
            let recette = app.descendants(matching: .any)["ouvrir-recette"].firstMatch
            XCTAssertTrue(recette.wait(for: \.isHittable, toEqual: true, timeout: 5))
            joindre("recettes-paysage")
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
            XCUIDevice.shared.orientation = .portrait
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
            XCTAssertTrue(app.navigationBars["Contenu reçu"].waitForExistence(timeout: 5), app.debugDescription)
        }

        @MainActor
        private func verifierActionsDestination(_ app: XCUIApplication) {
            let recette = app.buttons["import-destination-recette"]
            let articles = app.buttons["Articles de courses"]
            let abandonner = app.buttons["import-destination-abandonner"]
            for action in [recette, articles, abandonner] {
                XCTAssertTrue(action.wait(for: \.isHittable, toEqual: true, timeout: 5))
                XCTAssertEqual(action.frame.width, recette.frame.width, accuracy: 1)
                XCTAssertGreaterThanOrEqual(action.frame.height, 44)
            }
            XCTAssertLessThanOrEqual(app.staticTexts["apercu-destination"].frame.maxY, recette.frame.minY)
            XCTAssertLessThan(recette.frame.maxY, articles.frame.minY)
            XCTAssertLessThan(articles.frame.maxY, abandonner.frame.minY)
        }

        @MainActor
        private func verifierPlancheAvecReception(_ app: XCUIApplication, doitDefiler: Bool) {
            let titre = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "est vide.")).firstMatch
            let message = app.staticTexts[
                "Importez une première recette. Depuis Safari ou Messages : Partager, puis Persillade."]
            let coller = app.buttons["Coller un lien ou un texte"]
            XCTAssertTrue(app.buttons["ouvrir-contenu-recu"].wait(for: \.isHittable, toEqual: true, timeout: 5))
            XCTAssertTrue(titre.waitForExistence(timeout: 5))
            XCTAssertTrue(message.waitForExistence(timeout: 5))
            if doitDefiler {
                for _ in 0..<5 {
                    if message.isHittable, message.frame.maxY <= coller.frame.minY { break }
                    app.scrollViews.firstMatch.swipeUp(velocity: .slow)
                }
            } else {
                XCTAssertTrue(titre.isHittable)
                XCTAssertLessThanOrEqual(titre.frame.maxY, message.frame.minY)
            }
            XCTAssertTrue(message.isHittable)
            XCTAssertLessThanOrEqual(message.frame.maxY, coller.frame.minY)
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
        private func verifierLargeurActionCuisine(_ app: XCUIApplication) {
            let semaine = app.buttons["Ajouter à la semaine"]
            let cuisiner = app.buttons["ouvrir-cuisine"]
            XCTAssertGreaterThanOrEqual(cuisiner.frame.width + 1, semaine.frame.width)
        }

        @MainActor
        private func verifierChampsAuDessusDuClavier(_ champs: [XCUIElement], clavier: XCUIElement) {
            for champ in champs {
                XCTAssertTrue(champ.wait(for: \.isHittable, toEqual: true, timeout: 5), champ.debugDescription)
                XCTAssertLessThanOrEqual(champ.frame.maxY, clavier.frame.minY, champ.debugDescription)
            }
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
