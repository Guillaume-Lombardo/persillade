import CoreGraphics
import CoreText
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers

enum PageCorpusExtraction {
    static func rendre(
        _ source: String, manuscrite: Bool, rotation: Int = 0, enteteADroite: Bool = false, surtitre: String? = nil,
        enteteRapprochee: Bool = false
    ) throws -> Data {
        let quartDeTour = rotation == 90 || rotation == 270
        let contexte = try #require(
            CGContext(
                data: nil, width: quartDeTour ? 1_500 : 1_200, height: quartDeTour ? 1_200 : 1_500,
                bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        switch rotation {
        case 90: contexte.translateBy(x: 1_500, y: 0)
        case 180: contexte.translateBy(x: 1_200, y: 1_500)
        case 270: contexte.translateBy(x: 0, y: 1_200)
        default: break
        }
        contexte.rotate(by: CGFloat(rotation) * .pi / 180)
        contexte.setFillColor(CGColor(gray: 0.79, alpha: 1))
        contexte.fill(CGRect(x: 0, y: 0, width: 1_200, height: 1_500))
        contexte.translateBy(x: 80, y: 140)
        contexte.rotate(by: manuscrite ? -0.024 : 0.014)
        contexte.setFillColor(CGColor(red: 0.99, green: 0.975, blue: 0.93, alpha: 1))
        contexte.fill(CGRect(x: 0, y: 0, width: 1_040, height: 1_210))

        let police = manuscrite ? "Noteworthy-Light" : "Georgia"
        let blocs = source.components(separatedBy: "\n\n")
        if let surtitre { tracer(surtitre[...], x: 76, y: 1_150, taille: 26) }
        if blocs.count == 3 {
            for (index, ligne) in blocs[0].split(whereSeparator: \.isNewline).enumerated() {
                let y: CGFloat = enteteRapprochee ? 937 : 1_070
                tracer(ligne, x: enteteADroite ? 585 : 76, y: y - CGFloat(index) * 72, taille: index == 0 ? 49 : 31)
            }
            for (colonne, bloc) in blocs.dropFirst().enumerated() {
                for (index, ligne) in bloc.split(whereSeparator: \.isNewline).enumerated() {
                    tracer(ligne, x: colonne == 0 ? 76 : 485, y: 900 - CGFloat(index) * 39, taille: 26)
                }
            }
        } else {
            for (index, ligne) in source.split(whereSeparator: \.isNewline).enumerated() {
                let retrait = manuscrite ? CGFloat((index % 3) * 6) : 0
                tracer(ligne, x: 76 + retrait, y: 1_070 - CGFloat(index) * 72, taille: index == 0 ? 49 : 34)
            }
        }

        let image = try #require(contexte.makeImage())
        let jpeg = NSMutableData()
        let sortie = try #require(
            CGImageDestinationCreateWithData(jpeg, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(
            sortie, image, [kCGImageDestinationLossyCompressionQuality: 0.88] as CFDictionary)
        try #require(CGImageDestinationFinalize(sortie))
        return jpeg as Data

        func tracer(_ ligne: Substring, x: CGFloat, y: CGFloat, taille: CGFloat) {
            let texte = NSAttributedString(
                string: String(ligne),
                attributes: [
                    NSAttributedString.Key(kCTFontAttributeName as String):
                        CTFontCreateWithName(police as CFString, taille, nil),
                    NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                        CGColor(red: 0.14, green: 0.16, blue: manuscrite ? 0.33 : 0.16, alpha: 1),
                ])
            contexte.textPosition = CGPoint(x: x, y: y)
            CTLineDraw(CTLineCreateWithAttributedString(texte), contexte)
        }

    }
}
