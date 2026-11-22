import CoreGraphics
import Foundation
import ImageIO
import OSLog
import PersilladeCore
import UniformTypeIdentifiers

struct DemandePlanche: Hashable, Sendable {
    let planche: Planche
    let cadrage: Planche.Cadrage
    let largeurPixels: Int
    let hauteurPixels: Int
    let echelle: Double
    let sombre: Bool
    let contrasteAccru: Bool
    private let version = Planche.versionMoteur

    init?(
        planche: Planche, cadrage: Planche.Cadrage, largeur: Double, hauteur: Double, echelle: Double, sombre: Bool,
        contrasteAccru: Bool = false
    ) {
        let largeurPixels = (largeur * echelle).rounded()
        let hauteurPixels = (hauteur * echelle).rounded()
        guard (1...4).contains(echelle),
            (1...4_096).contains(largeur), (1...4_096).contains(hauteur),
            (1...16_384).contains(largeurPixels), (1...16_384).contains(hauteurPixels),
            largeurPixels * hauteurPixels * 4 <= Double(RenduPlanche.limiteOctets)
        else { return nil }
        self.planche = planche
        self.cadrage = cadrage
        self.largeurPixels = Int(largeurPixels)
        self.hauteurPixels = Int(hauteurPixels)
        self.echelle = echelle
        self.sombre = sombre
        self.contrasteAccru = contrasteAccru
    }
}

