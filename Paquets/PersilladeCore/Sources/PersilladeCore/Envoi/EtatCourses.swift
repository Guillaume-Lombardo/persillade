import Foundation

public enum EtatEnvoiLigne: Equatable, Sendable {
    case aEnvoyer
    case envoyee
    case rienAAjouter
    case supplement(Quantite, Unite)
    case echec(CauseEchecEnvoi)
}

public struct EtatCourses: Codable, Equatable, Sendable, DocumentVersionne {
    struct ResultatLigne: Codable, Equatable, Sendable {
        enum Issue: String, Codable, Sendable {
            case ajoutee, completee, couverte, echec
        }

        let ligneId: UUID
        let nomNormalise: String
        let unite: Unite?
        let quantiteTraitee: Quantite?
        let issue: Issue
        let cause: CauseEchecEnvoi?

        init(ligne: LigneCourses, quantiteTraitee: Quantite?, issue: Issue, cause: CauseEchecEnvoi? = nil) {
            ligneId = ligne.id
            nomNormalise = ligne.nomNormalise
            unite = ligne.unite
            self.quantiteTraitee = quantiteTraitee
            self.issue = issue
            self.cause = cause
        }

        func correspond(nom: String, unite: Unite?) -> Bool {
            guard nomNormalise == nom else { return false }
            if let a = self.unite, let b = unite { return a.comparablePourCourses(a: b) }
            return self.unite == nil && unite == nil
        }

        private enum CodingKeys: String, CodingKey {
            case ligneId = "ligne_id"
            case nomNormalise = "nom_normalise"
            case quantiteTraitee = "quantite_traitee"
            case unite, issue, cause
        }
    }

    struct IdentifiantsRappel: Codable, Equatable, Sendable {
        let id: String
        let externe: String?

        init(_ rappel: RappelCourses) {
            id = rappel.id
            externe = rappel.idExterne
        }

        func correspondent(au rappel: RappelCourses) -> Bool {
            id == rappel.id || (externe?.isEmpty == false && externe == rappel.idExterne)
        }
    }

    struct Ecriture: Codable, Equatable, Sendable {
        let id: UUID
        let destinationId: String
        let listeId: UUID
        let titre: String
        let article: ArticleRappel
        let resultat: ResultatLigne
        let date: Date
        let rappelsAvant: [IdentifiantsRappel]
    }

    public static let versionSchemaCourante = 2
    package static let versionsSchemaLisibles = 1...versionSchemaCourante

    public internal(set) var liste = ListeCourses()
    public internal(set) var selection = SelectionSemaine()
    public internal(set) var destinationId: String?
    public internal(set) var journal = JournalEnvoi()
    var enAttente: [Ecriture] = []
    var cochesAnterieures: [IdentifiantsRappel] = []
    var resultats: [ResultatLigne] = []

    public var destinationVerrouillee: Bool { journal.entrees.contains { $0.listeId == liste.id } }

    public var selectionModifieeDepuisGeneration: Bool {
        liste.selectionALaGeneration.map { $0 != selection } ?? false
    }

    public init() {}

    public func etatEnvoi(de ligne: LigneCourses) throws -> EtatEnvoiLigne {
        let deLaLigne = resultats.filter { $0.ligneId == ligne.id || ligne.idsFusionnes.contains($0.ligneId) }
        let resultat =
            deLaLigne.last { $0.correspond(nom: ligne.nomNormalise, unite: ligne.unite) }
            ?? deLaLigne.last { $0.unite == nil || ligne.unite == nil }
        guard let resultat else { return .aEnvoyer }
        if let cause = resultat.cause { return .echec(cause) }
        if let quantite = try ligne.quantiteArrondie, let unite = ligne.unite {
            let traitee = resultat.quantiteTraitee ?? Quantite(0)
            if quantite > traitee { return .supplement(try quantite - traitee, unite) }
        }
        return resultat.issue == .couverte ? .rienAAjouter : .envoyee
    }

    mutating func enregistrer(_ resultat: ResultatLigne) {
        resultats.removeAll {
            $0.ligneId == resultat.ligneId || $0.correspond(nom: resultat.nomNormalise, unite: resultat.unite)
        }
        resultats.append(resultat)
    }

    mutating func confirmer(_ ecriture: Ecriture, rappel: RappelCourses) {
        journal.entrees.append(
            .init(
                rappelId: rappel.id, rappelIdExterne: rappel.idExterne,
                destinationId: ecriture.destinationId, listeId: ecriture.listeId, ligneId: ecriture.resultat.ligneId,
                article: ecriture.article,
                titreEcrit: ecriture.titre, date: rappel.creeLe ?? ecriture.date))
        retirerEcriture(ecriture.id)
        if ecriture.listeId == liste.id { enregistrer(ecriture.resultat) }
    }

    mutating func retirerEcriture(_ id: UUID) {
        enAttente.removeAll { $0.id == id }
    }

    private enum CodingKeys: String, CodingKey {
        case liste, selection, journal, resultats
        case destinationId = "destination_id"
        case enAttente = "en_attente"
        case cochesAnterieures = "coches_anterieures"
    }
}
