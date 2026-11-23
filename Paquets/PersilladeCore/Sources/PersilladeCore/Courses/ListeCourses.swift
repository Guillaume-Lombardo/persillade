import Foundation

public struct ListeCourses: Codable, Equatable, Identifiable, Sendable {
    public enum Erreur: Error, Equatable, Sendable {
        case versionNonPriseEnCharge(Int)
        case messageDejaIntegre(UUID)
        case messageSansArticle
        case ligneIntrouvable(UUID)
    }

    public enum MotifConfirmation: Equatable, Sendable {
        case listeNonVide
        case remplacementRecettes
        case listeEnvoyee
    }

    public enum ChoixIntegration: Sendable {
        case completer
        case nouvelleListe
    }

    public struct Effets: Equatable, Sendable {
        public fileprivate(set) var decochagePropose: [UUID] = []
        public fileprivate(set) var lignesDecochees: [UUID] = []
        public fileprivate(set) var lignesAEnvoyer: [UUID] = []
        public fileprivate(set) var rappelsInchanges: Bool = false
    }

    public enum Resultat: Equatable, Sendable {
        case confirmationRequise([MotifConfirmation])
        case choixIntegrationRequis
        case applique(Effets)
    }

    public struct Rayon: Equatable, Sendable {
        public let categorie: Categorie
        public let lignes: [LigneCourses]
    }

    public static let versionSchemaCourante = 1

    public let versionSchema: Int
    public let id: UUID
    public var premierEnvoiLe: Date?
    public private(set) var selectionALaGeneration: SelectionSemaine?
    public private(set) var lignes: [LigneCourses] = []
    private var messagesIntegres: [UUID] = []

    public var envoyee: Bool { premierEnvoiLe != nil }

    public var lignesAEnvoyer: [LigneCourses] { lignes.filter { !$0.cochee } }

    public func ligne(id: UUID) -> LigneCourses? {
        lignes.first { $0.id == id || $0.idsFusionnes.contains(id) }
    }

    public var rayons: [Rayon] {
        let parCategorie = Dictionary(grouping: lignes, by: \.categorie)
        let francais = Locale(identifier: "fr_FR")
        return Categorie.allCases.compactMap { categorie in
            guard let lignes = parCategorie[categorie] else { return nil }
            let triees = lignes.sorted { gauche, droite in
                gauche.libelle.compare(droite.libelle, options: .caseInsensitive, locale: francais) == .orderedAscending
            }
            return Rayon(categorie: categorie, lignes: triees)
        }
    }

    public init(id: UUID = UUID()) {
        self.id = id
        versionSchema = Self.versionSchemaCourante
    }

    public mutating func nouvelleListe(confirmee: Bool = false) -> Resultat {
        guard lignes.isEmpty || confirmee else { return .confirmationRequise([.listeNonVide]) }
        repartirSurListeVide()
        return .applique(Effets())
    }

    public mutating func generer(_ preparation: SelectionSemaine.Preparation, confirmee: Bool = false) throws
        -> Resultat
    {
        var motifs: [MotifConfirmation] = []
        if lignes.contains(where: { $0.origines.contains(where: { $0.type == .recette }) }) {
            motifs.append(.remplacementRecettes)
        }
        if envoyee { motifs.append(.listeEnvoyee) }
        guard motifs.isEmpty || confirmee else { return .confirmationRequise(motifs) }

        var copie = self
        if !motifs.isEmpty { copie.repartirSurListeVide() }
        copie.selectionALaGeneration = preparation.selection
        for contribution in preparation.contributions {
            let origine = OrigineCourses(type: .recette, ref: contribution.recetteId)
            let ligne = try LigneCourses(article: contribution.article, origine: origine)
            if let index = copie.lignes.firstIndex(where: { $0.fusionnable(avec: ligne) }) {
                try copie.lignes[index].fusionner(avec: ligne)
            } else {
                copie.lignes.append(ligne)
            }
        }
        self = copie
        return .applique(Effets())
    }

    public func contientMessage(id: UUID) -> Bool { messagesIntegres.contains(id) }

    public mutating func integrer(
        _ articles: [ArticleCourses], messageId: UUID, choix: ChoixIntegration? = nil
    ) throws -> Resultat {
        guard !contientMessage(id: messageId) else { throw Erreur.messageDejaIntegre(messageId) }
        guard !articles.isEmpty else { throw Erreur.messageSansArticle }
        guard !envoyee || choix != nil else { return .choixIntegrationRequis }

        var copie = self
        if envoyee, choix == .nouvelleListe { copie.repartirSurListeVide() }
        var effets = Effets()
        var concernees = Set<UUID>()
        let origine = OrigineCourses(type: .message, ref: messageId)
        for article in articles {
            concernees.formUnion(try copie.incorporer(article, origine: origine, effets: &effets))
        }
        copie.messagesIntegres.append(messageId)
        copie.completer(&effets, concernees: concernees)
        self = copie
        return .applique(effets)
    }

    @discardableResult
    public mutating func ajouter(_ article: ArticleCourses, ref: UUID = UUID()) throws -> Effets {
        var effets = Effets()
        let concernees = try incorporer(article, origine: OrigineCourses(type: .manuel, ref: ref), effets: &effets)
        completer(&effets, concernees: concernees)
        return effets
    }

