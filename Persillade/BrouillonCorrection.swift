import Foundation
import OSLog
import SwiftUI
import UIKit

enum BrouillonCorrection: Codable, Equatable, Sendable {
    case recette(ContexteCorrection, FormulaireRecette, validation: Bool)
    case message(FormulaireMessage)
}

actor MagasinBrouillonCorrection {
    private struct Document: Codable {
        let versionSchema: Int
        let contenu: BrouillonCorrection

        enum CodingKeys: String, CodingKey {
            case versionSchema = "version_schema"
            case contenu
        }
    }

    enum Erreur: Error {
        case illisible
    }

    private let dossier: URL
    private var fichier: URL { dossier.appending(path: "Correction.json") }

    init(dossier: URL) {
        self.dossier = dossier
    }

    func lire() throws -> BrouillonCorrection? {
        let donnees: Data
        do {
            donnees = try Data(contentsOf: fichier)
        } catch let erreur as CocoaError where erreur.code == .fileReadNoSuchFile || erreur.code == .fileNoSuchFile {
            return nil
        }
        let document: Document
        do {
            document = try JSONDecoder().decode(Document.self, from: donnees)
        } catch {
            throw Erreur.illisible
        }
        guard document.versionSchema == 1 else { throw Erreur.illisible }
        return document.contenu
    }

    func ecrire(_ brouillon: BrouillonCorrection) throws {
        let donnees = try JSONEncoder().encode(Document(versionSchema: 1, contenu: brouillon))
        var dossier = dossier
        try FileManager.default.createDirectory(at: dossier, withIntermediateDirectories: true)
        var proprietes = URLResourceValues()
        proprietes.isExcludedFromBackup = true
        try dossier.setResourceValues(proprietes)
        try donnees.write(to: fichier, options: .atomic)
    }

    func effacer() throws {
        do {
            try FileManager.default.removeItem(at: fichier)
        } catch let erreur as CocoaError where erreur.code == .fileNoSuchFile {
            return
        }
    }
}

@MainActor
@Observable
final class SuiviBrouillonCorrection {
    private let magasin: MagasinBrouillonCorrection
    private var attente: Task<Void, Never>?
    private var derniereOperation: Task<Void, any Error>?
    private var courant: BrouillonCorrection?
    private var aEcrire: BrouillonCorrection?
    #if DEBUG
        private static let observerEcriture = ProcessInfo.processInfo.arguments.contains("-test-observer-brouillon")
        private var nombreEcritPourEssai: String?
    #endif

    private(set) var erreurEcriture = false
    var aUnBrouillon: Bool { aEcrire != nil || courant != nil || erreurEcriture }

    init(dossier: URL? = nil) {
        magasin = MagasinBrouillonCorrection(
            dossier: (dossier ?? URL.applicationSupportDirectory).appending(path: "Brouillons"))
    }

    func lire() async throws -> BrouillonCorrection? {
        let brouillon = try await magasin.lire()
        courant = brouillon
        return brouillon
    }

    func programmer(_ brouillon: BrouillonCorrection) {
        guard brouillon != courant || aEcrire != nil || erreurEcriture else { return }
        aEcrire = brouillon
        guard attente == nil else { return }
        let horloge = ContinuousClock()
        let echeance = horloge.now + .milliseconds(150)
        attente = Task { [weak self] in
            do {
                try await horloge.sleep(until: echeance, tolerance: .zero)
            } catch {
                return
            }
            guard let self, let aEcrire else { return }
            await constater(planifier(aEcrire))
        }
    }

    func forcer(_ brouillon: BrouillonCorrection) async throws {
        let operation = planifier(brouillon)
        await constater(operation)
        try await operation.value
    }

    func enArrierePlan(_ brouillon: BrouillonCorrection) {
        guard brouillon != courant || aEcrire != nil || erreurEcriture || derniereOperation != nil else { return }
        let operation = planifier(brouillon)
        var id = UIBackgroundTaskIdentifier.invalid
        func terminer() {
            guard id != .invalid else { return }
            UIApplication.shared.endBackgroundTask(id)
            id = .invalid
        }
        id = UIApplication.shared.beginBackgroundTask(withName: "Brouillon de correction", expirationHandler: terminer)
        Task {
            await constater(operation)
            terminer()
        }
    }

    func effacer() async throws {
        let operation = planifier(nil)
        await constater(operation)
        try await operation.value
    }

    private func planifier(_ brouillon: BrouillonCorrection?) -> Task<Void, any Error> {
        attente?.cancel()
        attente = nil
        aEcrire = nil
        let precedente = derniereOperation
        let operation = Task {
            _ = await precedente?.result
            if let brouillon {
                try await magasin.ecrire(brouillon)
            } else {
                try await magasin.effacer()
            }
        }
        derniereOperation = operation
        courant = brouillon
        return operation
    }

    private func constater(_ operation: Task<Void, any Error>) async {
        let resultat = await operation.result
        guard operation == derniereOperation else { return }
        derniereOperation = nil
        do {
            try resultat.get()
            erreurEcriture = false
            #if DEBUG
                if Self.observerEcriture {
                    nombreEcritPourEssai =
                        switch courant {
                        case .recette(_, let formulaire, _): formulaire.portions
                        case .message(let formulaire): formulaire.edition?.saisie.texte
                        case nil: nil
                        }
                }
            #endif
        } catch {
            Logger(subsystem: "xyz.g1lom.persillade", category: "Brouillon")
                .error("Écriture du brouillon impossible : \(String(describing: error), privacy: .private)")
            erreurEcriture = true
        }
    }
}

#if DEBUG
    extension SuiviBrouillonCorrection {
        @ViewBuilder var temoinEcriturePourEssai: some View {
            if Self.observerEcriture, let nombreEcritPourEssai {
                Text("Brouillon écrit \(nombreEcritPourEssai)")
                    .font(.caption2)
                    .padding(4)
                    .background(.thinMaterial)
                    .accessibilityIdentifier("brouillon-ecrit")
                    .allowsHitTesting(false)
            }
        }
    }
#endif
