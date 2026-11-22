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
    let activation = try #require(attributs["NSExtensionActivationRule"] as? [String: Any])
    #expect(activation["NSExtensionActivationSupportsWebURLWithMaxCount"] as? Int == 1)
    #expect(activation["NSExtensionActivationSupportsText"] as? Bool == true)
}