    @discardableResult
    public mutating func retirer(_ id: UUID) throws -> Effets {
        lignes.remove(at: try index(id))
        var effets = Effets()
        effets.rappelsInchanges = envoyee
        return effets
    }

    @discardableResult
    public mutating func modifierQuantite(_ id: UUID, valeur: Quantite?, unite: Unite?) throws -> Effets {
        let index = try index(id)
        var modifiee = lignes[index]
        try modifiee.fixerQuantite(valeur, unite: unite)

        var effets = Effets()
        if envoyee, let ancienne = lignes[index].quantite {
            effets.rappelsInchanges =
                modifiee.quantite.map { nouvelle in
                    guard let unite = modifiee.unite, let ancienneUnite = lignes[index].unite,
                        unite.comparablePourCourses(a: ancienneUnite)
                    else { return true }
                    return nouvelle < ancienne
                } ?? true
        }

        if let autre = lignes.indices.first(where: { $0 != index && lignes[$0].fusionnable(avec: modifiee) }) {
            let premiere = min(index, autre)
            let seconde = max(index, autre)
            var fusion = premiere == index ? modifiee : lignes[premiere]
            let ajout = seconde == index ? modifiee : lignes[seconde]
            if fusion.quantite == nil {
                fusion.cochee = ajout.cochee
            } else if ajout.quantite != nil {
                fusion.cochee = fusion.cochee && ajout.cochee
            }
            try fusion.fusionner(avec: ajout)
            fusion.idsFusionnes.append(ajout.id)
            fusion.idsFusionnes.append(contentsOf: ajout.idsFusionnes)
            lignes[premiere] = fusion
            lignes.remove(at: seconde)
        } else {
            lignes[index] = modifiee
        }
        return effets
    }

    public mutating func changerCategorie(_ id: UUID, categorie: Categorie) throws {
        lignes[try index(id)].categorie = categorie
    }

    public mutating func cocher(_ id: UUID, cochee: Bool = true) throws {
        lignes[try index(id)].cochee = cochee
    }

    private func index(_ id: UUID) throws -> Int {
        guard let index = lignes.firstIndex(where: { $0.id == id }) else { throw Erreur.ligneIntrouvable(id) }
        return index
    }

    private mutating func repartirSurListeVide() {
        var vide = Self()
        vide.messagesIntegres = messagesIntegres
        self = vide
    }

    private mutating func incorporer(
        _ article: ArticleCourses, origine: OrigineCourses, effets: inout Effets
    ) throws -> Set<UUID> {
        let ligne = try LigneCourses(article: article, origine: origine)
        let correspondances = lignes.indices.filter { lignes[$0].fusionnable(avec: ligne) }
        guard let index = correspondances.first else {
            lignes.append(ligne)
            return [ligne.id]
        }

        if ligne.quantite != nil || origine.type != .manuel {
            try lignes[index].fusionner(avec: ligne)
        }
        if ligne.quantite == nil {
            for index in correspondances where lignes[index].cochee {
                effets.decochagePropose.append(lignes[index].id)
            }
        } else if lignes[index].cochee {
            lignes[index].cochee = false
            effets.lignesDecochees.append(lignes[index].id)
        }
        return Set(correspondances.map { lignes[$0].id })
    }

    private func completer(_ effets: inout Effets, concernees: Set<UUID>) {
        let propositions = Set(effets.decochagePropose)
        effets.decochagePropose = lignes.filter { $0.cochee && propositions.contains($0.id) }.map(\.id)
        if envoyee { effets.lignesAEnvoyer = lignesAEnvoyer.filter { concernees.contains($0.id) }.map(\.id) }
    }

    private enum CodingKeys: String, CodingKey {
        case id, lignes
        case versionSchema = "version_schema"
        case premierEnvoiLe = "premier_envoi_le"
        case messagesIntegres = "messages_integres"
        case selectionALaGeneration = "selection_a_la_generation"
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        let version = try champs.decode(Int.self, forKey: .versionSchema)
        guard version == Self.versionSchemaCourante else { throw Erreur.versionNonPriseEnCharge(version) }
        versionSchema = version
        id = try champs.decode(UUID.self, forKey: .id)
        premierEnvoiLe = try champs.decodeIfPresent(Date.self, forKey: .premierEnvoiLe)
        selectionALaGeneration = try champs.decodeIfPresent(SelectionSemaine.self, forKey: .selectionALaGeneration)
        lignes = try champs.decode([LigneCourses].self, forKey: .lignes)
        messagesIntegres = try champs.decode([UUID].self, forKey: .messagesIntegres)

        var parNom: [String: [LigneCourses]] = [:]
        var ids = Set<UUID>()
        let messages = Set(messagesIntegres)
        for ligne in lignes {
            guard ids.insert(ligne.id).inserted,
                parNom[ligne.nomNormalise]?.contains(where: { $0.fusionnable(avec: ligne) }) != true,
                ligne.origines.allSatisfy({ $0.type != .message || messages.contains($0.ref) })
            else {
                throw DecodingError.dataCorruptedError(
                    forKey: .lignes, in: champs, debugDescription: "Liste incohérente")
            }
            parNom[ligne.nomNormalise, default: []].append(ligne)
        }
        guard messages.count == messagesIntegres.count else {
            throw DecodingError.dataCorruptedError(
                forKey: .messagesIntegres, in: champs, debugDescription: "Message intégré en double")
        }
    }
}
