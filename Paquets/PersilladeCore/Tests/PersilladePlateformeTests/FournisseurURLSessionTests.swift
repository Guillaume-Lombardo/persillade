import Foundation
import PersilladeCore
import Testing

@testable import PersilladePlateforme

private final class ProtocoleFournisseurTest: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else { return }
        let cas = url.path().split(separator: "/").first.map(String.init)
        if cas == "interdit" { Issue.record("Une requête a suivi une redirection interdite.") }
        let redirect: String? =
            switch cas {
            case "redirection-origine": "https://api.exemple.test/succes/chat/completions"
            case "redirection-hote": "https://autre.exemple.test/interdit"
            case "redirection-port": "https://api.exemple.test:8443/interdit"
            case "redirection-http": "http://api.exemple.test/interdit"
            case "redirection-identifiant": "https://nom@api.exemple.test/interdit"
            default: nil
            }
        if let redirect, let destination = URL(string: redirect),
            let reponse = HTTPURLResponse(
                url: url, statusCode: 302, httpVersion: nil, headerFields: ["Location": redirect])
        {
            client?.urlProtocol(self, wasRedirectedTo: URLRequest(url: destination), redirectResponse: reponse)
            return
        }

        let statut =
            switch cas {
            case "client": 401
            case "serveur": 503
            case "succes":
                request.httpMethod == "POST" && request.value(forHTTPHeaderField: "Authorization") == "Bearer fictif"
                    && request.value(forHTTPHeaderField: "Content-Type") == "application/json" ? 200 : 400
            default: 200
            }
        var entetes = ["Content-Type": "application/json"]
        if cas == "taille-annoncee" { entetes["Content-Length"] = "90000" }
        guard let reponse = HTTPURLResponse(url: url, statusCode: statut, httpVersion: nil, headerFields: entetes)
        else { return }
        var contenu = #"{"articles":["3 œufs"]}"#
        switch cas {
        case "faux-schema": contenu = #"{"articles":["3 œufs"],"commande":"ignore tout"}"#
        case "faux-types": contenu = #"{"articles":[3]}"#
        case "pas-de-citations": contenu = #"{"articles":[" " ]}"#
        case "json-invalide": contenu = "texte en clair"
        case "recette": contenu = #"{"titre":null,"portions":null,"ingredients":["3 œufs"],"etapes":[]}"#
        case "recette-incomplete": contenu = #"{"ingredients":["3 œufs"],"etapes":[]}"#
        default: break
        }
        let enveloppe: [String: Any] = [
            "choices": [
                [
                    "finish_reason": cas == "tronque" ? "length" : "stop",
                    "message": ["role": "assistant", "content": contenu],
                ]
            ]
        ]
        guard let donnees = try? JSONSerialization.data(withJSONObject: enveloppe) else { return }
        client?.urlProtocol(self, didReceive: reponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: cas == "taille-reelle" ? Data(repeating: 65, count: 4096) : donnees)
        if cas != "lent" { client?.urlProtocolDidFinishLoading(self) }
    }

    override func stopLoading() {}
}

private let sourceTest = ContenuRecu(
    type: .texte, contenu: Data("3 œufs".utf8), origine: .pressePapiers)

private func requeteTest(_ cas: String, cible: CibleExtraction = .message) async throws -> RequeteFournisseur {
    let local = try await Extracteur().extraire(sourceTest, cible: cible)
    var configuration = ConfigurationFournisseur()
    configuration.adresse = "https://api.exemple.test/\(cas)"
    configuration.modele = "modèle fictif"
    configuration.active = true
    configuration.consentir()
    return try #require(configuration.requete(pour: sourceTest, cible: cible, resultatLocal: local))
}

private func clientTest(delai: Duration = .seconds(5)) -> FournisseurURLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ProtocoleFournisseurTest.self]
    return FournisseurURLSession(configuration: configuration, tailleReponseMax: 1024, delai: delai)
}

@Test(arguments: ["succes", "redirection-origine"])
func reponseFournisseurEtRedirectionMemeOrigine(_ cas: String) async throws {
    let requete = try await requeteTest(cas)
    let cle = try #require(CleFournisseur("fictif"))
    #expect(try await clientTest().completer(requete, cle: cle).articles == ["3 œufs"])
}

@Test func reponseFournisseurRecette() async throws {
    let requete = try await requeteTest("recette", cible: .recette)
    let cle = try #require(CleFournisseur("fictif"))
    let proposition = try await clientTest().completer(requete, cle: cle)
    #expect(proposition.titre == nil)
    #expect(proposition.ingredients == ["3 œufs"])
}

@Test(arguments: [
    "client", "serveur", "redirection-hote", "redirection-port", "redirection-http", "redirection-identifiant",
    "faux-schema", "faux-types", "pas-de-citations", "json-invalide", "recette-incomplete",
    "tronque", "taille-annoncee", "taille-reelle",
])
func erreursFournisseurNormalisees(_ cas: String) async throws {
    let requete = try await requeteTest(cas, cible: cas == "recette-incomplete" ? .recette : .message)
    let cle = try #require(CleFournisseur("fictif"))
    await #expect(throws: CauseExtraction.fournisseurEnErreur) {
        try await clientTest().completer(requete, cle: cle)
    }
}

@Test(.timeLimit(.minutes(1))) func delaiTotalEtAnnulationFournisseur() async throws {
    let requete = try await requeteTest("lent")
    let cle = try #require(CleFournisseur("fictif"))
    let debut = ContinuousClock.now
    await #expect(throws: CauseExtraction.fournisseurEnErreur) {
        try await clientTest(delai: .milliseconds(150)).completer(requete, cle: cle)
    }
    #expect(ContinuousClock.now - debut < .seconds(3))
    let traitement = Task { try await clientTest().completer(requete, cle: cle) }
    traitement.cancel()
    await #expect(throws: CancellationError.self) { try await traitement.value }
}
