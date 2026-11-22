import Foundation
import PersilladePlateforme
import Testing

@testable import PersilladeCore

struct EnvoiCoursesTests {
    private static let seuil = Date(timeIntervalSinceReferenceDate: 1_000)
    private static let listes = [
        DestinationRappels(id: "courses", titre: "Courses", compte: "Test", modifiable: true),
        DestinationRappels(id: "autre", titre: "Autre", compte: "Test", modifiable: true),
        DestinationRappels(id: "lecture", titre: "Lecture", compte: "Test", modifiable: false),
    ]

    private let dossier = URL.temporaryDirectory.appending(path: UUID().uuidString)

    private func scenario(_ titres: [String] = []) -> (EnvoiCourses, MagasinRappelsMemoire) {
        let rappels = MagasinRappelsMemoire(
            destinations: Self.listes,
            contenu: ["courses": titres.map { RappelCourses(id: UUID().uuidString, titre: $0) }],
            maintenant: { Self.seuil })
        return (service(rappels), rappels)
    }

    private func service(_ rappels: MagasinRappelsMemoire) -> EnvoiCourses {
        EnvoiCourses(
            documents: MagasinDocumentFichiers(dossier: dossier), rappels: rappels,
            maintenant: { Self.seuil.addingTimeInterval(0.5) })
    }

    private func nettoyer() throws {
        if FileManager.default.fileExists(atPath: dossier.path()) {
            try FileManager.default.removeItem(at: dossier)
        }
    }

