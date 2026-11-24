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

@Test(arguments: Array(1..<EtatCourses.versionSchemaCourante))
func lesCoursesAnterieuresReprennentSansAlternative(versionPrecedente: Int) async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let fichier = dossier.appending(path: "636f7572736573.json")
    let magasin = MagasinDocumentFichiers(dossier: dossier)
    let courses = EnvoiCourses(documents: magasin, rappels: MagasinRappelsMemoire(destinations: []))
    try await courses.modifier { liste, _ in
        try liste.ajouter(ArticleCourses(nom: "abricots", quantite: Quantite(6)))
    }

    var enveloppe = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: fichier)) as? [String: Any])
    var document = try #require(enveloppe["document"] as? [String: Any])
    var liste = try #require(document["liste"] as? [String: Any])
    var lignes = try #require(liste["lignes"] as? [[String: Any]])
    lignes[0].removeValue(forKey: "alternatives")
    liste["lignes"] = lignes
    liste["version_schema"] = versionPrecedente
    document["liste"] = liste
    enveloppe["version_schema"] = versionPrecedente
    enveloppe["document"] = document
    try JSONSerialization.data(withJSONObject: enveloppe).write(to: fichier)

    let relue = try await courses.lire().liste
    #expect(relue.versionSchema == ListeCourses.versionSchemaCourante)
    #expect(relue.lignes.first?.quantite == Quantite(6))
    #expect(relue.lignes.first?.alternatives.isEmpty == true)
    try await courses.modifier { liste, _ in
        try liste.ajouter(ArticleCourses(nom: "abricots", quantite: Quantite(1)))
    }
    #expect(try await courses.lire().liste.lignes.first?.quantite == Quantite(7))
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

@Test func ouvreEtReecritLesCoursesDeVersionUn() async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let fichier = dossier.appending(path: "636f7572736573.json")
    let ancien = """
        {"version_schema":1,"document":{
          "liste":{"version_schema":1,"id":"10000000-0000-0000-0000-000000000001","premier_envoi_le":42,
            "messages_integres":[],"lignes":[{"id":"10000000-0000-0000-0000-000000000002",
              "libelle":"Tomates","nom_normalise":"tomate","categorie":"Épicerie salée","cochee":true,
              "quantite":{"numerateur":3,"denominateur":2},"unite":"piece",
              "origines":[{"type":"recette","ref":"10000000-0000-0000-0000-000000000003"}]}]},
          "selection":{"version_schema":1,"choix":[]},"destination_id":"maison",
          "journal":{"version_schema":1,"entrees":[{"rappel_id":"r1","destination_id":"maison",
            "liste_id":"10000000-0000-0000-0000-000000000001","ligne_id":"10000000-0000-0000-0000-000000000002",
            "article":{"nom_normalise":"tomate","quantite":{"numerateur":2,"denominateur":1},"unite":"piece"},
            "titre_ecrit":"Tomates 2","date":43}]},
          "en_attente":[],"coches_anterieures":[],"resultats":[]
        }}
        """
    try Data(ancien.utf8).write(to: fichier)
    let magasin = MagasinDocumentFichiers(dossier: dossier)
    let version = EtatCourses.versionSchemaCourante
    let etat = try await magasin.lire(EtatCourses.self, cle: "courses", version: version)
    let ligne = try #require(etat.liste.lignes.first)
    #expect(ligne.categorie == .epicerie)
    #expect(ligne.alternatives.isEmpty)
    #expect(ligne.quantite == (try Quantite(texte: "3/2")))
    #expect(ligne.cochee)
    #expect(etat.liste.premierEnvoiLe == Date(timeIntervalSinceReferenceDate: 42))
    #expect(etat.destinationVerrouillee)
    #expect(etat.journal.entrees.first?.ligneId == ligne.id)
    #expect(etat.journal.entrees.first?.titreEcrit == "Tomates 2")
    #expect(try Data(contentsOf: fichier) == Data(ancien.utf8))

    try await magasin.ecrire(etat, cle: "courses", version: version)
    let enveloppe = try #require(JSONSerialization.jsonObject(with: Data(contentsOf: fichier)) as? [String: Any])
    let document = try #require(enveloppe["document"] as? [String: Any])
    let liste = try #require(document["liste"] as? [String: Any])
    #expect(enveloppe["version_schema"] as? Int == version)
    #expect(liste["version_schema"] as? Int == ListeCourses.versionSchemaCourante)
    #expect(try await magasin.lire(EtatCourses.self, cle: "courses", version: version) == etat)
    await #expect(throws: ErreurMagasinDocument.versionInconnue(version)) {
        try await magasin.lire(EtatCourses.self, cle: "courses", version: 1)
    }
}
