import Foundation
import PersilladeCore
import Testing

private func q(_ texte: String) throws -> Quantite {
    try Quantite(texte: texte)
}

private func article(_ nom: String, _ valeur: String? = nil, _ unite: Unite? = nil) throws -> ArticleCourses {
    try ArticleCourses(nom: nom, quantite: valeur.map(q), unite: unite)
}

private func recette(_ articles: [ArticleCourses], portions: Int = 4) throws -> Recette {
    let ingredients = try articles.map {
        try Ingredient(nom: $0.nom, quantite: $0.quantite, unite: $0.unite, texteOrigine: $0.nom)
    }
    return try Recette(
        titre: "Recette", portions: portions, ingredients: ingredients, etapes: ["Préparer"], texteSource: "")
}

private func preparer(_ recettes: [Recette], portions: Int) throws -> SelectionSemaine.Preparation {
    var selection = SelectionSemaine()
    for recette in recettes {
        selection.selectionner(try .init(recetteId: recette.id, portions: portions))
    }
    return try selection.preparer(recettes: recettes)
}

@Suite struct SelectionSemaineTests {
    @Test func portionsStrictementPositivesEtDernierChoixParRecette() throws {
        let id = UUID()
        for portions in [0, -1] {
            #expect(throws: SelectionSemaine.Erreur.portionsNonPositives) {
                try SelectionSemaine.Choix(recetteId: id, portions: portions)
            }
        }
        var selection = SelectionSemaine()
        selection.selectionner(try .init(recetteId: id, portions: 1))
        selection.selectionner(try .init(recetteId: id, portions: 2))
        #expect(selection.choix.map(\.portions) == [2])
        selection.deselectionner(id)
        #expect(selection.choix.isEmpty)
    }

    @Test func retireEtSignaleLesRecettesSupprimees() throws {
        let presente = try recette([article("sel")])
        let absente = UUID()
        var selection = SelectionSemaine()
        selection.selectionner(try .init(recetteId: absente, portions: 2))
        selection.selectionner(try .init(recetteId: presente.id, portions: 3))
        let preparation = try selection.preparer(recettes: [presente])
        #expect(preparation.recettesAbsentes == [absente])
        #expect(selection.choix.map(\.recetteId) == [presente.id])
        #expect(preparation.contributions.map(\.recetteId) == [presente.id])
        #expect(preparation.contributions.first?.article.quantite == nil)
        #expect(try selection.preparer(recettes: [presente]).recettesAbsentes.isEmpty)
    }

    @Test func prorataExactEtOeufEtDemiAfficheDeuxPourUneRecetteSeule() throws {
        let entree = try recette([article("œufs", "2", .piece), article("huile", "1/2"), article("farine", "1/3", .kg)])
        let preparation = try preparer([entree], portions: 3)
        let oeufs = try #require(preparation.contributions.first)
        #expect(oeufs.article.quantite == (try q("3/2")))
        #expect(try oeufs.quantitePourRecette == Quantite(2))
        #expect(try preparation.contributions[1].quantitePourRecette == q("3/8"))
        #expect(try preparation.contributions.last?.quantitePourRecette == q("1/4"))
    }

    @Test func troisContributionsDUnTiersDOeufDonnentUnOeuf() throws {
        let recettes = try (0..<3).map { _ in try recette([article("œufs", "1", .piece)], portions: 3) }
        var liste = ListeCourses()
        _ = try liste.generer(preparer(recettes, portions: 1))
        #expect(liste.lignes.count == 1)
        #expect(liste.lignes.first?.quantite == Quantite(1))
        #expect(try liste.lignes.first?.titreCourses == "œufs 1")
        #expect(liste.lignes.first?.origines.map(\.ref) == recettes.map(\.id))
    }

    @Test func scenarioUnDeuxFoisUnOeufEtDemiEtFarineAffichesApresFusion() throws {
        let premiere = try recette([article("œufs", "2", .piece), article("farine", "500", .g)])
        let seconde = try recette([article("œufs", "2", .piece), article("farine", "1", .kg)])
        var liste = ListeCourses()
        _ = try liste.generer(preparer([premiere, seconde], portions: 3))
        #expect(try liste.lignes.map { try $0.titreCourses } == ["œufs 3", "farine 1,125 kg"])
        #expect(liste.lignes.map(\.quantite) == [Quantite(3), Quantite(1_125)])
    }
}

