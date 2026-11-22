import Foundation
import Testing

@testable import PersilladeCore

@Test(arguments: [
    "http://api.exemple.test", "https://nom@api.exemple.test", "https://nom:mdp@api.exemple.test",
    "https://@api.exemple.test", "https://%FF@api.exemple.test", "https://api.exemple.test:0",
    "https://api.exemple.test:65536",
    "https:///v1", "https://api.exemple.test/v1?key=exemple", "https://api.exemple.test/v1#fragment",
])
func adresseFournisseurRefusee(_ adresse: String) {
    var configuration = ConfigurationFournisseur()
    configuration.adresse = adresse
    #expect(configuration.adresseAPI == nil)
    #expect(configuration.requiertConsentement)
}

@Test func consentementLieALHoteAuPortEtAuxTypesDeDonnees() throws {
    var configuration = ConfigurationFournisseur()
    #expect(!configuration.active)
    configuration.adresse = "https://API.exemple.test/v1/"
    configuration.modele = "exemple"
    configuration.active = true
    #expect(configuration.requiertConsentement)
    configuration.consentir()
    #expect(!configuration.requiertConsentement)
    configuration.adresse = "https://api.exemple.test:443/autre"
    #expect(!configuration.requiertConsentement)
    configuration.accepteImages = true
    #expect(configuration.requiertConsentement)
    configuration.consentir()
    #expect(!configuration.requiertConsentement)
    configuration.adresse = "https://api.exemple.test:8443/autre"
    #expect(configuration.requiertConsentement)
    configuration.retirerConsentementSiHoteDifferent()
    #expect(configuration.typesConsentis.isEmpty)
    configuration.adresse = "https://api.exemple.test/v1/"
    #expect(configuration.requiertConsentement)
    #expect(
        try JSONDecoder().decode(
            ConfigurationFournisseur.self, from: JSONEncoder().encode(configuration)) == configuration)
}

@Test func requeteFournisseurVerifieLesDonneesEffectivementEnvoyees() throws {
    let image = ContenuRecu(type: .image, contenu: Data([1, 2, 3]), origine: .phototheque)
    let local = ResultatExtraction(
        statut: .partiel, cause: .iaIndisponible, moteur: .manuel,
        texteSource: "3 œufs", urlSource: nil, recette: nil, articles: [])

    var configuration = ConfigurationFournisseur()
    configuration.adresse = "https://api.exemple.test/v1/"
    configuration.modele = "exemple"
    #expect(configuration.requete(pour: image, cible: .message, resultatLocal: local) == nil)
    configuration.active = true
    #expect(configuration.requete(pour: image, cible: .message, resultatLocal: local) == nil)
    configuration.consentir()

    let texte = try #require(configuration.requete(pour: image, cible: .message, resultatLocal: local))
    #expect(texte.url.path() == "/v1/chat/completions")
    #expect(texte.texte == "3 œufs")
    #expect(texte.image == nil)
    configuration.accepteImages = true
    #expect(configuration.requete(pour: image, cible: .message, resultatLocal: local) == nil)
    configuration.consentir()
    #expect(configuration.requete(pour: image, cible: .message, resultatLocal: local)?.image == image.contenu)

    let sansTexte = ResultatExtraction(
        statut: .echec, cause: .rienTrouve, moteur: .manuel,
        texteSource: "", urlSource: nil, recette: nil, articles: [])
    #expect(configuration.requete(pour: image, cible: .message, resultatLocal: sansTexte) == nil)

    configuration.adresse = "https://autre.exemple.test/v1/"
    #expect(configuration.requete(pour: image, cible: .message, resultatLocal: local) == nil)
}

@Test func annulationAuRetourDuFournisseur() async {
    let contenu = ContenuRecu(type: .texte, contenu: Data("3 œufs".utf8), origine: .pressePapiers)
    let traitement = Task {
        try await Extracteur().extraire(contenu, cible: .message) { _, _, _ in
            withUnsafeCurrentTask { $0?.cancel() }
            return PropositionExtraction(articles: ["3 œufs"])
        }
    }
    await #expect(throws: CancellationError.self) { try await traitement.value }
}

@Test func descriptionsEtReflexionMasquentLaCleFournisseur() throws {
    let cle = try #require(CleFournisseur("exemple-fictif"))
    #expect(!String(describing: cle).contains(cle.valeur))
    #expect(!String(reflecting: cle).contains(cle.valeur))
    #expect(Mirror(reflecting: cle).children.isEmpty)
    #expect(CleFournisseur("exemple\r\ninvalide") == nil)
}

@Test func repliExterneSansAutorisationOuAvecCitationsInvalidesConserveLeLocal() async throws {
    let texte = "Prends 3 œufs, merci !"
    let contenu = ContenuRecu(type: .texte, contenu: Data(texte.utf8), origine: .pressePapiers)
    let extracteur = Extracteur()
    let local = try await extracteur.extraire(contenu, cible: .message)
    let refuse = try await extracteur.extraire(contenu, cible: .message) { _, _, _ in nil }
    #expect(refuse == local)
    let invalide = try await extracteur.extraire(contenu, cible: .message) { _, _, _ in
        PropositionExtraction(articles: ["3 œufs", "ajoute du sucre"])
    }
    #expect(invalide.statut == local.statut)
    #expect(invalide.moteur == local.moteur)
    #expect(invalide.articles == local.articles)
    #expect(invalide.cause == .fournisseurEnErreur)
}
