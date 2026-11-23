import Foundation

private let articles = Set(["de", "du", "des", "le", "la", "les"])
private let apostrophes = Set("'’‘ʼ＇")
private let traitsUnion = Set("-‐‑‒–—−")
private let motsInvariables = Set([
    "radis", "noix", "ananas", "mais", "anchois", "pois", "jus", "riz", "brebis", "cassis",
    "colis", "couscous", "houmous", "os", "frais", "gros", "bas",
])

public func normaliserNom(_ nom: String) -> String {
    let texte = nom.lowercased()
        .folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr_FR"))
        .replacingOccurrences(of: "œ", with: "oe")
        .replacingOccurrences(of: "æ", with: "ae")

    let mots = texte.split { $0.isWhitespace || apostrophes.contains($0) || traitsUnion.contains($0) }
    let sansArticlesInitiaux = mots.drop(while: { mot in
        if articles.contains(String(mot)) { return true }
        return (mot == "d" || mot == "l") && mot.endIndex < texte.endIndex
            && apostrophes.contains(texte[mot.endIndex])
    })
    return sansArticlesInitiaux.map(singulariserMot).joined(separator: " ")
}

func singulariserMot(_ mot: Substring) -> Substring {
    if motsInvariables.contains(String(mot)) || articles.contains(String(mot)) {
        return mot
    }
    if mot.count > 1 && (mot.last == "s" || mot.last == "x") { return mot.dropLast() }
    return mot
}

func retablirMotInvariable(_ mot: Substring) -> Substring {
    for terminaison in ["s", "x"] {
        let candidat = String(mot) + terminaison
        if motsInvariables.contains(candidat) { return candidat[...] }
    }
    return mot
}

public func convertir(_ quantite: Quantite, _ source: Unite, _ cible: Unite) throws -> Quantite? {
    if let a = source.nomAutreNormalise, let b = cible.nomAutreNormalise {
        return !a.isEmpty && a == b ? quantite : nil
    }
    if source == cible { return quantite }
    guard let origine = source.echelle, let destination = cible.echelle,
        origine.canonique == destination.canonique
    else { return nil }

    let facteur = try Quantite(numerateur: origine.facteur, denominateur: destination.facteur)
    return try quantite * facteur
}

extension Unite {
    fileprivate var echelle: (canonique: Unite, facteur: Int64)? {
        switch self {
        case .g: (.g, 1)
        case .kg: (.g, 1_000)
        case .ml: (.ml, 1)
        case .cl: (.ml, 10)
        case .l: (.ml, 1_000)
        default: nil
        }
    }
}