@Suite struct FusionCoursesTests {
    @Test func unitesComparablesConvertiesPuisAdditionnees() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("farine", "1", .kg))
        try liste.ajouter(article("farine", "500", .g))
        try liste.ajouter(article("lait", "25", .cl))
        try liste.ajouter(article("lait", "100", .ml))
        try liste.ajouter(article("lait", "1", .l))
        try liste.ajouter(article("tomates", "1", .autre("boîte")))
        try liste.ajouter(article("tomate", "2", .autre("Boîtes")))
        #expect(liste.lignes.map(\.quantite) == [Quantite(1_500), Quantite(1_350), Quantite(3)])
        #expect(liste.lignes.map(\.unite) == [.g, .ml, .autre("boîte")])
    }

    @Test func unitesNonComparablesEtVariantesDeNomRestentDistinctes() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("tomates", "2", .piece))
        try liste.ajouter(article("tomate", "300", .g))
        try liste.ajouter(article("tomates cerises", "2", .piece))
        try liste.ajouter(article("huile", "2", .cas))
        try liste.ajouter(article("huile", "10", .ml))
        #expect(liste.lignes.map(\.nomNormalise) == ["tomate", "tomate", "tomate cerise", "huile", "huile"])
        #expect(liste.lignes.map(\.unite) == [.piece, .g, .piece, .cas, .ml])
    }

    @Test func deuxSansQuantiteUneLigneAvecLibelleEtOrigines() throws {
        var liste = ListeCourses()
        let ref = UUID()
        let message = UUID()
        try liste.ajouter(article("Œufs"), ref: ref)
        _ = try liste.integrer([article("oeuf"), article("œufs")], messageId: message)
        let ligne = try #require(liste.lignes.first)
        #expect(liste.lignes.count == 1)
        #expect(try ligne.titreCourses == "Œufs")
        #expect(ligne.quantite == nil)
        #expect(ligne.unite == nil)
        #expect(ligne.origines.map(\.type) == [.manuel, .message])
        #expect(ligne.origines.map(\.ref) == [ref, message])
    }

    @Test(arguments: [true, false]) func uneSeuleQuantiteEstConserveeDansLesDeuxOrdres(inverser: Bool) throws {
        var liste = ListeCourses()
        let brut = try article("Tomates")
        let compte = try article("tomate", "3")
        for entree in inverser ? [compte, brut] : [brut, compte] {
            try liste.ajouter(entree)
        }
        #expect(liste.lignes.count == 1)
        #expect(liste.lignes.first?.libelle == (inverser ? "tomate" : "Tomates"))
        #expect(liste.lignes.first?.quantite == Quantite(3))
        #expect(liste.lignes.first?.unite == .piece)
    }

    @Test func ajoutApresAffichageArrondiRepartDeLaFractionExacte() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("œufs", "3/2", .piece))
        #expect(try liste.lignes.first?.quantiteArrondie == Quantite(2))
        try liste.ajouter(article("œufs", "3/2", .piece))
        #expect(liste.lignes.first?.quantite == Quantite(3))
        #expect(try liste.lignes.first?.quantiteArrondie == Quantite(3))
    }

    @Test(arguments: [Unite.g, .ml]) func grammesEtMillilitresArrondisAuPlusProcheMinimumUn(unite: Unite) throws {
        var liste = ListeCourses()
        try liste.ajouter(article("a", "0,01", unite))
        try liste.ajouter(article("b", "2,49", unite))
        try liste.ajouter(article("c", "2,50", unite))
        #expect(try liste.lignes.map { try $0.quantiteArrondie } == [Quantite(1), Quantite(2), Quantite(3)])
    }

    @Test(arguments: [Unite.cas, .cac, .autre("boîte")]) func cuilleresEtAutresArrondiesAuQuartSuperieur(unite: Unite)
        throws
    {
        var liste = ListeCourses()
        try liste.ajouter(article("a", "1/3", unite))
        try liste.ajouter(article("b", "3/4", unite))
        try liste.ajouter(article("c", "1/5", unite))
        #expect(try liste.lignes.map { try $0.quantiteArrondie } == [q("1/2"), q("3/4"), q("1/4")])
    }

    @Test func formatFrancaisExactSeuilTroisDecimalesEtComplement() throws {
        #expect(try formaterQuantiteCourses(q("999"), unite: .g) == "999 g")
        #expect(try formaterQuantiteCourses(q("1000"), unite: .g) == "1 kg")
        #expect(try formaterQuantiteCourses(q("1125"), unite: .g) == "1,125 kg")
        #expect(try formaterQuantiteCourses(q("1000,5"), unite: .g) == "1000,5 g")
        #expect(try formaterQuantiteCourses(q("999"), unite: .ml) == "999 ml")
        #expect(try formaterQuantiteCourses(q("1000"), unite: .ml) == "1 l")
        #expect(try formaterQuantiteCourses(q("1500"), unite: .ml) == "1,5 l")
        #expect(try formaterQuantiteCourses(q("1000,001"), unite: .ml) == "1000,001 ml")
        #expect(try formaterQuantiteCourses(q("0,1"), unite: .cas) == "0,1 cas")
        #expect(try formaterQuantiteCourses(q("3"), unite: .piece) == "3")
    }
}

