import Foundation

public protocol TelechargeurPage: Sendable {
    func telecharger(_ url: URL) async throws -> String
}

public protocol LecteurImage: Sendable {
    func lireTexte(_ image: Data) async throws -> String
}

public struct ChampsRecette: OptionSet, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }

    public static let titre = Self(rawValue: 1 << 0)
    public static let portions = Self(rawValue: 1 << 1)
    public static let ingredients = Self(rawValue: 1 << 2)
    public static let etapes = Self(rawValue: 1 << 3)
}

public struct PropositionExtraction: Sendable {
    public var titre: String?
    public var portions: String?
    public var ingredients: [String]
    public var etapes: [String]
    public var articles: [String]

    public init(
        titre: String? = nil, portions: String? = nil, ingredients: [String] = [],
        etapes: [String] = [], articles: [String] = []
    ) {
        self.titre = titre
        self.portions = portions
        self.ingredients = ingredients
        self.etapes = etapes
        self.articles = articles
    }
}

public protocol MoteurIA: Sendable {
    /// Budget alloué au texte source, après réservation de la place pour les instructions et la réponse.
    func budgetContexte(cible: CibleExtraction, champs: ChampsRecette) async throws -> Int
    func compterJetons(_ texte: String) async throws -> Int
    /// Chaque valeur renvoyée doit citer un extrait du texte fourni.
    func extraire(_ texte: String, cible: CibleExtraction, champs: ChampsRecette) async throws -> PropositionExtraction
}

public struct Extracteur: Sendable {
    /// Le repli vérifie le consentement courant. Il renvoie nil quand aucun envoi n'est autorisé.
    public typealias RepliConsenti =
        @Sendable (ContenuRecu, CibleExtraction, ResultatExtraction) async throws -> PropositionExtraction?

    private let telechargeur: (any TelechargeurPage)?
    private let moteurIA: (any MoteurIA)?
    private let lecteurImage: (any LecteurImage)?

    public init(
        telechargeur: (any TelechargeurPage)? = nil, moteurIA: (any MoteurIA)? = nil,
        lecteurImage: (any LecteurImage)? = nil
    ) {
        self.telechargeur = telechargeur
        self.moteurIA = moteurIA
        self.lecteurImage = lecteurImage
    }

    public func extraire(
        _ contenu: ContenuRecu, cible: CibleExtraction, repliConsenti: RepliConsenti? = nil
    ) async throws -> ResultatExtraction {
        try Task.checkCancellation()
        let brut = String(data: contenu.contenu, encoding: .utf8) ?? ""
        let texte: String
        var url: URL?
        var structure: BrouillonRecette?
        var corpsPage: String?
        do {
            switch contenu.type {
            case .texte:
                texte = brut
            case .image:
                guard let lecteurImage else { throw CauseExtraction.rienTrouve }
                texte = try await lecteurImage.lireTexte(contenu.contenu)
            case .url:
                url = URL(string: brut.epure)
                guard let url, let telechargeur else { throw CauseExtraction.pageInaccessible }
                let html = try await telechargeur.telecharger(url)
                try Task.checkCancellation()
                let page = try AnalysePage(html: html)
                texte = page.texte
                corpsPage = page.corps
                structure = page.recette
            }
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw error }
            let cause = (error as? CauseExtraction) ?? (contenu.type == .url ? .pageInaccessible : .rienTrouve)
            return ResultatExtraction(
                statut: .echec, cause: cause, moteur: .manuel, texteSource: contenu.type == .url ? brut : "",
                urlSource: url, recette: cible == .recette ? BrouillonRecette() : nil, articles: [],
                erreurAccesPage: error as? ErreurAccesPage)
        }
        try Task.checkCancellation()

        let analyse = cible == .recette ? try AnalyseTexteRecette(corpsPage ?? texte) : nil
        var proposition = EtatExtraction(cible: cible, messageID: contenu.id, texte: texte, url: url)
        if let analyse {
            proposition.recette = structure ?? analyse.recette
            if let structure, structure.statut != .complet {
                let memeRecette =
                    structure.titre.isEmpty || analyse.recette.titre.isEmpty
                    || normaliserNom(structure.titre) == normaliserNom(analyse.recette.titre)
                if memeRecette { proposition.completerRecette(analyse.recette) }
            }
            if proposition.recette.statut != .echec { proposition.moteur = .structure }
        }

        if !texte.epure.isEmpty, proposition.statut != .complet {
            try await tenterExtractionLocale(&proposition, bloc: analyse?.bloc)
            if cible == .message, proposition.articles.isEmpty {
                proposition.articles = articlesParLigne(texte, id: contenu.id)
            }
        }

