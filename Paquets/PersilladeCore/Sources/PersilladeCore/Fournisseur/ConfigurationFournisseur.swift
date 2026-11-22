import Foundation

public enum TypeDonneeFournisseur: String, Codable, Sendable {
    case texte, image
}

public struct HoteFournisseur: Codable, Equatable, Sendable {
    public let hote: String
    public let port: Int

    public init?(adresse: URL) {
        guard adresse.scheme?.lowercased() == "https", let hote = adresse.host(percentEncoded: true),
            !hote.isEmpty, adresse.user(percentEncoded: true) == nil, adresse.password(percentEncoded: true) == nil,
            (1...65535).contains(adresse.port ?? 443)
        else { return nil }
        self.hote = hote.lowercased()
        port = adresse.port ?? 443
    }
}

public struct ConfigurationFournisseur: Codable, Equatable, Sendable {
    public var active = false
    public var adresse = ""
    public var modele = ""
    public var accepteImages = false
    public private(set) var hoteConsenti: HoteFournisseur?
    public private(set) var typesConsentis: Set<TypeDonneeFournisseur> = []

    public init() {}

    public var adresseAPI: URL? {
        guard let url = URL(string: adresse.epure, encodingInvalidCharacters: false),
            HoteFournisseur(adresse: url) != nil,
            url.query(percentEncoded: true) == nil, url.fragment(percentEncoded: true) == nil
        else { return nil }
        return url
    }

    public var hote: HoteFournisseur? {
        adresseAPI.flatMap(HoteFournisseur.init(adresse:))
    }

    public var typesDemandes: Set<TypeDonneeFournisseur> {
        accepteImages ? [.texte, .image] : [.texte]
    }

    public var requiertConsentement: Bool {
        hote == nil || hote != hoteConsenti || !typesDemandes.isSubset(of: typesConsentis)
    }

    public mutating func consentir() {
        guard let hote else { return }
        if hote != hoteConsenti { typesConsentis = [] }
        hoteConsenti = hote
        typesConsentis.formUnion(typesDemandes)
    }

    public mutating func retirerConsentementSiHoteDifferent() {
        guard hote != hoteConsenti else { return }
        hoteConsenti = nil
        typesConsentis = []
    }

    public func requete(
        pour contenu: ContenuRecu, cible: CibleExtraction, resultatLocal: ResultatExtraction
    ) -> RequeteFournisseur? {
        guard active, resultatLocal.statut != .complet, let adresseAPI, let hote, hote == hoteConsenti,
            !modele.epure.isEmpty
        else { return nil }

        let texte = resultatLocal.texteSource
        let image = contenu.type == .image && accepteImages ? contenu.contenu : nil
        guard !texte.epure.isEmpty else { return nil }
        let types: Set<TypeDonneeFournisseur> = image == nil ? [.texte] : [.texte, .image]
        guard types.isSubset(of: typesConsentis) else { return nil }

        return RequeteFournisseur(
            url: adresseAPI.appending(path: "chat/completions"), modele: modele.epure,
            cible: cible, texte: texte, image: image)
    }
}

public struct RequeteFournisseur: Sendable {
    public let url: URL
    public let modele: String
    public let cible: CibleExtraction
    public let texte: String
    public let image: Data?
}

public protocol FournisseurIA: Sendable {
    func completer(_ requete: RequeteFournisseur, cle: CleFournisseur) async throws -> PropositionExtraction
}

public struct CleFournisseur: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package let valeur: String

    public init?(_ valeur: String) {
        let valeur = valeur.epure
        guard !valeur.isEmpty, valeur.utf8.count <= 4096,
            valeur.utf8.allSatisfy({ (33...126).contains($0) })
        else { return nil }
        self.valeur = valeur
    }

    public var description: String { "[clé masquée]" }
    public var debugDescription: String { description }
    public var customMirror: Mirror { Mirror(self, children: [:]) }
}
