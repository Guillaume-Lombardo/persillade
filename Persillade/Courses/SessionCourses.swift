import OSLog
import PersilladeCore
import SwiftUI

@MainActor
@Observable
final class SessionCourses {
    private let bibliotheque: BibliothequeRecettes
    var envoi: EnvoiCourses { bibliotheque.envoiCourses }
    #if DEBUG
        private var preparerEssai = false
    #endif

    var etat: EtatCourses? { bibliotheque.etatCourses }
    private(set) var recettes: [UUID: Recette] = [:]
    private(set) var destinations: [DestinationRappels] = []
    var occupee: Bool { bibliotheque.operationSemaine }
    private(set) var progressionEnvoi: Double?
    private(set) var recettesAbsentes = 0
    var erreur: String?

    var destination: DestinationRappels? { destinations.first { $0.id == etat?.destinationId } }

    init(bibliotheque: BibliothequeRecettes) {
        self.bibliotheque = bibliotheque
        #if DEBUG
            preparerEssai = ProcessInfo.processInfo.arguments.contains("-courses-recettes")
        #endif
    }

    func actualiser(semaine: Bool = false) async {
        await effectuer("La liste de courses n’a pas pu être lue.") {
            #if DEBUG
                if preparerEssai {
                    try await peuplerRecettesEssai()
                    preparerEssai = false
                }
            #endif
            try await relire()
            if semaine {
                try await actualiserRecettes()
            }
            if etat?.destinationId != nil, destinations.isEmpty {
                do {
                    try await chargerDestinations()
                } catch CauseEchecEnvoi.accesRefuse {
                    destinations = []
                }
            }
        }
    }

    func effectuer(_ message: String, operation: () async throws -> Void) async {
        guard bibliotheque.commencerOperation() else { return }
        defer { bibliotheque.terminerOperation() }
        do {
            try await operation()
        } catch {
            signaler(message, erreur: error)
        }
    }

    func signaler(_ message: String, erreur: any Error) {
        Logger(subsystem: "xyz.g1lom.persillade", category: "Courses").error(
            "\(message, privacy: .public) \(String(describing: erreur), privacy: .private)")
        self.erreur = message
    }

    func relire() async throws {
        try await bibliotheque.relireCourses()
    }

    func actualiserRecettes() async throws {
        guard let etat else { return }
        let selection = etat.selection.choix
        let origines = etat.liste.lignes.flatMap(\.origines).filter { $0.type == .recette }
        let ids = Set(selection.map(\.recetteId) + origines.map(\.ref))
        guard !ids.isEmpty else {
            recettes = [:]
            return
        }
        var relues: [UUID: Recette] = [:]
        for id in ids {
            relues[id] = try await bibliotheque.lire(id)
        }
        recettes = relues

        let absentes = selection.map(\.recetteId).filter { relues[$0] == nil }
        if !absentes.isEmpty {
            try await envoi.modifier { _, selection in
                for id in absentes { selection.deselectionner(id) }
            }
            recettesAbsentes = absentes.count
            try await relire()
        }
    }

    func portions(_ portions: Int?, pour id: UUID) async throws {
        try await envoi.modifier { _, selection in
            guard selection.choix.contains(where: { $0.recetteId == id }) else { return }
            if let portions {
                selection.selectionner(try .init(recetteId: id, portions: portions))
            } else {
                selection.deselectionner(id)
            }
        }
        try await relire()
    }

    func generer(confirmee: Bool) async throws -> ListeCourses.Resultat {
        try await actualiserRecettes()
        let disponibles = Array(recettes.values)
        let selectionLue = etat?.selection
        let resultat = try await envoi.modifier { liste, selection in
            guard selection == selectionLue else { throw Erreur.selectionModifiee }
            let preparation = try selection.preparer(recettes: disponibles)
            guard !preparation.selection.choix.isEmpty else { throw Erreur.semaineVide }
            return try liste.generer(preparation, confirmee: confirmee)
        }
        try await relire()
        return resultat
    }

    func chargerDestinations() async throws {
        destinations = try await envoi.destinations()
    }

    func choisirDestination(_ id: String) async throws {
        try await envoi.choisirDestination(id)
        try await relire()
    }

    func envoyer(_ ids: [UUID]? = nil) async throws -> RapportEnvoi {
        progressionEnvoi = 0
        defer { progressionEnvoi = nil }
        let rapport: RapportEnvoi
        do {
            rapport = try await envoi.envoyer(lignes: ids) { traitees, total in
                await self.actualiserProgression(traitees, total: total)
            }
        } catch {
            // Une interruption peut suivre une écriture durable ou laisser un envoi à rapprocher.
            let erreurEnvoi = error
            do {
                try await relire()
            } catch {
                Logger(subsystem: "xyz.g1lom.persillade", category: "Courses")
                    .error("Relecture après envoi impossible : \(String(describing: error), privacy: .private)")
            }
            throw erreurEnvoi
        }
        try await relire()
        return rapport
    }

    private func actualiserProgression(_ traitees: Int, total: Int) {
        if total > 0 { progressionEnvoi = Double(traitees) / Double(total) }
    }

    private enum Erreur: Error { case semaineVide, selectionModifiee }

    #if DEBUG
        private func peuplerRecettesEssai() async throws {
            guard try await bibliotheque.lister(recherche: "").isEmpty else { return }
            var choix: [SelectionSemaine.Choix] = []
            for (titre, farine, etape) in [
                ("Crêpes", 500, "Mélanger la pâte."), ("Gaufres", 1_000, "Cuire les gaufres."),
            ] {
                let recette = try Recette(
                    titre: titre, portions: 4,
                    ingredients: [
                        Ingredient(nom: "œufs", quantite: Quantite(2), unite: .piece, texteOrigine: "2 œufs"),
                        Ingredient(
                            nom: "farine", quantite: Quantite(Int64(farine)), unite: .g,
                            texteOrigine: "\(farine) g de farine"),
                    ],
                    etapes: [etape], texteSource: titre)
                try await bibliotheque.enregistrer(recette, modification: false, echelle: 1)
                choix.append(try .init(recetteId: recette.id, portions: recette.portions))
            }
            let semaine = choix
            try await envoi.modifier { _, selection in
                for entree in semaine { selection.selectionner(entree) }
            }
        }
    #endif
}
