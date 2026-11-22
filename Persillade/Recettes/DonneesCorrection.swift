import Foundation
import PersilladeCore

struct ContexteCorrection: Codable, Equatable, Sendable {
    let id: UUID
    let sourceId: UUID?
    let texteDerive: String?
    let url: URL?
    let cause: CauseExtraction?
    let photoSansTexte: Bool
    let modification: Bool
    let debutExtrait: Int
}

struct DonneesCorrection {
    let contexte: ContexteCorrection
    let source: String
    let formulaire: FormulaireRecette

    init() {
        source = ""
        contexte = .init(
            id: UUID(), sourceId: nil, texteDerive: nil, url: nil, cause: nil,
            photoSansTexte: false, modification: false, debutExtrait: 0)
        formulaire = FormulaireRecette(BrouillonRecette(portions: 4), source: "")
    }

    init(recu: ContenuRecu, resultat: ResultatExtraction, url: URL?, texteDeRepli: String?) {
        let brouillon = resultat.recette ?? BrouillonRecette()
        source = resultat.texteSource
        formulaire = FormulaireRecette(brouillon, source: source)
        let reference = recu.type == .texte ? recu.texteRecu : texteDeRepli
        contexte = .init(
            id: recu.id, sourceId: recu.id, texteDerive: source == reference ? nil : source,
            url: resultat.urlSource ?? url,
            cause: resultat.statut == .echec ? nil : resultat.cause,
            photoSansTexte: recu.type == .image && resultat.cause == .rienTrouve && source.isEmpty,
            modification: false,
            debutExtrait: resultat.urlSource == nil
                ? 0 : formulaire.debutExtraitWeb(dans: source))
    }

    init(recette: Recette) {
        source = recette.texteSource
        let brouillon = BrouillonRecette(
            titre: recette.titre, portions: recette.portions,
            ingredients: recette.ingredients.map {
                BrouillonIngredient(nom: $0.nom, quantite: $0.quantite, unite: $0.unite, texteOrigine: $0.texteOrigine)
            },
            etapes: recette.etapes)
        formulaire = FormulaireRecette(brouillon, source: recette.texteSource)
        contexte = .init(
            id: recette.id, sourceId: nil, texteDerive: nil, url: recette.urlSource,
            cause: nil, photoSansTexte: false, modification: true,
            debutExtrait: recette.urlSource == nil ? 0 : formulaire.debutExtraitWeb(dans: recette.texteSource))
    }

    init(contexte: ContexteCorrection, source: String, formulaire: FormulaireRecette) {
        self.contexte = contexte
        self.source = source
        self.formulaire = formulaire
    }
}

struct LigneIngredientCorrection: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let origine: String
    let uniteLue: Unite?
    let citation: CorrespondancesSource.Citation?
    var nom: String
    var quantite: SaisieQuantite
    var nonComprise: Bool

    init(_ ingredient: BrouillonIngredient, citation: CorrespondancesSource.Citation? = nil) {
        id = UUID()
        self.citation = citation
        origine = ingredient.texteOrigine
        uniteLue = ingredient.unite
        nom = ingredient.nom
        quantite = SaisieQuantite(quantite: ingredient.quantite, unite: ingredient.unite)
        nonComprise = ingredient.ligneNonComprise
    }

    var nomVide: Bool { nom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var aVerifier: Bool { nomVide || nonComprise }

    var note: String? {
        guard !aVerifier else { return nil }
        let nettoye = origine.lowercased()
        if nettoye.contains("au goût") { return "Au goût" }
        if origine.firstMatch(of: #/\d\s*(?:à|[-–])\s*\d/#) != nil { return "Borne haute de la fourchette" }
        if quantite.texte.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Quantité absente" }
        return nil
    }

    func valider() throws -> Ingredient {
        let (nombre, unite) = try quantite.valider()
        return try Ingredient(nom: nom, quantite: nombre, unite: unite, texteOrigine: origine)
    }
}

struct LigneEtapeCorrection: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var texte: String
}

struct FormulaireRecette: Codable, Equatable, Sendable {
    var titre: String
    var portions: String
    var ingredients: [LigneIngredientCorrection]
    var etapes: [LigneEtapeCorrection]

