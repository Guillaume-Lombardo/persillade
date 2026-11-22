import Foundation

/// Modèle de motif indépendant du cadre et de l’apparence.
public struct Planche: Hashable, Sendable {
    public static let versionMoteur = 1

    public enum Pluches: Hashable, Sendable {
        case vertes, sucreGlace, tonSurTon
    }

    public enum Fond: Int, CaseIterable, Hashable, Sendable {
        case persil, rose, beurre, faience, pois, aubergine

        private var palette: (clair: UInt32, sombre: UInt32, encre: UInt32, encreSombre: UInt32, pluches: [UInt32]) {
            switch self {
            case .persil: (0x0F5B33, 0x0C4527, 0xF4F8EC, 0xE8F3E3, [0x7FD36B, 0xB9E58A])
            case .rose: (0xF7C9D4, 0x6A2440, 0x4A1029, 0xFFDDE6, [0x0F5B33, 0x2E9E4F])
            case .beurre: (0xFFDC63, 0x42320A, 0x3A2A00, 0xFFE9A3, [0x0F5B33, 0x2E8B45])
            case .faience: (0xBCDDF5, 0x163F63, 0x0B2E4D, 0xD3EAFB, [0x0F5B33, 0x2E8B45])
            case .pois: (0xCBE38A, 0x39500F, 0x1F3304, 0xE2F3B4, [0x0F5B33, 0x2F7A2E])
            case .aubergine: (0x43214F, 0x371A42, 0xFBEAF6, 0xF3DDF0, [0x7FD36B, 0xB9E58A])
            }
        }

        public func couleur(sombre: Bool) -> UInt32 { sombre ? palette.sombre : palette.clair }
        public func encre(sombre: Bool) -> UInt32 { sombre ? palette.encreSombre : palette.encre }
        var pluches: [UInt32] { palette.pluches }
    }

    public struct Rangee: Hashable, Sendable {
        public let visuel: String
        public let hauteurRelative: Double
        public let neutre: Bool
    }

    public let id: UUID
    public let fond: Fond
    public let rangees: [Rangee]
    public let pluches: Pluches
    public let angle: Double
    public let empreinteIngredients: UInt64

    public init(recette: Recette) {
        self.init(id: recette.id, ingredients: recette.ingredients)
    }

    public init(id: UUID, ingredients: [Ingredient]) {
        self.id = id
        empreinteIngredients = Self.empreinte(ingredients)
        let analyse = Self.analyser(ingredients)
        let cle = id.uuidString
        fond = Self.choisirFond(cle: cle, pieces: analyse.pieces)
        pluches = analyse.pluches
        angle = [-18, -11, 11, 18][Int(Self.tirage(Self.graine(cle + "/cadre"), 0) * 4)]

        let maximum = sqrt(analyse.pieces.first?.masse ?? 1)
        var rangees = analyse.pieces.map { piece in
            let coupe = DictionnaireMotif.visuels[piece.visuel]?.coupe
            let plafond = coupe == .semis ? 0.6 : coupe == .filet ? 0.8 : 1
            return Rangee(
                visuel: piece.visuel, hauteurRelative: min(plafond, max(0.55, sqrt(piece.masse) / maximum)),
                neutre: false)
        }

        let replis = ["g-ruban", "g-de", "g-rondelle", "g-baton"]
        let indice = Int(Self.tirage(Self.graine(cle + "/repli"), 0) * 4)
        switch rangees.count {
        case 0:
            rangees = [
                Rangee(visuel: replis[indice], hauteurRelative: 1, neutre: true),
                Rangee(visuel: "g-semis", hauteurRelative: 0.55, neutre: true),
                Rangee(visuel: replis[(indice + 1) % 4], hauteurRelative: 0.9, neutre: true),
            ]
        case 1:
            rangees.append(Rangee(visuel: replis[indice], hauteurRelative: 0.9, neutre: true))
        default:
            break
        }
        self.rangees = rangees
    }

