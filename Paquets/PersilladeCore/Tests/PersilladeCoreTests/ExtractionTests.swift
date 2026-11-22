import Foundation
import Testing

@testable import PersilladeCore

struct CasIngredient: Sendable {
    let ligne: String
    let nom: String
    let mesure: String?
    let unite: Unite?

    init(_ ligne: String, _ nom: String, _ mesure: String? = nil, _ unite: Unite? = nil) {
        self.ligne = ligne
        self.nom = nom
        self.mesure = mesure
        self.unite = unite
    }
}

@Test(arguments: [
    CasIngredient("  - 200g de farine  ", "farine", "200", .g),
    CasIngredient("farine : 200 g", "farine", "200", .g),
    CasIngredient("farine 200 gr", "farine", "200", .g),
    CasIngredient("huile d’olive : 1,25 litre", "huile d’olive", "1.25", .l),
    CasIngredient("1.5 dl de lait", "lait", "15", .cl),
    CasIngredient("un demi-décilitre d’eau", "eau", "5", .cl),
    CasIngredient("3 œufs", "œufs", "3", .piece),
    CasIngredient("3 œufs de ferme", "œufs de ferme", "3", .piece),
    CasIngredient("une douzaine d’œufs", "œufs", "12", .piece),
    CasIngredient("2 à 3 carottes", "carottes", "3", .piece),
    CasIngredient("2-3 grosses carottes", "grosses carottes", "3", .piece),
    CasIngredient("3–2 carottes", "carottes", "3", .piece),
    CasIngredient("deux à trois oignons", "oignons", "3", .piece),
    CasIngredient("1/2 kg de pommes (pelées)", "pommes (pelées)", "1/2", .kg),
    CasIngredient("½ kilo de pommes", "pommes", "1/2", .kg),
    CasIngredient("1 ½ c. à s. d’huile", "huile", "3/2", .cas),
    CasIngredient("1 1/2 càs d’huile", "huile", "3/2", .cas),
    CasIngredient("1½ CS de miel", "miel", "3/2", .cas),
    CasIngredient("2 cuillères à soupe de vinaigre", "vinaigre", "2", .cas),
    CasIngredient("2 c. à soupe de vinaigre", "vinaigre", "2", .cas),
    CasIngredient("2 cuillères à café de sucre", "sucre", "2", .cac),
    CasIngredient("2 c. à café de sucre", "sucre", "2", .cac),
    CasIngredient("¼cc de muscade", "muscade", "1/4", .cac),
    CasIngredient("1 c. à c. de poivre", "poivre", "1", .cac),
    CasIngredient("demi-gousse d’ail", "ail", "1/2", .autre("gousse")),
    CasIngredient("2 tranches de pain", "pain", "2", .autre("tranche")),
    CasIngredient("deux sachets de levure", "levure", "2", .autre("sachet")),
    CasIngredient("1 botte de radis", "radis", "1", .autre("botte")),
    CasIngredient("2 verres d’eau", "eau", "2", .autre("verre")),
    CasIngredient("1 boîte de tomates", "tomates", "1", .autre("boîte")),
    CasIngredient("3 brins de persil", "persil", "3", .autre("brin")),
    CasIngredient("deux pincées de cumin", "cumin", "2", .autre("pincée")),
    CasIngredient("une pincée de paprika", "paprika", "1", .autre("pincée")),
    CasIngredient("1 boîte (400 g) de tomates", "tomates (400 g)", "1", .autre("boîte")),
    CasIngredient("une pincée de sel", "sel"),
    CasIngredient("sel, au goût", "sel"),
    CasIngredient("QS de persil", "persil"),
])
func lignesIngredients(_ cas: CasIngredient) throws {
    let analyse = AnalyseIngredient.analyser(cas.ligne)
    #expect(analyse.nom == cas.nom)
    #expect(analyse.quantite == (try cas.mesure.map { try Quantite(texte: $0) }))
    #expect(analyse.unite == cas.unite)
    #expect(analyse.texteOrigine == cas.ligne)
    #expect(!analyse.ligneNonComprise)
    #expect(try analyse.valider().nom == cas.nom)
}