@Suite struct ListeCoursesTests {
    @Test func nouvelleListeVideOuConfirmeeReinitialiseIdLignesEtEnvoi() throws {
        var liste = ListeCourses()
        let initial = liste.id
        _ = liste.nouvelleListe()
        #expect(liste.id != initial)
        try liste.ajouter(article("sel"))
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let envoyee = liste
        #expect(liste.nouvelleListe() == .confirmationRequise([.listeNonVide]))
        #expect(liste == envoyee)
        _ = liste.nouvelleListe(confirmee: true)
        #expect(liste.id != envoyee.id)
        #expect(liste.lignes.isEmpty)
        #expect(liste.premierEnvoiLe == nil)
    }

    @Test func generationConserveMessagesEtAjoutsAvantLesRecettes() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("sel"))
        _ = try liste.integrer([article("Farine", "100", .g)], messageId: UUID())
        let initial = liste
        let entree = try recette([article("farine", "200", .g), article("œufs", "2", .piece)])
        _ = try liste.generer(preparer([entree], portions: 4))
        #expect(liste.id == initial.id)
        #expect(liste.lignes.first == initial.lignes.first)
        #expect(liste.lignes[1].id == initial.lignes[1].id)
        #expect(liste.lignes[1].libelle == "Farine")
        #expect(liste.lignes[1].quantite == Quantite(300))
        #expect(liste.lignes[1].origines.map(\.type) == [.message, .recette])
        #expect(liste.lignes.last?.nomNormalise == "oeuf")
    }

    @Test(arguments: [true, false]) func generationRequiertConfirmationPourRecettesOuListeEnvoyee(recettes: Bool) throws
    {
        var liste = ListeCourses()
        let preparation = try preparer([recette([article("sel")])], portions: 4)
        if recettes {
            _ = try liste.generer(preparation)
        } else {
            liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        }
        try liste.ajouter(article("eau"))
        let avant = liste
        let motif: ListeCourses.MotifConfirmation = recettes ? .remplacementRecettes : .listeEnvoyee
        #expect(try liste.generer(preparation) == .confirmationRequise([motif]))
        #expect(liste == avant)
        _ = try liste.generer(preparation, confirmee: true)
        #expect(liste.id != avant.id)
        #expect(!liste.envoyee)
        #expect(liste.lignes.map(\.libelle) == ["sel"])
    }

    @Test func messageDejaIntegreRefuseMemeApresRetraitRelectureEtNouvelleListe() throws {
        var liste = ListeCourses()
        let id = UUID()
        let articles = try [article("sel"), article("farine")]
        _ = try liste.integrer(articles, messageId: id)
        for ligne in liste.lignes {
            try liste.retirer(ligne.id)
        }
        _ = liste.nouvelleListe()
        liste = try JSONDecoder().decode(ListeCourses.self, from: JSONEncoder().encode(liste))
        #expect(throws: ListeCourses.Erreur.messageDejaIntegre(id)) {
            try liste.integrer(articles, messageId: id)
        }
        #expect(liste.lignes.isEmpty)
    }

    @Test(arguments: [ListeCourses.ChoixIntegration.completer, .nouvelleListe])
    func messageSurListeEnvoyeeAttendChoixPuisComplementeOuRemplace(choix: ListeCourses.ChoixIntegration) throws {
        var liste = ListeCourses()
        try liste.ajouter(article("sel"))
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let avant = liste
        let message = UUID()
        let articles = try [article("farine")]
        #expect(try liste.integrer(articles, messageId: message) == .choixIntegrationRequis)
        #expect(liste == avant)
        let resultat = try liste.integrer(articles, messageId: message, choix: choix)
        guard case .applique(let effets) = resultat else {
            Issue.record("Intégration attendue")
            return
        }
        #expect(liste.lignes.last?.origines.map(\.ref) == [message])
        if choix == .completer {
            #expect(liste.id == avant.id)
            #expect(liste.premierEnvoiLe == avant.premierEnvoiLe)
            #expect(liste.lignes.first == avant.lignes.first)
            #expect(effets.lignesAEnvoyer == [try #require(liste.lignes.last).id])
        } else {
            #expect(liste.id != avant.id)
            #expect(!liste.envoyee)
            #expect(liste.lignes.count == 1)
            #expect(effets.lignesAEnvoyer.isEmpty)
        }
    }

    @Test func quantiteUniteEtEffacementReappliquentLaFusion() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("Tomates", "2", .piece))
        try liste.ajouter(article("tomate", "300", .g))
        try liste.ajouter(article("tomate", "2", .autre("boîtes")))
        let premiere = liste.lignes[0]
        try liste.modifierQuantite(liste.lignes[1].id, valeur: Quantite(3), unite: .piece)
        #expect(liste.lignes.count == 2)
        #expect(liste.lignes.first?.id == premiere.id)
        #expect(liste.lignes.first?.quantite == Quantite(5))
        #expect(liste.lignes.first?.origines.count == 2)
        try liste.modifierQuantite(premiere.id, valeur: nil, unite: nil)
        #expect(liste.lignes.count == 1)
        #expect(liste.lignes.first?.id == premiere.id)
        #expect(liste.lignes.first?.libelle == "Tomates")
        #expect(liste.lignes.first?.unite == .autre("boîtes"))
        #expect(liste.lignes.first?.origines.count == 3)
        try liste.modifierQuantite(premiere.id, valeur: nil, unite: nil)
        #expect(liste.lignes.first?.quantite == nil)
        #expect(liste.lignes.first?.unite == nil)
    }

    @Test func retoucheAvantEnvoiEstConserveeEtVisibleApresRelecture() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("sel"))
        try liste.ajouter(article("huile", "1", .l))
        let sel = liste.lignes[0].id
        let huile = liste.lignes[1].id
        #expect(try !liste.retirer(sel).rappelsInchanges)
        #expect(try !liste.modifierQuantite(huile, valeur: Quantite(500), unite: .ml).rappelsInchanges)
        let relue = try JSONDecoder().decode(ListeCourses.self, from: JSONEncoder().encode(liste))
        #expect(relue == liste)
        #expect(try relue.lignesAEnvoyer.map { try $0.titreCourses } == ["huile 500 ml"])
    }

    @Test(arguments: [true, false]) func effacementPreserveLaCocheDeLaQuantiteConservee(enPremier: Bool) throws {
        var liste = ListeCourses()
        let compte = try article("Tomates", "2", .piece)
        let poids = try article("tomates", "300", .g)
        for entree in enPremier ? [compte, poids] : [poids, compte] {
            try liste.ajouter(entree)
        }
        let aEffacer = try #require(liste.lignes.first { $0.unite == .piece })
        let aConserver = try #require(liste.lignes.first { $0.unite == .g })
        try liste.cocher(aConserver.id)
        try liste.modifierQuantite(aEffacer.id, valeur: nil, unite: nil)
        #expect(liste.lignes.map(\.quantite) == [Quantite(300)])
        #expect(liste.lignes.map(\.cochee) == [true])
        #expect(liste.lignesAEnvoyer.isEmpty)
    }

    @Test func retraitBaisseEffacementEtChangementDUniteApresEnvoiSontSignales() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("lait", "2", .l))
        try liste.ajouter(article("sel"))
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let id = liste.lignes[0].id
        #expect(try liste.retirer(liste.lignes[1].id).rappelsInchanges)
        #expect(try liste.modifierQuantite(id, valeur: Quantite(750), unite: .ml).rappelsInchanges)
        #expect(try !liste.modifierQuantite(id, valeur: Quantite(1), unite: .l).rappelsInchanges)
        #expect(try liste.modifierQuantite(id, valeur: Quantite(1), unite: .piece).rappelsInchanges)
        #expect(try liste.modifierQuantite(id, valeur: nil, unite: nil).rappelsInchanges)
    }

    @Test func cocherExclutDeLEnvoiEtDecocherRetablit() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("sel"))
        let id = try #require(liste.lignes.first?.id)
        try liste.cocher(id)
        #expect(liste.lignesAEnvoyer.isEmpty)
        try liste.cocher(id, cochee: false)
        #expect(liste.lignesAEnvoyer.map(\.id) == [id])
    }

    @Test func ajoutSansQuantiteConserveToutesLesLignesEtProposeDeDecocher() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("œufs", "2", .piece))
        try liste.ajouter(article("œufs", "200", .g))
        try liste.ajouter(article("lait", "1", .l))
        let ids = liste.lignes.map(\.id)
        try liste.cocher(ids[0])
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let avant = liste
        let effets = try liste.ajouter(article("oeuf"))
        #expect(liste == avant)
        #expect(effets.decochagePropose == [ids[0]])
        #expect(effets.lignesDecochees.isEmpty)
        #expect(effets.lignesAEnvoyer == [ids[1]])
    }

    @Test(arguments: [true, false]) func ajoutOuIntegrationQuantifieeDecocheEtNeCibleQueLaLigne(integrer: Bool) throws {
        var liste = ListeCourses()
        try liste.ajouter(article("oeuf"))
        try liste.ajouter(article("lait", "1", .l))
        let id = liste.lignes[0].id
        try liste.cocher(id)
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let entree = try article("œufs", "2", .piece)
        let effets: ListeCourses.Effets
        if integrer {
            let resultat = try liste.integrer([entree], messageId: UUID(), choix: .completer)
            guard case .applique(let appliques) = resultat else {
                Issue.record("Intégration attendue")
                return
            }
            effets = appliques
        } else {
            effets = try liste.ajouter(entree)
        }
        #expect(effets.decochagePropose.isEmpty)
        #expect(effets.lignesDecochees == [id])
        #expect(effets.lignesAEnvoyer == [id])
        #expect(liste.lignes.first?.quantite == Quantite(2))
        #expect(liste.lignes.first?.cochee == false)
    }

    @Test func ajoutApresEnvoiDUnArticleOublieCibleCetteLigneSeule() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("œufs", "6", .piece))
        try liste.ajouter(article("lait", "2", .l))
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let effets = try liste.ajouter(article("clémentines"))
        #expect(try effets.lignesAEnvoyer == [#require(liste.lignes.last).id])
    }

    @Test func categoriesOrdonneesAutresParDefautEtTriFrancaisStable() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("Zèbre inconnu"))
        try liste.ajouter(article("échalotes", "2", .piece))
        try liste.ajouter(article("Échalotes", "200", .g))
        try liste.ajouter(article("ail"))
        try liste.ajouter(article("farine"))
        let echalotes = liste.lignes[1...2].map(\.id)
        #expect(liste.rayons.map(\.categorie) == [.fruitsEtLegumes, .epicerieSalee, .autres])
        #expect(liste.rayons[0].lignes.map(\.libelle) == ["ail", "échalotes", "Échalotes"])
        #expect(liste.rayons[0].lignes.dropFirst().map(\.id) == echalotes)
        try liste.changerCategorie(liste.lignes[0].id, categorie: .boulangerie)
        #expect(liste.rayons.map(\.categorie) == [.fruitsEtLegumes, .boulangerie, .epicerieSalee])
    }
}

