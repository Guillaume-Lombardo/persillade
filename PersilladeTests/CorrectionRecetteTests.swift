import Foundation
import PersilladeCore
import Testing

@testable import Persillade

@Suite struct AlternativesCorrectionTests {
    @Test func leBrouillonConserveLEchangeEtLaCitation() throws {
        let source = "6 abricots ou 12 oreillons d’abricots au sirop"
        let ingredient = AnalyseIngredient.analyser(source)
        var ligne = LigneIngredientCorrection(ingredient)
        try ligne.echangerAvecAlternative(0)
        let relue = try JSONDecoder().decode(LigneIngredientCorrection.self, from: JSONEncoder().encode(ligne))
        let validee = try relue.valider()
        #expect(validee.nom == "oreillons d’abricots au sirop")
        #expect(validee.quantite == Quantite(12))
        #expect(validee.alternatives.map(\.nom) == ["abricots"])
        #expect(validee.alternatives.first?.quantite == Quantite(6))
        #expect(validee.texteOrigine == source)
    }
}

@Test func associeLesExtraitsAuxOccurrencesSansConfondreLesQuantites() {
    let source = """
        11 oignons
        2 carottes
        • 1 oignon (émincé)
        2 carottes
        1 oignon
        3 tomates et 1 oignon
        """
    let extraits = ["1 oignon", "2 carottes", "2 carottes", "1 oignon", "1 oignon", "1 oignon", "3 tomates"]
    let citations = CorrespondancesSource.associer(extraits, dans: source)
    #expect(citations.map { $0?.ligne } == [4, 1, 3, 2, 5, nil, 5])
    #expect(citations[4]?.plage.location == 13)
    #expect(citations[6]?.plage.location == 0)
}

@Test func privilegieLaCitationLongueQuandLesPlagesSeChevauchent() {
    let citations = CorrespondancesSource.associer(["1 citron", "1 citron vert"], dans: "1 citron vert et 1 citron")
    #expect(citations.map { $0?.plage.location } == [17, 0])
}

@Test func extraitWebCommenceAuTitreOuAuPremierIngredientSansDecalerLesCitations() {
    let source = "Rechercher\nSoupe de courge\nSe connecter\nSoupe de courge\nIngrédients\n500 g de courge"
    let brouillon = BrouillonRecette(
        titre: "Soupe de courge", ingredients: [.init(nom: "courge", texteOrigine: "500 g de courge")])
    var formulaire = FormulaireRecette(brouillon, source: source)
    #expect(formulaire.debutExtraitWeb(dans: source) == 3)
    #expect(formulaire.ingredients[0].citation?.ligne == 5)
    formulaire.titre = "Autre titre"
    #expect(formulaire.debutExtraitWeb(dans: source) == 5)
}