    private static func empreinte(_ ingredients: [Ingredient]) -> UInt64 {
        var valeur: UInt64 = 0xCBF2_9CE4_8422_2325
        for ingredient in ingredients {
            for champ in [
                ingredient.nom, ingredient.quantite?.texteFrancais ?? "",
                String(describing: ingredient.unite), ingredient.texteOrigine,
            ] {
                for octet in champ.utf8 {
                    valeur = (valeur ^ UInt64(octet)) &* 0x100_0000_01B3
                }
                // 0xFF n’est jamais un octet UTF-8.
                valeur = (valeur ^ 0xFF) &* 0x100_0000_01B3
            }
        }
        return valeur
    }

    static func graine(_ texte: String) -> UInt64 {
        texte.lowercased().utf8.reduce(0xCBF2_9CE4_8422_2325) { ($0 ^ UInt64($1)) &* 0x100_0000_01B3 }
    }

    static func tirage(_ graine: UInt64, _ index: UInt64) -> Double {
        var valeur = graine &+ ((index &+ 1) &* 0x9E37_79B9_7F4A_7C15)
        valeur = (valeur ^ (valeur >> 30)) &* 0xBF58_476D_1CE4_E5B9
        valeur = (valeur ^ (valeur >> 27)) &* 0x94D0_49BB_1331_11EB
        return Double((valeur ^ (valeur >> 31)) >> 11) / 9_007_199_254_740_992
    }

    static func rangPiece(_ colonne: Int) -> UInt64 {
        colonne >= 0 ? UInt64(colonne) * 2 : UInt64(-colonne) * 2 - 1
    }

    static func rangGrille(_ colonne: Int, _ ligne: Int) -> UInt64 {
        let x = rangPiece(colonne)
        let y = rangPiece(ligne)
        return (x + y) * (x + y + 1) / 2 + y
    }

