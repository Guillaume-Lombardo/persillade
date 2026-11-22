import Foundation
import PersilladeCore
import PersilladePlateforme

@MainActor
@Observable
final class BibliothequeRecettes {
    private let bibliotheque: Result<any Bibliotheque, any Error>
    let envoiCourses: EnvoiCourses
    private var actualisationReportee: (@MainActor () async -> Void)?

    private(set) var etatCourses: EtatCourses?
    var selection: SelectionSemaine { etatCourses?.selection ?? SelectionSemaine() }
    private(set) var revision = 0
    private(set) var selectionDisponible = false
    private(set) var operationSemaine = false
    var erreur: String?

    #if DEBUG
        private var simulerEchecEcriture = false
    #endif

    init(dossier: URL? = nil, rappels: any MagasinRappels) {
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
        envoiCourses = EnvoiCourses(documents: documents, rappels: rappels)
    }

    func commencerOperation() -> Bool {
        guard !operationSemaine else { return false }
        operationSemaine = true
        return true
    }

    func terminerOperation() {
        operationSemaine = false
        if let actualisationReportee {
            self.actualisationReportee = nil
            Task { await actualisationReportee() }
        }
    }

    func reporterActualisation(_ actualiser: @escaping @MainActor () async -> Void) {
        actualisationReportee = actualiser
    }

    func relireCourses() async throws {
        do {
            etatCourses = try await envoiCourses.lire()
            selectionDisponible = true
        } catch {
            selectionDisponible = false
            throw error
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
        guard selectionDisponible, commencerOperation() else { return }
        defer { terminerOperation() }
        do {
            if portions != nil, try await lire(id) == nil {
                self.erreur = "Cette recette a été supprimée."
                return
            }
            try await envoiCourses.modifier { _, semaine in
                if let portions {
                    semaine.selectionner(try .init(recetteId: id, portions: portions))
                } else {
                    semaine.deselectionner(id)
                }
            }
            try await relireCourses()
        } catch {
            self.erreur = "Impossible de mettre à jour la semaine. Réessayez."
        }
    }

    func supprimer(_ id: UUID) async -> Bool {
        guard commencerOperation() else { return false }
        defer { terminerOperation() }
        do {
            try await bibliotheque.get().supprimer(id: id)
        } catch {
            self.erreur = "Impossible de supprimer la recette. Réessayez."
            return false
        }
        revision += 1
        if portionsChoisies(id) != nil {
            do {
                try await envoiCourses.modifier { _, semaine in
                    semaine.deselectionner(id)
                }
                try await relireCourses()
            } catch {
                selectionDisponible = false
                self.erreur = "La recette a été supprimée. Réessayez de mettre à jour la semaine."
            }
        }
        return true
    }

}