        if let repliConsenti, proposition.statut != .complet, !texte.epure.isEmpty {
            do {
                if let reponse = try await repliConsenti(contenu, cible, proposition.resultat) {
                    try Task.checkCancellation()
                    let ancrages = AncragesExtraction(texte, echeance: .now + .seconds(2))
                    let citationsVerifiees = try ancrages.verifie(reponse)
                    guard citationsVerifiees || contenu.type == .image else {
                        throw CauseExtraction.fournisseurEnErreur
                    }
                    var candidat = proposition
                    if try candidat.appliquer(reponse, ancrages: ancrages, moteur: .cleExterne) {
                        try ancrages.verifierEcheance()
                        candidat.cause = citationsVerifiees ? nil : .fournisseurEnErreur
                        proposition = candidat
                    } else if !citationsVerifiees {
                        proposition.cause = .fournisseurEnErreur
                    }
                }
            } catch {
                try Task.checkCancellation()
                if error is CancellationError { throw error }
                proposition.cause = .fournisseurEnErreur
            }
        }
        try Task.checkCancellation()
        return proposition.resultat
    }

    private func tenterExtractionLocale(_ etat: inout EtatExtraction, bloc: String?) async throws {
        guard let moteurIA else {
            etat.cause = .iaIndisponible
            return
        }

        do {
            let champs = etat.champsManquants
            let budget = try await moteurIA.budgetContexte(cible: etat.cible, champs: champs)
            let (morceaux, tronque) = try await decouper(etat.texte, bloc: bloc, budget: budget, moteur: moteurIA)
            if tronque { etat.cause = .contenuTropLong }
            for morceau in morceaux {
                try Task.checkCancellation()
                let reponse = try await moteurIA.extraire(morceau, cible: etat.cible, champs: champs)
                try Task.checkCancellation()
                try etat.appliquer(reponse, ancrages: AncragesExtraction(morceau), moteur: .embarque)
            }
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw error }
            if etat.cause == .contenuTropLong { return }
            etat.cause =
                switch error as? CauseExtraction {
                case .iaIndisponible: .iaIndisponible
                case .contenuTropLong: .contenuTropLong
                default: .iaEnErreur
                }
        }
    }

    private func decouper(
        _ texte: String, bloc: String?, budget: Int, moteur: any MoteurIA
    ) async throws -> (morceaux: [String], tronque: Bool) {
        guard budget > 0 else { throw CauseExtraction.contenuTropLong }
        if try await moteur.compterJetons(texte) <= budget { return ([texte], false) }
        let source = (bloc?.isEmpty == false ? bloc : nil) ?? texte
        if source != texte, try await moteur.compterJetons(source) <= budget { return ([source], false) }

        var morceaux: [String] = []
        let mesures = AnalyseIngredient.positionsMesures(dans: source)
        var reste = source.drop(while: \.isWhitespace)
        while !reste.isEmpty, morceaux.count < 3 {
            try Task.checkCancellation()
            if try await moteur.compterJetons(String(reste)) <= budget {
                return (morceaux + [String(reste)], false)
            }
            var mesuresRestantes = mesures[...]
            let indices = reste.indices.filter { index in
                guard reste[index].isWhitespace else { return false }
                while let mesure = mesuresRestantes.first, mesure.upperBound <= index {
                    mesuresRestantes = mesuresRestantes.dropFirst()
                }
                return mesuresRestantes.first?.contains(index) != true
            }
            var bas = 0
            var haut = indices.count
            while bas < haut {
                let milieu = (bas + haut) / 2
                if try await moteur.compterJetons(String(reste[..<indices[milieu]])) <= budget {
                    bas = milieu + 1
                } else {
                    haut = milieu
                }
            }
            guard bas > 0 else { return (morceaux, true) }
            let limite = indices[bas - 1]
            // Préserve les lignes quand un retour se trouve près de la limite.
            let longueur = reste.distance(from: reste.startIndex, to: limite)
            let seuil = reste.index(limite, offsetBy: -min(80, longueur / 4))
            let coupure = reste[seuil...limite].lastIndex(where: \.isNewline) ?? limite
            morceaux.append(String(reste[..<coupure]))
            reste = reste[coupure...].drop(while: \.isWhitespace)
        }
        return (morceaux, !reste.isEmpty)
    }
}

