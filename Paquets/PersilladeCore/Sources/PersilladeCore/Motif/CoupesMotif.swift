import Foundation

extension DessinMotif {
    mutating func coupe(_ v: VisuelMotif, rayon r: Double, fond: UInt32, couteau: Double, jeu: Double, pose: PoseMotif)
    {
        let (p, c, d) = (v.peau, v.chair, v.detail)
        let bord = PrimitiveMotif.Trait(couleur: fond, largeur: couteau, arrondi: true)
        func trait(_ largeur: Double, arrondi: Bool = true) -> PrimitiveMotif.Trait {
            .init(couleur: d, largeur: largeur * r, arrondi: arrondi)
        }

        switch v.coupe {
        case .rondelle:
            rondelle(v, rayon: r, jeu: jeu, pose: pose, bord: bord)
        case .quartier:
            let pose = pose.tourner(jeu * 30)
            for (largeur, couleur, trait) in [(1.0, p, bord), (0.84, c, nil)] {
                profil(r, couleur, pose, trait) {
                    $0.aller(-largeur, -0.35)
                    $0.arc(largeur, largeur, -0.35, sensHoraire: false)
                    $0.fermer()
                }
            }
            if v.variante == .nu {
                profil(r, nil, pose, trait(0.1)) {
                    $0.aller(-0.5, -0.12)
                    $0.courbe(-0.05, 0.28, 0.5, -0.06)
                }
            } else {
                for x in [-0.14, 0.14] {
                    ellipse(r * 0.07, r * 0.14, d, x: r * x, y: -r * 0.1, pose: pose)
                }
            }
        case .de:
            let pose = pose.tourner(jeu * 26)
            let a = r * 0.82
            rectangle(-a, -a, 2 * a, 2 * a, r * 0.14, couleur: p, pose: pose, trait: bord)
            rectangle(-a, -a, 1.56 * a, 1.56 * a, r * 0.14, couleur: c, pose: pose)
            profil(a, nil, pose, trait(0.12)) {
                $0.aller(-0.62, 0.12)
                $0.courbe(-0.1, -0.3, 0.2, -0.62)
            }
        case .baton:
            let pose = pose.tourner(62 + jeu * 18)
            let l = r * 1.05
            let h = r * 0.27
            rectangle(-l, -h, 2 * l, 2 * h, r * 0.12, couleur: c, pose: pose, trait: bord)
            rectangle(-l, h * 0.2, 2 * l, h * 0.8, r * 0.1, couleur: p, pose: pose)
            rectangle(-l * 0.8, -h * 0.65, l * 1.1, h * 0.28, h * 0.14, couleur: d, pose: pose)
        case .lardon:
            let pose = pose.tourner(70 + jeu * 34)
            let l = r * 0.92
            let h = r * 0.42
            rectangle(-l, -h, 2 * l, 2 * h, r * 0.14, couleur: p, pose: pose, trait: bord)
            rectangle(-l, -h * 0.45, 2 * l, h * 0.5, couleur: c, pose: pose)
            rectangle(-l, h * 0.5, 2 * l, h * 0.5, r * 0.1, couleur: d, pose: pose)
        case .laniere:
            let pose = pose.tourner(jeu * 34)
            profil(r, p, pose, bord) {
                $0.aller(-0.5, -0.95)
                $0.courbe(0.5, 0, -0.5, 0.95)
                $0.ligne(0.05, 0.95)
                $0.courbe(1.05, 0, 0.05, -0.95)
                $0.fermer()
            }
            profil(r, nil, pose, .init(couleur: c, largeur: r * 0.2, arrondi: false)) {
                $0.aller(-0.36, -0.86)
                $0.courbe(0.62, 0, -0.36, 0.86)
            }
        case .tranche:
            let pose = pose.tourner(-58 + jeu * 8)
            let a = r * 1.08
            let b = r * 0.74
            rectangle(-a, -b, 2 * a, 2 * b, b * 0.62, couleur: p, pose: pose, trait: bord)
            rectangle(-a * 0.86, -b * 0.8, a * 1.72, b * 1.6, b * 0.5, couleur: c, pose: pose)
            for q in [-0.42, 0, 0.42] {
                profil(r, nil, pose, trait(0.09)) {
                    $0.aller(1.08 * q - 0.1, -0.74 * 0.55)
                    $0.courbe(1.08 * q + 0.16, 0, 1.08 * q - 0.1, 0.74 * 0.55)
                }
            }
        case .coin:
            let pose = pose.tourner(jeu * 22)
            profil(r, p, pose, bord) {
                $0.aller(-1.05, 0.62)
                $0.ligne(0.62, -0.7)
                $0.courbe(1.12, -0.1, 0.95, 0.62)
                $0.fermer()
            }
            profil(r, c, pose) {
                $0.aller(-0.98, 0.5)
                $0.ligne(0.58, -0.66)
                $0.courbe(0.86, -0.1, 0.7, 0.5)
                $0.fermer()
            }
            for (x, y, q) in [(0.2, 0.1, 0.17), (-0.22, 0.24, 0.1), (0.46, -0.2, 0.08)] {
                ellipse(r * q, r * q, d, x: r * x, y: r * y, pose: pose)
            }
        case .champignon:
            champignon(v, rayon: r, pose: pose.tourner(jeu * 36), bord: bord)
        case .gousse:
            gousse(v, rayon: r, pose: pose.tourner(15 + jeu * 8), bord: bord)
        case .feuille:
            let pose = pose.tourner(24 + jeu * 70)
            profil(r, p, pose, bord) {
                $0.aller(0, -1.05)
                $0.courbe(0.95, -0.1, 0, 1.05)
                $0.courbe(-0.95, -0.1, 0, -1.05)
                $0.fermer()
            }
            profil(r, c, pose) {
                $0.aller(0, -0.9)
                $0.courbe(0.76, -0.1, 0, 0.9)
                $0.fermer()
            }
            profil(r, nil, pose, trait(0.09, arrondi: false)) {
                $0.aller(0, -0.8)
                $0.ligne(0, 1.02)
            }
        case .fleurette:
            let pose = pose.tourner(jeu * 40)
            profil(r, d, pose, bord) {
                $0.aller(-0.22, 0.1)
                $0.ligne(-0.3, 0.98)
                $0.ligne(0.3, 0.98)
                $0.ligne(0.22, 0.1)
                $0.fermer()
            }
            for (x, y, q) in [
                (-0.52, 0.02, 0.44), (0.52, 0.02, 0.44), (-0.28, -0.46, 0.46),
                (0.3, -0.46, 0.46), (0, -0.06, 0.5),
            ] {
                ellipse(r * q, r * q, p, x: r * x, y: r * y, pose: pose, trait: bord)
            }
            for (x, y, q) in [
                (-0.52, -0.02, 0.34), (0.52, -0.02, 0.34), (-0.28, -0.5, 0.36),
                (0.3, -0.5, 0.36), (0, -0.12, 0.38),
            ] {
                ellipse(r * q, r * q, c, x: r * x, y: r * y, pose: pose)
            }
        case .crevette:
            let pose = pose.tourner(-20 + jeu * 30)
            profil(r, p, pose, bord) {
                $0.aller(-0.95, 0.25)
                $0.arc(0.95, 0.95, 0.1, sensHoraire: true)
                $0.ligne(0.42, 0.3)
                $0.arc(0.5, -0.4, 0.3, sensHoraire: false)
                $0.fermer()
            }
            for angle in [-60.0, -20, 20, 55] {
                profil(r, nil, pose.decaler(0, r * 0.14).tourner(angle), trait(0.11)) {
                    $0.aller(0, -0.5)
                    $0.ligne(0, -0.86)
                }
            }
        case .noix:
            let pose = pose.tourner(jeu * 80)
            profil(r, p, pose, bord) {
                $0.aller(0, -1)
                $0.courbe(0.95, -0.9, 0.86, 0)
                $0.courbe(0.9, 0.9, 0, 1)
                $0.courbe(-0.9, 0.9, -0.86, 0)
                $0.courbe(-0.95, -0.9, 0, -1)
                $0.fermer()
            }
            profil(r, nil, pose, .init(couleur: c, largeur: r * 0.14, arrondi: true)) {
                $0.aller(0, -0.86)
                $0.ligne(0, 0.86)
                for signe in [-1.0, 1] {
                    $0.aller(signe * 0.5, -0.5)
                    $0.courbe(signe * 0.15, -0.2, signe * 0.52, 0.1)
                    $0.courbe(signe * 0.2, 0.3, signe * 0.45, 0.6)
                }
            }
        case .olive:
            ellipse(r * 0.86, r * 0.86, p, pose: pose, trait: bord)
            ellipse(r * 0.4, r * 0.4, c, x: r * 0.06 * jeu, pose: pose)
            ellipse(r * 0.24, r * 0.24, d, x: r * 0.06 * jeu, pose: pose)
        default:
            ellipse(r, r, c, pose: pose, trait: bord)
        }
    }

