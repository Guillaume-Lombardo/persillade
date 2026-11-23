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

    private static let portionsPhoto =
        #"(?i)^[\[(]?\h*(?:pour\h*:?\h*\S+|[0-9]+)\h+(?:personnes?|parts?|portions?)\b(?:\h*\([^()]*\))?[\h:.)\]]*$"#
    private static let etiquetteDureePhoto = #"(?:(?:temps\h+de\h+)?(?:pr[ée]paration|cuisson|repos)|temps\h+total)"#
    private static let dureePhoto =
        #"(?i)^(?:(?:\#(etiquetteDureePhoto)\h*:?\h*)?[0-9]+\h*(?:min(?:utes?)?|h(?:eures?)?|s(?:econdes?)?|jours?)(?!\p{L})|(?:cuisson|repos)\h*[:.]?\h*$)"#
    private static let difficultePhoto = #"(?i)^(?:(?:tr[èe]s\h+)?facile|moyen(?:ne)?|difficile)\.?$"#
    private static let numeroEtapePhoto = #"\#(numeroEtape)|^[0-9]+\h*[-–—]\h*(?=\p{L})"#
    private static let actionNumeroteePhoto = #"(?i)^\p{L}+(?:er|ir|re|ez)\h+(?:(?:le|la|les|un|une)\h+|l['’])"#
    private static let suiteIngredientPhoto = #"(?i)^(?:d['’]|(?:de|ou)\h+)"#
    private static let suiteEtapePhoto = #"(?i)^(?:que\b|qu['’]|jusqu['’]|puis\b|ensuite\b|afin de\b)"#
    private static let debutEtapePhoto =
        #"(?i)^(?:fouetter|incorporer|[ée]craser|r[âa]per|d[ée]noyauter|beurrer|disposer|saupoudrer|d[ée]mouler|tapisser|r[ée]server|d[ée]layer|peser|filtrer|une\h+fois)\b"#
    private static let phraseEtapePhoto = #"[.!?]\h+\p{Lu}|(?i:\b(?:puis|ensuite)\h+\p{L}+(?:er|ez|ir|re)\b)"#

    init(_ texte: String, photo: Bool = false, indiceTitrePhoto: Int? = nil) throws {
        let lignes = texte.components(separatedBy: .newlines)
        var section = Section.introduction
        var ingredientsExplicites = false
        var etapeNumerotee = false
        var titrePossible: (index: Int, texte: String)?
        var mesureEnAttente: (index: Int, texte: String)?
        var premierIndice: Int?
        var dernierIndice: Int?

        for (index, origine) in lignes.enumerated() {
            if index.isMultiple(of: 64) { try Task.checkCancellation() }
            var ligne = retirerPuce(origine).remplacer(#"^#{1,6}\h+"#, par: "")
            guard !ligne.isEmpty, !ligne.correspond(Self.bruit),
                ligne.contains(where: \.isLetter)
                    || ligne.contains(where: \.isNumber)
            else { continue }
            let mesurePrecedente = mesureEnAttente
            mesureEnAttente = nil
            if photo {
                if ligne.correspond(Self.difficultePhoto) { continue }
                if section == .etapes ? !ligne.contains(where: \.isLetter) : ligne.correspond(Self.dureePhoto) {
                    continue
                }
            }
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
                etapeNumerotee = false
                premierIndice = premierIndice ?? index
                dernierIndice = index
                if ligne.isEmpty { continue }
            }

            if photo, ligne.correspond(Self.portionsPhoto) {
                recette.portions = recette.portions ?? Self.portionsDansLigne(ligne)
                if section == .introduction, !recette.titre.isEmpty || titrePossible != nil {
                    section = .ingredients
                }
                premierIndice = premierIndice ?? index
                dernierIndice = index
                continue
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
                    ligne = String(ligne[..<plage.lowerBound]).remplacer(#"\h*[(:–—-]\h*$"#, par: "").epure
                    if ligne.isEmpty || ligne.correspond(#"(?i)^(?:pour|rendement|(?:le tout\h+)?donne|recette)$"#) {
                        continue
                    }
                }
            }
            if titreMarque || index == indiceTitrePhoto {
                let titre = ligne.remplacer(Self.titreExplicite, par: "").epure
                if !titre.isEmpty {
                    recette.titre = titre
                    if photo, section == .introduction, recette.portions != nil { section = .ingredients }
                    premierIndice = premierIndice ?? index
                    dernierIndice = index
                }
                continue
            }
            if let indiceTitrePhoto, index < indiceTitrePhoto, section == .introduction { continue }

            let sansNumero = ligne.remplacer(photo ? Self.numeroEtapePhoto : Self.numeroEtape, par: "").epure
            let numerotee = sansNumero != ligne
            let etapeVerbale =
                Self.amorceEtape(sansNumero, photo: photo)
                || (photo && numerotee && Self.actionNumerotee(sansNumero))
            let ingredientNumerote = section == .ingredients && numerotee ? AnalyseIngredient.analyser(sansNumero) : nil
            let ingredientDose =
                (photo || sansNumero.first?.isNumber == true)
                && ingredientNumerote?.quantite != nil && (photo || ingredientNumerote?.ligneNonComprise == false)
            let marqueEtape = photo && numerotee && ligne.correspond(#"(?i)^[ée]tape\b"#)
            if section == .etapes || etapeVerbale || marqueEtape
                || (numerotee && !ingredientsExplicites && !ingredientDose)
                || (photo && section == .ingredients && Self.fragmentEtape(sansNumero))
            {
                section = .etapes
                if !sansNumero.isEmpty {
                    if photo, !numerotee, let precedente = recette.etapes.last,
                        etapeNumerotee || sansNumero.correspond(Self.suiteEtapePhoto)
                            || (!etapeVerbale && sansNumero.first?.isLowercase == true
                                && !precedente.correspond(#"[.!?:;]$"#))
                    {
                        recette.etapes[recette.etapes.count - 1] = precedente + " " + sansNumero
                    } else {
                        recette.etapes.append(sansNumero)
                        etapeNumerotee = numerotee
                    }
                    premierIndice = premierIndice ?? index
                    dernierIndice = index
                }
                continue
            }

            if photo, mesurePrecedente == nil, section == .ingredients, ligne.correspond(Self.suiteIngredientPhoto),
                let precedent = recette.ingredients.last, precedent.quantite != nil
            {
                let textePrecedent = retirerPuce(precedent.texteOrigine).remplacer(Self.numeroEtapePhoto, par: "")
                recette.ingredients[recette.ingredients.count - 1] = AnalyseIngredient.analyser(
                    textePrecedent + " " + ligne)
                dernierIndice = index
                continue
            }

            var ingredient: BrouillonIngredient
            if let analyse = ingredientNumerote {
                ingredient = BrouillonIngredient(
                    nom: analyse.nom, quantite: analyse.quantite, unite: analyse.unite,
                    texteOrigine: origine, ligneNonComprise: analyse.ligneNonComprise)
            } else {
                ingredient = AnalyseIngredient.analyser(enteteTrouvee ? ligne : origine)
            }
            if photo {
                if ingredient.nom.isEmpty {
                    if ingredient.quantite != nil {
                        mesureEnAttente = (index, sansNumero)
                        continue
                    }
                    if AnalyseIngredient.fragmentSansNom(sansNumero) { continue }
                } else if let mesurePrecedente, ingredient.quantite == nil {
                    let raccord = AnalyseIngredient.analyser(mesurePrecedente.texte + " " + sansNumero)
                    if raccord.quantite != nil, !raccord.nom.isEmpty {
                        ingredient = raccord
                        premierIndice = premierIndice ?? mesurePrecedente.index
                    }
                }
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

            if section == .introduction, Self.titrePlausible(ligne), !photo || titrePossible == nil {
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

    private static func amorceEtape(_ ligne: String, photo: Bool) -> Bool {
        ligne.correspond(verbeEtape) || (photo && ligne.correspond(debutEtapePhoto))
    }

    private static func actionNumerotee(_ ligne: String) -> Bool {
        ligne.split(separator: ",", maxSplits: 1).contains {
            let segment = String($0).epure
            return segment.correspond(actionNumeroteePhoto) || amorceEtape(segment, photo: true)
        }
    }

    private static func fragmentEtape(_ ligne: String) -> Bool {
        ligne.first?.isLetter == true && (ligne.correspond(suiteEtapePhoto) || ligne.correspond(phraseEtapePhoto))
    }

    static func ingredientPhotoPlausible(_ ligne: String, titre: String) -> Bool {
        let texte = retirerPuce(ligne)
        return normaliserNom(texte) != normaliserNom(titre)
            && !texte.correspond(titreExplicite)
            && !texte.correspond(Self.bruit) && !texte.correspond(portionsPhoto)
            && !texte.correspond(dureePhoto) && !texte.correspond(difficultePhoto)
            && !amorceEtape(texte, photo: true)
            && !texte.correspond(numeroEtapePhoto) && !fragmentEtape(texte)
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
