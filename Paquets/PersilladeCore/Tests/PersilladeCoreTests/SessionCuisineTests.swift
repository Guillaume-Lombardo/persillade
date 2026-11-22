import Testing

@testable import PersilladeCore

struct SessionCuisineTests {
    @Test func suivreLesEtapesDansLOrdre() throws {
        let sauvegardee = try recette(etapes: ["A", "B", "C", "D", "E"])
        var session = try #require(SessionCuisine(recette: sauvegardee))
        #expect(session.etapes == sauvegardee.etapes)
        session.precedente()
        #expect(session.position == 1)
        #expect(session.etapeCourante == "A")
        session.suivante()
        session.suivante()
        #expect(session.etapeCourante == "C")
        session.precedente()
        #expect(session.position == 2)
        #expect(session.etapeCourante == "B")
        #expect(session.etapeSuivante == "C")
    }

    @Test func bornerLaRepriseEtLaNavigation() throws {
        let raccourcie = try recette(etapes: ["A", "B"])
        var reprise = try #require(SessionCuisine(recette: raccourcie, position: .max))
        reprise.suivante()
        #expect(reprise.position == 2)
        #expect(reprise.etapeCourante == "B")
        #expect(reprise.etapeSuivante == nil)
        #expect(SessionCuisine(recette: raccourcie, position: .min)?.position == 1)
        #expect(SessionCuisine(recette: try recette(etapes: []), position: 2) == nil)
    }

    private func recette(etapes: [String]) throws -> Recette {
        try Recette(titre: "Test", portions: 4, ingredients: [], etapes: etapes, texteSource: "")
    }
}
