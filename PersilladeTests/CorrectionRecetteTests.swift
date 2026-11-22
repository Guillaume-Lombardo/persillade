import Testing

@testable import Persillade

@Test func associeLesExtraitsAuxOccurrencesSansConfondreLesQuantites() {
    let source = """
        11 oignons
        2 carottes
        • 1 oignon (émincé)
        2 carottes
        1 oignon
        """
    let extraits = ["1 oignon", "2 carottes", "2 carottes", "1 oignon", "1 oignon", "oignon râpé"]
    #expect(CorrespondancesSource.indices(extraits, dans: source) == [4, 1, 3, 2, nil, nil])
}