private struct EtatExtraction {
    let cible: CibleExtraction
    let messageID: UUID
    let texte: String
    let url: URL?
    var recette = BrouillonRecette()
    var articles: [ArticleExtrait] = []
    var moteur = ProvenanceExtraction.manuel
    var cause: CauseExtraction?
    private var articlesIncomplets = false
    private var ingredientsGeneres = false
    private var etapesGenerees = false

    var champsManquants: ChampsRecette {
        guard cible == .recette else { return [] }
        var champs: ChampsRecette = []
        if recette.titre.isEmpty { champs.insert(.titre) }
        if recette.portions == nil { champs.insert(.portions) }
        if recette.ingredients.isEmpty || recette.ingredients.contains(where: { $0.nom.isEmpty }) {
            champs.insert(.ingredients)
        }
        if recette.etapes.isEmpty { champs.insert(.etapes) }
        return champs
    }

    var statut: StatutExtraction {
        switch cible {
        case .recette:
            if recette.statut == .complet, cause == .contenuTropLong || cause == .fournisseurEnErreur {
                return .partiel
            }
            return recette.statut
        case .message:
            if articles.isEmpty { return .echec }
            return moteur == .manuel || articlesIncomplets || cause != nil ? .partiel : .complet
        }
    }

    var resultat: ResultatExtraction {
        ResultatExtraction(
            statut: statut, cause: statut == .complet ? nil : cause ?? .rienTrouve, moteur: moteur,
            texteSource: texte, urlSource: url, recette: cible == .recette ? recette : nil, articles: articles)
    }

    mutating func completerRecette(_ complement: BrouillonRecette) {
        if recette.titre.isEmpty { recette.titre = complement.titre }
        recette.portions = recette.portions ?? complement.portions
        if recette.ingredients.isEmpty { recette.ingredients = complement.ingredients }
        if recette.etapes.isEmpty { recette.etapes = complement.etapes }
    }

    @discardableResult
    mutating func appliquer(
        _ proposition: PropositionExtraction, ancrages: AncragesExtraction, moteur: ProvenanceExtraction
    ) throws -> Bool {
        let avant = recette
        let nombreArticles = articles.count

        if cible == .recette {
            if recette.titre.isEmpty, let titre = try ancrages.citation(proposition.titre),
                AnalyseTexteRecette.titrePlausible(titre)
            {
                recette.titre = titre
            }
            if recette.portions == nil, let citation = try ancrages.citation(proposition.portions) {
                recette.portions = AnalyseTexteRecette.portionsDansLigne(citation)
            }
            if recette.ingredients.isEmpty || ingredientsGeneres
                || recette.ingredients.contains(where: { $0.nom.isEmpty })
            {
                for citation in try ancrages.citations(proposition.ingredients) {
                    try ancrages.verifierEcheance()
                    let ingredient = AnalyseIngredient.analyser(citation)
                    guard !ingredient.ligneNonComprise, !recette.ingredients.contains(ingredient) else { continue }
                    if let index = try recette.ingredients.firstIndex(where: {
                        guard $0.nom.isEmpty else { return false }
                        let ligne = AncragesExtraction($0.texteOrigine, echeance: ancrages.echeance)
                        return try ligne.citation(citation) != nil
                    }) {
                        recette.ingredients[index].nom = ingredient.nom
                        recette.ingredients[index].quantite = ingredient.quantite
                        recette.ingredients[index].unite = ingredient.unite
                        recette.ingredients[index].ligneNonComprise = false
                    } else {
                        recette.ingredients.append(ingredient)
                    }
                    ingredientsGeneres = true
                }
            }
            if recette.etapes.isEmpty || (moteur == .embarque && etapesGenerees) {
                let etapes = try ancrages.citations(proposition.etapes)
                recette.etapes += etapes
                etapesGenerees = etapesGenerees || !etapes.isEmpty
            }
        } else {
            let extraits = try ancrages.citations(proposition.articles).compactMap { article($0, id: messageID) }
            if moteur == .cleExterne, !extraits.isEmpty {
                articles = extraits
                articlesIncomplets = extraits.count != proposition.articles.count
                self.moteur = moteur
                return true
            }
            articles += extraits
            articlesIncomplets = articlesIncomplets || extraits.count != proposition.articles.count
        }

        guard recette != avant || articles.count != nombreArticles else { return false }
        self.moteur = moteur
        return true
    }
}

private struct AncragesExtraction {
    private let source: String
    private let plageSource: NSRange
    private let mesures: [Range<String.Index>]
    let echeance: ContinuousClock.Instant?