    init(_ brouillon: BrouillonRecette, source: String) {
        titre = brouillon.titre
        portions = brouillon.portions.map(String.init) ?? ""
        let citations = CorrespondancesSource.associer(brouillon.ingredients.map(\.texteOrigine), dans: source)
        ingredients = zip(brouillon.ingredients, citations).map { LigneIngredientCorrection($0, citation: $1) }
        etapes = brouillon.etapes.map { LigneEtapeCorrection(texte: $0) }
    }

    func valider(_ contexte: ContexteCorrection, source: String) throws -> Recette {
        guard let portionsEffectives else { throw Recette.Erreur.portionsNonPositives }
        return try recette(
            contexte, source: source, portions: portionsEffectives, ingredients: ingredients.map { try $0.valider() })
    }

    func recette(
        _ contexte: ContexteCorrection, source: String, portions: Int, ingredients: [Ingredient]
    ) throws -> Recette {
        try Recette(
            id: contexte.id, titre: titre, portions: portions, ingredients: ingredients,
            etapes: etapes.map(\.texte).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            texteSource: source, urlSource: contexte.url)
    }

    func debutExtraitWeb(dans source: String) -> Int {
        let lignes = source.components(separatedBy: .newlines)
        let ingredient = ingredients.compactMap { $0.citation?.ligne }.min()
        let candidats = lignes.indices.prefix(through: ingredient ?? lignes.index(before: lignes.endIndex))
        if !titre.isEmpty,
            let ligneTitre = candidats.last(where: { indice in
                lignes[indice].trimmingCharacters(in: .whitespaces)
                    .compare(titre, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            })
        {
            return ligneTitre
        }
        return ingredient ?? 0
    }

    var titreVide: Bool { titre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var portionsEffectives: Int? {
        if portions.isEmpty { return 4 }
        guard let nombre = Int(portions), nombre > 0 else { return nil }
        return nombre
    }
}

enum CorrespondancesSource {
    struct Citation: Codable, Equatable, Sendable {
        let ligne: Int
        let plage: NSRange
    }

    static func associer(_ origines: [String], dans source: String) -> [Citation?] {
        let lignes = source.components(separatedBy: .newlines)
        var citations = [Citation?](repeating: nil, count: origines.count)
        var occupees: [Int: [NSRange]] = [:]
        let parLongueur = origines.indices.sorted { gauche, droite in
            let tailleGauche = origines[gauche].utf16.count
            let tailleDroite = origines[droite].utf16.count
            return tailleGauche == tailleDroite ? gauche < droite : tailleGauche > tailleDroite
        }
        for exacte in [true, false] {
            let ordre = exacte ? Array(origines.indices) : parLongueur
            for index in ordre where citations[index] == nil && !origines[index].isEmpty {
                let origine = origines[index]
                for (indice, ligne) in lignes.enumerated() {
                    if exacte, ligne.compare(origine, options: .literal) != .orderedSame { continue }
                    guard let plage = plageDisponible(origine, dans: ligne, occupees: occupees[indice, default: []])
                    else { continue }
                    citations[index] = Citation(ligne: indice, plage: plage)
                    occupees[indice, default: []].append(plage)
                    break
                }
            }
        }
        return citations
    }

    private static func plageDisponible(_ origine: String, dans texte: String, occupees: [NSRange]) -> NSRange? {
        var debut = texte.startIndex
        while debut < texte.endIndex,
            let plage = texte.range(of: origine, options: .literal, range: debut..<texte.endIndex)
        {
            let avant = plage.lowerBound == texte.startIndex ? nil : texte[texte.index(before: plage.lowerBound)]
            let apres = plage.upperBound == texte.endIndex ? nil : texte[plage.upperBound]
            let candidate = NSRange(plage, in: texte)
            if !(avant?.isLetter == true || avant?.isNumber == true),
                !(apres?.isLetter == true || apres?.isNumber == true),
                !occupees.contains(where: { NSIntersectionRange($0, candidate).length > 0 })
            {
                return candidate
            }
            debut = texte.index(after: plage.lowerBound)
        }
        return nil
    }
}
