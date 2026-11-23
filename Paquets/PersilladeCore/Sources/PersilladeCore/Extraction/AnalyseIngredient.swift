import Foundation

public enum AnalyseIngredient {
    private static let nombres: [String: Int64] = [
        "un": 1, "une": 1, "deux": 2, "trois": 3, "quatre": 4, "cinq": 5, "six": 6,
        "sept": 7, "huit": 8, "neuf": 9, "dix": 10, "onze": 11, "douze": 12, "treize": 13,
        "quatorze": 14, "quinze": 15, "seize": 16, "dix-sept": 17, "dix-huit": 18,
        "dix-neuf": 19, "vingt": 20, "trente": 30, "quarante": 40, "cinquante": 50,
        "soixante": 60, "cent": 100, "douzaine": 12, "une douzaine": 12,
    ]

    private static let fractions = "¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞"
    private static let fraction = #"[0-9]+\h*[/⁄]\h*[0-9]+"#
    private static let nombre = {
        let mots = (["(?:une?\\h+)?demie?"] + nombres.keys.sorted { $0.count > $1.count }).joined(separator: "|")
        return
            #"(?:[0-9]+\h+\#(fraction)|[0-9]+\h*[\#(fractions)]|\#(fraction)|[\#(fractions)]|[0-9]+(?:[.,][0-9]+)?|[.,][0-9]+|(?:\#(mots))(?!\p{L}))"#
    }()
    private static let plage = #"\#(nombre)(?:\h*(?:à|a|[-–—])\h*\#(nombre))?(?![0-9/⁄]|[.,][0-9])"#
    private static let marqueQuantiteSuffisante = #"(?i)^\s*(?:q\.?\h*s\.?|quantit[ée]\h+suffisante)(?=\h|$)\h*"#