@Test(arguments: [
    "200 g", "200 g de", "200 g ()", "½", "1/0 de farine", "0 g de farine", "-2 kg de farine", "QS", "3glevure",
])
func ingredientNonCompris(_ ligne: String) {
    let analyse = AnalyseIngredient.analyser(ligne)
    #expect(analyse.nom.isEmpty)
    #expect(analyse.texteOrigine == ligne)
    #expect(analyse.ligneNonComprise)
    #expect(throws: Ingredient.Erreur.nomVide) { try analyse.valider() }
}

private func fixture(_ nom: String, _ ext: String) throws -> String {
    let url = try #require(Bundle.module.url(forResource: nom, withExtension: ext, subdirectory: "Fixtures/Extraction"))
    return try String(contentsOf: url, encoding: .utf8)
}

private func texteRecu(_ texte: String, type: ContenuRecu.TypeContenu = .texte) -> ContenuRecu {
    ContenuRecu(type: type, contenu: Data(texte.utf8), origine: .pressePapiers)
}

private struct PageBouchon: TelechargeurPage {
    let reponse: @Sendable (URL) throws -> String
    func telecharger(_ url: URL) async throws -> String { try reponse(url) }
}

private actor MoteurBouchon: MoteurIA {
    enum Mode: Sendable {
        case reponse(@Sendable (String) -> PropositionExtraction)
        case erreur
        case indisponible
        case lent
    }

    let mode: Mode
    let budget: Int
    private(set) var morceaux: [String] = []
    private(set) var champs: ChampsRecette?
    private(set) var appelsBudget = 0
    private var debut: CheckedContinuation<Void, Never>?

    init(_ mode: Mode, budget: Int = 4_000) {
        self.mode = mode
        self.budget = budget
    }

    func budgetContexte(cible: CibleExtraction, champs: ChampsRecette) async throws -> Int {
        appelsBudget += 1
        self.champs = champs
        if case .indisponible = mode { throw CauseExtraction.iaIndisponible }
        return budget
    }

    func compterJetons(_ texte: String) async throws -> Int { texte.count }

    func extraire(_ texte: String, cible: CibleExtraction, champs: ChampsRecette) async throws -> PropositionExtraction
    {
        morceaux.append(texte)
        debut?.resume()
        debut = nil
        switch mode {
        case .reponse(let produire): return produire(texte)
        case .erreur, .indisponible: throw CauseExtraction.iaEnErreur
        case .lent:
            try await Task.sleep(for: .seconds(60))
            return PropositionExtraction()
        }
    }

    func attendrePremierMorceau() async {
        if morceaux.isEmpty {
            await withCheckedContinuation { debut = $0 }
        }
    }
}

@Test(arguments: [
    ("01-clafoutis", "Clafoutis du mercredi", 6, 4, 3),
    ("02-tartines", "Tartines aux fèves & au chèvre", 4, 4, 3),
    ("03-compote", "Compote pomme & coing", 5, 3, 2),
    ("04-creme", "Crème vanillée au four", 6, 4, 4),
    ("05-bouillon", "Bouillon du marché", 4, 4, 2),
    ("06-galette", "Galettes de pois chiches", 4, 4, 2),
    ("07-salade", "Salade tiède de lentilles", 4, 3, 2),
])
func corpusPages(nom: String, titre: String, portions: Int, ingredients: Int, etapes: Int) async throws {
    let html = try fixture(nom, "html")
    let client = PageBouchon { url in
        #expect(url.absoluteString == "https://recettes.example/fiche")
        return html
    }
    let moteur = MoteurBouchon(.erreur)
    let extracteur = Extracteur(telechargeur: client, moteurIA: moteur)
    let resultat = try await extracteur.extraire(
        texteRecu("https://recettes.example/fiche", type: .url), cible: .recette)
    #expect(resultat.statut == .complet)
    #expect(resultat.moteur == .structure)
    #expect(resultat.cause == nil)
    #expect(await moteur.appelsBudget == 0)
    let recette = try resultat.validerRecette()
    #expect(recette.titre == titre)
    #expect(recette.portions == portions)
    #expect(recette.ingredients.count == ingredients)
    #expect(recette.etapes.count == etapes)
    #expect(recette.urlSource?.host() == "recettes.example")
    #expect(recette.texteSource.contains(titre))
    #expect(!recette.texteSource.contains("conditions de vente"))
    #expect(!recette.texteSource.contains("<script"))
    if nom == "02-tartines" {
        #expect(recette.etapes == ["Écrasez les fèves.", "Ajoutez l’huile et le sel.", "Servez sur le pain grillé."])
        #expect(recette.ingredients[3].quantite == nil)
    }
}

