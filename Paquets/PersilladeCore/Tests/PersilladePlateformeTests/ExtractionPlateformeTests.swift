import Foundation
import FoundationModels
import PersilladeCore
import Testing

@testable import PersilladePlateforme

private final class ProtocolePageTest: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else { return }
        var statut = 200
        var entetes = ["Content-Type": "text/html"]
        var donnees = Data()
        switch url.path() {
        case "/utf8":
            donnees = Data("<p>Crêpes au miel</p>".utf8)
        case "/latin1-http":
            entetes["Content-Type"] = "text/html; charset=ISO-8859-1"
            donnees = Data([0x43, 0x72, 0xEA, 0x70, 0x65, 0x73])
        case "/latin1-meta":
            donnees = Data("<meta charset='ISO-8859-1'><p>Cr".utf8) + Data([0xEA]) + Data("pes</p>".utf8)
        case "/xhtml":
            entetes["Content-Type"] = "application/xhtml+xml; charset=utf-8"
            donnees = Data("<p>Salade d’été</p>".utf8)
        case "/mauvais-mime":
            entetes["Content-Type"] = "application/pdf"
        case "/statut":
            statut = 404
        case "/taille-annoncee":
            entetes["Content-Length"] = "99999"
        case "/taille-reelle":
            donnees = Data(repeating: 65, count: 4096)
        case "/hors-ligne":
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        case "/ats":
            client?.urlProtocol(self, didFailWithError: URLError(.appTransportSecurityRequiresSecureConnection))
            return
        case "/redirection":
            guard let destination = URL(string: "/utf8", relativeTo: url)?.absoluteURL,
                let reponse = HTTPURLResponse(
                    url: url, statusCode: 302, httpVersion: nil,
                    headerFields: ["Location": destination.absoluteString])
            else { return }
            client?.urlProtocol(self, wasRedirectedTo: URLRequest(url: destination), redirectResponse: reponse)
            return
        case "/lent":
            donnees = Data("<p>".utf8)
        default:
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }
        guard let reponse = HTTPURLResponse(url: url, statusCode: statut, httpVersion: nil, headerFields: entetes)
        else { return }
        client?.urlProtocol(self, didReceive: reponse, cacheStoragePolicy: .notAllowed)
        if !donnees.isEmpty { client?.urlProtocol(self, didLoad: donnees) }
        if url.path() != "/lent" { client?.urlProtocolDidFinishLoading(self) }
    }

    override func stopLoading() {}
}

private func clientTest(tailleMax: Int = 1024, delai: Duration = .seconds(5)) -> TelechargeurURLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [ProtocolePageTest.self]
    return TelechargeurURLSession(configuration: configuration, tailleMax: tailleMax, delai: delai)
}

private func urlTest(_ chemin: String, schema: String = "https") throws -> URL {
    try #require(URL(string: "\(schema)://recettes.example/\(chemin)"))
}

@Test(arguments: [
    ("utf8", "<p>Crêpes au miel</p>"),
    ("latin1-http", "Crêpes"),
    ("latin1-meta", "<meta charset='ISO-8859-1'><p>Crêpes</p>"),
    ("xhtml", "<p>Salade d’été</p>"),
])
func telechargementEtEncodages(chemin: String, attendu: String) async throws {
    #expect(try await clientTest().telecharger(urlTest(chemin)) == attendu)
}

@Test func suitUneRedirectionHTTP() async throws {
    #expect(try await clientTest().telecharger(urlTest("redirection")) == "<p>Crêpes au miel</p>")
}

@Test(arguments: ["mauvais-mime", "statut", "taille-annoncee", "taille-reelle"])
func typesEtTaillesRejetes(_ chemin: String) async throws {
    let url = try urlTest(chemin)
    await #expect(throws: CauseExtraction.pageInaccessible) {
        try await clientTest().telecharger(url)
    }
}

