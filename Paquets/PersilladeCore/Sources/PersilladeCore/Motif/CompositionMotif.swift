import Foundation

extension Planche {
    public enum Cadrage: Hashable, Sendable {
        case vignette, semaine, fiche, miniature, vide, preuve

        fileprivate var nombreRangees: Int {
            switch self {
            case .vignette, .semaine: 3
            case .fiche, .preuve: 4
            case .miniature, .vide: 2
            }
        }

        fileprivate var module: Double {
            switch self {
            case .vignette: 34
            case .semaine: 38
            case .fiche, .vide, .preuve: 58
            case .miniature: 11
            }
        }

        fileprivate var biais: Double? {
            switch self {
            case .fiche: -10
            case .vide: -18
            default: nil
            }
        }

        fileprivate var bande: Double? {
            switch self {
            case .fiche: 80
            case .vide: 116
            default: nil
            }
        }

        fileprivate var debut: Double? {
            switch self {
            case .fiche: -50
            case .vide: -134
            default: nil
            }
        }

        fileprivate var densitePluches: Double {
            switch self {
            case .miniature: 0
            case .vide: 0.25
            default: 1
            }
        }
    }

    /// Les primitives sont centrées dans le cadre et s’affichent sur la couleur de fond.
    public func primitives(
        largeur: Double, hauteur: Double, cadrage: Cadrage, sombre: Bool
    ) throws -> [PrimitiveMotif] {
        guard (1...4_096).contains(largeur), (1...4_096).contains(hauteur) else { return [] }
        let pose = PoseMotif.identite.tourner(cadrage.biais ?? angle)
        let cadre = CadreMotif(largeur: largeur, hauteur: hauteur, pose: pose, cadrage: cadrage)
        let couleurFond = fond.couleur(sombre: sombre)
        let encre = fond.encre(sombre: sombre)
        let rangees = rangees.prefix(cadrage.nombreRangees)
        let nombre = Double(rangees.count)
        let repetitions: Int
        if let bande = cadrage.bande {
            repetitions = Int(ceil(cadre.hauteurTournee / (bande * nombre * 0.8))) + 1
        } else {
            let module = cadrage == .vignette && largeur <= 96 ? 30 : cadrage.module
            repetitions = max(1, Int((cadre.hauteurTournee / (module * nombre * 0.9)).rounded()))
        }
        let bande =
            cadrage.bande
            ?? cadre.hauteurTournee / (Double(repetitions) * rangees.reduce(0) { $0 + $1.hauteurRelative })
        let visuels = rangees.compactMap { rangee in
            visuel(rangee, fond: couleurFond, encre: encre, sombre: sombre).map { (rangee, $0) }
        }
        let id = id.uuidString
        var dessin = DessinMotif()
        var y = cadrage.debut ?? -cadre.hauteurTournee / 2
        for repetition in 0..<repetitions {
            for (indice, (rangee, visuel)) in visuels.enumerated() {
                if y > cadre.hauteurTournee / 2 { break }
                try Task.checkCancellation()
                let hauteur = bande * rangee.hauteurRelative
                let graine = Self.graine(id + "/r" + String(repetition * rangees.count + indice))
                let ligne = RangeeMotif(
                    visuel: visuel, neutre: rangee.neutre, hauteur: hauteur, y: y + hauteur / 2, graine: graine)
                switch visuel.coupe {
                case .grain, .hache, .semis:
                    ligne.dessinerGrains(dans: &dessin, cadre: cadre, fond: couleurFond)
                case .filet:
                    ligne.dessinerFilet(dans: &dessin, cadre: cadre)
                default:
                    ligne.dessinerPieces(dans: &dessin, cadre: cadre, fond: couleurFond, nombreRangees: nombre)
                }
                y += hauteur
            }
        }

        if min(largeur, hauteur) >= 24 {
            let couleurs: [UInt32] =
                switch pluches {
                case .sucreGlace: [0xFFFFFF, 0xFFF6E6]
                case .vertes: fond.pluches
                case .tonSurTon: [melanger(couleurFond, encre, 0.22), melanger(couleurFond, encre, 0.36)]
                }
            let densite = cadrage.densitePluches
            let nombre = min(120, Int((densite * cadre.surface / (cadre.petit ? 640 : 1_500)).rounded()))
            let rayon = max(1.4, min(4.4, sqrt(cadre.surface) / 44))
            let graine = Self.graine(id + "/pluches")
            for i in 0..<nombre {
                let tirage = TirageMotif(graine: graine, index: UInt64(i) * 16)
                let x = (tirage(12) - 0.5) * largeur
                let y = (tirage(13) - 0.5) * hauteur
                let position = cadrage.debut == nil ? y : y * 0.62 + hauteur * 0.19
                dessin.fragment(
                    rayon: rayon * (0.5 + tirage(14) * 0.8), couleur: couleurs[tirage(15) < 0.6 ? 0 : 1],
                    pose: .identite.decaler(x, position), tirage: tirage)
            }
        }
        return dessin.primitives
    }

