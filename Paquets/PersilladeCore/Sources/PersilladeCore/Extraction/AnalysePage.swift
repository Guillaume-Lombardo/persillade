import Foundation

struct AnalysePage {
    let corps: String
    let texte: String
    let recette: BrouillonRecette?

    init(html: String) throws {
        try Task.checkCancellation()
        let sansCommentaires = html.remplacer(#"(?is)<!--(?!\s*(?:\{|\[)).*?-->"#, par: "")
        let recettes = try Self.recettesStructurees(sansCommentaires)
        recette = recettes.max { Self.score($0) < Self.score($1) }
        corps = try HTML.texte(html)
        // Certaines pages ne dupliquent pas dans le DOM les données du bloc Recipe.
        let fiche = recette.map(Self.texteStructure) ?? ""
        let morceaux = fiche.split(whereSeparator: \.isNewline).map(String.init)
        let lignesVisibles = Set(corps.split(whereSeparator: \.isNewline).map(String.init))
        let lignesManquantes = morceaux.filter { !lignesVisibles.contains($0) }
        texte = ([corps] + lignesManquantes).filter { !$0.isEmpty }.joined(separator: "\n")
    }

    private static func score(_ recette: BrouillonRecette) -> Int {
        if recette.statut == .complet { return 8 + (recette.portions == nil ? 0 : 1) }
        return (recette.titre.isEmpty ? 0 : 2) + (recette.ingredients.isEmpty ? 0 : 2)
            + (recette.etapes.isEmpty ? 0 : 2) + (recette.portions == nil ? 0 : 1)
    }

    private static func texteStructure(_ recette: BrouillonRecette) -> String {
        var lignes = [recette.titre]
        lignes += recette.ingredients.map(\.texteOrigine)
        lignes += recette.etapes
        return lignes.joined(separator: "\n")
    }

    private static func recettesStructurees(_ html: String) throws -> [BrouillonRecette] {
        let scripts = html.ranges(of: #"(?is)<script\b(?:[^>"']|"[^"]*"|'[^']*')*>.*?</script\s*>"#)
        return try scripts.flatMap { plage -> [BrouillonRecette] in
            try Task.checkCancellation()
            let script = String(html[plage])
            guard
                let balise = script.range(
                    of: #"(?is)^<script\b(?:[^>"']|"[^"]*"|'[^']*')*>"#, options: .regularExpression),
                script[balise].range(
                    of:
                        #"(?i)\s+type\s*=\s*(?:"application/ld\+json(?:\s*;[^"]*)?"|'application/ld\+json(?:\s*;[^']*)?'|application/ld\+json(?=\s|>))"#,
                    options: .regularExpression) != nil
            else { return [] }
            var contenu = String(script[balise.upperBound...])
                .remplacer(#"(?is)</script\s*>$"#, par: "").epure
            // Les enveloppes de commentaires XML et HTML sont encore présentes sur certaines pages.
            for (debut, fin) in [("<!--", "-->"), ("<![CDATA[", "]]>"), ("//<![CDATA[", "//]]>")] {
                if contenu.hasPrefix(debut), contenu.hasSuffix(fin) {
                    contenu = String(contenu.dropFirst(debut.count).dropLast(fin.count)).epure
                }
            }
            guard let objet = try? JSONSerialization.jsonObject(with: Data(contenu.utf8)) else { return [] }
            return try parcourir(objet)
        }
    }

    private static func parcourir(_ objet: Any) throws -> [BrouillonRecette] {
        try Task.checkCancellation()
        if let tableau = objet as? [Any] { return try tableau.flatMap(parcourir) }
        guard let noeud = objet as? [String: Any] else { return [] }
        let types = (noeud["@type"] as? [String]) ?? (noeud["@type"] as? String).map { [$0] } ?? []
        if types.contains(where: { $0 == "Recipe" || $0.hasSuffix("schema.org/Recipe") || $0 == "schema:Recipe" }) {
            let titre = try (noeud["name"] as? String).map(HTML.texte) ?? ""
            let ingredients = try textes(noeud["recipeIngredient"] ?? noeud["ingredients"])
                .flatMap { try HTML.texte($0).split(whereSeparator: \.isNewline).map(String.init) }
                .map(AnalyseIngredient.analyser)
            return [
                try BrouillonRecette(
                    titre: titre, portions: rendement(noeud["recipeYield"]), ingredients: ingredients,
                    etapes: instructions(noeud["recipeInstructions"]))
            ]
        }
        return try noeud.keys.sorted().flatMap { cle -> [BrouillonRecette] in
            guard cle != "@context", let valeur = noeud[cle] else { return [] }
            return try parcourir(valeur)
        }
    }

    private static func textes(_ objet: Any?) -> [String] {
        if let texte = objet as? String { return [texte] }
        if let tableau = objet as? [Any] { return tableau.flatMap { textes($0) } }
        return []
    }

    private static func rendement(_ objet: Any?) throws -> Int? {
        if let tableau = objet as? [Any] {
            for valeur in tableau {
                if let portions = try rendement(valeur) { return portions }
            }
            return nil
        }
        if let texte = objet as? String {
            let propre = try HTML.texte(texte)
            return AnalyseTexteRecette.portionsDansLigne(propre) ?? AnalyseTexteRecette.nombrePortions(propre)
        }
        if let nombre = objet as? NSNumber, String(cString: nombre.objCType) != "c",
            let entier = Int(exactly: nombre.doubleValue), entier > 0
        {
            return entier
        }
        return nil
    }

    private static func instructions(_ objet: Any?) throws -> [String] {
        try Task.checkCancellation()
        if let chaine = objet as? String {
            return try HTML.texte(chaine).split(whereSeparator: \.isNewline).map(String.init)
        }
        if let tableau = objet as? [Any] { return try tableau.flatMap { try instructions($0) } }
        if let noeud = objet as? [String: Any] {
            for cle in ["itemListElement", "steps", "text", "name"] {
                let etapes = try instructions(noeud[cle])
                if !etapes.isEmpty { return etapes }
            }
        }
        return []
    }
}

enum HTML {
    private static let entites: [String: String] = [
        "amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": " ",
        "ensp": " ", "emsp": " ", "thinsp": " ", "nnbsp": " ", "shy": "",
        "ndash": "–", "mdash": "—", "rsquo": "’", "lsquo": "‘", "ldquo": "“", "rdquo": "”",
        "laquo": "«", "raquo": "»", "hellip": "…", "bull": "•", "middot": "·", "deg": "°",
        "frac12": "½", "frac14": "¼", "frac34": "¾", "sol": "/", "frasl": "⁄", "times": "×",
        "agrave": "à", "acirc": "â", "auml": "ä", "Agrave": "À", "Acirc": "Â", "Auml": "Ä",
        "eacute": "é", "egrave": "è", "ecirc": "ê", "euml": "ë",
        "Eacute": "É", "Egrave": "È", "Ecirc": "Ê", "Euml": "Ë",
        "icirc": "î", "iuml": "ï", "Icirc": "Î", "Iuml": "Ï", "ocirc": "ô", "ouml": "ö",
        "Ocirc": "Ô", "Ouml": "Ö", "ugrave": "ù", "ucirc": "û", "uuml": "ü",
        "Ugrave": "Ù", "Ucirc": "Û", "Uuml": "Ü", "ccedil": "ç", "Ccedil": "Ç",
        "oelig": "œ", "OElig": "Œ", "aelig": "æ", "AElig": "Æ", "copy": "©",
    ]

    static func texte(_ html: String) throws -> String {
        try Task.checkCancellation()
        if !html.contains("<"), !html.contains("&") { return html.epure }
        var texte = html.remplacer(#"(?s)<!--.*?-->"#, par: "")
        for tag in ["script", "style", "noscript", "template", "head", "nav", "footer", "aside", "svg"] {
            try Task.checkCancellation()
            texte = texte.remplacer("(?is)<\(tag)\\b[^>]*>.*?</\(tag)\\s*>", par: "\n")
        }
        texte =
            texte
            .remplacer(
                #"(?is)</?(?:address|article|blockquote|br|dd|div|dl|dt|h[1-6]|hr|li|main|ol|p|pre|section|table|tr|ul)\b(?:[^>"']|"[^"]*"|'[^']*')*>"#,
                par: "\n"
            )
            .remplacer(#"(?s)</?[a-zA-Z](?:[^>"']|"[^"]*"|'[^']*')*>|(?i:<!DOCTYPE[^>]*>)"#, par: "")
        texte = try decoder(texte)
        return texte.components(separatedBy: .newlines)
            .map { $0.remplacer(#"\h+"#, par: " ").epure }
            .filter { !$0.isEmpty }.joined(separator: "\n")
    }

    private static func decoder(_ texte: String) throws -> String {
        var resultat = ""
        var debut = texte.startIndex
        let plages = texte.ranges(of: #"&(?:#[xX][0-9a-fA-F]{1,8}|#[0-9]{1,10}|[A-Za-z][A-Za-z0-9]{1,30});"#)
        for (index, plage) in plages.enumerated() {
            if index.isMultiple(of: 64) { try Task.checkCancellation() }
            resultat += texte[debut..<plage.lowerBound]
            let code = texte[plage].dropFirst().dropLast()
            if code.first == "#" {
                let hexadecimal = code.dropFirst().first?.lowercased() == "x"
                let chiffres = code.dropFirst(hexadecimal ? 2 : 1)
                if let valeur = UInt32(chiffres, radix: hexadecimal ? 16 : 10),
                    let caractere = UnicodeScalar(valeur), valeur > 0
                {
                    resultat.unicodeScalars.append(caractere)
                } else {
                    resultat += "�"
                }
            } else {
                resultat += entites[String(code)] ?? String(texte[plage])
            }
            debut = plage.upperBound
        }
        return resultat + texte[debut...]
    }
}

extension String {
    func ranges(of motif: String) -> [Range<Index>] {
        guard let regex = try? NSRegularExpression(pattern: motif) else { return [] }
        return regex.matches(in: self, range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range, in: self) }
    }
}