@Test func horsLigneEtATS() async throws {
    let client = clientTest()
    let horsLigne = try urlTest("hors-ligne")
    await #expect(throws: CauseExtraction.horsLigne) { try await client.telecharger(horsLigne) }
    let bloque = try urlTest("ats", schema: "http")
    await #expect(throws: ErreurAccesPage.httpBloque) { try await client.telecharger(bloque) }
    let permis = try urlTest("utf8", schema: "http")
    #expect(try await client.telecharger(permis) == "<p>Crêpes au miel</p>")
    let ftp = try urlTest("utf8", schema: "ftp")
    await #expect(throws: CauseExtraction.pageInaccessible) { try await client.telecharger(ftp) }
}

@Test(.timeLimit(.minutes(1))) func delaiTotalInclutLeCorps() async throws {
    let url = try urlTest("lent")
    let debut = ContinuousClock.now
    await #expect(throws: CauseExtraction.delai) {
        try await clientTest(delai: .milliseconds(150)).telecharger(url)
    }
    #expect(ContinuousClock.now - debut < .seconds(3))
}

@Test(.timeLimit(.minutes(1))) func annulationTelechargement() async throws {
    let url = try urlTest("lent")
    let tache = Task { try await clientTest().telecharger(url) }
    tache.cancel()
    await #expect(throws: CancellationError.self) { try await tache.value }
}

@available(iOS 27.0, macOS 27.0, *)
@Test(arguments: [
    (
        SystemLanguageModel.Availability.unavailable(.appleIntelligenceNotEnabled),
        MoteurFondation.Indisponibilite.desactive
    ),
    (SystemLanguageModel.Availability.unavailable(.modelNotReady), MoteurFondation.Indisponibilite.modeleEnAttente),
    (
        SystemLanguageModel.Availability.unavailable(.deviceNotEligible),
        MoteurFondation.Indisponibilite.appareilNonCompatible
    ),
])
func disponibiliteFondation(
    etat: SystemLanguageModel.Availability, attendu: MoteurFondation.Indisponibilite
) {
    #expect(MoteurFondation.indisponibilite(etat, francaisPrisEnCharge: true) == attendu)
}

@available(iOS 27.0, macOS 27.0, *)
@Test(.enabled(if: ProcessInfo.processInfo.environment["PERSILLADE_TEST_FONDATION"] == "1"), .timeLimit(.minutes(3)))
func essaiManuelFondation() async throws {
    let moteur = MoteurFondation()
    if let raison = moteur.indisponibilite {
        print("Essai local indisponible (\(raison)).")
        return
    }

    let extracteur = Extracteur(moteurIA: moteur)
    let textes: [(String, CibleExtraction, String)] = [
        (
            "Recette en prose", .recette,
            """
            Hier j’ai refait la brioche à la fleur d’oranger qu’on mangeait le samedi matin.
            J’ai pesé 350 g de farine et j’ai délayé un sachet de levure dans 15 cl de lait tiède.
            On ajoute ensuite deux œufs et on laisse lever la pâte près du four pendant deux heures.
            Le tout donne 8 parts généreuses.
            """
        ),
        ("Message en prose", .message, "Si tu passes au marché, prends deux citrons et 1 kg de pommes, merci !"),
        ("Liste de courses", .message, "Pour demain\n3 œufs\n120 g de noix\nune botte de radis"),
    ]
    for (nom, cible, texte) in textes {
        let recu = ContenuRecu(type: .texte, contenu: Data(texte.utf8), origine: .pressePapiers)
        let debut = ContinuousClock.now
        let resultat = try await extracteur.extraire(recu, cible: cible)
        let elements = resultat.recette?.ingredients.count ?? resultat.articles.count
        let statut = resultat.statut.rawValue
        print(
            "\(nom) : \(statut), \(elements) éléments, \(ContinuousClock.now - debut), \(resultat.cause?.rawValue ?? "sans erreur")"
        )
        #expect(resultat.moteur == .embarque)
        #expect(elements > 0)
    }
}
