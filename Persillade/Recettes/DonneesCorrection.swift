import Foundation
import PersilladeCore

struct DonneesCorrection {
    let id: UUID
    let brouillon: BrouillonRecette
    let source: String
    let url: URL?
    let cause: CauseExtraction?
    let modification: Bool

    init() {
        id = UUID()
        brouillon = BrouillonRecette(portions: 4)
        source = ""
        url = nil
        cause = nil
        modification = false
    }

    init(id: UUID, resultat: ResultatExtraction, url: URL?) {
        self.id = id
        brouillon = resultat.recette ?? BrouillonRecette()
        source = resultat.texteSource
        self.url = resultat.urlSource ?? url
        cause = resultat.statut == .echec ? nil : resultat.cause
        modification = false
    }

    init(recette: Recette) {
        id = recette.id
        brouillon = BrouillonRecette(
            titre: recette.titre, portions: recette.portions,
            ingredients: recette.ingredients.map {
                BrouillonIngredient(nom: $0.nom, quantite: $0.quantite, unite: $0.unite, texteOrigine: $0.texteOrigine)
            },
            etapes: recette.etapes)
        source = recette.texteSource
        url = recette.urlSource
        cause = nil
        modification = true
    }
}

struct LigneIngredientCorrection: Equatable, Identifiable {
    let id = UUID()
    let origine: String
    let uniteLue: Unite?
    let indiceSource: Int?
    var nom: String
    var quantite: SaisieQuantite
    var nonComprise: Bool

    init(_ ingredient: BrouillonIngredient, indiceSource: Int? = nil) {
        self.indiceSource = indiceSource
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

struct LigneEtapeCorrection: Equatable, Identifiable {
    let id = UUID()
    var texte: String
}

struct FormulaireRecette: Equatable {
    var titre: String
    var portions: String
    var ingredients: [LigneIngredientCorrection]
    var etapes: [LigneEtapeCorrection]

    init(_ brouillon: BrouillonRecette, source: String) {
        titre = brouillon.titre
        portions = brouillon.portions.map(String.init) ?? ""
        let indices = CorrespondancesSource.indices(brouillon.ingredients.map(\.texteOrigine), dans: source)
        ingredients = zip(brouillon.ingredients, indices).map { LigneIngredientCorrection($0, indiceSource: $1) }
        etapes = brouillon.etapes.map(LigneEtapeCorrection.init)
    }

    var titreVide: Bool { titre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var portionsEffectives: Int? {
        if portions.isEmpty { return 4 }
        guard let nombre = Int(portions), nombre > 0 else { return nil }
        return nombre
    }
}

enum CorrespondancesSource {
    static func indices(_ origines: [String], dans source: String) -> [Int?] {
        let lignes = source.components(separatedBy: .newlines)
        var indices = [Int?](repeating: nil, count: origines.count)
        var occupees: Set<Int> = []
        for exacte in [true, false] {
            for (index, origine) in origines.enumerated() where indices[index] == nil && !origine.isEmpty {
                let correspondance = lignes.indices.first { indice in
                    guard !occupees.contains(indice) else { return false }
                    return exacte
                        ? lignes[indice].compare(origine, options: .literal) == .orderedSame
                        : plage(origine, dans: lignes[indice]) != nil
                }
                if let correspondance {
                    indices[index] = correspondance
                    occupees.insert(correspondance)
                }
            }
        }
        return indices
    }

    static func plage(_ origine: String, dans texte: String) -> Range<String.Index>? {
        guard !origine.isEmpty else { return nil }
        var debut = texte.startIndex
        while debut < texte.endIndex,
            let plage = texte.range(of: origine, options: .literal, range: debut..<texte.endIndex)
        {
            let avant = plage.lowerBound == texte.startIndex ? nil : texte[texte.index(before: plage.lowerBound)]
            let apres = plage.upperBound == texte.endIndex ? nil : texte[plage.upperBound]
            if !(avant?.isLetter == true || avant?.isNumber == true),
                !(apres?.isLetter == true || apres?.isNumber == true)
            {
                return plage
            }
            debut = texte.index(after: plage.lowerBound)
        }
        return nil
    }
}