    private static let unites: [(motif: String, unite: Unite, facteur: Int64)] = [
        (#"cuill[èe]res?\h+(?:à|a)\h+soupe|c\.?\h*(?:à|a)\h*(?:soupe|s\.?)|cs"#, .cas, 1),
        (#"cuill[èe]res?\h+(?:(?:à|a)\h+)?caf[ée]|c\.?\h*(?:à|a)\h*(?:caf[ée]|c\.?)|cc"#, .cac, 1),
        (#"kilogrammes?|kilos?|kg"#, .kg, 1),
        (#"grammes?|gr\.?|g"#, .g, 1),
        (#"millilitres?|ml"#, .ml, 1),
        (#"centilitres?|cl"#, .cl, 1),
        (#"d[ée]cilitres?|dl"#, .cl, 10),
        (#"litres?|l"#, .l, 1),
        (#"pi[èe]ces?|unit[ée]s?"#, .piece, 1),
        (#"pinc[ée]es?"#, .autre("pincée"), 1),
        (#"gousses?"#, .autre("gousse"), 1),
        (#"tranches?"#, .autre("tranche"), 1),
        (#"sachets?"#, .autre("sachet"), 1),
        (#"bottes?"#, .autre("botte"), 1),
        (#"verres?"#, .autre("verre"), 1),
        (#"bo[îi]tes?"#, .autre("boîte"), 1),
        (#"brins?"#, .autre("brin"), 1),
        (#"bouquets?"#, .autre("bouquet"), 1),
        (#"b[âa]tons?"#, .autre("bâton"), 1),
        (#"poign[ée]es?"#, .autre("poignée"), 1),
        (#"tasses?"#, .autre("tasse"), 1),
        (#"pots?"#, .autre("pot"), 1),
        (#"paquets?"#, .autre("paquet"), 1),
        (#"filets?"#, .autre("filet"), 1),
        (#"gouttes?"#, .autre("goutte"), 1),
        (#"feuilles?"#, .autre("feuille"), 1),
    ]
    private static let uniteEnFin = unites.map { "(?:\($0.motif))" }.joined(separator: "|")

    static func positionsMesures(dans texte: String) -> [Range<String.Index>] {
        texte.ranges(of: #"(?i)(?<![\p{L}\p{N}.,/⁄])[-−+]?\#(plage)"#)
    }

    static func fragmentSansNom(_ texte: String) -> Bool {
        let sansMesure = texte.remplacer(marqueQuantiteSuffisante, par: "")
            .remplacer(#"(?i)^[-−+]?\#(plage)\h*"#, par: "")
        let reste = lireUnite(sansMesure)?.suite ?? sansMesure
        return !reste.contains(where: \.isLetter)
    }

    public static func analyser(_ ligne: String) -> BrouillonIngredient {
        let texte = retirerPuce(ligne)
        let sansMarque =
            texte
            .remplacer(marqueQuantiteSuffisante, par: "")
            .remplacer(#"(?i)\h*[,;]?\h*(?:\((?:au go[uû]t|q\.?\h*s\.?)\)|\b(?:au go[uû]t|q\.?\h*s\.?))\.?$"#, par: "")
            .epure
        let pinceeDeSel = #"(?i)^(?:une|1)\h+pinc[ée]e\h+(?=de\h+sel\b)"#
        if sansMarque != texte || texte.correspond(pinceeDeSel) {
            let nom = sansMarque.remplacer(pinceeDeSel, par: "")
            return resultat(nom: nom, origine: ligne)
        }

        if let mesure = texte.range(of: #"(?i)^\#(plage)"#, options: .regularExpression) {
            let nombre = String(texte[mesure])
            var suite = String(texte[mesure.upperBound...])
            if nombre.lowercased().hasSuffix("demi") || nombre.lowercased().hasSuffix("demie"), suite.hasPrefix("-") {
                suite = " " + suite.dropFirst()
            }
            // Une mesure accolée à des lettres est admise seulement si elle est suivie d'une unité.
            let unite = lireUnite(suite.epure)
            if !suite.isEmpty && suite.first?.isWhitespace != true && unite == nil {
                return incompris(ligne)
            }
            return resultat(
                nom: unite?.suite ?? suite, origine: ligne, mesure: String(texte[mesure]), unite: unite)
        }

        // « farine : 200 g », « farine 200 g » et « œufs : 3 ».
        if let mesure = texte.range(
            of: #"(?i)(?<=:)\h*\#(plage)\h*(?:(?:\#(uniteEnFin)))?\h*$|(?<=\h)\#(plage)\h*(?:\#(uniteEnFin))\h*$"#,
            options: .regularExpression)
        {
            let suffixe = String(texte[mesure]).epure
            if let quantite = suffixe.range(of: #"(?i)^\#(plage)"#, options: .regularExpression) {
                let nom = String(texte[..<mesure.lowerBound]).remplacer(#"\h*:\h*$"#, par: "")
                return resultat(
                    nom: nom, origine: ligne, mesure: String(suffixe[quantite]),
                    unite: lireUnite(String(suffixe[quantite.upperBound...])))
            }
        }
        if texte.correspond(#"^[-+−]?(?:[0-9]|[/⁄])"#) || texte.correspond(#"(?i)^(?:\#(uniteEnFin))$"#) {
            return incompris(ligne)
        }
        return resultat(nom: texte, origine: ligne)
    }

    private static func lireUnite(_ texte: String) -> (unite: Unite, facteur: Int64, suite: String)? {
        let texte = texte.epure
        for variante in unites {
            if let plage = texte.range(of: "(?i)^(?:\(variante.motif))(?=$|[^\\p{L}])", options: .regularExpression) {
                return (variante.unite, variante.facteur, String(texte[plage.upperBound...]))
            }
        }
        return nil
    }

    private static func resultat(
        nom: String, origine: String, mesure: String? = nil,
        unite: (unite: Unite, facteur: Int64, suite: String)? = nil
    ) -> BrouillonIngredient {
        let nom = nom.epure
            .remplacer(#"(?i)^(\([^()]+\))\h+((?:de\h+|d['’]).+)$"#, par: "$2 $1")
            .remplacer(#"(?i)^(?:de\h+(?:(?:la|le|les)\h+|l['’])?|(?:de|du|des)(?:\h+|$)|d['’]\h*)"#, par: "")
            .epure
        let nomVide = !nom.contains(where: \.isLetter)
        let libelle = nomVide ? "" : nom
        guard let mesure else {
            return BrouillonIngredient(nom: libelle, texteOrigine: origine, ligneNonComprise: nomVide)
        }

        do {
            let quantite = try lireNombre(mesure) * Quantite(unite?.facteur ?? 1)
            guard quantite > Quantite(0) else { return incompris(origine) }
            return BrouillonIngredient(
                nom: libelle, quantite: quantite, unite: unite?.unite ?? .piece, texteOrigine: origine,
                ligneNonComprise: nomVide)
        } catch {
            return incompris(origine)
        }
    }

    static func lireNombre(_ texte: String) throws -> Quantite {
        let texte = texte.lowercased().epure
        if let valeur = nombres[texte] { return Quantite(valeur) }
        if texte.correspond(#"^(?:une?\h+)?demie?$"#) { return try Quantite(texte: "½") }
        if let premiereBorne = texte.range(
            of: #"(?i)^\#(nombre)\h*(?:à|a|[-–—])\h*(?=\#(nombre)$)"#, options: .regularExpression)
        {
            let borne = String(texte[premiereBorne]).remplacer(#"[àa\-–—]\h*$"#, par: "")
            return try max(lireNombre(borne), lireNombre(String(texte[premiereBorne.upperBound...])))
        }
        if let entier = texte.range(
            of: #"^[0-9]+(?=\h*[\#(fractions)]$|\h+\#(fraction)$)"#, options: .regularExpression)
        {
            return try Quantite(texte: String(texte[entier]))
                + Quantite(texte: String(texte[entier.upperBound...]).remplacer(#"\h+"#, par: ""))
        }
        return try Quantite(texte: texte.remplacer(#"\h+"#, par: ""))
    }

    private static func incompris(_ origine: String) -> BrouillonIngredient {
        BrouillonIngredient(nom: "", texteOrigine: origine, ligneNonComprise: true)
    }
}

func retirerPuce(_ texte: String) -> String {
    texte.epure.remplacer(#"^(?:[-*•▪◦‣–—☐☑]\h+|[•▪◦‣☐☑]\h*)"#, par: "").epure
}
