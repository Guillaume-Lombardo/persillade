import Foundation
import PersilladeCore
import PersilladePlateforme

@MainActor
@Observable
final class BibliothequeRecettes {
    private let bibliotheque: Result<any Bibliotheque, any Error>
    let envoiCourses: EnvoiCourses

    private(set) var selection = SelectionSemaine()
    private(set) var revision = 0
    private(set) var selectionDisponible = false
    private(set) var operationSemaine = false
    var erreur: String?

    #if DEBUG
        private var simulerEchecEcriture = false
    #endif

    init(dossier: URL? = nil) {
        bibliotheque = Result {
            if let dossier {
                try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
            }
            return try BibliothequeSwiftData(url: dossier?.appending(path: "Recettes.store"))
        }
        #if DEBUG
            simulerEchecEcriture =
                dossier != nil
                && ProcessInfo.processInfo.arguments.contains("-recettes-echec-ecriture")
        #endif
        let documents = dossier.map { MagasinDocumentFichiers(dossier: $0) } ?? MagasinDocumentFichiers()
        envoiCourses = EnvoiCourses(documents: documents, rappels: MagasinRappelsEventKit())
    }

    func actualiserSemaine() async {
        guard !operationSemaine else { return }
        operationSemaine = true
        defer { operationSemaine = false }
        do {
            let semaine = try await envoiCourses.lire().selection
            let ids = Set(try await bibliotheque.get().lister().map(\.id))
            let absentes = semaine.choix.map(\.recetteId).filter { !ids.contains($0) }
            if absentes.isEmpty {
                selection = semaine
            } else {
                selection = try await envoiCourses.modifier { _, choix in
                    for id in absentes { choix.deselectionner(id) }
                    return choix
                }
                erreur = "La semaine a été mise à jour. Des recettes ont été supprimées."
            }
            selectionDisponible = true
        } catch {
            selectionDisponible = false
            self.erreur = "Impossible de lire la semaine."
        }
    }

    func lister(recherche: String) async throws -> [ResumeRecette] {
        try await bibliotheque.get().rechercherParTitre(recherche)
    }

    func lire(_ id: UUID) async throws -> Recette? {
        try await bibliotheque.get().lire(id: id)
    }

    func enregistrer(_ recette: Recette, modification: Bool, echelle: Double) async throws {
        #if DEBUG
            if simulerEchecEcriture {
                simulerEchecEcriture = false
                throw CocoaError(.fileWriteNoPermission)
            }
        #endif
        let depot = try bibliotheque.get()
        if modification {
            try await depot.modifier(recette)
        } else {
            _ = try await depot.enregistrer(recette)
        }
        revision += 1
        Task(priority: .utility) {
            await RenduPlanche.partage.preparerVignettes(Planche(recette: recette), echelle: echelle)
        }
    }

    func portionsChoisies(_ id: UUID) -> Int? {
        selection.choix.first { $0.recetteId == id }?.portions
    }

    func choisir(_ id: UUID, portions: Int?) async {
        guard selectionDisponible, !operationSemaine else { return }
        operationSemaine = true
        defer { operationSemaine = false }
        do {
            if portions != nil, try await lire(id) == nil {
                self.erreur = "Cette recette a été supprimée."
                return
            }
            selection = try await envoiCourses.modifier { _, semaine in
                if let portions {
                    semaine.selectionner(try .init(recetteId: id, portions: portions))
                } else {
                    semaine.deselectionner(id)
                }
                return semaine
            }
        } catch {
            self.erreur = "Impossible de mettre à jour la semaine. Réessayez."
        }
    }

    func supprimer(_ id: UUID) async -> Bool {
        guard !operationSemaine else { return false }
        operationSemaine = true
        defer { operationSemaine = false }
        do {
            try await bibliotheque.get().supprimer(id: id)
        } catch {
            self.erreur = "Impossible de supprimer la recette. Réessayez."
            return false
        }
        revision += 1
        if portionsChoisies(id) != nil {
            selection.deselectionner(id)
            do {
                selection = try await envoiCourses.modifier { _, semaine in
                    semaine.deselectionner(id)
                    return semaine
                }
            } catch {
                selectionDisponible = false
                self.erreur = "La recette a été supprimée. Réessayez de mettre à jour la semaine."
            }
        }
        return true
    }

}
