import Foundation
import PersilladeCore
import Security

struct TrousseauFournisseur {
    let service: String

    private struct Entree: Codable {
        let hote: HoteFournisseur
        let cle: String
    }

    private var selecteur: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "fournisseur-ia",
            kSecAttrSynchronizable as String: false,
            kSecUseDataProtectionKeychain as String: true,
        ]
    }

    func lire(pour hote: HoteFournisseur) throws -> CleFournisseur? {
        guard let entree = try lireEntree(), entree.hote == hote else { return nil }
        guard let cle = CleFournisseur(entree.cle) else { throw ErreurReglagesFournisseur.trousseau }
        return cle
    }

    func hoteEnregistre() throws -> HoteFournisseur? {
        try lireEntree()?.hote
    }

    private func lireEntree() throws -> Entree? {
        var requete = selecteur
        requete[kSecReturnData as String] = true
        requete[kSecMatchLimit as String] = kSecMatchLimitOne
        var resultat: CFTypeRef?
        let statut = SecItemCopyMatching(requete as CFDictionary, &resultat)
        if statut == errSecItemNotFound { return nil }
        guard statut == errSecSuccess, let donnees = resultat as? Data,
            let entree = try? JSONDecoder().decode(Entree.self, from: donnees)
        else { throw ErreurReglagesFournisseur.trousseau }
        return entree
    }

    func ecrire(_ cle: CleFournisseur, pour hote: HoteFournisseur) throws {
        guard let donnees = try? JSONEncoder().encode(Entree(hote: hote, cle: cle.valeur))
        else { throw ErreurReglagesFournisseur.trousseau }
        let attributs: [String: Any] = [
            kSecValueData as String: donnees,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        let statut = SecItemUpdate(selecteur as CFDictionary, attributs as CFDictionary)
        if statut == errSecItemNotFound {
            let entree = selecteur.merging(attributs) { _, nouveau in nouveau }
            guard SecItemAdd(entree as CFDictionary, nil) == errSecSuccess
            else { throw ErreurReglagesFournisseur.trousseau }
        } else if statut != errSecSuccess {
            throw ErreurReglagesFournisseur.trousseau
        }
    }

    func supprimer() throws {
        let statut = SecItemDelete(selecteur as CFDictionary)
        guard statut == errSecSuccess || statut == errSecItemNotFound
        else { throw ErreurReglagesFournisseur.trousseau }
    }
}
