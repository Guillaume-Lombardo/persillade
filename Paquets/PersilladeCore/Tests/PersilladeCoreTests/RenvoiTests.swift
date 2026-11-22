import Foundation
import PersilladeCore
import Testing

struct RenvoiTests {
    private let seuil = Date(timeIntervalSinceReferenceDate: 100)

    private func plan(
        _ nom: String, _ quantite: Quantite?, _ unite: Unite? = nil,
        titres: [String] = [], coches: [(String, Date?)] = [], exclue: Bool = false
    ) throws -> PlanEnvoi {
        var liste = ListeCourses()
        try liste.ajouter(ArticleCourses(nom: nom, quantite: quantite, unite: unite))
        let id = try #require(liste.lignes.first?.id)
        if exclue { try liste.cocher(id) }
        let ligne = try #require(liste.lignes.first)
        let rappels =
            titres.map { RappelCourses(id: UUID().uuidString, titre: $0) }
            + coches.map { RappelCourses(id: UUID().uuidString, titre: $0.0, coche: true, cocheLe: $0.1) }
        return try PlanEnvoi(ligne: ligne, rappels: rappels, journal: JournalEnvoi(), premierEnvoiLe: seuil)
    }

    @Test func sansRappelAjouteLaLigne() throws {
        #expect(try plan("lait", Quantite(2), .l) == .ajouter(Quantite(2_000)))
    }

    @Test func unLitreOuvertPourDeuxAjouteUnLitre() throws {
        #expect(try plan("lait", Quantite(2), .l, titres: ["lait 1 l"]) == .completer(Quantite(1_000)))
    }

    @Test func deuxRappelsOuvertsCouvrentDeuxLitres() throws {
        #expect(try plan("lait", Quantite(2), .l, titres: ["lait 1 l", "lait 1 l"]) == .ignorer)
    }

    @Test func unLitreCocheDepuisLeSeuilCouvreLaMoitie() throws {
        #expect(try plan("lait", Quantite(2), .l, coches: [("lait 1 l", seuil)]) == .completer(Quantite(1_000)))
    }

    @Test func sixOeufsCochesDepuisLeSeuilCouvrentSixOeufs() throws {
        #expect(try plan("œufs", Quantite(6), coches: [("œufs 6", seuil.addingTimeInterval(1))]) == .ignorer)
    }

    @Test func sixOeufsCochesAvantLeSeuilSontRedemandes() throws {
        #expect(
            try plan("œufs", Quantite(6), coches: [("œufs 6", seuil.addingTimeInterval(-1))]) == .ajouter(Quantite(6)))
    }

    @Test func troisLitresOuvertsCouvrentDeuxLitres() throws {
        #expect(try plan("lait", Quantite(2), .l, titres: ["lait 3 l"]) == .ignorer)
    }

    @Test func desTomatesALaPieceNeCouvrentPasDesGrammes() throws {
        let titres = ["tomates 3"]
        #expect(try plan("tomates", Quantite(500), .g, titres: titres) == .ajouter(Quantite(500)))
        #expect(try plan("tomates", Quantite(500), .g, titres: titres + ["tomates 500 g"]) == .ignorer)
    }

    @Test func leLaitSansQuantiteNeCouvrePasDeuxLitres() throws {
        #expect(try plan("lait", Quantite(2), .l, titres: ["lait"]) == .ajouter(Quantite(2_000)))
        #expect(try plan("lait", Quantite(2), .l, titres: ["lait", "lait 2 l"]) == .ignorer)
    }

    @Test func unLitreOuvertCouvreLeLaitSansQuantite() throws {
        #expect(try plan("lait", nil, titres: ["lait 1 l"]) == .ignorer)
    }

    @Test func lesTomatesCerisesNeCouvrentPasLesTomates() throws {
        #expect(try plan("tomates", nil, titres: ["tomates cerises"]) == .ajouter(nil))
    }

    @Test func uneCocheSansDateEstIgnoree() throws {
        #expect(try plan("œufs", Quantite(6), coches: [("œufs 6", nil)]) == .ajouter(Quantite(6)))
    }

    @Test func uneLigneCocheeDansLAppEstExclue() throws {
        #expect(try plan("lait", nil, exclue: true) == .exclure)
    }

    @Test func uneUniteLibreNestNormaliseeQuUneFois() throws {
        #expect(try plan("café", Quantite(2), .autre("press"), titres: ["café 2 press"]) == .ignorer)
    }

    @Test func leComplementConserveLaFractionExacte() throws {
        #expect(
            try plan("farine", Quantite(1), .g, titres: ["farine 1/3 g"])
                == .completer(Quantite(numerateur: 2, denominateur: 3)))
    }

    @Test(arguments: [
        ("lait 1 l", "lait", "1", Unite.l),
        ("tomates pelées 2 boîtes", "tomate pelee", "2", .autre("boite")),
        ("2 laits", "lait", "2", .piece),
        ("1 l de lait", "lait", "1", .l),
        ("farine 1,5 kg", "farine", "1,5", .kg),
        ("œufs 6", "oeuf", "6", .piece),
    ])
    func litLesTitres(_ cas: (String, String, String, Unite)) throws {
        let article = ArticleRappel(titre: cas.0)
        #expect(article.nomNormalise == cas.1)
        #expect(try article.quantite == Quantite(texte: cas.2))
        #expect(article.unite == cas.3)
    }

    @Test(arguments: ["sel", "lait 0 l", "lait -1 l"])
    func conserveUnTitreSansQuantitePositive(_ titre: String) {
        let article = ArticleRappel(titre: titre)
        #expect(article.nomNormalise == normaliserNom(titre))
        #expect(article.quantite == nil)
        #expect(article.unite == nil)
    }
}
