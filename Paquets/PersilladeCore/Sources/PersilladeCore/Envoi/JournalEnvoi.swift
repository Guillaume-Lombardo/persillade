import Foundation

public struct ArticleRappel: Codable, Equatable, Sendable {
    public let nomNormalise: String
    public let quantite: Quantite?
    let uniteOriginale: Unite?

    public var unite: Unite? {
        if case .autre(let nom) = uniteOriginale { return .autre(normaliserNom(nom)) }
        return uniteOriginale
    }

    init(nomNormalise: String, quantite: Quantite?, unite: Unite?) {
        self.nomNormalise = nomNormalise
        self.quantite = quantite
        uniteOriginale = unite
    }

    public init(titre: String) {
        let mots = titre.split(whereSeparator: \.isWhitespace)
        if mots.count >= 2, let derniere = Self.lireQuantite(mots.last) {
            self.init(
                nomNormalise: normaliserNom(mots.dropLast().joined(separator: " ")),
                quantite: derniere, unite: .piece)
        } else if mots.count >= 3, let avantDerniere = Self.lireQuantite(mots.dropLast().last),
            let dernier = mots.last, !normaliserNom(String(dernier)).isEmpty
        {
            self.init(
                nomNormalise: normaliserNom(mots.dropLast(2).joined(separator: " ")),
                quantite: avantDerniere,
                unite: Self.uniteConnue(dernier) ?? .autre(String(dernier)))
        } else if mots.count >= 2, let premiere = Self.lireQuantite(mots.first) {
            let unite = mots.count >= 3 ? Self.uniteConnue(mots[1]) : nil
            let nom = mots.dropFirst(unite == nil ? 1 : 2).joined(separator: " ")
            self.init(nomNormalise: normaliserNom(nom), quantite: premiere, unite: unite ?? .piece)
        } else {
            self.init(nomNormalise: normaliserNom(titre), quantite: nil, unite: nil)
        }
    }

    private static func lireQuantite(_ mot: Substring?) -> Quantite? {
        guard let mot else { return nil }
        do {
            let quantite = try Quantite(texte: String(mot))
            return quantite > Quantite(0) ? quantite : nil
        } catch {
            // Dans un titre libre, un mot qui ne représente pas une quantité reste du texte.
            return nil
        }
    }

    private static func uniteConnue(_ mot: Substring) -> Unite? {
        switch mot.lowercased() {
        case "g": .g
        case "kg": .kg
        case "ml": .ml
        case "cl": .cl
        case "l": .l
        case "cac": .cac
        case "cas": .cas
        default: nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case nomNormalise = "nom_normalise"
        case quantite
        case uniteOriginale = "unite"
    }
}

public struct JournalEnvoi: Codable, Equatable, Sendable {
    public struct Entree: Codable, Equatable, Sendable {
        public let rappelId: String
        public let rappelIdExterne: String?
        public let identifiantEcriture: UUID
        public let destinationId: String
        public let listeId: UUID
        public let ligneId: UUID
        public let article: ArticleRappel
        public let titreEcrit: String
        public let date: Date

        private enum CodingKeys: String, CodingKey {
            case rappelId = "rappel_id"
            case rappelIdExterne = "rappel_id_externe"
            case identifiantEcriture = "identifiant_ecriture"
            case destinationId = "destination_id"
            case listeId = "liste_id"
            case ligneId = "ligne_id"
            case article
            case titreEcrit = "titre_ecrit"
            case date
        }
    }

    public static let versionSchemaCourante = 1
    public internal(set) var entrees: [Entree] = []

    public init() {}

    public func article(du rappel: RappelCourses, destinationId: String? = nil) -> ArticleRappel {
        let entree =
            entrees.last { $0.rappelId == rappel.id }
            ?? rappel.identifiantEcriture.flatMap { identifiant in
                entrees.last { $0.identifiantEcriture == identifiant }
            }
            ?? rappel.idExterne.flatMap { identifiant in
                let correspondances = entrees.filter {
                    $0.rappelIdExterne == identifiant && (destinationId == nil || $0.destinationId == destinationId)
                }
                return correspondances.count == 1 ? correspondances.first : nil
            }
        if let entree, entree.titreEcrit == rappel.titre { return entree.article }
        return ArticleRappel(titre: rappel.titre)
    }

    private enum CodingKeys: String, CodingKey {
        case versionSchema = "version_schema"
        case entrees
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        let version = try champs.decode(Int.self, forKey: .versionSchema)
        guard version == Self.versionSchemaCourante else { throw ErreurMagasinDocument.versionInconnue(version) }
        entrees = try champs.decode([Entree].self, forKey: .entrees)
    }

    public func encode(to encoder: any Encoder) throws {
        var champs = encoder.container(keyedBy: CodingKeys.self)
        try champs.encode(Self.versionSchemaCourante, forKey: .versionSchema)
        try champs.encode(entrees, forKey: .entrees)
    }
}
