import Foundation
import PersilladeCore

/// File persistante des photos en cours d’import, dans un dossier dédié hors sauvegarde.
public struct MagasinPhotos: Sendable {
    private let dossier: URL
    private let file: FileEntree

    public init(
        dossier: URL = URL.applicationSupportDirectory.appending(path: "PhotosImport", directoryHint: .isDirectory)
    ) {
        self.dossier = dossier
        file = FileEntree(dossier: dossier)
    }

    public func deposer(_ image: Data, origine: ContenuRecu.Origine) async throws -> ContenuRecu {
        guard origine == .appareilPhoto || origine == .phototheque else {
            throw ErreurCapture.origineInvalide
        }
        try Task.checkCancellation()
        let contenu = ContenuRecu(type: .image, contenu: try ImageCapture.preparer(image), origine: origine)
        try Task.checkCancellation()
        do {
            try preparerDossier()
            try await file.deposer(contenu)
            return contenu
        } catch {
            throw ErreurCapture.stockage(error)
        }
    }

    public func lire() async throws -> FileEntree.Lecture {
        do {
            try preparerDossier()
            return try await file.lire()
        } catch {
            throw ErreurCapture.stockage(error)
        }
    }

    /// À appeler après un enregistrement réussi ou un abandon explicite. L’opération est idempotente.
    public func retirer(id: UUID) async throws {
        do {
            try preparerDossier()
            try await file.retirer(id: id)
        } catch {
            throw ErreurCapture.stockage(error)
        }
    }

    private func preparerDossier() throws {
        var dossier = dossier
        try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
        var proprietes = URLResourceValues()
        proprietes.isExcludedFromBackup = true
        try dossier.setResourceValues(proprietes)
    }
}
