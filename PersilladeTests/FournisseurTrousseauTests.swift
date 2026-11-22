import Foundation
import PersilladeCore
import Security
import Testing

@testable import PersilladePlateforme

#if targetEnvironment(simulator)
    private actor FournisseurBouchon: FournisseurIA {
        private(set) var appels = 0
        private var suspendre = false
        private var attenteDuDebut: CheckedContinuation<Void, Never>?

        func suspendreProchainAppel() { suspendre = true }

        func attendreAppelSuspendu() async {
            if suspendre { await withCheckedContinuation { attenteDuDebut = $0 } }
        }

        func completer(_ requete: RequeteFournisseur, cle: CleFournisseur) async throws -> PropositionExtraction {
            appels += 1
            #expect(requete.url.path() == "/v1/chat/completions")
            if suspendre {
                suspendre = false
                attenteDuDebut?.resume()
                attenteDuDebut = nil
                try await Task.sleep(for: .seconds(15))
            }
            return PropositionExtraction(articles: ["3 œufs"])
        }
    }

    @MainActor @Test func trousseauFournisseurEtRepliSurIPhone() async throws {
        let service = "persillade.tests.fournisseur.\(UUID().uuidString)"
        let preferences = try #require(UserDefaults(suiteName: service))
        let fournisseur = FournisseurBouchon()
        let reglages = ReglagesFournisseur(preferences: preferences, service: service, fournisseur: fournisseur)
        defer {
            do {
                try reglages.supprimerCle()
            } catch {
                Issue.record("Suppression de la clé de test impossible.")
            }
            preferences.removePersistentDomain(forName: service)
        }

        let contenu = ContenuRecu(type: .texte, contenu: Data("3 œufs".utf8), origine: .pressePapiers)
        let extracteur = Extracteur()
        let local = try await extracteur.extraire(contenu, cible: .message)
        var configuration = reglages.configuration
        #expect(!configuration.active)
        #expect(
            try await extracteur.extraire(
                contenu, cible: .message, repliConsenti: reglages.repliConsenti) == local)

        configuration.adresse = "https://api.exemple.test/v1"
        configuration.modele = "fictif"
        configuration.active = true
        #expect(throws: ErreurReglagesFournisseur.consentement) {
            try reglages.enregistrer(configuration, nouvelleCle: "cle-fictive-du-test")
        }
        #expect(try !reglages.aUneCle(pour: configuration))
        configuration.consentir()
        #expect(throws: ErreurReglagesFournisseur.cle) { try reglages.enregistrer(configuration) }
        #expect(await fournisseur.appels == 0)

        try reglages.enregistrer(configuration, nouvelleCle: "cle-fictive-du-test")
        #expect(try reglages.aUneCle(pour: configuration))
        var attributs: CFTypeRef?
        let requete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "fournisseur-ia",
            kSecUseDataProtectionKeychain as String: true,
            kSecAttrSynchronizable as String: false,
            kSecReturnAttributes as String: true,
        ]
        #expect(SecItemCopyMatching(requete as CFDictionary, &attributs) == errSecSuccess)
        let accessibilite = (attributs as? [String: Any])?[kSecAttrAccessible as String] as? String
        #expect(accessibilite == kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String)
        let donnees = try #require(preferences.data(forKey: ReglagesFournisseur.clePreferences))
        #expect(!String(decoding: donnees, as: UTF8.self).contains("cle-fictive-du-test"))

        let recharge = ReglagesFournisseur(preferences: preferences, service: service, fournisseur: fournisseur)
        let distant = try await extracteur.extraire(contenu, cible: .message, repliConsenti: recharge.repliConsenti)
        #expect(distant.statut == .complet)
        #expect(distant.moteur == .cleExterne)
        #expect(await fournisseur.appels == 1)

        await fournisseur.suspendreProchainAppel()
        let enCours = Task {
            try await extracteur.extraire(contenu, cible: .message, repliConsenti: recharge.repliConsenti)
        }
        await fournisseur.attendreAppelSuspendu()
        try recharge.desactiver()
        #expect(try await enCours.value == local)
        #expect(!recharge.configuration.active)
        #expect(try recharge.aUneCle(pour: configuration))

        configuration.adresse = "https://autre.exemple.test/v1"
        configuration.consentir()
        #expect(try !recharge.aUneCle(pour: configuration))
        #expect(throws: ErreurReglagesFournisseur.cle) { try recharge.enregistrer(configuration) }

        try recharge.supprimerCle()
        #expect(SecItemCopyMatching(requete as CFDictionary, nil) == errSecItemNotFound)
        #expect(!recharge.configuration.active)
        #expect(
            try await extracteur.extraire(
                contenu, cible: .message, repliConsenti: recharge.repliConsenti) == local)
        #expect(await fournisseur.appels == 2)
    }
#endif