    @Test func premierEnvoiCouvertFixeLeSeuilPuisLaCocheCompte() async throws {
        let (envoi, rappels) = scenario(["lait 2 l"])
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "lait", quantite: Quantite(2), unite: .l))
        }
        let premier = try await envoi.renvoyer()
        #expect(premier.ignores.count == 1)
        let etat = try await envoi.lire()
        #expect(etat.liste.premierEnvoiLe == Self.seuil.addingTimeInterval(0.5))
        #expect(!etat.destinationVerrouillee)
        let ligne = try #require(etat.liste.lignes.first)
        #expect(try etat.etatEnvoi(de: ligne) == .rienAAjouter)
        let lait = try #require(try await rappels.lire(destinationId: "courses").first)
        await rappels.remplacerRappels(
            [RappelCourses(id: lait.id, titre: lait.titre, coche: true, cocheLe: Self.seuil)],
            destinationId: "courses")
        #expect(try await service(rappels).renvoyer().ignores == [ligne.id])
        #expect(try await rappels.lire(destinationId: "courses").count == 1)
        try await envoi.choisirDestination("autre")
        #expect(try await envoi.lire().liste.premierEnvoiLe == nil)
        #expect(try await envoi.lire().etatEnvoi(de: ligne) == .aEnvoyer)
        try nettoyer()
    }

    @Test func uneCocheDejaVueALaSecondeDuPremierEnvoiResteAnterieure() async throws {
        let (envoi, rappels) = scenario()
        await rappels.remplacerRappels(
            [RappelCourses(id: "ancien", titre: "œufs 6", coche: true, cocheLe: Self.seuil)],
            destinationId: "courses")
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "œufs", quantite: Quantite(6)))
        }
        #expect(try await envoi.renvoyer().ajoutes.count == 1)
        let relance = service(rappels)
        let articles = try await rappels.lire(destinationId: "courses")
        await rappels.remplacerRappels(articles.filter { $0.id == "ancien" }, destinationId: "courses")
        #expect(try await relance.renvoyer().ajoutes.count == 1)
        try nettoyer()
    }

    @Test func uneCocheDateeApresLeSeuilCompteDesLaPremiereLecture() async throws {
        let (envoi, rappels) = scenario()
        await rappels.remplacerRappels(
            [RappelCourses(id: "nouveau", titre: "œufs 6", coche: true, cocheLe: Self.seuil.addingTimeInterval(0.6))],
            destinationId: "courses")
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "œufs", quantite: Quantite(6)))
        }
        #expect(try await envoi.renvoyer().ignores.count == 1)
        #expect(try await !envoi.lire().destinationVerrouillee)
        try nettoyer()
    }

    @Test func unEchecPartielLaisseReprendreSeulementLeManquant() async throws {
        let (envoi, rappels) = scenario()
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "farine", quantite: Quantite(1500), unite: .g))
            try liste.ajouter(ArticleCourses(nom: "œufs", quantite: Quantite(6)))
            try liste.ajouter(ArticleCourses(nom: "sel"))
        }
        await rappels.fixerEcrituresEnEchec(["œufs 6"])
        let premier = try await envoi.renvoyer()
        #expect(premier.ajoutes.count == 2)
        #expect(premier.echecs.map(\.cause) == [.ecriture])
        let relance = service(rappels)
        let etat = try await relance.lire()
        #expect(etat.destinationVerrouillee)
        let farine = try #require(etat.liste.lignes.first)
        let oeufs = try #require(etat.liste.lignes.dropFirst().first)
        #expect(try etat.etatEnvoi(de: farine) == .envoyee)
        #expect(try etat.etatEnvoi(de: oeufs) == .echec(.ecriture))
        await #expect(throws: EnvoiCourses.Erreur.destinationVerrouillee) {
            try await relance.choisirDestination("autre")
        }
        await rappels.fixerEcrituresEnEchec([])
        #expect(try await relance.renvoyer().ajoutes == [oeufs.id])
        #expect(try await relance.renvoyer().ajoutes.isEmpty)
        #expect(try await rappels.lire(destinationId: "courses").map(\.titre) == ["farine 1,5 kg", "sel", "œufs 6"])
        try nettoyer()
    }

    @Test func toutesLesEcrituresEnEchecFixentLeSeuilSansVerrouiller() async throws {
        let (envoi, rappels) = scenario()
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "sel")) }
        await rappels.fixerEcrituresEnEchec(["sel"])
        #expect(try await envoi.renvoyer().echecs.count == 1)
        #expect(try await envoi.lire().liste.premierEnvoiLe == Self.seuil.addingTimeInterval(0.5))
        #expect(try await !envoi.lire().destinationVerrouillee)
        try await envoi.choisirDestination("autre")
        #expect(try await envoi.lire().liste.premierEnvoiLe == nil)
        try nettoyer()
    }

    @Test func refusSuppressionEtLectureSeuleOntDesCausesDistinctes() async throws {
        let (envoi, rappels) = scenario()
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "sel")) }

        await rappels.fixerAcces(false)
        let refus = try await envoi.renvoyer()
        #expect(refus.echecs.map(\.cause) == [.accesRefuse])
        #expect(refus.causeGenerale == .accesRefuse)
        #expect(try await envoi.lire().liste.premierEnvoiLe == nil)
        await rappels.fixerAcces(true)
        await rappels.supprimerDestination("courses")
        #expect(try await envoi.renvoyer().echecs.map(\.cause) == [.listeIntrouvable])
        try await envoi.choisirDestination("lecture")
        #expect(try await envoi.renvoyer().echecs.map(\.cause) == [.listeNonModifiable])
        #expect(try await envoi.lire().liste.lignes.count == 1)
        try nettoyer()
    }

    @Test func ajoutCibleNeReexamineNiLesAutresNomsNiLesLignesExclues() async throws {
        let (envoi, rappels) = scenario()
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "sel"))
            try liste.ajouter(ArticleCourses(nom: "tomates", quantite: Quantite(2)))
            try liste.ajouter(ArticleCourses(nom: "tomates", quantite: Quantite(250), unite: .g))
        }
        let etat = try await envoi.lire()
        let grammes = try #require(etat.liste.lignes.last)
        try await envoi.modifier { liste, _ in try liste.cocher(grammes.id) }
        _ = try await envoi.renvoyer()
        await rappels.remplacerRappels([], destinationId: "courses")
        let effets = try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "tomates")) }
        #expect(effets.decochagePropose == [grammes.id])
        #expect(effets.lignesAEnvoyer.count == 1)
        #expect(try await envoi.envoyer(lignes: effets.lignesAEnvoyer).ajoutes == effets.lignesAEnvoyer)
        #expect(try await rappels.lire(destinationId: "courses").map(\.titre) == ["tomates 2"])
        #expect(try await envoi.envoyerLigne(grammes.id).ajoutes.isEmpty)
        let ajout = try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "tomates", quantite: Quantite(1)))
        }
        #expect(try await envoi.envoyer(lignes: ajout.lignesAEnvoyer).complements == ajout.lignesAEnvoyer)
        #expect(try await rappels.lire(destinationId: "courses").map(\.titre) == ["tomates 2", "tomates 1"])
        try nettoyer()
    }

    @Test func leResultatSuitLaLigneFusionneeEtExposeLeSupplement() async throws {
        let (envoi, _) = scenario(["tomates 2"])
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "tomates", quantite: Quantite(2), unite: .g))
            try liste.ajouter(ArticleCourses(nom: "tomates", quantite: Quantite(2)))
        }
        let avant = try await envoi.lire()
        let ancienId = try #require(avant.liste.lignes.last?.id)
        #expect(try await envoi.envoyerLigne(ancienId).ignores == [ancienId])
        let premierId = try #require(avant.liste.lignes.first?.id)
        try await envoi.modifier { liste, _ in
            try liste.modifierQuantite(premierId, valeur: Quantite(3), unite: .piece)
        }
        let etat = try await envoi.lire()
        let fusion = try #require(etat.liste.lignes.first)
        #expect(etat.liste.lignes.count == 1)
        #expect(fusion.id != ancienId)
        #expect(try etat.etatEnvoi(de: fusion) == .supplement(Quantite(3), .piece))
        try await envoi.modifier { liste, _ in
            try liste.retirer(fusion.id)
            try liste.ajouter(ArticleCourses(nom: "tomates", quantite: Quantite(1)))
        }
        let nouvelle = try await envoi.lire()
        #expect(try nouvelle.etatEnvoi(de: #require(nouvelle.liste.lignes.first)) == .aEnvoyer)
        try nettoyer()
    }

    @Test func uneProvenanceCommuneSansFusionNeTransferePasLeResultat() async throws {
        let (envoi, _) = scenario()
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in
            try liste.integrer(
                [
                    ArticleCourses(nom: "tomates", quantite: Quantite(250), unite: .g),
                    ArticleCourses(nom: "tomates", quantite: Quantite(2)),
                ], messageId: UUID())
        }
        let lignes = try await envoi.lire().liste.lignes
        let grammes = try #require(lignes.first)
        let pieces = try #require(lignes.last)
        _ = try await envoi.envoyerLigne(pieces.id)
        try await envoi.modifier { liste, _ in
            try liste.retirer(pieces.id)
            try liste.modifierQuantite(grammes.id, valeur: Quantite(2), unite: .piece)
        }
        let etat = try await envoi.lire()
        #expect(try etat.etatEnvoi(de: #require(etat.liste.lignes.first)) == .aEnvoyer)
        try nettoyer()
    }

    @Test func uneNouvelleListeLibereLaDestinationEtConserveLeJournal() async throws {
        let (envoi, _) = scenario()
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "5 épices")) }
        _ = try await envoi.renvoyer()
        let avant = try await envoi.lire()
        try await envoi.modifier { liste, _ in liste.nouvelleListe(confirmee: true) }
        let apres = try await envoi.lire()
        #expect(avant.liste.id != apres.liste.id)
        #expect(apres.journal.entrees == avant.journal.entrees)
        #expect(!apres.destinationVerrouillee)
        #expect(apres.liste.premierEnvoiLe == nil)
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "5 épices")) }
        #expect(try await envoi.renvoyer().ignores.count == 1)
        try await envoi.choisirDestination("autre")
        try nettoyer()
    }

    @Test func laCopieDeSelectionSurvitAuxModificationsEtALaRelance() async throws {
        let (envoi, rappels) = scenario()
        let recette = try Recette(
            titre: "Salade", portions: 1,
            ingredients: [
                try Ingredient(nom: "tomates", quantite: Quantite(2), unite: .piece, texteOrigine: "2 tomates")
            ], etapes: ["Couper les tomates."], texteSource: "Salade de tomates.")
        try await envoi.modifier { liste, selection in
            selection.selectionner(try .init(recetteId: recette.id, portions: 2))
            return try liste.generer(selection.preparer(recettes: [recette]))
        }
        let initiale = try await envoi.lire()
        #expect(!initiale.selectionModifieeDepuisGeneration)
        try await envoi.modifier { _, selection in
            selection.selectionner(try .init(recetteId: recette.id, portions: 3))
        }
        let relue = try await service(rappels).lire()
        #expect(relue.selectionModifieeDepuisGeneration)
        #expect(relue.liste.selectionALaGeneration?.choix.first?.portions == 2)
        #expect(relue.selection.choix.first?.portions == 3)
        try nettoyer()
    }

    @Test(arguments: [false, true])
    func coupureApresEventKitRetrouveLEcritureMemeAvecTitreAmbigu(effacerNotes: Bool) async throws {
        let (_, rappels) = scenario()
        let disque = MagasinDocumentFichiers(dossier: dossier)
        let interrompu = DocumentsAvecCoupure(disque)
        let envoi = EnvoiCourses(documents: interrompu, rappels: rappels, maintenant: { Self.seuil })

        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "5 épices")) }
        await #expect(throws: DocumentsAvecCoupure.Erreur.coupure) { try await envoi.renvoyer() }
        let rappelsEcrits = try await rappels.lire(destinationId: "courses")
        #expect(rappelsEcrits.count == 1)
        #expect(try await envoi.lire().journal.entrees.isEmpty)
        if effacerNotes {
            let original = try #require(rappelsEcrits.first)
            await rappels.remplacerRappels(
                [RappelCourses(id: original.id, titre: original.titre, creeLe: original.creeLe)],
                destinationId: "courses")
        }

        let relance = service(rappels)
        if effacerNotes {
            await #expect(throws: EnvoiCourses.Erreur.ecritureIncertaine) {
                try await relance.choisirDestination("autre")
            }
            #expect(try await relance.renvoyer().ignores.count == 1)
            #expect(try await rappels.lire(destinationId: "courses").count == 1)
            #expect(try await relance.lire().journal.entrees.isEmpty)
            #expect(try await !relance.lire().destinationVerrouillee)
            await rappels.remplacerRappels(rappelsEcrits, destinationId: "courses")
        }
        await #expect(throws: EnvoiCourses.Erreur.destinationVerrouillee) {
            try await relance.choisirDestination("autre")
        }
        #expect(try await relance.renvoyer().ignores.count == 1)
        #expect(try await rappels.lire(destinationId: "courses").count == 1)
        let entree = try #require(try await relance.lire().journal.entrees.first)
        #expect(entree.article.nomNormalise == "5 epice")
        #expect(entree.article.quantite == nil)

        let renomme = RappelCourses(id: entree.rappelId, titre: "2 laits")
        #expect(try await relance.lire().journal.article(du: renomme).nomNormalise == "lait")
        try nettoyer()
    }
    @Test func unTitreAjouteManuellementApresCoupureNeProuvePasUneEcriture() async throws {
        let (_, rappels) = scenario()
        let disque = MagasinDocumentFichiers(dossier: dossier)
        let envoi = EnvoiCourses(
            documents: DocumentsAvecCoupure(disque, avantEventKit: true),
            rappels: rappels, maintenant: { Self.seuil })
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "5 épices")) }
        await #expect(throws: DocumentsAvecCoupure.Erreur.coupure) { try await envoi.renvoyer() }
        #expect(try await rappels.lire(destinationId: "courses").isEmpty)
        await rappels.remplacerRappels(
            [RappelCourses(id: "manuel", titre: "5 épices", creeLe: Self.seuil)], destinationId: "courses")

        let relance = service(rappels)
        try await relance.modifier { liste, _ in
            try liste.ajouter(ArticleCourses(nom: "épices", quantite: Quantite(5)))
        }
        let rapport = try await relance.renvoyer()
        #expect(rapport.ignores.count == 2)
        #expect(rapport.ajoutes.isEmpty)
        #expect(try await rappels.lire(destinationId: "courses").map(\.id) == ["manuel"])
        #expect(try await relance.lire().journal.entrees.isEmpty)
        #expect(try await !relance.lire().destinationVerrouillee)
        await #expect(throws: EnvoiCourses.Erreur.ecritureIncertaine) {
            try await relance.choisirDestination("autre")
        }
        await rappels.remplacerRappels([], destinationId: "courses")
        try await relance.choisirDestination("autre")
        #expect(try await relance.lire().destinationId == "autre")
        try nettoyer()
    }

    @Test(arguments: [false, true])
    func nouvelleListeLocalePossibleApresCoupureEtDestinationInaccessible(supprimee: Bool) async throws {
        let (_, rappels) = scenario()
        let disque = MagasinDocumentFichiers(dossier: dossier)
        let envoi = EnvoiCourses(documents: DocumentsAvecCoupure(disque), rappels: rappels, maintenant: { Self.seuil })
        try await envoi.choisirDestination("courses")
        try await envoi.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "5 épices")) }
        let precedente = try await envoi.lire().liste.id
        await #expect(throws: DocumentsAvecCoupure.Erreur.coupure) { try await envoi.renvoyer() }

        if supprimee { await rappels.supprimerDestination("courses") }
        await rappels.fixerAcces(false)
        let relance = service(rappels)
        try await relance.modifier { liste, _ in liste.nouvelleListe(confirmee: true) }
        try await relance.choisirDestination("autre")
        #expect(try await relance.lire().liste.id != precedente)
        #expect(try await !relance.lire().destinationVerrouillee)

        await rappels.fixerAcces(true)
        if !supprimee {
            try await relance.choisirDestination("courses")
            try await relance.modifier { liste, _ in try liste.ajouter(ArticleCourses(nom: "5 épices")) }
            #expect(try await relance.renvoyer().ignores.count == 1)
            let etat = try await relance.lire()
            #expect(etat.journal.entrees.map(\.listeId) == [precedente])
            #expect(!etat.destinationVerrouillee)
        }
        try nettoyer()
    }

}

private actor DocumentsAvecCoupure: MagasinDocument {
    enum Erreur: Error {
        case coupure
    }

    let disque: MagasinDocumentFichiers
    let avantEventKit: Bool

    init(_ disque: MagasinDocumentFichiers, avantEventKit: Bool = false) {
        self.disque = disque
        self.avantEventKit = avantEventKit
    }

    func lire<Document: Codable & Sendable>(_ type: Document.Type, cle: String, version: Int) async throws -> Document {
        try await disque.lire(type, cle: cle, version: version)
    }

    func ecrire<Document: Codable & Sendable>(_ document: Document, cle: String, version: Int) async throws {
        let etat = document as? EtatCourses
        if !avantEventKit, etat?.destinationVerrouillee == true { throw Erreur.coupure }
        try await disque.ecrire(document, cle: cle, version: version)
        if avantEventKit, etat?.enAttente.isEmpty == false { throw Erreur.coupure }
    }
}