private struct GenerateurCourses: RandomNumberGenerator {
    var etat: UInt64 = 812

    mutating func next() -> UInt64 {
        etat = etat &* 6_364_136_223_846_793_005 &+ 1
        return etat
    }
}

@Suite struct InvariantsCoursesTests {
    @Test func invariantsApresAjoutsIntegrationsEtRetouchesAleatoires() throws {
        var generateur = GenerateurCourses()
        var liste = ListeCourses()
        let noms = ["œufs", "oeuf", "farine", "de la farine", "sel", "lait"]
        let unites: [Unite] = [.piece, .kg, .g, .ml, .cl, .l, .cas, .cac, .autre("Boîtes"), .autre("boîte")]
        for _ in 0..<300 {
            let nom = try #require(noms.randomElement(using: &generateur))
            let unite = try #require(unites.randomElement(using: &generateur))
            let valeur = Quantite(Int64.random(in: 1...5, using: &generateur))
            switch Int.random(in: 0...4, using: &generateur) {
            case 0:
                try liste.ajouter(ArticleCourses(nom: nom))
            case 1:
                try liste.ajouter(ArticleCourses(nom: nom, quantite: valeur, unite: unite))
            case 2:
                _ = try liste.integrer([ArticleCourses(nom: nom, quantite: valeur, unite: unite)], messageId: UUID())
            case 3:
                if let ligne = liste.lignes.randomElement(using: &generateur) {
                    try liste.modifierQuantite(ligne.id, valeur: valeur, unite: unite)
                }
            default:
                if let ligne = liste.lignes.randomElement(using: &generateur) {
                    try liste.modifierQuantite(ligne.id, valeur: nil, unite: nil)
                }
            }
            for groupe in Dictionary(grouping: liste.lignes, by: \.nomNormalise).values {
                for (index, ligne) in groupe.enumerated() {
                    for autre in groupe.dropFirst(index + 1) {
                        let a = try #require(ligne.unite)
                        let b = try #require(autre.unite)
                        #expect(try convertir(Quantite(1), a, b) == nil)
                    }
                }
            }
        }
    }