    private mutating func rondelle(
        _ v: VisuelMotif, rayon r: Double, jeu: Double, pose: PoseMotif, bord: PrimitiveMotif.Trait
    ) {
        let (p, c, d) = (v.peau, v.chair, v.detail)
        ellipse(r, r, p, pose: pose, trait: bord)
        if v.variante != .jaune { ellipse(r * 0.86, r * 0.86, c, pose: pose) }
        switch v.variante {
        case .coeur:
            ellipse(r * 0.36, r * 0.36, d, pose: pose)
            for i in 0..<8 {
                let a = Double(i) * .pi / 4 + jeu
                profil(r, nil, pose, .init(couleur: d, largeur: r * 0.07, arrondi: true)) {
                    $0.aller(cos(a) * 0.44, sin(a) * 0.44)
                    $0.ligne(cos(a) * 0.7, sin(a) * 0.7)
                }
            }
        case .graines:
            for i in 0..<7 {
                let a = Double(i) * 2 * .pi / 7 + jeu
                ellipse(r * 0.07, r * 0.14, d, y: -r * 0.48, pose: pose.tourner(a * 57.3))
            }
        case .quartiers:
            for i in 0..<5 {
                let pose = pose.tourner(Double(i) * 72 + jeu * 60)
                profil(r, d, pose) {
                    $0.aller(0, -0.16)
                    $0.ligne(0.3, -0.56)
                    $0.courbe(0, -0.86, -0.3, -0.56)
                    $0.fermer()
                }
                for x in [-0.1, 0.1] { ellipse(r * 0.06, r * 0.06, p, x: r * x, y: -r * 0.5, pose: pose) }
            }
        case .anneaux:
            for q in [0.66, 0.46, 0.24] {
                ellipse(r * q, r * q, nil, pose: pose, trait: .init(couleur: d, largeur: r * 0.08, arrondi: false))
            }
        case .rayons:
            for i in 0..<8 {
                profil(r, d, pose.tourner(Double(i) * 45 + jeu * 40)) {
                    $0.aller(0, -0.1)
                    $0.ligne(0.22, -0.66)
                    $0.courbe(0, -0.8, -0.22, -0.66)
                    $0.fermer()
                }
            }
        case .jaune:
            ellipse(r * 0.5, r * 0.5, d, x: r * 0.08 * jeu, y: r * 0.08, pose: pose)
        default:
            break
        }
    }