    init(_ source: String, echeance: ContinuousClock.Instant? = nil) {
        self.source = source
        self.echeance = echeance
        plageSource = NSRange(source.startIndex..., in: source)
        mesures = AnalyseIngredient.positionsMesures(dans: source)
    }

    func verifierEcheance() throws {
        try Task.checkCancellation()
        if let echeance, ContinuousClock.now >= echeance { throw CauseExtraction.fournisseurEnErreur }
    }

    func citation(_ proposition: String?) throws -> String? {
        try plageDeCitation(proposition, sauf: []).map { String(source[$0]) }
    }

    func verifie(_ proposition: PropositionExtraction) throws -> Bool {
        let valeurs = [proposition.titre, proposition.portions].compactMap { $0 }
        let listes = [proposition.ingredients, proposition.etapes, proposition.articles]
        let tailleMax = max(4096, source.utf8.count)
        guard listes.allSatisfy({ $0.reduce(0) { $0 + $1.utf8.count } <= tailleMax }) else {
            throw CauseExtraction.fournisseurEnErreur
        }
        return try valeurs.allSatisfy { try citation($0) != nil }
            && listes.allSatisfy { try plagesDeCitations($0).count == $0.count }
    }

    func citations(_ propositions: [String]) throws -> [String] {
        try texteDesCitations(plagesDeCitations(propositions))
    }

    private func texteDesCitations(_ plages: Set<Range<String.Index>>) -> [String] {
        plages.sorted { $0.lowerBound < $1.lowerBound }.map { String(source[$0]) }
    }

    private func plagesDeCitations(_ propositions: [String]) throws -> Set<Range<String.Index>> {
        var plages = Set<Range<String.Index>>()
        for proposition in propositions {
            if let plage = try plageDeCitation(proposition, sauf: plages) { plages.insert(plage) }
        }
        return plages
    }

    private func plageDeCitation(_ proposition: String?, sauf utilisees: Set<Range<String.Index>>) throws
        -> Range<String.Index>?
    {
        try verifierEcheance()
        guard let texte = proposition?.epure, !texte.isEmpty, texte.utf16.count <= plageSource.length else {
            return nil
        }
        // Interdit notamment de citer le « 5 » de « 1,5 » ou « g » dans « kg ».
        let mots = texte.split(whereSeparator: \.isWhitespace).map {
            NSRegularExpression.escapedPattern(for: String($0))
        }
        let motif =
            #"(?i)(?<![\p{L}\p{N}])(?<![0-9][.,/⁄])\#(mots.joined(separator: #"\s+"#))(?![\p{L}\p{N}]|[.,/⁄][0-9])"#
        let regex = try NSRegularExpression(pattern: motif)
        var retenue: Range<String.Index>?
        regex.enumerateMatches(in: source, options: .reportProgress, range: plageSource) { resultat, _, stop in
            if Task.isCancelled || echeance.map({ ContinuousClock.now >= $0 }) == true {
                stop.pointee = true
                return
            }
            guard let resultat, let citation = Range(resultat.range, in: source), !utilisees.contains(citation)
            else { return }
            let coupeUneMesure = mesures.contains { mesure in
                mesure.overlaps(citation)
                    && (mesure.lowerBound < citation.lowerBound || mesure.upperBound > citation.upperBound)
            }
            if !coupeUneMesure {
                retenue = citation
                stop.pointee = true
            }
        }
        try verifierEcheance()
        return retenue
    }
}

private func article(_ texte: String, id: UUID) -> ArticleExtrait? {
    let ingredient = AnalyseIngredient.analyser(texte)
    guard !ingredient.ligneNonComprise, !ingredient.nom.isEmpty else { return nil }
    return ArticleExtrait(nom: ingredient.nom, quantite: ingredient.quantite, unite: ingredient.unite, messageID: id)
}

private func articlesParLigne(_ texte: String, id: UUID) -> [ArticleExtrait] {
    texte.split(whereSeparator: \.isNewline).flatMap { origine in
        let ligne = retirerPuce(String(origine))
        let morceaux = ligne.split(separator: ",").map { String($0).epure }
        let listeCourte =
            (2...8).contains(morceaux.count)
            && !ligne.correspond(
                #"\d,\d|[():!?;]|(?i)\b(?:au go[uû]t|et|ou|pour|svp|bonjour|merci|prends?|ach[èe]te|il faut)\b"#)
            && morceaux.allSatisfy { $0.split(whereSeparator: \.isWhitespace).count <= 4 && article($0, id: id) != nil }
        return (listeCourte ? morceaux : [ligne]).compactMap { article($0, id: id) }
    }
}
