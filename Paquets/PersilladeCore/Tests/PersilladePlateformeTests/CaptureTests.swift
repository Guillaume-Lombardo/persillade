import CoreGraphics
import CoreText
import Foundation
import ImageIO
import PersilladeCore
import PersilladePlateforme
import Testing
import UniformTypeIdentifiers

@Suite(.serialized)
struct CaptureTests {
    private static let titre = "Soupe de courge et pommes de terre"
    private static let ingredients = ["Ingrédients", "500 g de courge", "2 pommes de terre"]
    private static let preparation = ["Préparation", "Couper la courge.", "Cuire les légumes."]

    @Test func uneColonneEnFrancais() async throws {
        let attendu = ["Crêpes au miel", "Ingrédients", "250 g de farine", "Préparation", "Mélanger la pâte."]
        let photo = try page(attendu)
        let texte = try await mesurer("Une colonne") { try await LecteurImageVision().lireTexte(photo) }
        #expect(texte.components(separatedBy: .newlines) == attendu)
    }

    @Test func deuxColonnesAvecTitreTraversant() async throws {
        let photo = try pageRecette()
        let texte = try await mesurer("Deux colonnes") { try await LecteurImageVision().lireTexte(photo) }
        #expect(texte.components(separatedBy: .newlines) == [Self.titre] + Self.ingredients + Self.preparation)
    }

    @Test func uneColonneAvecListesIndentees() async throws {
        let attendu = [
            "Tarte maison", "Sauce", "100 g de crème", "2 tomates", "Pâte", "250 g de farine", "100 ml de lait",
        ]
        let photo = try page(attendu, retraits: [2: 168, 3: 168, 5: 168, 6: 168])
        let texte = try await LecteurImageVision().lireTexte(photo)
        #expect(texte.components(separatedBy: .newlines) == attendu)
    }

    @Test func manuscritSimule() async throws {
        let attendu = ["Compote de pommes", "300 g de pommes", "Laisser cuire"]
        let photo = try page(attendu, manuscrit: true)
        let texte = try await mesurer("Manuscrit simulé") { try await LecteurImageVision().lireTexte(photo) }
        #expect(texte.components(separatedBy: .newlines) == attendu)
    }

    @Test func photoTourneeSelonExif() async throws {
        let attendu = ["Salade de tomates", "Couper les tomates."]
        let photo = try page(attendu, orientation: .right)
        let proprietes = try proprietesImage(photo)
        #expect(proprietes[kCGImagePropertyOrientation] as? UInt32 == CGImagePropertyOrientation.right.rawValue)
        #expect(proprietes[kCGImagePropertyPixelWidth] as? Int == 1_200)
        #expect(proprietes[kCGImagePropertyPixelHeight] as? Int == 1_600)
        let texte = try await mesurer("Rotation EXIF") { try await LecteurImageVision().lireTexte(photo) }
        #expect(texte.components(separatedBy: .newlines) == attendu)
    }

