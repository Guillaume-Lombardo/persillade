import Foundation

public struct PointMotif: Hashable, Sendable {
    public let x: Double
    public let y: Double

    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
}

public struct PrimitiveMotif: Equatable, Sendable {
    public enum Commande: Equatable, Sendable {
        case aller(PointMotif)
        case ligne(PointMotif)
        case quadratique(controle: PointMotif, fin: PointMotif)
        case cubique(controle1: PointMotif, controle2: PointMotif, fin: PointMotif)
        case arc(centre: PointMotif, rayon: Double, debut: Double, fin: Double, sensHoraire: Bool)
        case fermer
    }

    public enum Geometrie: Equatable, Sendable {
        case ellipse(centre: PointMotif, rx: Double, ry: Double)
        case rectangle(origine: PointMotif, largeur: Double, hauteur: Double, rayon: Double)
        case chemin([Commande])
    }

    public struct Trait: Equatable, Sendable {
        public let couleur: UInt32
        public let largeur: Double
        public let arrondi: Bool
    }

    public let geometrie: Geometrie
    public let remplissage: UInt32?
    public let trait: Trait?
    public let origine: PointMotif
    /// Rotation en radians dans le repère d’image (axe y vers le bas).
    public let angle: Double
}

struct VisuelMotif: Sendable {
    enum Coupe: Sendable {
        case rondelle, tranche, baton, laniere, lardon, de, coin, champignon, gousse, feuille
        case quartier, fleurette, crevette, noix, olive
        case grain, hache, semis, filet

        var pasRelatif: Double {
            switch self {
            case .rondelle: 1.18
            case .tranche: 1
            case .baton: 0.62
            case .laniere: 0.82
            case .lardon: 1.02
            case .de: 1.86
            case .coin, .champignon: 1.62
            case .gousse: 0.84
            case .feuille: 1.16
            case .quartier, .fleurette, .crevette, .noix, .olive: 1.5
            default: 1.4
            }
        }
    }

    enum Variante: Sendable {
        case nu, pepins, quartiers, graines, coeur, anneaux, rayons, jaune
    }

    let coupe: Coupe
    let peau: UInt32
    let chair: UInt32
    let detail: UInt32
    let variante: Variante?

    init(_ coupe: Coupe, _ peau: UInt32, _ chair: UInt32, _ detail: UInt32, _ variante: Variante? = nil) {
        self.coupe = coupe
        self.peau = peau
        self.chair = chair
        self.detail = detail
        self.variante = variante
    }
}

struct PoseMotif {
    var origine: PointMotif
    var angle: Double

    static let identite = Self(origine: PointMotif(0, 0), angle: 0)

    func decaler(_ x: Double, _ y: Double) -> Self {
        let c = cos(angle)
        let s = sin(angle)
        return Self(origine: PointMotif(origine.x + x * c - y * s, origine.y + x * s + y * c), angle: angle)
    }

    func tourner(_ degres: Double) -> Self {
        Self(origine: origine, angle: angle + degres * .pi / 180)
    }
}

struct DessinMotif {
    var primitives: [PrimitiveMotif] = []

    mutating func ellipse(
        _ rx: Double, _ ry: Double, _ couleur: UInt32?, x: Double = 0, y: Double = 0,
        pose: PoseMotif, trait: PrimitiveMotif.Trait? = nil
    ) {
        ajouter(.ellipse(centre: PointMotif(x, y), rx: rx, ry: ry), couleur, pose, trait)
    }

    mutating func rectangle(
        _ x: Double, _ y: Double, _ w: Double, _ h: Double, _ rayon: Double = 0,
        couleur: UInt32, pose: PoseMotif, trait: PrimitiveMotif.Trait? = nil
    ) {
        ajouter(.rectangle(origine: PointMotif(x, y), largeur: w, hauteur: h, rayon: rayon), couleur, pose, trait)
    }

    mutating func chemin(
        _ commandes: [PrimitiveMotif.Commande], _ couleur: UInt32?, pose: PoseMotif,
        trait: PrimitiveMotif.Trait? = nil
    ) {
        ajouter(.chemin(commandes), couleur, pose, trait)
    }

    private mutating func ajouter(
        _ geometrie: PrimitiveMotif.Geometrie, _ couleur: UInt32?, _ pose: PoseMotif, _ trait: PrimitiveMotif.Trait?
    ) {
        primitives.append(
            .init(
                geometrie: geometrie, remplissage: couleur, trait: trait,
                origine: pose.origine, angle: pose.angle))
    }
}

/// Chemin local d’une coupe, en multiples de son rayon.
struct ProfilMotif {
    let rayon: Double
    private(set) var commandes: [PrimitiveMotif.Commande] = []
    private var position = PointMotif(0, 0)

    init(_ rayon: Double) { self.rayon = rayon }

    mutating func aller(_ x: Double, _ y: Double) {
        position = point(x, y)
        commandes.append(.aller(position))
    }

    mutating func ligne(_ x: Double, _ y: Double) {
        position = point(x, y)
        commandes.append(.ligne(position))
    }

    mutating func courbe(_ cx: Double, _ cy: Double, _ x: Double, _ y: Double) {
        position = point(x, y)
        commandes.append(.quadratique(controle: point(cx, cy), fin: position))
    }

    mutating func cubique(_ ax: Double, _ ay: Double, _ bx: Double, _ by: Double, _ x: Double, _ y: Double) {
        position = point(x, y)
        commandes.append(.cubique(controle1: point(ax, ay), controle2: point(bx, by), fin: position))
    }

    mutating func arc(_ r: Double, _ x: Double, _ y: Double, large: Bool = false, sensHoraire: Bool) {
        let fin = point(x, y)
        let dx = (position.x - fin.x) / 2
        let dy = (position.y - fin.y) / 2
        let distance = hypot(dx, dy)
        let rayon = max(r * rayon, distance)
        let signe = large == sensHoraire ? -1.0 : 1.0
        let facteur = signe * sqrt(max(0, rayon * rayon / (distance * distance) - 1))
        let centre = PointMotif((position.x + fin.x) / 2 + facteur * dy, (position.y + fin.y) / 2 - facteur * dx)
        let a = atan2(position.y - centre.y, position.x - centre.x)
        let b = atan2(fin.y - centre.y, fin.x - centre.x)
        commandes.append(.arc(centre: centre, rayon: rayon, debut: a, fin: b, sensHoraire: sensHoraire))
        position = fin
    }

    mutating func fermer() { commandes.append(.fermer) }

    private func point(_ x: Double, _ y: Double) -> PointMotif { PointMotif(x * rayon, y * rayon) }
}
