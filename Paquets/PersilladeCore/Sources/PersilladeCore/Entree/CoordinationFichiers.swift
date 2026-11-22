import Foundation

package func coordonnerEcriture<Resultat>(
    _ url: URL, operation: (URL) throws -> Resultat
) throws -> Resultat {
    var erreur: NSError?
    var resultat: Result<Resultat, any Error>?
    NSFileCoordinator().coordinate(writingItemAt: url, options: [], error: &erreur) { url in
        resultat = Result { try operation(url) }
    }
    if let resultat { return try resultat.get() }
    throw erreur ?? CocoaError(.fileWriteUnknown, userInfo: [NSURLErrorKey: url]) as NSError
}