    private func visuel(_ rangee: Rangee, fond: UInt32, encre: UInt32, sombre: Bool) -> VisuelMotif? {
        let coupe: VisuelMotif.Coupe
        switch rangee.visuel {
        case "g-ruban": coupe = .filet
        case "g-de": coupe = .de
        case "g-rondelle": coupe = .rondelle
        case "g-baton": coupe = .baton
        case "g-semis": coupe = .semis
        default: return DictionnaireMotif.visuels[rangee.visuel]
        }
        return VisuelMotif(
            coupe, melanger(fond, encre, 0.2), melanger(fond, encre, sombre ? 0.11 : 0.1),
            melanger(fond, encre, 0.3), coupe == .rondelle ? .anneaux : nil)
    }
}

private func melanger(_ a: UInt32, _ b: UInt32, _ proportion: Double) -> UInt32 {
    [16, 8, 0].reduce(0) { couleur, decalage in
        let canal = Double((a >> decalage) & 255) * (1 - proportion) + Double((b >> decalage) & 255) * proportion
        return couleur | (UInt32(canal.rounded()) << decalage)
    }
}

private struct CadreMotif {
    let largeur: Double
    let hauteur: Double
    let pose: PoseMotif
    let cadrage: Planche.Cadrage
    let cosinus: Double
    let sinus: Double

    init(largeur: Double, hauteur: Double, pose: PoseMotif, cadrage: Planche.Cadrage) {
        self.largeur = largeur
        self.hauteur = hauteur
        self.pose = pose
        self.cadrage = cadrage
        cosinus = cos(pose.angle)
        sinus = sin(pose.angle)
    }

    var surface: Double { largeur * hauteur }
    var petit: Bool { surface < 16_000 }
    var largeurTournee: Double { largeur * cosinus + hauteur * abs(sinus) }
    var hauteurTournee: Double { largeur * abs(sinus) + hauteur * cosinus }
    var trait: Double { max(1, min(largeur, hauteur) / (cadrage == .preuve ? 150 : cadrage == .miniature ? 22 : 62)) }

    func contient(_ pose: PoseMotif, rayon: Double) -> Bool {
        let x = pose.origine.x
        let y = pose.origine.y
        return abs(x) <= largeur / 2 + rayon && abs(y) <= hauteur / 2 + rayon
            && (cadrage != .semaine || x - rayon >= -largeur / 2)
    }
}

private struct TirageMotif {
    let graine: UInt64
    let index: UInt64

    func callAsFunction(_ decalage: UInt64) -> Double {
        Planche.tirage(graine, index + decalage)
    }
}

private struct RangeeMotif {
    let visuel: VisuelMotif
    let neutre: Bool
    let hauteur: Double
    let y: Double
    let graine: UInt64

    func dessinerPieces(dans dessin: inout DessinMotif, cadre: CadreMotif, fond: UInt32, nombreRangees: Double) {
        let rayon = hauteur * 0.5 * 0.97
        let budget = (cadre.petit ? 90.0 : 260) / nombreRangees
        let largeur = cadre.largeurTournee
        let pas = max(rayon * visuel.coupe.pasRelatif, largeur / budget)
        let decalage = Planche.tirage(graine, 999_983) * pas
        let maximum = Int(ceil(largeur / 2 / pas)) + 1
        for j in (-maximum - 1)...maximum {
            let tirage = TirageMotif(graine: graine, index: Planche.rangPiece(j) * 4)
            let x = Double(j) * pas + decalage
            let pose = cadre.pose.decaler(x, y + (tirage(0) - 0.5) * hauteur * 0.05)
            guard cadre.contient(pose, rayon: rayon * 1.08) else { continue }
            dessin.coupe(visuel, rayon: rayon, fond: fond, couteau: cadre.trait, jeu: tirage(1) - 0.5, pose: pose)
        }
    }

