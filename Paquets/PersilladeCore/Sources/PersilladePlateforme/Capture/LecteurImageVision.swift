import Foundation
import PersilladeCore
import Vision

public struct LecteurImageVision: LecteurImage {
    public init() {}

    public func lireTexte(_ image: Data) async throws -> String {
        try Task.checkCancellation()
        let pixels = try ImageCapture.decoder(image)
        try Task.checkCancellation()
        var requete = RecognizeTextRequest()
        requete.recognitionLevel = .accurate
        requete.recognitionLanguages = [Locale.Language(identifier: "fr-FR")]
        requete.usesLanguageCorrection = true

        let observations: [RecognizedTextObservation]
        do {
            observations = try await requete.perform(on: pixels, orientation: .up)
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw error }
            throw ErreurCapture.lectureVision(error)
        }
        try Task.checkCancellation()
        let lignes = observations.compactMap { observation -> Ligne? in
            guard
                let texte = observation.topCandidates(1).first?.string
                    .trimmingCharacters(in: .whitespacesAndNewlines), !texte.isEmpty
            else { return nil }
            return Ligne(texte: texte, cadre: observation.boundingBox.cgRect)
        }
        guard !lignes.isEmpty else { throw CauseExtraction.rienTrouve }
        let rapportImage = CGFloat(pixels.height) / CGFloat(pixels.width)
        return Self.ordonner(lignes, rapportImage: rapportImage).map(\.texte).joined(separator: "\n")
    }

    private struct Ligne {
        let texte: String
        let cadre: CGRect
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