    @Test func totauxExactsIndependantsDeLOrdreDesContributionsAleatoires() throws {
        var generateur = GenerateurCourses()
        let articles = try (0..<40).map { _ in
            let haut = Int64.random(in: 1...20, using: &generateur)
            let bas = Int64.random(in: 1...9, using: &generateur)
            let unite: Unite = Bool.random(using: &generateur) ? .g : .kg
            let quantite = try Quantite(numerateur: haut, denominateur: bas)
            return try ArticleCourses(nom: "farine", quantite: quantite, unite: unite)
        }
        let total = try articles.reduce(Quantite(0)) { somme, article in
            let valeur = try #require(article.quantite)
            let unite = try #require(article.unite)
            let canonique = try convertir(valeur, unite, .g)
            return try somme + #require(canonique)
        }
        for _ in 0..<12 {
            let recettes = try articles.shuffled(using: &generateur).map { try recette([$0], portions: 1) }
            var liste = ListeCourses()
            _ = try liste.generer(preparer(recettes, portions: 1))
            #expect(liste.lignes.count == 1)
            #expect(liste.lignes.first?.quantite == total)
        }
    }

    @Test func quantitesEtUnitesInvalidesRefuseesSansModifierLaListe() throws {
        #expect(throws: Ingredient.Erreur.nomVide) { try ArticleCourses(nom: "de la") }
        #expect(throws: Ingredient.Erreur.quantiteNonPositive) { try article("sel", "0", .g) }
        #expect(throws: Ingredient.Erreur.uniteSansQuantite) { try article("sel", nil, .g) }
        #expect(throws: Ingredient.Erreur.uniteSansLibelle) { try article("sel", "1", .autre(" ")) }

        var liste = ListeCourses()
        try liste.ajouter(article("sel", "1", .g))
        let avant = liste
        let id = try #require(liste.lignes.first?.id)
        #expect(throws: Ingredient.Erreur.quantiteNonPositive) {
            try liste.modifierQuantite(id, valeur: Quantite(-1), unite: .g)
        }
        #expect(liste == avant)
    }

    @Test func generationEtIntegrationSontAtomiquesSiLeCalculDepasseLeDomaine() throws {
        var liste = ListeCourses()
        try liste.ajouter(ArticleCourses(nom: "sel", quantite: Quantite(Int64.max), unite: .g))
        let avant = liste
        let articles = try [article("huile"), article("sel", "1", .g)]
        let preparation = try preparer([recette(articles)], portions: 4)
        #expect(throws: Quantite.Erreur.depassement) { try liste.generer(preparation) }
        #expect(liste == avant)
        let message = UUID()
        #expect(throws: Quantite.Erreur.depassement) { try liste.integrer(articles, messageId: message) }
        #expect(liste == avant)
        _ = try liste.integrer([article("huile")], messageId: message)
    }

    @Test func schemaUnConserveQuantiteExacteCocheCategorieEtEnvoi() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("tomates", "3/2", .piece))
        let id = try #require(liste.lignes.first?.id)
        try liste.changerCategorie(id, categorie: .epicerieSalee)
        try liste.cocher(id)
        liste.premierEnvoiLe = Date(timeIntervalSince1970: 42)
        let donnees = try JSONEncoder().encode(liste)
        let objet = try #require(JSONSerialization.jsonObject(with: donnees) as? [String: Any])
        #expect(objet["version_schema"] as? Int == 1)
        #expect(objet["premier_envoi_le"] != nil)
        let lignes = try #require(objet["lignes"] as? [[String: Any]])
        #expect(lignes.first?["nom_normalise"] as? String == "tomate")
        let relue = try JSONDecoder().decode(ListeCourses.self, from: donnees)
        #expect(relue == liste)
        #expect(relue.lignes.first?.quantite == (try q("3/2")))
        #expect(try relue.lignes.first?.quantiteArrondie == Quantite(2))
    }

    @Test func decodageRefuseVersionInconnueEtLignesFusionnables() throws {
        var liste = ListeCourses()
        try liste.ajouter(article("farine", "1", .g))
        let donnees = try JSONEncoder().encode(liste)
        var objet = try #require(JSONSerialization.jsonObject(with: donnees) as? [String: Any])
        objet["version_schema"] = 2
        #expect(throws: ListeCourses.Erreur.versionNonPriseEnCharge(2)) {
            try JSONDecoder().decode(ListeCourses.self, from: JSONSerialization.data(withJSONObject: objet))
        }
        objet["version_schema"] = 1
        let lignes = try #require(objet["lignes"] as? [[String: Any]])
        var seconde = try #require(lignes.first)
        seconde["id"] = UUID().uuidString
        objet["lignes"] = lignes + [seconde]
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ListeCourses.self, from: JSONSerialization.data(withJSONObject: objet))
        }
        seconde.removeValue(forKey: "quantite")
        seconde.removeValue(forKey: "unite")
        objet["lignes"] = lignes + [seconde]
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ListeCourses.self, from: JSONSerialization.data(withJSONObject: objet))
        }
    }
}
