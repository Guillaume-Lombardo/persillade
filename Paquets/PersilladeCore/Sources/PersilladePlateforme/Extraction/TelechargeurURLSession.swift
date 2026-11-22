import Foundation
import PersilladeCore

public struct TelechargeurURLSession: TelechargeurPage {
    private let session: URLSession
    private let tailleMax: Int
    private let delai: Duration

    public init(tailleMax: Int = 2_000_000) {
        self.init(configuration: .ephemeral, tailleMax: tailleMax, delai: .seconds(15))
    }

    init(configuration: URLSessionConfiguration, tailleMax: Int, delai: Duration) {
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.waitsForConnectivity = false
        configuration.httpShouldSetCookies = false
        configuration.urlCredentialStorage = nil
        self.session = URLSession(configuration: configuration)
        self.tailleMax = tailleMax
        self.delai = delai
    }

    public func telecharger(_ url: URL) async throws -> String {
        guard RedirectionsPage.urlPermise(url) else { throw CauseExtraction.pageInaccessible }
        do {
            return try await withThrowingTaskGroup(of: String.self) { groupe in
                groupe.addTask { try await lirePage(url) }
                groupe.addTask {
                    try await Task.sleep(for: delai)
                    throw CauseExtraction.delai
                }
                defer { groupe.cancelAll() }
                guard let texte = try await groupe.next() else { throw CauseExtraction.pageInaccessible }
                return texte
            }
        } catch let erreur as URLError {
            try Task.checkCancellation()
            switch erreur.code {
            case .timedOut: throw CauseExtraction.delai
            case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff:
                throw CauseExtraction.horsLigne
            case .appTransportSecurityRequiresSecureConnection:
                throw ErreurAccesPage.httpBloque
            case .cancelled: throw CancellationError()
            default: throw CauseExtraction.pageInaccessible
            }
        }
    }

    private func lirePage(_ url: URL) async throws -> String {
        var requete = URLRequest(url: url)
        requete.setValue("text/html, application/xhtml+xml, text/plain;q=0.8", forHTTPHeaderField: "Accept")
        let (octets, reponse) = try await session.bytes(for: requete, delegate: RedirectionsPage())
        defer { octets.task.cancel() }
        guard let http = reponse as? HTTPURLResponse, (200..<300).contains(http.statusCode),
            let mime = http.mimeType?.lowercased(),
            ["text/html", "application/xhtml+xml", "text/plain"].contains(mime),
            http.expectedContentLength <= tailleMax, tailleMax > 0
        else { throw CauseExtraction.pageInaccessible }

        var donnees = Data()
        if http.expectedContentLength > 0 { donnees.reserveCapacity(Int(http.expectedContentLength)) }
        for try await octet in octets {
            guard donnees.count < tailleMax else { throw CauseExtraction.pageInaccessible }
            donnees.append(octet)
        }

        guard let texte = Self.decoder(donnees, charsetHTTP: http.textEncodingName) else {
            throw CauseExtraction.pageInaccessible
        }
        return texte
    }

    private static func decoder(_ donnees: Data, charsetHTTP: String?) -> String? {
        if donnees.starts(with: [0xEF, 0xBB, 0xBF]) { return String(data: donnees.dropFirst(3), encoding: .utf8) }
        if donnees.starts(with: [0xFE, 0xFF]) || donnees.starts(with: [0xFF, 0xFE]) {
            return String(data: donnees, encoding: .utf16)
        }

        let entete = String(decoding: donnees.prefix(4096), as: UTF8.self)
        let motif = #"(?is)<meta\b[^>]*?\bcharset\s*=\s*["']?\s*([a-z0-9_-]+)"#
        var charsetMeta: String?
        if let regex = try? NSRegularExpression(pattern: motif),
            let resultat = regex.firstMatch(in: entete, range: NSRange(entete.startIndex..., in: entete)),
            let plage = Range(resultat.range(at: 1), in: entete)
        {
            charsetMeta = String(entete[plage])
        }

        for charset in [charsetHTTP, charsetMeta].compactMap({ $0?.lowercased() }) {
            switch charset {
            case "utf-8", "utf8": return String(data: donnees, encoding: .utf8)
            case "iso-8859-1", "iso8859-1", "latin1", "latin-1":
                return String(data: donnees, encoding: .isoLatin1)
            case "windows-1252", "cp1252": return String(data: donnees, encoding: .windowsCP1252)
            default: continue
            }
        }
        return String(data: donnees, encoding: .utf8) ?? String(data: donnees, encoding: .isoLatin1)
    }
}

private final class RedirectionsPage: NSObject, URLSessionTaskDelegate {
    static func urlPermise(_ url: URL) -> Bool {
        guard let protocole = url.scheme?.lowercased(), ["https", "http"].contains(protocole),
            let hote = url.host(), !hote.isEmpty
        else { return false }
        return url.user() == nil && url.password() == nil
    }

    func urlSession(
        _ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(request.url.map(Self.urlPermise) == true ? request : nil)
    }
}
