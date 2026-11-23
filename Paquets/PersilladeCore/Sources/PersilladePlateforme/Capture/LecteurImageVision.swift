import Foundation
import PersilladeCore
import Vision

public struct LecteurImageVision: LecteurImage {
    public init() {}

    public func lireTexte(_ image: Data) async throws -> String {
        try Task.checkCancellation()
        let pixels = try ImageCapture.decoder(image)
        let rapportImage = CGFloat(pixels.height) / CGFloat(pixels.width)
        let orientations: [CGImagePropertyOrientation] = [.up, .right, .down, .left]
        var lignes: [Ligne] = []
        var meilleurSens = CGImagePropertyOrientation.up
        var meilleurScore = 0.0
        try Task.checkCancellation()
        do {
            for orientation in orientations {
                try Task.checkCancellation()
                let (candidates, precise) = try await Self.reconnaitre(pixels, orientation: orientation)
                var scores: [CGImagePropertyOrientation: Double] = [:]
                for ligne in candidates {
                    let sens = ligne.sens(rapportImage: rapportImage)
                    scores[sens, default: 0] += Double(ligne.texte.filter(\.isLetter).count) * Double(ligne.confiance)
                }
                for sens in orientations {
                    let score = scores[sens, default: 0]
                    if score > meilleurScore || (lignes.isEmpty && !candidates.isEmpty) {
                        lignes = candidates
                        meilleurSens = sens
                        meilleurScore = score
                    }
                }
                // Une page déjà lisible à l’endroit n’a pas besoin de trois autres passages.
                if precise, orientation == .up, meilleurSens == .up, meilleurScore >= 20 { break }
            }
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw error }
            throw ErreurCapture.lectureVision(error)
        }
        try Task.checkCancellation()
        guard !lignes.isEmpty else { throw CauseExtraction.rienTrouve }
        // Vision peut lire le texte de travers et renvoyer ses cadres dans les pixels d’origine.
        let rapport = meilleurSens == .left || meilleurSens == .right ? 1 / rapportImage : rapportImage
        return Self.ordonner(lignes.map { $0.redressee(meilleurSens) }, rapportImage: rapport)
            .map(\.texte).joined(separator: "\n")
    }

    private static func reconnaitre(
        _ pixels: CGImage, orientation: CGImagePropertyOrientation
    ) async throws -> (lignes: [Ligne], precise: Bool) {
        var requete = RecognizeTextRequest()
        requete.recognitionLevel = .accurate
        requete.recognitionLanguages = [Locale.Language(identifier: "fr-FR")]
        requete.usesLanguageCorrection = true
        do {
            let lignes: [Ligne] = try await requete.perform(on: pixels, orientation: orientation).compactMap {
                guard let candidat = $0.topCandidates(1).first else { return nil }
                return Ligne(
                    texte: candidat.string, cadre: $0.boundingBox.cgRect, confiance: candidat.confidence,
                    debut: $0.topLeft.cgPoint, fin: $0.topRight.cgPoint)
            }
            return (lignes, true)
        } catch {
            #if os(macOS)
                try Task.checkCancellation()
                if error is CancellationError { throw error }
                return (try reconnaitreRapidement(pixels, orientation: orientation), false)
            #else
                throw error
            #endif
        }
    }

    #if os(macOS)
        // Certains runners macOS ne peuvent pas compiler le modèle du mode précis.
        private static func reconnaitreRapidement(
            _ pixels: CGImage, orientation: CGImagePropertyOrientation
        ) throws -> [Ligne] {
            let requete = VNRecognizeTextRequest()
            requete.recognitionLevel = .fast
            requete.recognitionLanguages = ["fr-FR"]
            requete.usesLanguageCorrection = true
            try VNImageRequestHandler(cgImage: pixels, orientation: orientation).perform([requete])
            return (requete.results ?? []).compactMap {
                guard let candidat = $0.topCandidates(1).first else { return nil }
                return Ligne(
                    texte: candidat.string, cadre: $0.boundingBox, confiance: candidat.confidence,
                    debut: $0.topLeft, fin: $0.topRight)
            }
        }
    #endif

    private struct Ligne {
        let texte: String
        var cadre: CGRect
        let confiance: Float
        let axe: CGVector

        init?(texte: String, cadre: CGRect, confiance: Float, debut: CGPoint, fin: CGPoint) {
            let texte = texte.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !texte.isEmpty else { return nil }
            self.texte = texte
            self.cadre = cadre
            self.confiance = confiance
            axe = CGVector(dx: fin.x - debut.x, dy: fin.y - debut.y)
        }

        func sens(rapportImage: CGFloat) -> CGImagePropertyOrientation {
            if abs(axe.dx) >= abs(axe.dy) * rapportImage {
                return axe.dx >= 0 ? .up : .down
            }
            return axe.dy >= 0 ? .right : .left
        }

        func redressee(_ sens: CGImagePropertyOrientation) -> Self {
            var ligne = self
            let transformation: CGAffineTransform
            switch sens {
            case .down: transformation = CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: 1, ty: 1)
            case .right: transformation = CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: 1)
            case .left: transformation = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
            default: return self
            }
            ligne.cadre = cadre.applying(transformation)
            return ligne
        }
    }

    private static func ordonner(_ lignes: [Ligne], rapportImage: CGFloat) -> [Ligne] {
        // Les ordonnées Vision partent du bas de l’image.
        let lignes = lignes.sorted {
            if $0.cadre.midY == $1.cadre.midY { return $0.cadre.minX < $1.cadre.minX }
            return $0.cadre.midY > $1.cadre.midY
        }

        // Une gouttière sépare deux blocs qui se chevauchent en hauteur. Un titre ou un pied
        // de page peut traverser la gouttière hors de ces blocs.
        let hauteurs = lignes.map(\.cadre.height).sorted()
        let hauteurMediane = hauteurs[hauteurs.count / 2]
        let largeurGouttiere = hauteurMediane * rapportImage / 4
        var meilleureLargeur = largeurGouttiere
        var ordre = lignes
        for debutDroite in Set(lignes.map { $0.cadre.minX }).sorted() {
            let gauche = lignes.filter { $0.cadre.maxX <= debutDroite - largeurGouttiere }
            let droite = lignes.filter { $0.cadre.minX >= debutDroite }
            guard lignesVoisines(gauche, espacementMax: hauteurMediane),
                lignesVoisines(droite, espacementMax: hauteurMediane)
            else { continue }

            let blocGauche = gauche.reduce(CGRect.null) { $0.union($1.cadre) }
            let blocDroite = droite.reduce(CGRect.null) { $0.union($1.cadre) }
            let largeur = debutDroite - blocGauche.maxX
            guard largeur > meilleureLargeur,
                min(blocGauche.maxY, blocDroite.maxY) > max(blocGauche.minY, blocDroite.minY)
            else { continue }

            let traversantes = lignes.filter {
                $0.cadre.maxX > debutDroite - largeurGouttiere && $0.cadre.minX < debutDroite
            }
            let haut = max(blocGauche.maxY, blocDroite.maxY)
            let bas = min(blocGauche.minY, blocDroite.minY)
            let avant = traversantes.filter { $0.cadre.minY >= haut }
            let apres = traversantes.filter { $0.cadre.maxY <= bas }
            guard avant.count + apres.count == traversantes.count else { continue }

            meilleureLargeur = largeur
            ordre = avant + gauche + droite + apres
        }
        return ordre
    }

    private static func lignesVoisines(_ lignes: [Ligne], espacementMax: CGFloat) -> Bool {
        // Des sous-titres épars devant des listes indentées ne forment pas une colonne.
        zip(lignes, lignes.dropFirst()).contains { haute, basse in
            haute.cadre.minY - basse.cadre.maxY <= espacementMax
        }
    }
}