actor RenduPlanche {
    typealias Dessin = @Sendable (DemandePlanche) async throws -> CGImage

    static let partage = RenduPlanche { demande in
        guard demande.cadrage == .vignette else { return try dessiner(demande) }
        return try imageVignette(demande)
    }
    static let limiteOctets = 24_000_000

    enum Erreur: Error {
        case espaceCouleur, contexte, image, encodage
    }

    private final class Cle: NSObject {
        let demande: DemandePlanche

        init(_ demande: DemandePlanche) { self.demande = demande }

        override var hash: Int { demande.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            (object as? Cle)?.demande == demande
        }
    }

    private struct Travail {
        let id: UUID
        let tache: Task<Void, Never>
        var attentes: [UUID: CheckedContinuation<CGImage, any Error>]
    }

    private let cache = NSCache<Cle, CGImage>()
    private var travaux: [DemandePlanche: Travail] = [:]
    private let dessin: Dessin

    init(dessin: @escaping Dessin = { try RenduPlanche.dessiner($0) }) {
        self.dessin = dessin
        cache.totalCostLimit = Self.limiteOctets
    }

    #if DEBUG
        func nombreConsommateurs(_ demande: DemandePlanche) -> Int {
            travaux[demande]?.attentes.count ?? 0
        }
    #endif

    func image(_ demande: DemandePlanche) async throws -> CGImage {
        try Task.checkCancellation()
        if let image = cache.object(forKey: Cle(demande)) { return image }
        let consommateur = UUID()
        let image: CGImage = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { attente in
                if Task.isCancelled {
                    attente.resume(throwing: CancellationError())
                } else {
                    inscrire(attente, pour: demande, consommateur: consommateur)
                }
            }
        } onCancel: {
            Task { await self.annuler(demande, consommateur: consommateur) }
        }
        try Task.checkCancellation()
        return image
    }

    func preparerVignettes(_ planche: Planche, echelle: Double) async {
        for sombre in [false, true] {
            guard
                let demande = DemandePlanche(
                    planche: planche, cadrage: .vignette, largeur: 112, hauteur: 96, echelle: echelle, sombre: sombre)
            else { continue }
            do {
                _ = try await image(demande)
            } catch is CancellationError {
                return
            } catch {
                Self.journal.error("Préparation d’une vignette impossible : \(error.localizedDescription)")
            }
        }
    }

    func vider() { cache.removeAllObjects() }

    private static let journal = Logger(subsystem: "xyz.g1lom.persillade", category: "Motif")

    private static func imageVignette(_ demande: DemandePlanche) throws -> CGImage {
        let dossier = URL.cachesDirectory.appending(path: "Vignettes")
        let variante = [
            String(Planche.versionMoteur), String(demande.largeurPixels), String(demande.hauteurPixels),
            String(demande.echelle), String(demande.sombre), String(demande.contrasteAccru),
        ].joined(separator: "-")
        let fichier = dossier.appending(path: "\(demande.planche.id.uuidString)-\(variante).png.cache")
        let empreinte = withUnsafeBytes(of: demande.planche.empreinteIngredients.bigEndian) { Data($0) }
        do {
            let donnees = try Data(contentsOf: fichier)
            if donnees.starts(with: empreinte),
                let source = CGImageSourceCreateWithData(Data(donnees.dropFirst(empreinte.count)) as CFData, nil),
                let image = CGImageSourceCreateImageAtIndex(
                    source, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary),
                image.width == demande.largeurPixels, image.height == demande.hauteurPixels
            {
                return image
            }
        } catch let erreur as CocoaError where erreur.code == .fileReadNoSuchFile {
        } catch {
            journal.error("Lecture d’une vignette impossible : \(error.localizedDescription)")
        }
        let image = try dessiner(demande)
        do {
            let png = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(png, UTType.png.identifier as CFString, 1, nil)
            else { throw Erreur.encodage }
            CGImageDestinationAddImage(destination, image, nil)
            guard CGImageDestinationFinalize(destination) else { throw Erreur.encodage }
            try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
            try (empreinte + (png as Data)).write(to: fichier, options: .atomic)
        } catch {
            journal.error("Écriture d’une vignette impossible : \(error.localizedDescription)")
        }
        return image
    }

    private func inscrire(
        _ attente: CheckedContinuation<CGImage, any Error>, pour demande: DemandePlanche, consommateur: UUID
    ) {
        if travaux[demande] != nil {
            travaux[demande]?.attentes[consommateur] = attente
            return
        }
        let id = UUID()
        let tache = Task.detached(priority: .userInitiated) { [dessin] in
            let resultat: Result<CGImage, any Error>
            do {
                resultat = .success(try await dessin(demande))
            } catch {
                resultat = .failure(error)
            }
            await self.terminer(demande, id: id, resultat: resultat)
        }
        travaux[demande] = Travail(id: id, tache: tache, attentes: [consommateur: attente])
    }

    private func annuler(_ demande: DemandePlanche, consommateur: UUID) {
        guard let attente = travaux[demande]?.attentes.removeValue(forKey: consommateur) else { return }
        attente.resume(throwing: CancellationError())
        if travaux[demande]?.attentes.isEmpty == true {
            travaux.removeValue(forKey: demande)?.tache.cancel()
        }
    }

    private func terminer(_ demande: DemandePlanche, id: UUID, resultat: Result<CGImage, any Error>) {
        guard travaux[demande]?.id == id, let travail = travaux.removeValue(forKey: demande) else { return }
        if case .success(let image) = resultat {
            let cout = image.bytesPerRow * image.height
            if cout <= Self.limiteOctets { cache.setObject(image, forKey: Cle(demande), cost: cout) }
        }
        for attente in travail.attentes.values { attente.resume(with: resultat) }
    }

    private static func dessiner(_ demande: DemandePlanche) throws -> CGImage {
        try Task.checkCancellation()
        guard let srgb = CGColorSpace(name: CGColorSpace.sRGB) else { throw Erreur.espaceCouleur }
        guard
            let ctx = CGContext(
                data: nil, width: demande.largeurPixels, height: demande.hauteurPixels,
                bitsPerComponent: 8, bytesPerRow: 0, space: srgb,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        else { throw Erreur.contexte }

        var palette: [UInt32: CGColor] = [:]
        func couleur(_ valeur: UInt32) -> CGColor {
            if let couleur = palette[valeur] { return couleur }
            let composantes = composantesSRGB(valeur)
            let couleur = CGColor(srgbRed: composantes.rouge, green: composantes.vert, blue: composantes.bleu, alpha: 1)
            palette[valeur] = couleur
            return couleur
        }

        ctx.setFillColor(couleur(demande.planche.fond.couleur(sombre: demande.sombre)))
        let largeur = Double(demande.largeurPixels)
        let hauteur = Double(demande.hauteurPixels)
        ctx.fill(CGRect(x: 0, y: 0, width: largeur, height: hauteur))
        ctx.translateBy(x: largeur / 2, y: hauteur / 2)
        ctx.scaleBy(x: demande.echelle, y: -demande.echelle)

        let primitives = try demande.planche.primitives(
            largeur: largeur / demande.echelle, hauteur: hauteur / demande.echelle,
            cadrage: demande.cadrage, sombre: demande.sombre)
        for (i, primitive) in primitives.enumerated() {
            if i.isMultiple(of: 32) { try Task.checkCancellation() }
            ctx.saveGState()
            ctx.translateBy(x: primitive.origine.x, y: primitive.origine.y)
            ctx.rotate(by: primitive.angle)
            if let remplissage = primitive.remplissage { ctx.setFillColor(couleur(remplissage)) }
            if let trait = primitive.trait {
                ctx.setStrokeColor(couleur(trait.couleur))
                ctx.setLineWidth(trait.largeur)
                ctx.setLineJoin(trait.arrondi ? .round : .miter)
                ctx.setLineCap(trait.arrondi ? .round : .butt)
            }
            primitive.ajouterChemin(a: ctx)
            let mode: CGPathDrawingMode =
                if primitive.remplissage == nil { .stroke } else if primitive.trait == nil { .fill } else {
                    .fillStroke
                }
            ctx.drawPath(using: mode)
            ctx.restoreGState()
        }
        try Task.checkCancellation()
        guard let image = ctx.makeImage() else { throw Erreur.image }
        return image
    }
}