@Test func texteLibreetEtapes() async throws {
    let contenu = texteRecu(try fixture("08-soupe", "txt"))
    let resultat = try await Extracteur().extraire(contenu, cible: .recette)
    #expect(resultat.statut == .complet)
    #expect(resultat.moteur == .structure)
    let recette = try resultat.validerRecette()
    #expect(recette.titre == "Soupe orange du dimanche")
    #expect(recette.portions == 5)
    #expect(recette.ingredients.map(\.nom) == ["carottes", "courge (avec la peau)", "bouillon", "sel"])
    #expect(recette.ingredients[0].texteOrigine == "- 2-3 carottes")
    #expect(recette.etapes.first == "Coupez la courge et les carottes.")
}

@Test func listeSansEnteteConserveTitreEtIngredientsNonDoses() async throws {
    let contenu = texteRecu("Cake\n2 œufs\nfarine\n100 g de beurre\nMélanger.")
    let resultat = try await Extracteur().extraire(contenu, cible: .recette)
    #expect(resultat.statut == .complet)
    #expect(resultat.recette?.titre == "Cake")
    #expect(resultat.recette?.ingredients.map(\.nom) == ["œufs", "farine", "beurre"])
    #expect(resultat.recette?.etapes == ["Mélanger."])
}

@Test func brouillonOCRConserveLaLigneIncomprise() async throws {
    let original = try fixture("11-ocr", "txt")
    let resultat = try await Extracteur().extraire(texteRecu(original), cible: .recette)
    #expect(resultat.statut == .partiel)
    #expect(resultat.cause == .iaIndisponible)
    #expect(resultat.texteSource == original)
    var brouillon = try #require(resultat.recette)
    #expect(brouillon.portions == 6)
    #expect(brouillon.ingredients.count == 4)
    #expect(brouillon.etapes.count == 2)
    #expect(brouillon.ingredients[1].ligneNonComprise)
    #expect(brouillon.ingredients[1].texteOrigine == "150 g")
    #expect(throws: Ingredient.Erreur.nomVide) { try resultat.validerRecette() }
    brouillon.ingredients[1].nom = "sucre"
    brouillon.ingredients[1].ligneNonComprise = false
    #expect(try brouillon.valider(texteSource: original).ingredients[1].nom == "sucre")
}

@Test func portionsSupposeesEtEtapesSansNotes() async throws {
    let resultat = try await Extracteur().extraire(texteRecu(fixture("12-fiche", "txt")), cible: .recette)
    #expect(resultat.statut == .complet)
    let recette = try #require(resultat.recette)
    #expect(recette.portionsSupposees)
    #expect(recette.portionsEffectives == 4)
    #expect(recette.ingredients.map(\.nom) == ["tomates", "ail", "huile d’olive"])
    #expect(recette.ingredients[1].quantite == (try Quantite(texte: "1/2")))
    #expect(recette.etapes == ["Couper les tomates en deux.", "Ajouter l’ail et enfourner."])
    #expect(try resultat.validerRecette().portions == 4)
}

@Test func recetteComposeeDepuisDesCitations() async throws {
    let original = try fixture("10-prose", "txt")
    let moteur = MoteurBouchon(
        .reponse { _ in
            PropositionExtraction(
                titre: "brioche à la fleur d’oranger", portions: "8 parts",
                ingredients: [
                    "350 g de farine", "un sachet de levure", "15 cl de lait tiède", "deux œufs", "50 g de beurre",
                ],
                etapes: ["on laisse lever la pâte près du four pendant deux heures."])
        })
    let resultat = try await Extracteur(moteurIA: moteur).extraire(texteRecu(original), cible: .recette)
    #expect(resultat.statut == .complet)
    #expect(resultat.moteur == .embarque)
    #expect(resultat.texteSource == original)
    let recette = try resultat.validerRecette()
    #expect(recette.titre == "brioche à la fleur d’oranger")
    #expect(recette.portions == 8)
    #expect(recette.ingredients.map(\.nom) == ["farine", "levure", "lait tiède", "œufs"])
    #expect(recette.ingredients[2].unite == .cl)
}

