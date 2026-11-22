import Foundation
import PersilladeCore
import PersilladePlateforme

@MainActor
@Observable
final class BibliothequeRecettes {
    private struct ChoixStocke: Codable {
        let recetteId: UUID
        let portions: Int

        enum CodingKeys: String, CodingKey {
            case recetteId = "recette_id"
            case portions
        }
    }

    private let bibliotheque: Result<any Bibliotheque, any Error>
    private let documents: any MagasinDocument
    private static let cleSemaine = "selection-semaine"

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
        documents = dossier.map { MagasinDocumentFichiers(dossier: $0) } ?? MagasinDocumentFichiers()
    }

    func actualiserSemaine() async {
        guard !operationSemaine, !selectionDisponible else { return }
        operationSemaine = true
        defer { operationSemaine = false }
        do {
            let choix = try await documents.lire([ChoixStocke].self, cle: Self.cleSemaine, version: 1)
            let ids = Set(try await bibliotheque.get().lister().map(\.id))
            var semaine = SelectionSemaine()
            for entree in choix where ids.contains(entree.recetteId) {
                semaine.selectionner(try .init(recetteId: entree.recetteId, portions: entree.portions))
            }
            selection = semaine
            if semaine.choix.count < choix.count {
                erreur = "La semaine a été mise à jour. Des recettes ont été supprimées."
                try await ecrireSemaine(semaine)
            }
            selectionDisponible = true
        } catch ErreurMagasinDocument.absent {
            selectionDisponible = true
        } catch {
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
            var semaine = selection
            if let portions {
                guard try await lire(id) != nil else {
                    self.erreur = "Cette recette a été supprimée."
                    return
                }
                semaine.selectionner(try .init(recetteId: id, portions: portions))
            } else {
                semaine.deselectionner(id)
            }
            try await ecrireSemaine(semaine)
            selection = semaine
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
                try await ecrireSemaine(selection)
            } catch {
                self.erreur = "La recette a été supprimée. La semaine sera vérifiée à la prochaine ouverture."
            }
        }
        return true
    }

    private func ecrireSemaine(_ semaine: SelectionSemaine) async throws {
        let choix = semaine.choix.map { ChoixStocke(recetteId: $0.recetteId, portions: $0.portions) }
        try await documents.ecrire(choix, cle: Self.cleSemaine, version: 1)
    }
}
