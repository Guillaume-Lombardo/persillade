import Foundation

struct AnalyseTexteRecette {
    private enum Section {
        case introduction, ingredients, etapes, fin
    }

    var recette = BrouillonRecette()
    var bloc: String?

    private static let titreExplicite = #"(?i)^(?:titre|recette)\h*:\h*"#
    private static let enteteIngredients = #"(?i)^(?:liste des\h+)?ingr[ée]dients?\h*(?::\h*|(?=pour\b|\()|$)"#
    private static let enteteEtapes =
        #"(?i)^(?:pr[ée]parat[ií]on|instructions|[ée]tapes|m[ée]thode|r[ée]alisation)\h*(?::\h*|$)"#
    private static let enteteFin =
        #"(?i)^(?:commentaires?|avis|suggestions?|variantes?|notes?|astuces?|recettes? (?:similaires?|associ[ée]es?)|valeurs? nutritionnelles?)\h*(?::|$)"#
    private static let portions =
        #"(?i)(?:\b(?:pour|serves?|portions?)\h*:?\h*([0-9]+)(?=\b)|(?<![\d.,])([0-9]+)\h*(?:personnes?|portions?|parts?|servings?)\b)"#
    private static let numeroEtape = #"^(?:[0-9]+[.)](?=\h|\p{L})|(?i:[ée]tape\h+[0-9]+\b\h*[:.)–-]?))\h*"#
    private static let verbeEtape =
        #"(?i)^(?:pr[ée]chauff(?:er|ez)|m[ée]lang(?:er|ez)|ajout(?:er|ez)|vers(?:er|ez)|[ée]pluch(?:er|ez)|hach(?:er|ez)|coup(?:er|ez)|[ée]minc(?:er|ez)|fai(?:re|tes)|cuire|cuisez|laisser|laissez|enfourn(?:er|ez)|serv(?:ir|ez)|mettre|mettez|battre|battez|remu(?:er|ez)|form(?:er|ez)|r[ée]part(?:ir|issez)|assaisonn(?:er|ez)|[ée]goutt(?:er|ez))\b"#
    private static let bruit =
        #"(?i)^(?:https?://|www\.|copyright\b|©|publicit[ée]\b|accueil\b|partager\b|imprimer\b|abonne[sz]\b|ouvrir le menu\b|[ée]crit par\b|par\h+[^\d]+$|(?:temps|dur[ée]e|cuisson|repos|difficult[ée]|calories|publi[ée])\b\h*[:\d]|pr[ée]paration\h*:\h*[0-9]+\h*(?:min|h)\b|(?:bonjour|salut|coucou|merci|bisous)\b)"#