func composantesSRGB(_ couleur: UInt32) -> (rouge: Double, vert: Double, bleu: Double) {
    (Double((couleur >> 16) & 255) / 255, Double((couleur >> 8) & 255) / 255, Double(couleur & 255) / 255)
}

extension PrimitiveMotif {
    fileprivate func ajouterChemin(a ctx: CGContext) {
        ctx.beginPath()
        switch geometrie {
        case .ellipse(let centre, let rx, let ry):
            ctx.addEllipse(in: CGRect(x: centre.x - rx, y: centre.y - ry, width: rx * 2, height: ry * 2))
        case .rectangle(let origine, let largeur, let hauteur, let rayon):
            let rect = CGRect(x: origine.x, y: origine.y, width: largeur, height: hauteur)
            if rayon == 0 {
                ctx.addRect(rect)
            } else {
                ctx.addPath(CGPath(roundedRect: rect, cornerWidth: rayon, cornerHeight: rayon, transform: nil))
            }
        case .chemin(let commandes):
            for commande in commandes {
                switch commande {
                case .aller(let p): ctx.move(to: p.cgPoint)
                case .ligne(let p): ctx.addLine(to: p.cgPoint)
                case .quadratique(let controle, let fin): ctx.addQuadCurve(to: fin.cgPoint, control: controle.cgPoint)
                case .cubique(let a, let b, let fin):
                    ctx.addCurve(to: fin.cgPoint, control1: a.cgPoint, control2: b.cgPoint)
                case .arc(let centre, let rayon, let debut, let fin, let sensHoraire):
                    ctx.addArc(
                        center: centre.cgPoint, radius: rayon, startAngle: debut, endAngle: fin,
                        clockwise: !sensHoraire)
                case .fermer: ctx.closePath()
                }
            }
        }
    }
}

extension PointMotif {
    fileprivate var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}
