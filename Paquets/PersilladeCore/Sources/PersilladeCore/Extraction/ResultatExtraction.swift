import Foundation

public enum CibleExtraction: String, Sendable {
    case recette, message
}

public enum StatutExtraction: String, Sendable {
    case complet, partiel, echec
}

public enum CauseExtraction: String, Codable, Error, Sendable {
    case iaIndisponible = "ia_indisponible"
    case iaEnErreur = "ia_en_erreur"
    case horsLigne = "hors_ligne"
    case pageInaccessible = "page_inaccessible"
    case delai
    case contenuTropLong = "contenu_trop_long"
    case rienTrouve = "rien_trouve"
    case fournisseurEnErreur = "fournisseur_en_erreur"
}

public enum ProvenanceExtraction: String, Sendable {
    case structure, embarque, manuel
    case cleExterne = "cle_externe"
}

public enum ErreurAccesPage: LocalizedError, Sendable {
    case httpBloque

    public var errorDescription: String? {
        "Le téléchargement HTTP est bloqué. Vous pouvez coller le texte de la recette."
    }
}

public struct BrouillonIngredient: Equatable, Sendable {
    public var nom: String
    public var quantite: Quantite?
    public var unite: Unite?
    public var alternatives: [AlternativeIngredient]
    public let texteOrigine: String
    public var ligneNonComprise: Bool

    public init(
        nom: String, quantite: Quantite? = nil, unite: Unite? = nil,
        texteOrigine: String, ligneNonComprise: Bool = false, alternatives: [AlternativeIngredient] = []
    ) {
        self.nom = nom
        self.quantite = quantite
        self.unite = unite
        self.alternatives = alternatives
        self.texteOrigine = texteOrigine
        self.ligneNonComprise = ligneNonComprise
    }

    public func valider() throws -> Ingredient {
        try Ingredient(
            nom: nom, quantite: quantite, unite: unite, texteOrigine: texteOrigine, alternatives: alternatives)
    }
}

public struct BrouillonRecette: Equatable, Sendable {
    public var titre: String
    public var portions: Int?
    public var ingredients: [BrouillonIngredient]
    public var etapes: [String]

    public var portionsEffectives: Int { Recette.portionsImportees(portions).portions }
    public var portionsSupposees: Bool { portions == nil }

    public init(
        titre: String = "", portions: Int? = nil, ingredients: [BrouillonIngredient] = [], etapes: [String] = []
    ) {
        self.titre = titre
        self.portions = portions
        self.ingredients = ingredients
        self.etapes = etapes
    }

    public func valider(id: UUID = UUID(), texteSource: String, urlSource: URL? = nil) throws -> Recette {
        try Recette(
            id: id, titre: titre, portions: portionsEffectives, ingredients: ingredients.map { try $0.valider() },
            etapes: etapes, texteSource: texteSource, urlSource: urlSource)
    }

    var statut: StatutExtraction {
        let aUnTitre = !titre.epure.isEmpty
        if aUnTitre && !ingredients.isEmpty && ingredients.allSatisfy({ !$0.nom.epure.isEmpty }) && !etapes.isEmpty {
            return .complet
        }
        return aUnTitre || !ingredients.isEmpty || !etapes.isEmpty ? .partiel : .echec
    }
}

public struct ArticleExtrait: Equatable, Sendable {
    public var nom: String
    public var quantite: Quantite?
    public var unite: Unite?
    public let messageID: UUID

    public init(nom: String, quantite: Quantite? = nil, unite: Unite? = nil, messageID: UUID) {
        self.nom = nom
        self.quantite = quantite
        self.unite = unite
        self.messageID = messageID
    }
}

public struct ResultatExtraction: Equatable, Sendable {
    public let statut: StatutExtraction
    public let cause: CauseExtraction?
    public let moteur: ProvenanceExtraction
    public let texteSource: String
    public let urlSource: URL?
    public var recette: BrouillonRecette?
    public var articles: [ArticleExtrait]
    public internal(set) var erreurAccesPage: ErreurAccesPage?

    public var messageAccesPage: String? {
        if let erreurAccesPage { return erreurAccesPage.errorDescription }
        switch cause {
        case .horsLigne: return "Vous êtes hors ligne. Vous pouvez coller le texte de la recette."
        case .pageInaccessible: return "Cette page est inaccessible. Vous pouvez coller le texte de la recette."
        case .delai: return "La page a mis trop de temps à répondre. Vous pouvez coller le texte de la recette."
        default: return nil
        }
    }

    public func validerRecette(id: UUID = UUID()) throws -> Recette {
        try (recette ?? BrouillonRecette()).valider(id: id, texteSource: texteSource, urlSource: urlSource)
    }
}

extension String {
    var epure: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    func remplacer(_ motif: String, par remplacement: String) -> String {
        replacingOccurrences(of: motif, with: remplacement, options: .regularExpression)
    }

    func correspond(_ motif: String) -> Bool {
        range(of: motif, options: .regularExpression) != nil
    }
}