@Test func iaCompleteLesChampsManquants() async throws {
    let original = "Tarte salée\n250 g de farine\nDans un bol, on pétrit la pâte."
    let moteur = MoteurBouchon(
        .reponse { _ in
            PropositionExtraction(
                titre: "Tarte", ingredients: ["250 g de farine"], etapes: ["on pétrit la pâte."])
        })
    let resultat = try await Extracteur(moteurIA: moteur).extraire(texteRecu(original), cible: .recette)
    #expect(await moteur.champs == [.portions, .etapes])
    #expect(resultat.statut == .complet)
    #expect(resultat.recette?.titre == "Tarte salée")
    #expect(resultat.recette?.etapes == ["on pétrit la pâte."])
}

@Test func messageSansIACoupeSeulementUneListeCourte() async throws {
    let contenu = texteRecu(try fixture("09-whatsapp", "txt"))
    let moteur = MoteurBouchon(.indisponible)
    let resultat = try await Extracteur(moteurIA: moteur).extraire(contenu, cible: .message)
    #expect(resultat.statut == .partiel)
    #expect(resultat.moteur == .manuel)
    #expect(resultat.cause == .iaIndisponible)
    #expect(
        resultat.articles.map(\.nom) == [
            "Pour demain 🙂", "lait", "œufs", "pain de seigle", "pommes", "pommes de terre", "Merci !",
        ])
    #expect(resultat.articles.allSatisfy { $0.messageID == contenu.id })
    #expect(resultat.articles.first { $0.nom == "pommes de terre" }?.quantite == (try Quantite(texte: "1,5")))
}

@Test func messageCompletEtAncre() async throws {
    let moteur = MoteurBouchon(.reponse { _ in .init(articles: ["3 œufs", "500 g de farine"]) })
    let resultat = try await Extracteur(moteurIA: moteur).extraire(
        texteRecu("Prends 500 g de farine et 3 œufs, merci !"), cible: .message)
    #expect(resultat.statut == .complet)
    #expect(resultat.moteur == .embarque)
    #expect(resultat.articles.map(\.nom) == ["farine", "œufs"])
    #expect(resultat.articles.map(\.quantite) == [Quantite(500), Quantite(3)])
}

@Test func messagePartielSiCitationsInventeesOuTronquees() async throws {
    let moteur = MoteurBouchon(
        .reponse { _ in .init(articles: ["500 g de farine", "5 kg d’avoine", "pain", "3 œufs"]) })
    let resultat = try await Extracteur(moteurIA: moteur).extraire(
        texteRecu("1500 g de farine, 1,5 kg d’avoine, du pain et 3 œufs"), cible: .message)
    #expect(resultat.statut == .partiel)
    #expect(resultat.moteur == .embarque)
    #expect(resultat.articles.map(\.nom) == ["pain", "œufs"])
}

@Test(arguments: [("1 1/2 kg", "1/2 kg"), ("1 ½ kg", "½ kg"), ("2 à 3 kg", "3 kg")])
func citationNeCoupePasUneMesureComposee(mesure: String, tronquee: String) async throws {
    let moteur = MoteurBouchon(.reponse { _ in .init(articles: ["\(tronquee) de pommes", "pain"]) })
    let resultat = try await Extracteur(moteurIA: moteur).extraire(
        texteRecu("Achète \(mesure) de pommes et du pain"), cible: .message)
    #expect(resultat.statut == .partiel)
    #expect(resultat.articles.map(\.nom) == ["pain"])
}

@Test func echecsNettoyesEtRepliManuel() async throws {
    let moteur = MoteurBouchon(.erreur)
    let extracteur = Extracteur(moteurIA: moteur)
    let vide = try await extracteur.extraire(texteRecu("  "), cible: .recette)
    #expect(vide.statut == .echec)
    #expect(vide.cause == .rienTrouve)
    #expect(vide.recette == BrouillonRecette())
    let erreur = try await extracteur.extraire(texteRecu("pommes\nlait"), cible: .message)
    #expect(erreur.statut == .partiel)
    #expect(erreur.cause == .iaEnErreur)
    #expect(erreur.articles.map(\.nom) == ["pommes", "lait"])
    let aucunArticle = try await extracteur.extraire(texteRecu("-----"), cible: .message)
    #expect(aucunArticle.statut == .echec)
    #expect(aucunArticle.cause == .iaEnErreur)
}

