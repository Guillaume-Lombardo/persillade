import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum ErreurCapture: LocalizedError {
    case origineInvalide
    case imageIllisible
    case encodageImpossible
    case lectureVision(any Error)
    case stockage(any Error)

    public var errorDescription: String? {
        switch self {
        case .origineInvalide: "L’origine de cette photo est inconnue."
        case .imageIllisible: "Cette photo est illisible."
        case .encodageImpossible: "Impossible de préparer cette photo."
        case .lectureVision: "Impossible de lire le texte de cette photo."
        case .stockage: "Impossible d’accéder aux photos d’import."
        }
    }
}

enum ImageCapture {
    static func decoder(_ donnees: Data) throws -> CGImage {
        guard let source = CGImageSourceCreateWithData(donnees as CFData, nil),
            let identifiant = CGImageSourceGetType(source),
            UTType(identifiant as String)?.conforms(to: .image) == true,
            let image = CGImageSourceCreateThumbnailAtIndex(
                source, CGImageSourceGetPrimaryImageIndex(source),
                [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: 2_560,
                ] as CFDictionary)
        else { throw ErreurCapture.imageIllisible }
        return image
    }

    static func preparer(_ donnees: Data) throws -> Data {
        let image = try decoder(donnees)
        let jpeg = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(jpeg, UTType.jpeg.identifier as CFString, 1, nil)
        else { throw ErreurCapture.encodageImpossible }
        // Réencode les pixels orientés sans recopier les métadonnées de la source.
        CGImageDestinationAddImage(
            destination, image,
            [
                kCGImageDestinationLossyCompressionQuality: 0.88,
                kCGImageDestinationBackgroundColor: CGColor(gray: 1, alpha: 1),
            ] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw ErreurCapture.encodageImpossible }
        return jpeg as Data
    }
}
