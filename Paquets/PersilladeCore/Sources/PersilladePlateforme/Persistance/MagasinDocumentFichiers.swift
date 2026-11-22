import Foundation
import PersilladeCore

public actor MagasinDocumentFichiers: MagasinDocument {
    private struct Version: Decodable {
        let versionSchema: Int

        enum CodingKeys: String, CodingKey {
            case versionSchema = "version_schema"
        }
    }

    private struct Enveloppe<Document: Codable>: Codable {
        let versionSchema: Int
        let document: Document

        enum CodingKeys: String, CodingKey {
            case versionSchema = "version_schema"
            case document
        }
    }

    private let dossier: URL

    public init(dossier: URL = URL.applicationSupportDirectory.appending(path: "Documents")) {
        self.dossier = dossier
    }

    public func lire<Document: Codable & Sendable>(
        _ type: Document.Type, cle: String, version: Int
    ) throws -> Document {
        try coordonnerEcriture(fichier(cle: cle)) { url in
            try decoder(type, url: url, version: version)
        }
    }

    public func ecrire<Document: Codable & Sendable>(
        _ document: Document, cle: String, version: Int
    ) throws {
        let donnees = try JSONEncoder().encode(Enveloppe(versionSchema: version, document: document))
        try coordonnerEcriture(fichier(cle: cle)) { url in
            do {
                _ = try decoder(Document.self, url: url, version: version)
            } catch ErreurMagasinDocument.absent {
                // Premier enregistrement pour cette clé.
            }
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try donnees.write(to: url, options: .atomic)
        }
    }

    private func fichier(cle: String) throws -> URL {
        let caracteres = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
        guard (1...250).contains(cle.utf8.count), cle.allSatisfy({ caracteres.contains($0) }) else {
            throw ErreurMagasinDocument.cleInvalide(cle)
        }
        // L'encodage distingue les casses. Les segments laissent de la place au suffixe de quarantaine.
        let nom = cle.utf8.map { String(format: "%02x", $0) }.joined()
        var repertoire = dossier
        var reste = nom[...]
        while reste.count > 128 {
            repertoire.append(path: String(reste.prefix(128)), directoryHint: .isDirectory)
            reste = reste.dropFirst(128)
        }
        return repertoire.appending(path: reste + ".json", directoryHint: .notDirectory)
    }

    private func decoder<Document: Codable>(
        _ type: Document.Type, url: URL, version: Int
    ) throws -> Document {
        let donnees: Data
        do {
            donnees = try Data(contentsOf: url)
        } catch let erreur as CocoaError where erreur.code == .fileReadNoSuchFile || erreur.code == .fileNoSuchFile {
            throw ErreurMagasinDocument.absent
        }
        let decodeur = JSONDecoder()
        let lue: Int
        do {
            lue = try decodeur.decode(Version.self, from: donnees).versionSchema
        } catch {
            throw try isolerDocumentCorrompu(url)
        }
        guard lue == version else { throw ErreurMagasinDocument.versionInconnue(lue) }
        do {
            return try decodeur.decode(Enveloppe<Document>.self, from: donnees).document
        } catch {
            throw try isolerDocumentCorrompu(url)
        }
    }

    private func isolerDocumentCorrompu(_ url: URL) throws -> ErreurMagasinDocument {
        let copie = url.deletingPathExtension().appendingPathExtension("\(UUID().uuidString).corrompu")
        try FileManager.default.moveItem(at: url, to: copie)
        return .corrompu(copie: copie)
    }
}
