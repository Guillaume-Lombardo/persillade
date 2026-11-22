import Foundation

public struct Quantite: Codable, Comparable, Hashable, Sendable {
    public enum Erreur: Error, Equatable, Sendable {
        case divisionParZero
        case depassement
        case formatInvalide
    }

    public let numerateur: Int64
    public let denominateur: Int64

    public init(_ entier: Int64) {
        numerateur = entier
        denominateur = 1
    }

    public init(numerateur: Int64, denominateur: Int64) throws {
        try self.init(Int128(numerateur), Int128(denominateur))
    }

    private init(_ numerateur: Int128, _ denominateur: Int128) throws {
        guard denominateur != 0 else { throw Erreur.divisionParZero }

        let diviseur = Self.pgcd(numerateur.magnitude, denominateur.magnitude)
        let magnitude = numerateur.magnitude / diviseur
        let negatif = (numerateur < 0) != (denominateur < 0)
        guard let reduit = Int128(exactly: magnitude),
            let haut = Int64(exactly: negatif ? -reduit : reduit),
            let bas = Int64(exactly: denominateur.magnitude / diviseur)
        else { throw Erreur.depassement }

        self.numerateur = haut
        self.denominateur = bas
    }

    private static func pgcd(_ a: UInt128, _ b: UInt128) -> UInt128 {
        var (a, b) = (a, b)
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }

    private static let fractions = [
        "¼": "1/4", "½": "1/2", "¾": "3/4", "⅐": "1/7", "⅑": "1/9", "⅒": "1/10",
        "⅓": "1/3", "⅔": "2/3", "⅕": "1/5", "⅖": "2/5", "⅗": "3/5", "⅘": "4/5",
        "⅙": "1/6", "⅚": "5/6", "⅛": "1/8", "⅜": "3/8", "⅝": "5/8", "⅞": "7/8",
    ]

    /// Lit un entier, un décimal avec virgule ou point, ou une fraction exacte.
    public init(texte: String) throws {
        var texte = texte.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "−", with: "-")
        let negatif = texte.first == "-"
        if negatif || texte.first == "+" { texte.removeFirst() }
        if let fraction = Self.fractions[texte] { texte = fraction }

        let termes = texte.split(omittingEmptySubsequences: false) { $0 == "/" || $0 == "⁄" }
        if termes.count == 2 {
            let haut = try Self.entier(termes[0])
            let bas = try Self.entier(termes[1])
            try self.init(negatif ? -haut : haut, bas)
            return
        }

        let parties = texte.split(omittingEmptySubsequences: false) { $0 == "," || $0 == "." }
        guard parties.count <= 2, !texte.isEmpty, texte != ",", texte != "." else {
            throw Erreur.formatInvalide
        }
        if parties.count == 1 {
            let haut = try Self.entier(parties[0])
            try self.init(negatif ? -haut : haut, 1)
            return
        }

        var fraction = Array(parties[1].utf8)
        guard fraction.allSatisfy({ (48...57).contains($0) }),
            parties[0].utf8.allSatisfy({ (48...57).contains($0) })
        else { throw Erreur.formatInvalide }

        while fraction.last == 48 { fraction.removeLast() }
        // Après retrait des zéros finaux, le dénominateur réduit contient 2^n ou 5^n.
        guard fraction.count <= 62 else { throw Erreur.depassement }
        var chiffres = (parties[0].utf8 + fraction).map { $0 - 48 }
        var bas: Int128 = 1
        for premier: UInt8 in [2, 5] {
            for _ in fraction {
                if let dernier = chiffres.last, dernier.isMultiple(of: premier) {
                    Self.diviser(&chiffres, par: premier)
                } else {
                    bas *= Int128(premier)
                    guard bas <= Int64.max else { throw Erreur.depassement }
                }
            }
        }

        var haut: Int128 = 0
        for chiffre in chiffres {
            haut = haut * 10 + Int128(chiffre)
            guard haut <= Int128(Int64.max) + 1 else { throw Erreur.depassement }
        }
        try self.init(negatif ? -haut : haut, bas)
    }

    private static func entier(_ texte: Substring) throws -> Int128 {
        guard !texte.isEmpty, texte.utf8.allSatisfy({ (48...57).contains($0) }) else {
            throw Erreur.formatInvalide
        }
        guard let nombre = Int128(texte) else { throw Erreur.depassement }
        return nombre
    }

    private static func diviser(_ chiffres: inout [UInt8], par diviseur: UInt8) {
        var reste: UInt8 = 0
        for index in chiffres.indices {
            let valeur = reste * 10 + chiffres[index]
            chiffres[index] = valeur / diviseur
            reste = valeur % diviseur
        }
    }

    public var texteFrancais: String {
        var facteurs = denominateur
        for premier: Int64 in [2, 5] {
            while facteurs.isMultiple(of: premier) { facteurs /= premier }
        }
        guard facteurs == 1 else { return "\(numerateur)/\(denominateur)" }

        let haut = UInt128(numerateur.magnitude)
        let bas = UInt128(denominateur)
        let signe = numerateur < 0 ? "-" : ""
        var texte = signe + String(haut / bas)
        var reste = haut % bas
        if reste > 0 { texte += "," }
        while reste > 0 {
            reste *= 10
            texte += String(reste / bas)
            reste %= bas
        }
        return texte
    }

    // Deux produits d'Int64 à dénominateur positif et leur somme tiennent dans Int128.
    public static func + (gauche: Self, droite: Self) throws -> Self {
        let a = Int128(gauche.numerateur) * Int128(droite.denominateur)
        let b = Int128(droite.numerateur) * Int128(gauche.denominateur)
        return try Self(a + b, Int128(gauche.denominateur) * Int128(droite.denominateur))
    }

    public static func - (gauche: Self, droite: Self) throws -> Self {
        let a = Int128(gauche.numerateur) * Int128(droite.denominateur)
        let b = Int128(droite.numerateur) * Int128(gauche.denominateur)
        return try Self(a - b, Int128(gauche.denominateur) * Int128(droite.denominateur))
    }

    public static func * (gauche: Self, droite: Self) throws -> Self {
        try Self(
            Int128(gauche.numerateur) * Int128(droite.numerateur),
            Int128(gauche.denominateur) * Int128(droite.denominateur))
    }

    public static func / (gauche: Self, droite: Self) throws -> Self {
        try Self(
            Int128(gauche.numerateur) * Int128(droite.denominateur),
            Int128(gauche.denominateur) * Int128(droite.numerateur))
    }

    public static func < (gauche: Self, droite: Self) -> Bool {
        Int128(gauche.numerateur) * Int128(droite.denominateur)
            < Int128(droite.numerateur) * Int128(gauche.denominateur)
    }

    private enum CodingKeys: String, CodingKey {
        case numerateur, denominateur
    }

    public init(from decoder: any Decoder) throws {
        let champs = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            numerateur: champs.decode(Int64.self, forKey: .numerateur),
            denominateur: champs.decode(Int64.self, forKey: .denominateur))
    }
}