    func dessinerGrains(dans dessin: inout DessinMotif, cadre: CadreMotif, fond: UInt32) {
        let coupe = visuel.coupe
        let (taille, dx0, dy0): (Double, Double, Double) =
            switch coupe {
            case .grain: (hauteur / (hauteur > 44 ? 7.4 : 5.2), 2.02, 1.62)
            case .hache: (cadre.cadrage == .vide ? 9 : max(2.2, hauteur / 9), 1.62, 1.22)
            default: (max(0.8, hauteur / 26), 2.7, 1.9)
            }
        let budget = (cadre.petit ? 150.0 : 420) * (coupe == .semis ? (neutre ? 0.8 : 1.2) : 1)
        let largeur = cadre.largeurTournee
        let estimation = (largeur / (taille * dx0)) * (hauteur / (taille * dy0))
        let q = taille * max(1, sqrt(estimation / budget))
        let dx = q * dx0
        let dy = q * dy0
        let lignes = max(1, Int(floor((hauteur - q * 0.6) / dy)))
        let depart = y - Double(lignes - 1) * dy / 2
        let maximum = Int(ceil(largeur / 2 / dx)) + 1
        for a in 0..<lignes {
            for j in -maximum...maximum {
                let tirage = TirageMotif(graine: graine, index: Planche.rangGrille(j, a) * 16)
                let x = (Double(j) + Double(a % 2) / 2) * dx
                let y = depart + Double(a) * dy
                let pose = cadre.pose.decaler(x, y)
                guard cadre.contient(pose, rayon: q * 1.5) else { continue }
                switch coupe {
                case .hache:
                    let pose = pose.decaler((tirage(12) - 0.5) * q * 0.7, (tirage(13) - 0.5) * q * 0.5)
                    let couleurs = [visuel.peau, visuel.chair, visuel.detail]
                    dessin.fragment(
                        rayon: q * (0.62 + tirage(14) * 0.42), couleur: couleurs[Int(tirage(15) * 2.4)],
                        pose: pose, tirage: tirage)
                case .semis:
                    let rayon = q * (0.45 + tirage(2) * 0.75)
                    dessin.ellipse(
                        rayon, rayon, tirage(3) < 0.25 ? visuel.peau : visuel.chair,
                        x: (tirage(0) - 0.5) * dx * 0.8, y: (tirage(1) - 0.5) * dy * 0.8, pose: pose)
                default:
                    let pose = pose.decaler((tirage(0) - 0.5) * q * 0.6, (tirage(1) - 0.5) * q * 0.5)
                        .tourner((tirage(3) - 0.5) * 90)
                    dessin.ellipse(
                        q, q * 0.8, tirage(2) < 0.3 ? visuel.detail : visuel.chair, pose: pose,
                        trait: .init(couleur: fond, largeur: cadre.trait * 0.8, arrondi: false))
                }
            }
        }
    }

    func dessinerFilet(dans dessin: inout DessinMotif, cadre: CadreMotif) {
        let amplitude = hauteur * 0.13
        let longueurOnde = hauteur * (2.1 + Planche.tirage(graine, 0))
        let phase = Planche.tirage(graine, 1) * 6.283
        let demiEpaisseur = hauteur * 0.31
        let largeur = cadre.largeurTournee
        let margeTrait = max(1, hauteur * 0.07) / 2
        let projectionY = y * cadre.sinus + (amplitude + demiEpaisseur) * abs(cadre.sinus)
        let gauche =
            cadre.cadrage == .semaine
            ? (-cadre.largeur / 2 + margeTrait + projectionY) / cadre.cosinus
            : -largeur / 2 - 4
        let droite = largeur / 2 + 4
        guard gauche < droite else { return }
        let nombre = min(60, Int(ceil(largeur / (longueurOnde / 14))))
        var haut: [PrimitiveMotif.Commande] = []
        var bas: [PrimitiveMotif.Commande] = []
        var milieu: [PrimitiveMotif.Commande] = []
        for k in 0...nombre {
            let x = gauche + (droite - gauche) * Double(k) / Double(nombre)
            let centre = y + sin(x / longueurOnde * 6.283 + phase) * amplitude
            let pointHaut = PointMotif(x, centre - demiEpaisseur)
            haut.append(k == 0 ? .aller(pointHaut) : .ligne(pointHaut))
            bas.append(.ligne(PointMotif(x, centre + demiEpaisseur)))
            if k > 1 {
                let pointMilieu = PointMotif(x, centre - demiEpaisseur * 0.36)
                milieu.append(k == 2 ? .aller(pointMilieu) : .ligne(pointMilieu))
            }
        }
        haut.append(contentsOf: bas.reversed())
        haut.append(.fermer)
        dessin.chemin(
            haut, visuel.chair, pose: cadre.pose,
            trait: .init(couleur: visuel.peau, largeur: max(1, hauteur * 0.05), arrondi: true))
        dessin.chemin(
            milieu, nil, pose: cadre.pose,
            trait: .init(couleur: visuel.detail, largeur: max(1, hauteur * 0.07), arrondi: true))
    }
}

extension DessinMotif {
    fileprivate mutating func fragment(rayon: Double, couleur: UInt32, pose: PoseMotif, tirage: TirageMotif) {
        let nombre = 4 + Int(tirage(0) * 2)
        let depart = tirage(1) * 6.283
        var profil = ProfilMotif(rayon)
        for i in 0..<nombre {
            let angle = depart + Double(i) * 6.283 / Double(nombre) + (tirage(UInt64(2 + 2 * i)) - 0.5) * 0.7
            let q = 0.55 + tirage(UInt64(3 + 2 * i)) * 0.6
            let x = cos(angle) * q * 1.25
            let y = sin(angle) * q * 0.8
            if i == 0 { profil.aller(x, y) } else { profil.ligne(x, y) }
        }
        profil.fermer()
        chemin(profil.commandes, couleur, pose: pose)
    }
}
