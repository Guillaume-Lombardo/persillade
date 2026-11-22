import Foundation
import PersilladeCore

public enum ErreurReglagesFournisseur: Error {
    case adresse, modele, cle, consentement, trousseau, preferences
}

@MainActor
public final class ReglagesFournisseur {
    public static let partage = ReglagesFournisseur(
        preferences: .standard, service: "xyz.g1lom.persillade.fournisseur", fournisseur: FournisseurURLSession())

    private let preferences: UserDefaults
    private let trousseau: TrousseauFournisseur
    private let fournisseur: any FournisseurIA
    private var traitements: [UUID: Task<PropositionExtraction, any Error>] = [:]
    static let clePreferences = "fournisseur-ia.v1"

    init(preferences: UserDefaults, service: String, fournisseur: any FournisseurIA) {
        self.preferences = preferences
        self.trousseau = TrousseauFournisseur(service: service)
        self.fournisseur = fournisseur
    }

    public var configuration: ConfigurationFournisseur {
        guard let donnees = preferences.data(forKey: Self.clePreferences),
            let configuration = try? JSONDecoder().decode(ConfigurationFournisseur.self, from: donnees)
        else { return ConfigurationFournisseur() }
        return configuration
    }

    public func aUneCle(pour configuration: ConfigurationFournisseur) throws -> Bool {
        guard let hote = configuration.hote else { return false }
        return try trousseau.lire(pour: hote) != nil
    }

    public func hoteCleEnregistree() throws -> HoteFournisseur? {
        try trousseau.hoteEnregistre()
    }

    public func enregistrer(_ brouillon: ConfigurationFournisseur, nouvelleCle: String = "") throws {
        var brouillon = brouillon
        brouillon.retirerConsentementSiHoteDifferent()
        let hote = brouillon.hote
        let hoteChange = hote != configuration.hote
        let cle = CleFournisseur(nouvelleCle)
        if (brouillon.active || !brouillon.adresse.isEmpty || !nouvelleCle.isEmpty) && hote == nil {
            throw ErreurReglagesFournisseur.adresse
        }
        if !nouvelleCle.isEmpty && cle == nil { throw ErreurReglagesFournisseur.cle }
        if brouillon.active {
            guard !brouillon.modele.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { throw ErreurReglagesFournisseur.modele }
            guard try cle != nil || (!hoteChange && aUneCle(pour: brouillon))
            else { throw ErreurReglagesFournisseur.cle }
            guard !brouillon.requiertConsentement else { throw ErreurReglagesFournisseur.consentement }
        }

        let donnees = try encoder(brouillon)
        if let cle, let hote {
            try trousseau.ecrire(cle, pour: hote)
        }
        annulerTraitements()
        preferences.set(donnees, forKey: Self.clePreferences)
        if cle == nil, hoteChange { try trousseau.supprimer() }
    }

    public func desactiver() throws {
        var configuration = configuration
        configuration.active = false
        let donnees = try encoder(configuration)
        annulerTraitements()
        preferences.set(donnees, forKey: Self.clePreferences)
    }

    public func supprimerCle() throws {
        try desactiver()
        try trousseau.supprimer()
    }

    public var repliConsenti: Extracteur.RepliConsenti {
        { contenu, cible, local in
            try await self.completer(contenu, cible: cible, resultatLocal: local)
        }
    }

    private func completer(
        _ contenu: ContenuRecu, cible: CibleExtraction, resultatLocal: ResultatExtraction
    ) async throws -> PropositionExtraction? {
        try Task.checkCancellation()
        let configuration = configuration
        guard let requete = configuration.requete(pour: contenu, cible: cible, resultatLocal: resultatLocal),
            let hote = configuration.hote, let cle = try trousseau.lire(pour: hote)
        else { return nil }

        let id = UUID()
        let fournisseur = fournisseur
        let traitement = Task {
            try Task.checkCancellation()
            return try await fournisseur.completer(requete, cle: cle)
        }
        traitements[id] = traitement
        defer { traitements[id] = nil }
        let resultat = await withTaskCancellationHandler {
            await traitement.result
        } onCancel: {
            traitement.cancel()
        }
        try Task.checkCancellation()
        guard !traitement.isCancelled else { return nil }
        return try resultat.get()
    }

    private func encoder(_ configuration: ConfigurationFournisseur) throws -> Data {
        guard let donnees = try? JSONEncoder().encode(configuration)
        else { throw ErreurReglagesFournisseur.preferences }
        return donnees
    }

    private func annulerTraitements() {
        for traitement in traitements.values { traitement.cancel() }
    }
}
