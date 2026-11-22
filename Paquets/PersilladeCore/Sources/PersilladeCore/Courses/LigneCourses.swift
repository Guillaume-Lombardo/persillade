import Foundation

public struct OrigineCourses: Codable, Hashable, Sendable {
    public enum TypeOrigine: String, Codable, Sendable {
        case recette, message, manuel
    }

    public let type: TypeOrigine
    public let ref: UUID
}

public struct LigneCourses: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let nomNormalise: String
    public let libelle: String
    public private(set) var quantite: Quantite?
    public private(set) var unite: Unite?
    public internal(set) var categorie: Categorie
    public private(set) var origines: [OrigineCourses]
    public internal(set) var cochee: Bool
    var idsFusionnes: [UUID] = []

    public var quantiteArrondie: Quantite? {
        get throws {
            guard let quantite, let unite else { return nil }
            return try arrondirPourCourses(quantite, unite: unite)
        }
    }

    public var titreCourses: String {
        get throws {
            guard let quantite = try quantiteArrondie, let unite else { return libelle }
            return libelle + " " + (try formaterQuantiteCourses(quantite, unite: unite))
        }
    }

    init(article: ArticleCourses, origine: OrigineCourses) throws {
        id = UUID()
        libelle = article.nom
        nomNormalise = normaliserNom(article.nom)
        categorie = categorieParDefaut(nomNormalise)
        origines = [origine]
        cochee = false
        try fixerQuantite(article.quantite, unite: article.unite)
    }

    mutating func fixerQuantite(_ valeur: Quantite?, unite: Unite?) throws {
        guard let valeur else {
            guard unite == nil else { throw Ingredient.Erreur.uniteSansQuantite }
            quantite = nil
            self.unite = nil
            return
        }
        guard valeur > Quantite(0) else { throw Ingredient.Erreur.quantiteNonPositive }
        let source = unite ?? .piece
        guard source.nomAutreNormalise != "" else { throw Ingredient.Erreur.uniteSansLibelle }
        let canonique = source.canoniqueCourses
        quantite = try convertir(valeur, source, canonique)
        self.unite = canonique
    }

    func fusionnable(avec autre: LigneCourses) -> Bool {
        guard nomNormalise == autre.nomNormalise else { return false }
        guard let unite, let autreUnite = autre.unite else { return true }
        return unite.comparablePourCourses(a: autreUnite)
    }

    mutating func fusionner(avec autre: LigneCourses) throws {
        if let supplement = autre.quantite {
            if let quantite {
                self.quantite = try quantite + supplement
            } else {
                quantite = supplement
                unite = autre.unite
            }
        }
        for origine in autre.origines where !origines.contains(origine) {
            origines.append(origine)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, libelle, quantite, unite, categorie, origines, cochee
        case nomNormalise = "nom_normalise"
        case idsFusionnes = "ids_fusionnes"
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        id = try champs.decode(UUID.self, forKey: .id)
        libelle = try champs.decode(String.self, forKey: .libelle)
        nomNormalise = try champs.decode(String.self, forKey: .nomNormalise)
        categorie = try champs.decode(Categorie.self, forKey: .categorie)
        origines = try champs.decode([OrigineCourses].self, forKey: .origines)
        cochee = try champs.decode(Bool.self, forKey: .cochee)
        idsFusionnes = try champs.decodeIfPresent([UUID].self, forKey: .idsFusionnes) ?? []

        let quantite = try champs.decodeIfPresent(Quantite.self, forKey: .quantite)
        let unite = try champs.decodeIfPresent(Unite.self, forKey: .unite)
        guard !nomNormalise.isEmpty, nomNormalise == normaliserNom(libelle),
            !origines.isEmpty, Set(origines).count == origines.count,
            !idsFusionnes.contains(id), Set(idsFusionnes).count == idsFusionnes.count,
            (quantite == nil) == (unite == nil), unite == unite?.canoniqueCourses
        else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Ligne de courses invalide"))
        }
        try fixerQuantite(quantite, unite: unite)
    }
}
