import Foundation

/// Conserver une instance par document pour sérialiser les modifications et les envois.
public actor EnvoiCourses {
    public enum Erreur: Error, Equatable, Sendable {
        case operationEnCours
        case destinationVerrouillee
        case destinationNonChoisie
    }

    private let documents: any MagasinDocument
    private let rappels: any MagasinRappels
    private let maintenant: @Sendable () -> Date
    private let etatInitial = EtatCourses()
    private var operationEnCours = false

    public init(
        documents: any MagasinDocument, rappels: any MagasinRappels,
        maintenant: @escaping @Sendable () -> Date = Date.init
    ) {
        self.documents = documents
        self.rappels = rappels
        self.maintenant = maintenant
    }

    public func lire() async throws -> EtatCourses {
        do {
            return try await documents.lire(
                EtatCourses.self, cle: "courses", version: EtatCourses.versionSchemaCourante)
        } catch ErreurMagasinDocument.absent {
            return etatInitial
        }
    }

    @discardableResult
    public func modifier<Resultat: Sendable>(
        _ modifier: @Sendable (inout ListeCourses, inout SelectionSemaine) throws -> Resultat
    ) async throws -> Resultat {
        try commencer()
        defer { operationEnCours = false }
        var etat = try await lire()
        var liste = etat.liste
        let resultat = try modifier(&liste, &etat.selection)
        if liste.id != etat.liste.id {
            if let destination = etat.destinationId, etat.enAttente != nil {
                let rappelsLus = try await rappels.lire(destinationId: destination)
                reprendre(&etat, rappelsLus: rappelsLus, destinationId: destination)
            }
            etat.resultats = []
            liste.premierEnvoiLe = nil
        } else {
            liste.premierEnvoiLe = etat.liste.premierEnvoiLe
        }
        etat.liste = liste
        try await persister(etat)
        return resultat
    }

    public func destinations() async throws -> [DestinationRappels] {
        try await rappels.destinations()
    }

    public func choisirDestination(_ id: String) async throws {
        try commencer()
        defer { operationEnCours = false }
        var etat = try await lire()
        guard etat.destinationId != id else { return }
        if let precedente = etat.destinationId, etat.enAttente != nil {
            let anciensRappels = try await rappels.lire(destinationId: precedente)
            reprendre(&etat, rappelsLus: anciensRappels, destinationId: precedente)
            try await persister(etat)
        }
        guard !etat.destinationVerrouillee else { throw Erreur.destinationVerrouillee }
        etat.destinationId = id
        etat.liste.premierEnvoiLe = nil
        etat.resultats = []
        try await persister(etat)
    }

    public func renvoyer() async throws -> RapportEnvoi {
        try await envoyer(lignes: nil)
    }

    public func envoyerLigne(_ ligneId: UUID) async throws -> RapportEnvoi {
        try await envoyer(lignes: [ligneId])
    }

    /// Pour un ajout ou une intégration, utiliser les identifiants de ListeCourses.Effets.lignesAEnvoyer.
    public func envoyer(lignes: [UUID]?) async throws -> RapportEnvoi {
        try commencer()
        defer { operationEnCours = false }
        var etat = try await lire()
        let concernees = Set(lignes ?? etat.liste.lignes.map(\.id))
        if let manquante = concernees.subtracting(etat.liste.lignes.map(\.id)).first {
            throw ListeCourses.Erreur.ligneIntrouvable(manquante)
        }
        let aTraiter = etat.liste.lignesAEnvoyer.filter { concernees.contains($0.id) }
        var rapport = RapportEnvoi()
        if lignes != nil && aTraiter.isEmpty { return rapport }
        guard let destination = etat.destinationId else { throw Erreur.destinationNonChoisie }

        // EventKit ramène les dates de coche à la seconde.
        let instant = maintenant().timeIntervalSinceReferenceDate
        let avantLecture = Date(timeIntervalSinceReferenceDate: instant.rounded(.down))
        let rappelsLus: [RappelCourses]
        do {
            rappelsLus = try await rappels.lire(destinationId: destination)
        } catch let cause as CauseEchecEnvoi {
            try await signaler(cause, lignes: aTraiter[...], etat: &etat, rapport: &rapport)
            return rapport
        }

        reprendre(&etat, rappelsLus: rappelsLus, destinationId: destination)
        let seuil = etat.liste.premierEnvoiLe ?? avantLecture
        etat.liste.premierEnvoiLe = seuil
        try await persister(etat)

        for (index, ligne) in aTraiter.enumerated() {
            let rappelsActuels: [RappelCourses]
            do {
                rappelsActuels = index == 0 ? rappelsLus : try await rappels.lire(destinationId: destination)
            } catch let cause as CauseEchecEnvoi {
                try await signaler(cause, lignes: aTraiter[index...], etat: &etat, rapport: &rapport)
                return rapport
            }
            let plan = try PlanEnvoi(
                ligne: ligne, rappels: rappelsActuels, journal: etat.journal, premierEnvoiLe: seuil,
                destinationId: destination)
            let quantite = try ligne.quantiteArrondie
            let ecriture: EtatCourses.Ecriture
            switch plan {
            case .exclure:
                continue
            case .ignorer:
                rapport.ignores.append(ligne.id)
                etat.enregistrer(.init(ligne: ligne, quantiteTraitee: quantite, issue: .couverte))
                try await persister(etat)
                continue
            case .ajouter(let valeur):
                ecriture = try preparer(ligne, valeur: valeur, quantiteTraitee: quantite, issue: .ajoutee)
            case .completer(let valeur):
                ecriture = try preparer(ligne, valeur: valeur, quantiteTraitee: quantite, issue: .completee)
            }

            etat.enAttente = ecriture
            try await persister(etat)
            let rappel: RappelCourses
            do {
                rappel = try await rappels.ajouter(
                    titre: ecriture.titre, destinationId: destination, identifiantEcriture: ecriture.id)
            } catch let cause as CauseEchecEnvoi {
                etat.enAttente = nil
                signaler(cause, ligne: ligne, etat: &etat, rapport: &rapport)
                try await persister(etat)
                continue
            }

            etat.confirmer(ecriture, rappel: rappel, destinationId: destination)
            if case .completer = plan {
                rapport.complements.append(ligne.id)
            } else {
                rapport.ajoutes.append(ligne.id)
            }
            try await persister(etat)
        }
        return rapport
    }

    private func commencer() throws {
        guard !operationEnCours else { throw Erreur.operationEnCours }
        operationEnCours = true
    }

    private func persister(_ etat: EtatCourses) async throws {
        try await documents.ecrire(etat, cle: "courses", version: EtatCourses.versionSchemaCourante)
    }

    private func reprendre(_ etat: inout EtatCourses, rappelsLus: [RappelCourses], destinationId: String) {
        if let ecriture = etat.enAttente,
            let rappel = rappelsLus.first(where: { $0.identifiantEcriture == ecriture.id })
        {
            etat.confirmer(ecriture, rappel: rappel, destinationId: destinationId)
        }
        etat.enAttente = nil
    }

    private func preparer(
        _ ligne: LigneCourses, valeur: Quantite?, quantiteTraitee: Quantite?, issue: EtatCourses.ResultatLigne.Issue
    ) throws -> EtatCourses.Ecriture {
        var titre = ligne.libelle
        if let valeur, let unite = ligne.unite {
            titre += " " + (try formaterQuantiteCourses(valeur, unite: unite))
        }
        return EtatCourses.Ecriture(
            id: UUID(), titre: titre,
            article: ArticleRappel(nomNormalise: ligne.nomNormalise, quantite: valeur, unite: ligne.unite),
            resultat: .init(ligne: ligne, quantiteTraitee: quantiteTraitee, issue: issue), date: maintenant())
    }

    private func signaler(
        _ cause: CauseEchecEnvoi, lignes: ArraySlice<LigneCourses>, etat: inout EtatCourses, rapport: inout RapportEnvoi
    ) async throws {
        rapport.causeGenerale = cause
        for ligne in lignes {
            signaler(cause, ligne: ligne, etat: &etat, rapport: &rapport)
        }
        try await persister(etat)
    }

    private func signaler(
        _ cause: CauseEchecEnvoi, ligne: LigneCourses, etat: inout EtatCourses, rapport: inout RapportEnvoi
    ) {
        rapport.echecs.append(.init(ligneId: ligne.id, cause: cause))
        etat.enregistrer(.init(ligne: ligne, quantiteTraitee: nil, issue: .echec, cause: cause))
    }
}