    private mutating func champignon(
        _ v: VisuelMotif, rayon r: Double, pose: PoseMotif, bord: PrimitiveMotif.Trait
    ) {
        profil(r, v.peau, pose, bord) {
            $0.aller(-1.02, 0.1)
            $0.courbe(-1.02, -0.88, 0, -0.88)
            $0.courbe(1.02, -0.88, 1.02, 0.1)
            $0.courbe(0.9, 0.36, 0.3, 0.26)
            $0.courbe(0.24, 0.6, 0.4, 0.88)
            $0.courbe(0, 1.04, -0.4, 0.88)
            $0.courbe(-0.24, 0.6, -0.3, 0.26)
            $0.courbe(-0.9, 0.36, -1.02, 0.1)
            $0.fermer()
        }
        profil(r, v.chair, pose) {
            $0.aller(-0.84, 0.06)
            $0.courbe(-0.8, -0.7, 0, -0.7)
            $0.courbe(0.8, -0.7, 0.84, 0.06)
            $0.courbe(0.5, -0.08, 0.2, 0.08)
            $0.courbe(0.1, 0.5, 0.24, 0.8)
            $0.courbe(0, 0.88, -0.24, 0.8)
            $0.courbe(-0.1, 0.5, -0.2, 0.08)
            $0.courbe(-0.5, -0.08, -0.84, 0.06)
            $0.fermer()
        }
        profil(r, nil, pose, .init(couleur: v.detail, largeur: r * 0.08, arrondi: true)) {
            $0.aller(-0.56, -0.1)
            $0.courbe(-0.4, -0.5, 0, -0.5)
            $0.courbe(0.4, -0.5, 0.56, -0.1)
        }
    }

    private mutating func gousse(
        _ v: VisuelMotif, rayon r: Double, pose: PoseMotif, bord: PrimitiveMotif.Trait
    ) {
        profil(r, v.peau, pose, bord) {
            $0.aller(0, -1.08)
            $0.cubique(0.1, -0.8, 0.72, -0.42, 0.72, 0.28)
            $0.cubique(0.72, 0.78, 0.4, 1, 0, 1)
            $0.cubique(-0.4, 1, -0.72, 0.78, -0.72, 0.28)
            $0.cubique(-0.72, -0.42, -0.1, -0.8, 0, -1.08)
            $0.fermer()
        }
        profil(r, v.chair, pose) {
            $0.aller(0, -0.78)
            $0.cubique(0.08, -0.58, 0.54, -0.3, 0.54, 0.26)
            $0.cubique(0.54, 0.64, 0.3, 0.82, 0, 0.82)
            $0.cubique(-0.3, 0.82, -0.54, 0.64, -0.54, 0.26)
            $0.cubique(-0.54, -0.3, -0.08, -0.58, 0, -0.78)
            $0.fermer()
        }
        profil(r, nil, pose, .init(couleur: v.detail, largeur: r * 0.15, arrondi: true)) {
            $0.aller(-0.2, -0.2)
            $0.courbe(-0.13, 0.14, -0.2, 0.44)
        }
    }

    private mutating func profil(
        _ rayon: Double, _ couleur: UInt32?, _ pose: PoseMotif, _ trait: PrimitiveMotif.Trait? = nil,
        _ construire: (inout ProfilMotif) -> Void
    ) {
        var profil = ProfilMotif(rayon)
        construire(&profil)
        chemin(profil.commandes, couleur, pose: pose, trait: trait)
    }
}
