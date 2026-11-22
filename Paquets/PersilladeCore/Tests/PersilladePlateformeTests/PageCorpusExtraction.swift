import CoreGraphics
import CoreText
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers

enum PageCorpusExtraction {
    static func rendre(_ source: String, manuscrite: Bool) throws -> Data {
        let contexte = try #require(
            CGContext(
                data: nil, width: 1_200, height: 1_500, bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        contexte.setFillColor(CGColor(gray: 0.79, alpha: 1))
        contexte.fill(CGRect(x: 0, y: 0, width: 1_200, height: 1_500))
        contexte.translateBy(x: 80, y: 140)
        contexte.rotate(by: manuscrite ? -0.024 : 0.014)
        contexte.setFillColor(CGColor(red: 0.99, green: 0.975, blue: 0.93, alpha: 1))
        contexte.fill(CGRect(x: 0, y: 0, width: 1_040, height: 1_210))

        let police = manuscrite ? "Noteworthy-Light" : "Georgia"
        for (index, ligne) in source.split(whereSeparator: \.isNewline).enumerated() {
            let texte = NSAttributedString(
                string: String(ligne),
                attributes: [
                    NSAttributedString.Key(kCTFontAttributeName as String):
                        CTFontCreateWithName(police as CFString, index == 0 ? 49 : 34, nil),
                    NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                        CGColor(red: 0.14, green: 0.16, blue: manuscrite ? 0.33 : 0.16, alpha: 1),
                ])
            let retrait = manuscrite ? CGFloat((index % 3) * 6) : 0
            contexte.textPosition = CGPoint(x: 76 + retrait, y: 1_070 - CGFloat(index) * 72)
            CTLineDraw(CTLineCreateWithAttributedString(texte), contexte)
        }

        let image = try #require(contexte.makeImage())
        let jpeg = NSMutableData()
        let sortie = try #require(
            CGImageDestinationCreateWithData(jpeg, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(
            sortie, image, [kCGImageDestinationLossyCompressionQuality: 0.88] as CFDictionary)
        try #require(CGImageDestinationFinalize(sortie))
        return jpeg as Data
    }
}
