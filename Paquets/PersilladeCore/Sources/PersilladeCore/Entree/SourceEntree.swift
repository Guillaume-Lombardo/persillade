import Foundation

extension ContenuRecu {
    public enum ErreurSource: Error, Equatable, Sendable {
        case contenuNonPrisEnCharge
    }

    public init?(urlWeb: URL, origine: Origine) {
        guard let schema = urlWeb.scheme?.lowercased(), ["http", "https"].contains(schema),
            let hote = urlWeb.host(), !hote.isEmpty
        else { return nil }
        self.init(type: .url, contenu: Data(urlWeb.absoluteString.utf8), origine: origine)
    }

    public init?(texte: String, origine: Origine) {
        let valeur = texte.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !valeur.isEmpty else { return nil }
        if valeur.rangeOfCharacter(from: .whitespacesAndNewlines) == nil,
            let url = URL(string: valeur), let lien = Self(urlWeb: url, origine: origine)
        {
            self = lien
        } else {
            self.init(type: .texte, contenu: Data(texte.utf8), origine: origine)
        }
    }

    @MainActor
    public static func charger(
        _ fournisseurs: [NSItemProvider], origine: Origine
    ) async throws -> ContenuRecu {
        var derniereErreur: any Error = ErreurSource.contenuNonPrisEnCharge
        for fournisseur in fournisseurs where fournisseur.hasItemConformingToTypeIdentifier("public.url") {
            do {
                let url: URL = try await withCheckedThrowingContinuation { suite in
                    _ = fournisseur.loadObject(ofClass: URL.self) { url, erreur in
                        if let url {
                            suite.resume(returning: url)
                        } else {
                            suite.resume(throwing: erreur ?? ErreurSource.contenuNonPrisEnCharge)
                        }
                    }
                }
                if let contenu = Self(urlWeb: url, origine: origine) { return contenu }
            } catch {
                derniereErreur = error
            }
        }
        for fournisseur in fournisseurs {
            for type in ["public.plain-text", "public.text"]
            where fournisseur.hasItemConformingToTypeIdentifier(type) {
                do {
                    let donnees: Data = try await withCheckedThrowingContinuation { suite in
                        _ = fournisseur.loadDataRepresentation(forTypeIdentifier: type) { donnees, erreur in
                            if let donnees {
                                suite.resume(returning: donnees)
                            } else {
                                suite.resume(throwing: erreur ?? ErreurSource.contenuNonPrisEnCharge)
                            }
                        }
                    }
                    let texte =
                        String(data: donnees, encoding: .utf8)
                        ?? String(data: donnees, encoding: .utf16)
                    if let texte, let contenu = Self(texte: texte, origine: origine) { return contenu }
                } catch {
                    derniereErreur = error
                }
            }
        }
        throw derniereErreur
    }
}
