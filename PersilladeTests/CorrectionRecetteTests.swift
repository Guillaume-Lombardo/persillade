import PersilladeCore
import Testing

@testable import Persillade

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