    static func normaliserPourMotif(_ nom: String) -> String {
        let sansParentheses = nom.replacingOccurrences(of: #"\([^)]*\)"#, with: " ", options: .regularExpression)
        let sansPonctuation = sansParentheses.replacingOccurrences(
            of: #"[^\p{L}\p{M}\p{N}%\s'’‘ʼ＇\-‐‑‒–—−]"#, with: " ", options: .regularExpression)
        return normaliserNom(sansPonctuation)
    }

    enum Reconnaissance {
        case piece(DictionnaireMotif.Entree)
        case exclu, inconnu
    }

    static func reconnaitre(_ nom: String) -> Reconnaissance {
        reconnaitreMots(" " + normaliserPourMotif(nom) + " ")
    }

    private static func reconnaitreMots(_ mots: String) -> Reconnaissance {
        var meilleur: (entree: DictionnaireMotif.Entree, longueur: Int, debut: String.Index)?
        for (cle, entree) in DictionnaireMotif.cles {
            guard let debut = mots.range(of: " " + cle + " ")?.lowerBound else { continue }
            if let precedent = meilleur,
                cle.count < precedent.longueur || (cle.count == precedent.longueur && debut >= precedent.debut)
            {
                continue
            }
            meilleur = (entree, cle.count, debut)
        }
        for cle in DictionnaireMotif.exclusions {
            guard let debut = mots.range(of: " " + cle + " ")?.lowerBound else { continue }
            if let meilleur, debut > meilleur.debut || (debut == meilleur.debut && cle.count < meilleur.longueur) {
                continue
            }
            return .exclu
        }
        if let meilleur { return .piece(meilleur.entree) }
        return .inconnu
    }

    static func masse(_ ingredient: Ingredient, piece: Double) -> Double {
        guard let quantite = ingredient.quantite else { return 5 }
        let nombre = borneHaute(ingredient, quantite: quantite) ?? quantite
        let facteur: Double =
            switch ingredient.unite {
            case .g, .ml: 1
            case .kg, .l: 1_000
            case .cl: 10
            case .cas: 15
            case .cac: 5
            case .autre(let nom): DictionnaireMotif.massesAutresUnites[normaliserNom(nom)] ?? piece
            case .piece, nil: piece
            }
        return Double(nombre.numerateur) / Double(nombre.denominateur) * facteur
    }

    private static func borneHaute(_ ingredient: Ingredient, quantite: Quantite) -> Quantite? {
        let motif =
            #/^\s*(?:[-•*]\s*)?([0-9]+(?:[/⁄.,][0-9]+)?|[¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])\s*(?:à|[-–—])\s*([0-9]+(?:[/⁄.,][0-9]+)?|[¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])(?![0-9/⁄.,])/#
        guard let (_, bas, haut) = ingredient.texteOrigine.firstMatch(of: motif)?.output,
            let minimum = try? Quantite(texte: String(bas)), minimum == quantite,
            let maximum = try? Quantite(texte: String(haut)), maximum > minimum
        else { return nil }
        return maximum
    }

    private struct PiecePesee {
        let visuel: String
        let classe: DictionnaireMotif.Classe
        var masse: Double
    }

    private static func analyser(_ ingredients: [Ingredient]) -> (pieces: [PiecePesee], pluches: Pluches) {
        var parVisuel: [String: PiecePesee] = [:]
        var sale = false
        for ingredient in ingredients {
            let mots = " " + normaliserPourMotif(ingredient.nom) + " "
            switch reconnaitreMots(mots) {
            case .piece(let entree):
                parVisuel[entree.visuel, default: PiecePesee(visuel: entree.visuel, classe: entree.classe, masse: 0)]
                    .masse += masse(ingredient, piece: entree.masse)
                sale = sale || DictionnaireMotif.sales.contains(entree.visuel)
            case .exclu:
                sale = sale || DictionnaireMotif.exclusionsSalees.contains { mots.contains(" " + $0 + " ") }
            case .inconnu:
                break
            }
        }

        let tous = parVisuel.values.sorted { a, b in a.masse == b.masse ? a.visuel < b.visuel : a.masse > b.masse }
        let solides = tous.filter { $0.classe == .solide && $0.masse >= 8 }
        let pieces: [PiecePesee]
        if solides.count >= 2 {
            pieces = Array(solides.prefix(4))
        } else {
            let petitsSolides = tous.filter { $0.classe == .solide && $0.masse < 8 }.prefix(2)
            let ajouts = [tous.first { $0.classe == .liquide }, tous.first { $0.classe == .poudre }].compactMap { $0 }
            pieces = Array((solides + petitsSolides + ajouts).sorted { $0.masse > $1.masse }.prefix(3))
        }

        let masseSucree = ["sucre", "cassonade", "chocolat", "miel", "confiture"]
            .reduce(0.0) { $0 + (parVisuel[$1]?.masse ?? 0) }
        return (pieces, sale ? .vertes : masseSucree >= 40 ? .sucreGlace : .tonSurTon)
    }

    private static func choisirFond(cle: String, pieces: [PiecePesee]) -> Fond {
        let fonds = Fond.allCases
        let depart = Int(graine(cle + "/fond") % UInt64(fonds.count))
        let visuels = pieces.prefix(3).compactMap { DictionnaireMotif.visuels[$0.visuel] }
        var choix = fonds[depart]
        var plusGrandEcart = -1.0
        for i in fonds.indices {
            let fond = fonds[(depart + i) % fonds.count]
            let lab = Lab(couleur: fond.couleur(sombre: false))
            let ecart =
                visuels.map { max(lab.ecart(Lab(couleur: $0.peau)), lab.ecart(Lab(couleur: $0.chair))) }
                .min() ?? 1
            if ecart >= 0.14 { return fond }
            if ecart > plusGrandEcart {
                choix = fond
                plusGrandEcart = ecart
            }
        }
        return choix
    }

    private struct Lab {
        let l: Double
        let a: Double
        let b: Double

        init(couleur: UInt32) {
            let srgb = [16, 8, 0].map { decalage in
                let canal = Double((couleur >> decalage) & 255) / 255
                return canal <= 0.04045 ? canal / 12.92 : pow((canal + 0.055) / 1.055, 2.4)
            }
            let r = srgb[0]
            let g = srgb[1]
            let b = srgb[2]
            let rouge = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
            let vert = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
            let bleu = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
            l = 0.2104542553 * rouge + 0.793617785 * vert - 0.0040720468 * bleu
            a = 1.9779984951 * rouge - 2.428592205 * vert + 0.4505937099 * bleu
            self.b = 0.0259040371 * rouge + 0.7827717662 * vert - 0.808675766 * bleu
        }

        func ecart(_ autre: Self) -> Double {
            let dl = l - autre.l
            let da = a - autre.a
            let db = b - autre.b
            return sqrt(dl * dl + da * da + db * db)
        }
    }
}
