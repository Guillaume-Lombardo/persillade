import Foundation

public protocol MagasinDocument: Sendable {
    func lire<Document: Codable & Sendable>(
        _ type: Document.Type, cle: String, version: Int
    ) async throws -> Document

    func ecrire<Document: Codable & Sendable>(
        _ document: Document, cle: String, version: Int
    ) async throws
}

public enum ErreurMagasinDocument: Error, Equatable, Sendable {
    case absent
    case corrompu(copie: URL)
    case versionInconnue(Int)
    case cleInvalide(String)
}
