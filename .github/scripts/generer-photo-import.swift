import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let destination = URL(fileURLWithPath: CommandLine.arguments[1])
let largeur = 1_400
let hauteur = 1_050
let contexte = CGContext(
    data: nil, width: largeur, height: hauteur, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
)!
contexte.setFillColor(gray: 1, alpha: 1)
contexte.fill(CGRect(x: 0, y: 0, width: largeur, height: hauteur))

if !CommandLine.arguments.contains("--vide") {
    let texte = [
        "Soupe de courge", "Pour 4 personnes", "Ingrédients", "500 g de courge", "2 pommes de terre",
        "Préparation", "Couper la courge.", "Cuire les légumes.",
    ]
    for (index, ligne) in texte.enumerated() {
        let police = CTFontCreateWithName("Helvetica" as CFString, index == 0 ? 72 : 58, nil)
        let texte = NSAttributedString(
            string: ligne, attributes: [NSAttributedString.Key(kCTFontAttributeName as String): police])
        contexte.textPosition = CGPoint(x: 90, y: 900 - index * 100)
        CTLineDraw(CTLineCreateWithAttributedString(texte), contexte)
    }
}

let fichier = CGImageDestinationCreateWithURL(destination as CFURL, UTType.jpeg.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(fichier, contexte.makeImage()!, nil)
precondition(CGImageDestinationFinalize(fichier))
