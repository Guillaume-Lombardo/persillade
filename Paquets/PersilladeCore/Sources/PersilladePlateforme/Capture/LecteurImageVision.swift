import Foundation
import PersilladeCore
import Vision

public struct LecteurImageVision: LecteurImageAvecEntete {
    typealias Reconnaissance =
        @Sendable (CGImage, CGImagePropertyOrientation) async throws -> (lignes: [Ligne], precise: Bool)
    private let reconnaitre: Reconnaissance

    public init() { self.init(reconnaitre: Self.reconnaitre) }

    init(reconnaitre: @escaping Reconnaissance) {
        self.reconnaitre = reconnaitre
    }

    public func lireTexte(_ image: Data) async throws -> String {
        try await lirePage(image).texte
    }

    package func lirePage(_ image: Data) async throws -> (texte: String, indiceTitre: Int?) {
        try Task.checkCancellation()
        let pixels = try ImageCapture.decoder(image)
        let rapportImage = CGFloat(pixels.height) / CGFloat(pixels.width)
        let orientations: [CGImagePropertyOrientation] = [.up, .right, .down, .left]
        var lignes: [Ligne] = []
        var meilleurSens = CGImagePropertyOrientation.up
        var meilleurScore = 0.0
        var premiereErreur: (any Error)?
        for orientation in orientations {
            try Task.checkCancellation()
            do {
                let (candidates, precise) = try await reconnaitre(pixels, orientation)
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
            } catch {
                try Task.checkCancellation()
                if error is CancellationError { throw error }
                premiereErreur = premiereErreur ?? error
            }
        }
        try Task.checkCancellation()
        guard !lignes.isEmpty else {
            if let premiereErreur { throw ErreurCapture.lectureVision(premiereErreur) }
            throw CauseExtraction.rienTrouve
        }
        // Vision peut lire le texte de travers et renvoyer ses cadres dans les pixels d’origine.
        let rapport = meilleurSens == .left || meilleurSens == .right ? 1 / rapportImage : rapportImage
        let page = Self.ordonner(lignes.map { $0.redressee(meilleurSens) }, rapportImage: rapport)
        return (page.lignes.map(\.texte).joined(separator: "\n"), page.indiceTitre)
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

    struct Ligne {
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

    private static func ordonner(
        _ lignes: [Ligne], rapportImage: CGFloat
    ) -> (lignes: [Ligne], indiceTitre: Int?) {
        // Les ordonnées Vision partent du bas de l’image.
        let lignes = lignes.sorted {
            if $0.cadre.midY == $1.cadre.midY { return $0.cadre.minX < $1.cadre.minX }
            return $0.cadre.midY > $1.cadre.midY
        }

        let hauteurs = lignes.map(\.cadre.height).sorted()
        let hauteurMediane = (hauteurs[(hauteurs.count - 1) / 2] + hauteurs[hauteurs.count / 2]) / 2
        let tailleTitre = hauteurMediane * 1.2
        let taille: (Ligne) -> CGFloat = { ligne in
            // La largeur moyenne d’un caractère aide lorsque les cadres OCR ont des hauteurs proches.
            let caracteres = ligne.texte.filter { !$0.isWhitespace }.count
            let largeurParCaractere = ligne.cadre.width / CGFloat(max(1, caracteres)) / rapportImage
            return max(ligne.cadre.height, largeurParCaractere * 1.5)
        }

        // Une gouttière sépare deux blocs qui se chevauchent en hauteur.
        let espacementMax = hauteurs[hauteurs.count / 2]
        let largeurGouttiere = espacementMax * rapportImage / 4
        let intertitreIngredients = lignes.first {
            $0.texte.range(of: #"(?i)^ingr[ée]dients\h*:?$"#, options: .regularExpression) != nil
        }
        let intertitrePreparation = lignes.first {
            $0.texte.range(of: #"(?i)^pr[ée]paration\h*:?$"#, options: .regularExpression) != nil
        }
        var meilleureLargeur = largeurGouttiere
        var ordre = lignes
        var tailleEntete =
            lignes.indices.dropLast().first {
                taille(lignes[$0]) < tailleTitre && taille(lignes[$0 + 1]) < tailleTitre
            } ?? (lignes.count > 1 && lignes[0].cadre.minY >= lignes[1].cadre.maxY ? 1 : 0)
        var enColonnes = false
        for debutDroite in Set(lignes.map { $0.cadre.minX }).sorted() {
            let gauche = lignes.filter { $0.cadre.maxX <= debutDroite - largeurGouttiere }
            let droite = lignes.filter { $0.cadre.minX >= debutDroite }
            guard let debutGauche = debutDuBloc(gauche, espacementMax: espacementMax),
                let debutDroit = debutDuBloc(droite, espacementMax: espacementMax)
            else { continue }

            let premiereGauche = gauche[debutGauche]
            let premiereDroite = droite[debutDroit]
            // Un titre proche de sa colonne se distingue par sa taille et sa position au-dessus de l’autre bloc.
            let titreAGauche =
                premiereGauche.cadre.midY >= premiereDroite.cadre.maxY && taille(premiereGauche) >= tailleTitre
            let titreADroite =
                premiereDroite.cadre.midY >= premiereGauche.cadre.maxY && taille(premiereDroite) >= tailleTitre
            let hautGauche = gauche[debutGauche + (titreAGauche ? 1 : 0)].cadre.maxY
            let hautDroite = droite[debutDroit + (titreADroite ? 1 : 0)].cadre.maxY
            let blocGauche = gauche.reduce(CGRect.null) { $0.union($1.cadre) }
            let blocDroite = droite.reduce(CGRect.null) { $0.union($1.cadre) }
            let largeur = debutDroite - blocGauche.maxX
            guard largeur > meilleureLargeur,
                min(hautGauche, hautDroite) > max(blocGauche.minY, blocDroite.minY)
            else { continue }

            let traversantes = lignes.filter {
                $0.cadre.maxX > debutDroite - largeurGouttiere && $0.cadre.minX < debutDroite
            }
            // Les premières lignes proches ancrent chaque colonne sous les éléments isolés du bandeau.
            var seuilEntete = max(hautGauche, hautDroite)
            // Deux intertitres alignés ancrent le début des colonnes même s’ils sont espacés de leur texte.
            if let ingredients = intertitreIngredients, let preparation = intertitrePreparation,
                ingredients.cadre.maxX <= debutDroite - largeurGouttiere,
                preparation.cadre.minX >= debutDroite,
                abs(ingredients.cadre.midY - preparation.cadre.midY) <= espacementMax
            {
                seuilEntete = max(seuilEntete, ingredients.cadre.maxY, preparation.cadre.maxY)
            }
            let appartientEntete: (Ligne) -> Bool = { $0.cadre.midY >= seuilEntete }
            let bas = min(blocGauche.minY, blocDroite.minY)
            let avant = lignes.filter(appartientEntete)
            let apres = traversantes.filter { $0.cadre.maxY <= bas }
            guard traversantes.allSatisfy({ appartientEntete($0) || $0.cadre.maxY <= bas }) else { continue }

            meilleureLargeur = largeur
            enColonnes = true
            tailleEntete = avant.count
            ordre =
                avant + gauche.filter { !appartientEntete($0) }
                + droite.filter { !appartientEntete($0) } + apres
        }
        let indiceTitre = ordre.indices.prefix(tailleEntete)
            .filter { enColonnes || taille(ordre[$0]) >= tailleTitre }
            .max {
                let gauche = taille(ordre[$0])
                let droite = taille(ordre[$1])
                return gauche == droite ? $0 > $1 : gauche < droite
            }
        return (ordre, indiceTitre)
    }

    private static func debutDuBloc(_ lignes: [Ligne], espacementMax: CGFloat) -> Int? {
        lignes.indices.dropLast().first {
            lignes[$0].cadre.minY - lignes[$0 + 1].cadre.maxY <= espacementMax
        }
    }
}
