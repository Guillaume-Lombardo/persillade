import Foundation
import PersilladeCore
import Testing

@Test func ordreEtRepriseDeLaFileSurDisque() async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let premier = ContenuRecu(
        type: .url, contenu: Data("https://example.org".utf8), origine: .feuillePartage,
        recuLe: Date(timeIntervalSince1970: 2))
    let second = ContenuRecu(
        type: .texte, contenu: Data("2 œufs".utf8), origine: .pressePapiers,
        recuLe: Date(timeIntervalSince1970: 1))
    do {
        let file = FileEntree(dossier: dossier)
        try await file.deposer(premier)
        try await file.deposer(second)
        try await file.deposer(premier)
    }

    let relance = FileEntree(dossier: dossier)
    #expect(try await relance.lire().contenus == [premier, second])
    #expect(try await FileEntree(dossier: dossier).lire().contenus == [premier, second])
    try await relance.retirer(id: premier.id)
    #expect(try await FileEntree(dossier: dossier).lire().contenus == [second])
}

@Test func contenuIllisibleIsoleSansPerte() async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let donnees = Data("{".utf8)
    let suffixe = UUID().uuidString + ".json"
    try donnees.write(to: dossier.appending(path: "00000000000000000001-" + suffixe))
    try FileManager.default.createDirectory(
        at: dossier.appending(path: "00000000000000000002-" + suffixe), withIntermediateDirectories: false)
    let valide = try #require(ContenuRecu(texte: "Sel", origine: .feuillePartage))
    let file = FileEntree(dossier: dossier)
    try await file.deposer(valide)

    let lecture = try await file.lire()
    #expect(lecture.contenus == [valide])
    #expect(lecture.fichiersIllisibles.count == 2)
    let copie = try #require(lecture.fichiersIllisibles.first)
    #expect(try Data(contentsOf: copie) == donnees)
    let repertoire = try #require(lecture.fichiersIllisibles.last)
    #expect(try repertoire.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true)
    let suivante = try await file.lire()
    #expect(suivante.contenus == [valide])
    #expect(suivante.fichiersIllisibles.isEmpty)
}

@Test func depotsConcurrentsDepuisDeuxFiles() async throws {
    let dossier = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    defer { try! FileManager.default.removeItem(at: dossier) }
    let app = FileEntree(dossier: dossier)
    let extensionPartage = FileEntree(dossier: dossier)
    let contenus = (1...20).map {
        ContenuRecu(type: .texte, contenu: Data(String($0).utf8), origine: .feuillePartage)
    }
    try await withThrowingTaskGroup(of: Void.self) { groupe in
        for (index, contenu) in contenus.enumerated() {
            let file = index.isMultiple(of: 2) ? app : extensionPartage
            groupe.addTask { try await file.deposer(contenu) }
        }
        try await groupe.waitForAll()
    }
    let lecture = try await app.lire()
    #expect(Set(lecture.contenus.map(\.id)) == Set(contenus.map(\.id)))
    let fichiers = try FileManager.default.contentsOfDirectory(atPath: dossier.path())
    #expect(Set(fichiers.map { $0.prefix(20) }).count == contenus.count)
}

@Test @MainActor func interpreteLesFournisseursDePartageEtDeCollage() async throws {
    let url = try #require(URL(string: "https://example.org/recette"))
    let lien = try await ContenuRecu.charger([NSItemProvider(object: url as NSURL)], origine: .feuillePartage)
    #expect(lien.type == .url)
    #expect(lien.origine == .feuillePartage)
    #expect(lien.contenu == Data(url.absoluteString.utf8))

    for (texte, type) in [
        ("  https://example.org/recette\n", ContenuRecu.TypeContenu.url),
        ("Pâtes\nVoir https://example.org/recette", .texte),
        ("file:///tmp/recette", .texte),
    ] {
        let recu = try await ContenuRecu.charger(
            [NSItemProvider(object: texte as NSString)], origine: .pressePapiers)
        #expect(recu.type == type)
        #expect(recu.origine == .pressePapiers)
        #expect(recu.contenu == Data((type == .url ? url.absoluteString : texte).utf8))
    }
}

@Test @MainActor func accepteUnFournisseurPublicText() async throws {
    let fournisseur = NSItemProvider()
    let donnees = Data("Poireaux".utf8)
    fournisseur.registerDataRepresentation(forTypeIdentifier: "public.text", visibility: .all) { terminer in
        terminer(donnees, nil)
        return nil
    }
    let recu = try await ContenuRecu.charger([fournisseur], origine: .feuillePartage)
    #expect(recu.type == .texte)
    #expect(recu.contenu == donnees)
}
