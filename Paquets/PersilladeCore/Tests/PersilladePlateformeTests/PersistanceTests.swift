import Foundation
import PersilladeCore
import PersilladePlateforme
import Testing

@Test func bibliothequePersistanteSansDoublon() async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let url = dossier.appending(path: "Bibliotheque.store")
    let recette = try Recette(titre: "Épinards", portions: 4, ingredients: [], etapes: [], texteSource: "")
    let autre = try Recette(titre: "Zeste de citron", portions: 4, ingredients: [], etapes: [], texteSource: "")
    let corrigee = try Recette(
        id: recette.id, titre: "Épinards à la crème", portions: 2,
        ingredients: [
            Ingredient(nom: "épinards", quantite: Quantite(250), unite: .g, texteOrigine: "250 g d’épinards")
        ],
        etapes: ["Cuire à feu doux."], texteSource: "Une recette d’épinards.")
    let creeLe: Date
    do {
        let bibliotheque: any Bibliotheque = try BibliothequeSwiftData(url: url)
        #expect(try await bibliotheque.enregistrer(recette) == recette.id)
        #expect(try await bibliotheque.enregistrer(autre) == autre.id)
        await #expect(throws: ErreurBibliotheque.recetteDejaEnregistree(recette.id)) {
            try await bibliotheque.enregistrer(recette)
        }
        let resume = try #require(try await bibliotheque.lister().first)
        creeLe = resume.creeLe
        #expect(resume.modifieLe == creeLe)
        try await bibliotheque.modifier(corrigee)
    }

    let relance = try BibliothequeSwiftData(url: url)
    let resumes = try await relance.lister()
    #expect(resumes.map(\.id) == [recette.id, autre.id])
    #expect(try await relance.lire(id: recette.id) == corrigee)
    let resume = try #require(resumes.first)
    #expect(resume.titre == corrigee.titre)
    #expect(resume.nombreIngredients == 1)
    #expect(resume.nombreEtapes == 1)
    #expect(resume.creeLe == creeLe)
    #expect(resume.modifieLe > creeLe)
    #expect(try await relance.rechercherParTitre(" PINARDS A LA CREME ") == [resume])
    #expect(try await relance.rechercherParTitre("tout autre chose").isEmpty)

    try await relance.supprimer(id: recette.id)
    #expect(try await relance.lire(id: recette.id) == nil)
    await #expect(throws: ErreurBibliotheque.recetteIntrouvable(recette.id)) {
        try await relance.modifier(corrigee)
    }
    #expect(try await relance.lister().map(\.id) == [autre.id])
}

@Test func magasinDistingueAbsenceEtVersionInconnue() async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let magasin = MagasinDocumentFichiers(dossier: dossier)
    await #expect(throws: ErreurMagasinDocument.absent) {
        try await magasin.lire([String].self, cle: "liste", version: 1)
    }
    try await magasin.ecrire(["Sel"], cle: "liste", version: 2)
    try await magasin.ecrire(["Farine"], cle: "LISTE", version: 1)
    let cleLongue = String(repeating: "A", count: 250)
    try await magasin.ecrire(["Beurre"], cle: cleLongue, version: 1)
    await #expect(throws: ErreurMagasinDocument.versionInconnue(2)) {
        try await magasin.lire([String].self, cle: "liste", version: 1)
    }
    await #expect(throws: ErreurMagasinDocument.versionInconnue(2)) {
        try await magasin.ecrire(["Poivre"], cle: "liste", version: 1)
    }

    let relance = MagasinDocumentFichiers(dossier: dossier)
    #expect(try await relance.lire([String].self, cle: "liste", version: 2) == ["Sel"])
    #expect(try await relance.lire([String].self, cle: "LISTE", version: 1) == ["Farine"])
    #expect(try await relance.lire([String].self, cle: cleLongue, version: 1) == ["Beurre"])
    try await relance.ecrire(["Poivre"], cle: "liste", version: 2)
    #expect(try await magasin.lire([String].self, cle: "liste", version: 2) == ["Poivre"])
}

@Test(arguments: [false, true])
func sauvegardeUnDocumentCorrompuAvantRecuperation(ecriture: Bool) async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let corrompu = Data(#"{"version_schema":1,"document":false}"#.utf8)
    try corrompu.write(to: dossier.appending(path: "6c69737465.json"))
    let magasin = MagasinDocumentFichiers(dossier: dossier)

    do {
        if ecriture {
            try await magasin.ecrire(["Sel"], cle: "liste", version: 1)
        } else {
            _ = try await magasin.lire([String].self, cle: "liste", version: 1)
        }
        Issue.record("La corruption doit être signalée")
    } catch ErreurMagasinDocument.corrompu(let copie) {
        #expect(try Data(contentsOf: copie) == corrompu)
    }
    await #expect(throws: ErreurMagasinDocument.absent) {
        try await magasin.lire([String].self, cle: "liste", version: 1)
    }
    try await magasin.ecrire(["Sel"], cle: "liste", version: 1)
    #expect(try await magasin.lire([String].self, cle: "liste", version: 1) == ["Sel"])
}