@Test(arguments: [CauseExtraction.horsLigne, .pageInaccessible, .delai])
func causePageEtLienConserve(_ cause: CauseExtraction) async throws {
    let moteur = MoteurBouchon(.erreur)
    let extracteur = Extracteur(telechargeur: PageBouchon { _ in throw cause }, moteurIA: moteur)
    let resultat = try await extracteur.extraire(texteRecu("https://recettes.example/", type: .url), cible: .recette)
    #expect(resultat.statut == .echec)
    #expect(resultat.cause == cause)
    #expect(resultat.texteSource == "https://recettes.example/")
    #expect(resultat.urlSource?.absoluteString == resultat.texteSource)
    #expect(resultat.messageAccesPage?.contains("coller le texte") == true)
    #expect(await moteur.appelsBudget == 0)
}

@Test func atsProduitUnMessageExplicite() async throws {
    let extracteur = Extracteur(telechargeur: PageBouchon { _ in throw ErreurAccesPage.httpBloque })
    let resultat = try await extracteur.extraire(texteRecu("http://recettes.example/", type: .url), cible: .recette)
    #expect(resultat.cause == .pageInaccessible)
    #expect(resultat.messageAccesPage?.contains("HTTP est bloqué") == true)
}

@Test func reductionDuBlocPuisDecoupageOrdonne() async throws {
    let morceau1 = "Tarte express\nIngrédients"
    let morceau2 = "2 œufs\n200 g de farine"
    let bloc = morceau1 + "\n" + morceau2
    let original =
        "Publicité " + String(repeating: "🍪", count: 80) + "\n" + bloc
        + "\nAvis\n" + String(repeating: "Très bon ! ", count: 80)
    let moteur = MoteurBouchon(.reponse { _ in .init() }, budget: 28)
    let resultat = try await Extracteur(moteurIA: moteur).extraire(texteRecu(original), cible: .recette)
    #expect(await moteur.morceaux == [morceau1, morceau2])
    #expect(resultat.texteSource == original)
    #expect(resultat.statut == .partiel)
    #expect(resultat.cause == .rienTrouve)
}

@Test func generationConcateneeSurTroisMorceaux() async throws {
    let morceaux = ["tomates", "farine", "chocolat"]
    let moteur = MoteurBouchon(.reponse { .init(articles: [$0]) }, budget: 8)
    let resultat = try await Extracteur(moteurIA: moteur).extraire(
        texteRecu(morceaux.joined(separator: "\n")), cible: .message)
    #expect(await moteur.morceaux == morceaux)
    #expect(resultat.statut == .complet)
    #expect(resultat.articles.map(\.nom) == morceaux)
}

@Test func contenuTropLongPreserveLeDecoupageManuel() async throws {
    let moteur = MoteurBouchon(.erreur, budget: 8)
    let resultat = try await Extracteur(moteurIA: moteur).extraire(
        texteRecu("tomates\ncitrons\nchocolat\nfarine"), cible: .message)
    #expect(resultat.statut == .partiel)
    #expect(resultat.cause == .contenuTropLong)
    #expect(resultat.articles.count == 4)
    #expect(await moteur.morceaux == ["tomates"])
}

@Test func contenuTropLongPreserveLesTroisResultatsGeneres() async throws {
    let morceaux = ["tomates", "citrons", "chocolat", "farine"]
    let texte = morceaux.joined(separator: "\n")
    let moteur = MoteurBouchon(.reponse { .init(articles: [$0]) }, budget: 8)
    let resultat = try await Extracteur(moteurIA: moteur).extraire(texteRecu(texte), cible: .message)
    #expect(resultat.statut == .partiel)
    #expect(resultat.cause == .contenuTropLong)
    #expect(resultat.texteSource == texte)
    #expect(resultat.articles.map(\.nom) == Array(morceaux.prefix(3)))
    #expect(await moteur.morceaux == Array(morceaux.prefix(3)))
}

