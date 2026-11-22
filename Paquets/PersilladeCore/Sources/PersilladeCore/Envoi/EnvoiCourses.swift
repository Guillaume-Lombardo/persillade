import Foundation

/// Conserver une instance par document pour sérialiser les modifications et les envois.
public actor EnvoiCourses {
    public enum Erreur: Error, Equatable, Sendable {
        case operationEnCours
        case destinationVerrouillee
        case destinationNonChoisie
        case ecritureIncertaine
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
            etat.cochesAnterieures = []
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
        guard !etat.destinationVerrouillee else { throw Erreur.destinationVerrouillee }
        if let precedente = etat.destinationId,
            etat.enAttente.contains(where: { $0.listeId == etat.liste.id })
        {
            let anciensRappels = try await rappels.lire(destinationId: precedente)
            _ = reprendre(&etat, rappelsLus: anciensRappels, destinationId: precedente)
            try await persister(etat)
            guard !etat.destinationVerrouillee else { throw Erreur.destinationVerrouillee }
            guard !etat.enAttente.contains(where: { $0.listeId == etat.liste.id }) else {
                throw Erreur.ecritureIncertaine
            }
        }
        etat.destinationId = id
        etat.liste.premierEnvoiLe = nil
        etat.cochesAnterieures = []
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

        let avantLecture: Date
        let rappelsLus: [RappelCourses]
        do {
            try await rappels.autoriser()
            avantLecture = maintenant()
            rappelsLus = try await rappels.lire(destinationId: destination)
        } catch let cause as CauseEchecEnvoi {
            try await signaler(cause, lignes: aTraiter[...], etat: &etat, rapport: &rapport)
            return rapport
        }

        var reprises = reprendre(&etat, rappelsLus: rappelsLus, destinationId: destination)
        let seuil = etat.liste.premierEnvoiLe ?? avantLecture
        if etat.liste.premierEnvoiLe == nil {
            etat.liste.premierEnvoiLe = seuil
            // EventKit tronque les dates de coche à la seconde. La première lecture départage les coches de cette seconde.
            etat.cochesAnterieures = rappelsLus.filter { $0.coche && $0.cocheLe == seuil.debutSeconde }
                .map(EtatCourses.IdentifiantsRappel.init)
        }
        let cochesAnterieures = etat.cochesAnterieures
        try await persister(etat)

        for (index, ligne) in aTraiter.enumerated() {
            let rappelsActuels: [RappelCourses]
            do {
                rappelsActuels = index == 0 ? rappelsLus : try await rappels.lire(destinationId: destination)
            } catch let cause as CauseEchecEnvoi {
                try await signaler(cause, lignes: aTraiter[index...], etat: &etat, rapport: &rapport)
                return rapport
            }
            if index > 0 {
                reprises = reprendre(&etat, rappelsLus: rappelsActuels, destinationId: destination)
            }
            let journal = etat.journal
            let rapprochements = reprises.filter { _, ecriture in
                ecriture.listeId == etat.liste.id
                    && (ecriture.resultat.ligneId == ligne.id || ligne.idsFusionnes.contains(ecriture.resultat.ligneId))
            }
            let plan = try PlanEnvoi(
                ligne: ligne, rappels: rappelsActuels,
                lireArticle: { rappel in
                    rapprochements[rappel.id]?.article ?? journal.article(du: rappel, destinationId: destination)
                },
                cocheDepuisPremierEnvoi: { rappel in
                    guard let date = rappel.cocheLe else { return false }
                    return date >= seuil
                        || (date == seuil.debutSeconde
                            && !cochesAnterieures.contains { $0.correspondent(au: rappel) })
                })
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
                ecriture = try preparer(
                    ligne, valeur: valeur, quantiteTraitee: quantite, issue: .ajoutee,
                    listeId: etat.liste.id, destinationId: destination, rappelsActuels: rappelsActuels)
            case .completer(let valeur):
                ecriture = try preparer(
                    ligne, valeur: valeur, quantiteTraitee: quantite, issue: .completee,
                    listeId: etat.liste.id, destinationId: destination, rappelsActuels: rappelsActuels)
            }

            if etat.enAttente.contains(where: { enAttente in
                enAttente.destinationId == destination
                    && enAttente.article.nomNormalise == ligne.nomNormalise
                    && (ligne.unite == nil
                        || enAttente.resultat.correspond(nom: ligne.nomNormalise, unite: ligne.unite))
                    && !rapprochements.values.contains { $0.id == enAttente.id }
            }) {
                signaler(.ecriture, ligne: ligne, etat: &etat, rapport: &rapport)
                try await persister(etat)
                continue
            }

            etat.enAttente.append(ecriture)
            try await persister(etat)
            let rappel: RappelCourses
            do {
                rappel = try await rappels.ajouter(
                    titre: ecriture.titre, destinationId: destination, identifiantEcriture: ecriture.id)
            } catch let cause as CauseEchecEnvoi {
                etat.retirerEcriture(ecriture.id)
                signaler(cause, ligne: ligne, etat: &etat, rapport: &rapport)
                try await persister(etat)
                continue
            }

            etat.confirmer(ecriture, rappel: rappel)
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

    private func reprendre(
        _ etat: inout EtatCourses, rappelsLus: [RappelCourses], destinationId: String
    ) -> [String: EtatCourses.Ecriture] {
        var rapprochements: [String: EtatCourses.Ecriture] = [:]
        for ecriture in etat.enAttente where ecriture.destinationId == destinationId {
            let marques = rappelsLus.filter { $0.identifiantEcriture == ecriture.id }
            if marques.count == 1, let rappel = marques.first {
                etat.confirmer(ecriture, rappel: rappel)
                continue
            }
            let candidats = rappelsLus.filter { rappel in
                rappel.identifiantEcriture == nil && rappel.titre == ecriture.titre
                    && rappel.creeLe.map { $0 >= ecriture.date.debutSeconde } == true
                    && !ecriture.rappelsAvant.contains { $0.correspondent(au: rappel) }
                    && !etat.journal.entrees.contains { $0.rappelId == rappel.id }
            }
            if candidats.isEmpty && marques.isEmpty {
                etat.retirerEcriture(ecriture.id)
            } else if candidats.count == 1, let rappel = candidats.first {
                // Un titre permet de calculer la couverture. Seul le marqueur prouve l'écriture.
                rapprochements[rappel.id] = ecriture
            }
        }
        return rapprochements
    }

    private func preparer(
        _ ligne: LigneCourses, valeur: Quantite?, quantiteTraitee: Quantite?, issue: EtatCourses.ResultatLigne.Issue,
        listeId: UUID, destinationId: String, rappelsActuels: [RappelCourses]
    ) throws -> EtatCourses.Ecriture {
        var titre = ligne.libelle
        if let valeur, let unite = ligne.unite {
            titre += " " + (try formaterQuantiteCourses(valeur, unite: unite))
        }
        return EtatCourses.Ecriture(
            id: UUID(), destinationId: destinationId, listeId: listeId, titre: titre,
            article: ArticleRappel(nomNormalise: ligne.nomNormalise, quantite: valeur, unite: ligne.unite),
            resultat: .init(ligne: ligne, quantiteTraitee: quantiteTraitee, issue: issue), date: maintenant(),
            rappelsAvant: rappelsActuels.map(EtatCourses.IdentifiantsRappel.init))
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

extension Date {
    fileprivate var debutSeconde: Date {
        Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.rounded(.down))
    }
}
