import SwiftUI
import XCTest

@testable import Persillade

final class TypographiePersilladeTests: XCTestCase {
    private let titre = "Çà, gâteau façon pâtissière à l'œuf poché"

    @MainActor
    func testInterligneSerreEtGlyphesEntiers() throws {
        let styles: [(TypographiePersillade, CGFloat, Font.Width, CGFloat)] = [
            (.fiche, 46, .compressed, 46),
            (.etatVide, 54, .compressed, 50),
            (.recette, 22, .condensed, 23),
        ]
        for (role, taille, largeur, interligne) in styles {
            let modele = try rendre(Text(titre).font(.system(size: taille, weight: .heavy).width(largeur)))
            let affiche = try rendre(Text(titre).typographie(role))
            let lignes = titre.replacingOccurrences(of: " pâtissière", with: "\npâtissière")
            let afficheMultiligne = try rendre(Text(lignes).typographie(role))

            XCTAssertEqual(try hauteurEncre(affiche), try hauteurEncre(modele), accuracy: 1, "\(role)")
            XCTAssertEqual(Double(afficheMultiligne.height - affiche.height) / 2, interligne, accuracy: 0.5, "\(role)")
        }
    }

    @MainActor
    private func rendre(_ vue: some View) throws -> CGImage {
        let rendu = ImageRenderer(
            content: vue.foregroundStyle(.black).fixedSize().environment(\.dynamicTypeSize, .large))
        rendu.scale = 2
        return try XCTUnwrap(rendu.cgImage)
    }

    private func hauteurEncre(_ image: CGImage) throws -> Int {
        let contexte = try XCTUnwrap(
            CGContext(
                data: nil, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: image.width,
                space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue))
        let cadre = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        contexte.setFillColor(gray: 1, alpha: 1)
        contexte.fill(cadre)
        contexte.draw(image, in: cadre)
        let pixels = try XCTUnwrap(contexte.data?.assumingMemoryBound(to: UInt8.self))
        let lignesEncre = (0..<image.height).filter { ligne in
            let debut = ligne * contexte.bytesPerRow
            return (debut..<(debut + image.width)).contains { pixels[$0] < 128 }
        }
        let premiere = try XCTUnwrap(lignesEncre.first)
        return try XCTUnwrap(lignesEncre.last) - premiere + 1
    }
}
