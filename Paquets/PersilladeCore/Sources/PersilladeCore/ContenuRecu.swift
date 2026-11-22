import Foundation

public struct ContenuRecu: Codable, Equatable, Identifiable, Sendable {
    public enum TypeContenu: String, Codable, Sendable {
        case url, texte, image
    }

    public enum Origine: String, Codable, Sendable {
        case feuillePartage = "feuille_partage"
        case pressePapiers = "presse_papiers"
        case appareilPhoto = "appareil_photo"
        case phototheque
    }

    public let id: UUID
    public let type: TypeContenu
    /// URL ou texte en UTF-8, ou octets de l'image. JSON encode ces données en base 64.
    public let contenu: Data
    public let origine: Origine
    public let recuLe: Date

    public init(
        id: UUID = UUID(), type: TypeContenu, contenu: Data, origine: Origine, recuLe: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.contenu = contenu
        self.origine = origine
        self.recuLe = recuLe
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, contenu, origine
        case recuLe = "recu_le"
    }
}
