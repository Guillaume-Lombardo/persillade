public struct SessionCuisine: Sendable {
    public let etapes: [String]
    public private(set) var position: Int

    public var etapeCourante: String { etapes[position - 1] }
    public var etapeSuivante: String? { position < etapes.count ? etapes[position] : nil }

    public init?(recette: Recette, position: Int = 1) {
        guard !recette.etapes.isEmpty else { return nil }
        etapes = recette.etapes
        self.position = min(max(1, position), etapes.count)
    }

    public mutating func suivante() {
        if position < etapes.count { position += 1 }
    }

    public mutating func precedente() {
        if position > 1 { position -= 1 }
    }
}