    @Test func photoVideEtBrouillonManuel() async throws {
        let photo = try page([])
        let lecteur = LecteurImageVision()
        await #expect(throws: CauseExtraction.rienTrouve) {
            try await mesurer("Page vide") { try await lecteur.lireTexte(photo) }
        }
        let contenu = ContenuRecu(type: .image, contenu: photo, origine: .appareilPhoto)
        let resultat = try await Extracteur(lecteurImage: lecteur).extraire(contenu, cible: .recette)
        #expect(resultat.statut == .echec)
        #expect(resultat.cause == .rienTrouve)
        #expect(resultat.recette == BrouillonRecette())
    }

    @Test func photoStockeeJusquAuBrouillon() async throws {
        let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { #expect(throws: Never.self) { try FileManager.default.removeItem(at: dossier) } }
        let magasin = MagasinPhotos(dossier: dossier)
        let photo = try pageRecette(gouttiereEtroite: true)
        let (contenu, resultat) = try await mesurer("Préparation, stockage et extraction") {
            let contenu = try await magasin.deposer(photo, origine: .phototheque)
            let resultat = try await Extracteur(lecteurImage: LecteurImageVision()).extraire(contenu, cible: .recette)
            return (contenu, resultat)
        }
        let brouillon = try #require(resultat.recette)
        #expect(resultat.statut == .complet)
        #expect(resultat.moteur == .structure)
        #expect(brouillon.titre == Self.titre)
        #expect(brouillon.ingredients.map(\.nom) == ["courge", "pommes de terre"])
        #expect(brouillon.etapes == Array(Self.preparation.dropFirst()))
        #expect(try await magasin.lire().contenus == [contenu])
        try await magasin.retirer(id: contenu.id)
        #expect(try await magasin.lire().contenus.isEmpty)
    }

    @Test func preparationEtCycleDeVie() async throws {
        let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { #expect(throws: Never.self) { try FileManager.default.removeItem(at: dossier) } }
        let magasin = MagasinPhotos(dossier: dossier)
        let photo = try page(["Soupe de courge"], orientation: .right, echelle: 2, localisation: true)
        let originales = try proprietesImage(photo)
        #expect(originales[kCGImagePropertyGPSDictionary] != nil)
        let contenu = try await mesurer("Préparation JPEG et dépôt") {
            try await magasin.deposer(photo, origine: .appareilPhoto)
        }
        #expect(contenu.type == .image)
        #expect(contenu.origine == .appareilPhoto)
        let proprietes = try proprietesImage(contenu.contenu)
        #expect(proprietes[kCGImagePropertyPixelWidth] as? Int == 2_560)
        #expect(proprietes[kCGImagePropertyPixelHeight] as? Int == 1_920)
        #expect(proprietes[kCGImagePropertyOrientation] as? UInt32 ?? 1 == 1)
        #expect(proprietes[kCGImagePropertyGPSDictionary] == nil)
        #expect(try await LecteurImageVision().lireTexte(contenu.contenu) == "Soupe de courge")

        let autre = try await magasin.deposer(page([]), origine: .phototheque)
        let relance = MagasinPhotos(dossier: dossier)
        #expect(try dossier.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true)
        #expect(try await relance.lire().contenus == [contenu, autre])
        try await relance.retirer(id: contenu.id)
        try await relance.retirer(id: contenu.id)
        #expect(try await relance.lire().contenus == [autre])
        try await relance.retirer(id: autre.id)
        #expect(try FileManager.default.contentsOfDirectory(atPath: dossier.path).isEmpty)
    }

    @Test func imageIllisibleEtAnnulation() async throws {
        let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let magasin = MagasinPhotos(dossier: dossier)
        await #expect {
            try await magasin.deposer(Data("pas une image".utf8), origine: .phototheque)
        } throws: { erreur in
            if case ErreurCapture.imageIllisible = erreur { true } else { false }
        }
        let photo = try page(["Soupe de courge"])
        let tache = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await LecteurImageVision().lireTexte(photo)
        }
        await #expect(throws: CancellationError.self) { try await tache.value }
        #expect(!FileManager.default.fileExists(atPath: dossier.path))
    }

    private func pageRecette(gouttiereEtroite: Bool = false) throws -> Data {
        try page([Self.titre] + Self.ingredients, droite: Self.preparation, gouttiereEtroite: gouttiereEtroite)
    }

    private func page(
        _ gauche: [String], droite: [String] = [], gouttiereEtroite: Bool = false, manuscrit: Bool = false,
        orientation: CGImagePropertyOrientation = .up, echelle: Int = 1, localisation: Bool = false,
        retraits: [Int: CGFloat] = [:]
    ) throws -> Data {
        let largeur = 1_600
        let hauteur = 1_200
        let tournee = orientation == .right
        let contexte = try #require(
            CGContext(
                data: nil, width: (tournee ? hauteur : largeur) * echelle,
                height: (tournee ? largeur : hauteur) * echelle,
                bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        contexte.scaleBy(x: CGFloat(echelle), y: CGFloat(echelle))
        if tournee {
            contexte.translateBy(x: CGFloat(hauteur), y: 0)
            contexte.rotate(by: .pi / 2)
        }
        contexte.setFillColor(gray: 1, alpha: 1)
        contexte.fill(CGRect(x: 0, y: 0, width: largeur, height: hauteur))

        for (indice, texte) in gauche.enumerated() {
            let taille: CGFloat = indice == 0 ? 62 : 48
            let y = indice == 0 ? 1_040 : 870 - CGFloat(indice - 1) * 90
            tracer(
                texte, x: 100 + retraits[indice, default: 0], y: y, taille: taille,
                inclinaison: manuscrit ? (indice.isMultiple(of: 2) ? 0.04 : -0.03) : 0)
        }
        let departDroite: CGFloat
        if gouttiereEtroite {
            let largeurGauche =
                gauche.dropFirst().map {
                    CTLineGetBoundsWithOptions(ligneTexte($0, taille: 48), .useGlyphPathBounds).maxX
                }.max() ?? 0
            departDroite = 100 + largeurGauche + 32
        } else {
            departDroite = 850
        }
        let hauteurDroite: CGFloat = gouttiereEtroite ? 825 : 866
        for (indice, texte) in droite.enumerated() {
            tracer(texte, x: departDroite, y: hauteurDroite - CGFloat(indice) * 90, taille: 48, inclinaison: 0)
        }

        let rendu = try #require(contexte.makeImage())
        let donnees = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(donnees, UTType.jpeg.identifier as CFString, 1, nil))
        var proprietes: [CFString: Any] = [kCGImagePropertyOrientation: orientation.rawValue]
        if localisation {
            proprietes[kCGImagePropertyGPSDictionary] = [
                kCGImagePropertyGPSLatitude: 10.0, kCGImagePropertyGPSLatitudeRef: "N",
                kCGImagePropertyGPSLongitude: 20.0, kCGImagePropertyGPSLongitudeRef: "E",
            ]
        }
        CGImageDestinationAddImage(destination, rendu, proprietes as CFDictionary)
        try #require(CGImageDestinationFinalize(destination))
        return donnees as Data

        func ligneTexte(_ texte: String, taille: CGFloat) -> CTLine {
            let police = CTFontCreateWithName((manuscrit ? "Noteworthy-Bold" : "Helvetica") as CFString, taille, nil)
            return CTLineCreateWithAttributedString(
                NSAttributedString(
                    string: texte, attributes: [NSAttributedString.Key(kCTFontAttributeName as String): police]))
        }

        func tracer(_ texte: String, x: CGFloat, y: CGFloat, taille: CGFloat, inclinaison: CGFloat) {
            contexte.saveGState()
            contexte.translateBy(x: x, y: y)
            contexte.rotate(by: inclinaison)
            contexte.textMatrix = .identity
            contexte.textPosition = .zero
            CTLineDraw(ligneTexte(texte, taille: taille), contexte)
            contexte.restoreGState()
        }
    }

    private func proprietesImage(_ donnees: Data) throws -> [CFString: Any] {
        let source = try #require(CGImageSourceCreateWithData(donnees as CFData, nil))
        return try #require(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
    }

    private func mesurer<T>(_ nom: String, _ operation: () async throws -> T) async rethrows -> T {
        let debut = ContinuousClock.now
        defer { print("\(nom) : \(ContinuousClock.now - debut)") }
        return try await operation()
    }
}