@Test func recetteTronqueeRestePartielleAvecTousLesChamps() async throws {
    let texte = """
        On prépare un cake à la cannelle.
        Il faut 2 œufs et de la patience.
        On mélange et on enfourne.
        Puis on attend encore une bonne demi-heure.
        """
    let moteur = MoteurBouchon(
        .reponse { _ in
            .init(titre: "cake à la cannelle", ingredients: ["2 œufs"], etapes: ["On mélange et on enfourne."])
        }, budget: 35)
    let resultat = try await Extracteur(moteurIA: moteur).extraire(texteRecu(texte), cible: .recette)
    #expect(resultat.recette?.titre == "cake à la cannelle")
    #expect(resultat.recette?.ingredients.map(\.nom) == ["œufs"])
    #expect(resultat.recette?.etapes == ["On mélange et on enfourne."])
    #expect(resultat.statut == .partiel)
    #expect(resultat.cause == .contenuTropLong)
}

@Test func repliConsentiSuitLeMoteurEmbarque() async throws {
    let moteur = MoteurBouchon(.indisponible)
    let recu = texteRecu("Prends 3 œufs, merci !")
    let resultat = try await Extracteur(moteurIA: moteur).extraire(recu, cible: .message) { contenu, cible, local in
        #expect(contenu == recu)
        #expect(cible == .message)
        #expect(local.cause == .iaIndisponible)
        #expect(local.statut == .partiel)
        #expect(await moteur.appelsBudget == 1)
        return .init(articles: ["3 œufs"])
    }
    #expect(resultat.statut == .complet)
    #expect(resultat.moteur == .cleExterne)
    #expect(resultat.articles.map(\.nom) == ["œufs"])

    let enEchec = try await Extracteur(moteurIA: moteur).extraire(recu, cible: .message) { _, _, _ in
        throw CauseExtraction.fournisseurEnErreur
    }
    #expect(enEchec.statut == .partiel)
    #expect(enEchec.cause == .fournisseurEnErreur)
    #expect(enEchec.articles.count == 1)
}

@Test func repliIgnorePourUnResultatComplet() async throws {
    let moteur = MoteurBouchon(.reponse { _ in .init(articles: ["3 œufs"]) })
    let resultat = try await Extracteur(moteurIA: moteur).extraire(
        texteRecu("3 œufs"), cible: .message
    ) { _, _, _ in
        Issue.record("Le repli a été appelé pour un résultat complet.")
        return .init()
    }
    #expect(resultat.moteur == .embarque)
}

@Test(.timeLimit(.minutes(1))) func annulationPendantLaGeneration() async {
    let moteur = MoteurBouchon(.lent)
    let tache = Task {
        try await Extracteur(moteurIA: moteur).extraire(texteRecu("2 œufs"), cible: .message)
    }
    await moteur.attendrePremierMorceau()
    tache.cancel()
    await #expect(throws: CancellationError.self) { try await tache.value }
}

@Test func annulationALaReceptionDeLaPage() async {
    let client = PageBouchon { _ in
        withUnsafeCurrentTask { $0?.cancel() }
        return "<h1>Crêpes</h1>"
    }
    let tache = Task {
        try await Extracteur(telechargeur: client).extraire(
            texteRecu("https://recettes.example/", type: .url), cible: .recette)
    }
    await #expect(throws: CancellationError.self) { try await tache.value }
}

private struct LecteurBouchon: LecteurImage {
    func lireTexte(_ image: Data) async throws -> String {
        #expect(image == Data([42]))
        return "3 œufs"
    }
}

@Test func imageAvecEtSansLecteur() async throws {
    let image = ContenuRecu(type: .image, contenu: Data([42]), origine: .phototheque)
    let sansLecteur = try await Extracteur().extraire(image, cible: .recette)
    #expect(sansLecteur.statut == .echec)
    #expect(sansLecteur.cause == .rienTrouve)
    let lu = try await Extracteur(lecteurImage: LecteurBouchon()).extraire(image, cible: .recette)
    #expect(lu.statut == .partiel)
    #expect(lu.recette?.ingredients.first?.nom == "œufs")
    #expect(lu.texteSource == "3 œufs")
}
