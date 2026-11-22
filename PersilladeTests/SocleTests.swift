import Foundation
import Testing

@Test func embarqueExtensionDePartage() throws {
    let app = Bundle.main
    #expect(app.bundleIdentifier == "xyz.g1lom.persillade")
    #expect(app.developmentLocalization == "fr")
    #expect(app.object(forInfoDictionaryKey: "ITSAppUsesNonExemptEncryption") as? Bool == false)
    let dossier = try #require(app.builtInPlugInsURL)
    let extensionPartage = try #require(
        Bundle(url: dossier.appendingPathComponent("PersilladePartage.appex")))
    #expect(extensionPartage.bundleIdentifier == "xyz.g1lom.persillade.partage")
    let declaration = try #require(extensionPartage.infoDictionary?["NSExtension"] as? [String: Any])
    #expect(declaration["NSExtensionPointIdentifier"] as? String == "com.apple.share-services")
    let attributs = try #require(declaration["NSExtensionAttributes"] as? [String: Any])
    let activation = try #require(attributs["NSExtensionActivationRule"] as? String)
    let predicat = NSPredicate(format: activation)
    func accepte(_ fournisseurs: [[String]]) -> Bool {
        let pieces = fournisseurs.map { ["registeredTypeIdentifiers": $0] }
        return predicat.evaluate(with: ["extensionItems": [["attachments": pieces]]])
    }
    #expect(accepte([["public.url", "public.plain-text"]]))
    #expect(accepte([["public.utf8-plain-text"]]))
    #expect(accepte([["public.text"]]))
    #expect(!accepte([["public.jpeg"]]))
    #expect(!accepte([["public.file-url", "public.url"]]))
    #expect(!accepte([["public.plain-text"], ["public.jpeg"]]))
    #expect(!accepte([["public.plain-text"], ["public.plain-text"]]))
}