    init(_ texte: String) throws {
        let lignes = texte.components(separatedBy: .newlines)
        var section = Section.introduction
        var ingredientsExplicites = false
        var titrePossible: (index: Int, texte: String)?
        var premierIndice: Int?
        var dernierIndice: Int?

        for (index, origine) in lignes.enumerated() {
            if index.isMultiple(of: 64) { try Task.checkCancellation() }
            var ligne = retirerPuce(origine).remplacer(#"^#{1,6}\h+"#, par: "")
            guard !ligne.isEmpty, !ligne.correspond(Self.bruit),
                ligne.contains(where: \.isLetter)
                    || ligne.contains(where: \.isNumber)
            else { continue }
            if section != .introduction, ligne.correspond(Self.enteteFin) {
                section = .fin
                continue
            }
            guard section != .fin else { continue }

            var enteteTrouvee = false
            if let entete = ligne.range(of: Self.enteteIngredients, options: .regularExpression) {
                section = .ingredients
                ingredientsExplicites = true
                ligne = String(ligne[entete.upperBound...]).epure
                enteteTrouvee = true
            } else if let entete = ligne.range(of: Self.enteteEtapes, options: .regularExpression) {
                section = .etapes
                ligne = String(ligne[entete.upperBound...]).epure
                enteteTrouvee = true
            }
            if enteteTrouvee {
                premierIndice = premierIndice ?? index
                dernierIndice = index
                if ligne.isEmpty { continue }
            }

            let titreMarque = ligne.correspond(Self.titreExplicite)
            if let portions = Self.portionsDansLigne(ligne),
                section == .introduction || enteteTrouvee
            {
                recette.portions = recette.portions ?? portions
                premierIndice = premierIndice ?? index
                dernierIndice = index
                // Conserve un titre qui précède « pour 4 personnes » sur la même ligne.
                if let plage = ligne.range(of: Self.portions, options: .regularExpression) {
                    ligne = String(ligne[..<plage.lowerBound]).remplacer(#"\h*[(:–-]\h*$"#, par: "").epure
                    if ligne.isEmpty || ligne.correspond(#"(?i)^(?:pour|rendement|(?:le tout\h+)?donne|recette)$"#) {
                        continue
                    }
                }
            }
            if titreMarque {
                let titre = ligne.remplacer(Self.titreExplicite, par: "").epure
                if !titre.isEmpty {
                    recette.titre = titre
                    premierIndice = premierIndice ?? index
                    dernierIndice = index
                }
                continue
            }

            let sansNumero = ligne.remplacer(Self.numeroEtape, par: "").epure
            let etapeVerbale = sansNumero.correspond(Self.verbeEtape)
            if section == .etapes || etapeVerbale || (!ingredientsExplicites && sansNumero != ligne) {
                section = .etapes
                if !sansNumero.isEmpty {
                    recette.etapes.append(sansNumero)
                    premierIndice = premierIndice ?? index
                    dernierIndice = index
                }
                continue
            }

            var ingredient = AnalyseIngredient.analyser(enteteTrouvee ? ligne : origine)
            if section == .ingredients, sansNumero != ligne {
                let analyse = AnalyseIngredient.analyser(sansNumero)
                ingredient = BrouillonIngredient(
                    nom: analyse.nom, quantite: analyse.quantite, unite: analyse.unite,
                    texteOrigine: origine, ligneNonComprise: analyse.ligneNonComprise)
            }
            let ligneIngredient = ingredient.quantite != nil || ingredient.ligneNonComprise
            let nomSeul = section == .ingredients && (ingredientsExplicites || Self.titrePlausible(ligne))
            if ligneIngredient || nomSeul {
                section = .ingredients
                recette.ingredients.append(ingredient)
                premierIndice = premierIndice ?? index
                dernierIndice = index
                continue
            }

            if section == .introduction, Self.titrePlausible(ligne) {
                titrePossible = (index, ligne)
            }
        }
        if recette.titre.isEmpty, let titrePossible {
            recette.titre = titrePossible.texte
            premierIndice = min(premierIndice ?? titrePossible.index, titrePossible.index)
        }
        if let premierIndice, let dernierIndice, premierIndice <= dernierIndice,
            !recette.ingredients.isEmpty || !recette.etapes.isEmpty
        {
            bloc = lignes[premierIndice...dernierIndice].joined(separator: "\n")
        }
    }

    static func titrePlausible(_ ligne: String) -> Bool {
        ligne.count <= 100 && ligne.split(whereSeparator: \.isWhitespace).count <= 12
            && ligne.contains(where: \.isLetter) && !ligne.correspond(Self.bruit)
            && !ligne.correspond(#"[.!?]$|(?i)^(?:il|je|j['’]|nous|on|vous|ceci|c['’]|tu)\b"#)
    }

    static func portionsDansLigne(_ ligne: String) -> Int? {
        guard let plage = ligne.range(of: portions, options: .regularExpression) else { return nil }
        return nombrePortions(String(ligne[plage]))
    }

    static func nombrePortions(_ texte: String) -> Int? {
        guard let plage = texte.range(of: #"[0-9]+"#, options: .regularExpression),
            let valeur = Int(texte[plage]), valeur > 0
        else { return nil }
        return valeur
    }
}
