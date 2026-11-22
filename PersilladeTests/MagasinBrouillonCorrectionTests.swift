import Foundation
import PersilladeCore
import Testing

@testable import Persillade

struct MagasinBrouillonCorrectionTests {
    @Test func reprendLaRecetteEtSesSaisiesInvalidesSansDupliquerLaPhoto() async throws {
        let dossier = URL.temporaryDirectory.appending(path: UUID().uuidString)
        let magasin = MagasinBrouillonCorrection(dossier: dossier)
        let sourceId = UUID()
        let texteLu = "2 pommes de terre\n3 tomates"
        let contexte = ContexteCorrection(
            id: sourceId, sourceId: sourceId, texteDerive: texteLu, url: nil, cause: .iaIndisponible,
            photoSansTexte: false, modification: false, debutExtrait: 0)
        var formulaire = FormulaireRecette(
            BrouillonRecette(
                titre: "Titre retouché",
                ingredients: [
                    .init(
                        nom: "pommes de terre", quantite: Quantite(2), unite: .piece, texteOrigine: "2 pommes de terre"),
                    .init(
                        nom: "tomates", quantite: Quantite(3), unite: .piece, texteOrigine: "3 tomates",
                        ligneNonComprise: true),
                ],
                etapes: ["Faire cuire.", ""]),
            source: texteLu)
        formulaire.portions = "0"
        formulaire.ingredients.swapAt(0, 1)
        formulaire.ingredients[0].nonComprise = false
        formulaire.ingredients[0].quantite.texte = "1/"
        formulaire.ingredients[0].quantite.unite = .autre("")
        formulaire.ingredients[0].quantite.autre = "  "
        let brouillon = BrouillonCorrection.recette(contexte, formulaire, validation: false)

        #expect(try await magasin.lire() == nil)
        try await magasin.ecrire(brouillon)
        let nouveauMagasin = MagasinBrouillonCorrection(dossier: dossier)
        #expect(try await nouveauMagasin.lire() == brouillon)
        #expect(try dossier.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true)
        #expect(try FileManager.default.contentsOfDirectory(atPath: dossier.path()) == ["Correction.json"])
        try await nouveauMagasin.effacer()
        try await nouveauMagasin.effacer()
        #expect(try await magasin.lire() == nil)
        try FileManager.default.removeItem(at: dossier)
    }

    @Test func reprendUnMessageEtRemplaceUnFichierIllisibleSansToucherLaSource() async throws {
        let dossier = URL.temporaryDirectory.appending(path: UUID().uuidString)
        let file = FileEntree(dossier: dossier.appending(path: "Entree"))
        let original = ContenuRecu(type: .texte, contenu: Data("2 pommes".utf8), origine: .pressePapiers)
        try await file.deposer(original)
        let brouillons = dossier.appending(path: "Brouillons")
        try FileManager.default.createDirectory(at: brouillons, withIntermediateDirectories: true)
        let fichier = brouillons.appending(path: "Correction.json")
        let illisible = Data(#"{"version_schema":1,"contenu":null}"#.utf8)
        try illisible.write(to: fichier)
        let suivi = await SuiviBrouillonCorrection(dossier: dossier)
        await #expect(throws: MagasinBrouillonCorrection.Erreur.illisible) { try await suivi.lire() }
        #expect(try Data(contentsOf: fichier) == illisible)
        #expect(try await file.lire().contenus == [original])

        let proposition = FormulaireMessage.Proposition(
            nom: "pommes", quantite: Quantite(2), unite: .piece, exclue: true)
        var saisie = SaisieQuantite(quantite: Quantite(2), unite: .piece)
        saisie.texte = "2,"
        let brouillon = BrouillonCorrection.message(
            .init(
                sourceId: original.id, texteDerive: nil, cause: .iaIndisponible, propositions: [proposition],
                edition: .init(id: proposition.id, saisie: saisie)))
        await suivi.programmer(brouillon)
        try await suivi.forcer(brouillon)
        #expect(try await suivi.lire() == brouillon)
        #expect(try !String(contentsOf: fichier, encoding: .utf8).contains(original.texteRecu))
        try await suivi.effacer()
        #expect(try await suivi.lire() == nil)
        #expect(try await file.lire().contenus == [original])
        try FileManager.default.removeItem(at: dossier)
    }
}
