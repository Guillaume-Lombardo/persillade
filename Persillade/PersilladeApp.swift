import PersilladeCore
import PersilladePlateforme
import SwiftUI
import UIKit

@main
struct PersilladeApp: App {
    var body: some Scene {
        WindowGroup {
            Group {
                #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-galerie") {
                        GalerieDesign()
                    } else {
                        Racine()
                            .preferredColorScheme(
                                ProcessInfo.processInfo.arguments.contains("-recettes-sombre") ? .dark : nil
                            )
                            .environment(\.dynamicTypeSize, tailleEssai)
                    }
                #else
                    Racine()
                #endif
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) {
                _ in Task { await RenduPlanche.partage.vider() }
            }
        }
    }

    #if DEBUG
        @Environment(\.dynamicTypeSize) private var tailleSysteme

        private var tailleEssai: DynamicTypeSize {
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("-recettes-ax3") { return .accessibility3 }
            if arguments.contains("-recettes-ax5") { return .accessibility5 }
            return tailleSysteme
        }
    #endif
}

private struct Racine: View {
    private enum Onglet: Hashable { case recettes, semaine, courses, recherche }

    private enum Feuille: Identifiable {
        case importation(ContenuRecu?)
        case ecriture
        case modification(Recette)
        case reglages

        var id: String {
            switch self {
            case .importation: "importation"
            case .ecriture: "ecriture"
            case .modification: "modification"
            case .reglages: "reglages"
            }
        }
    }

    @Environment(\.scenePhase) private var phase
    @Environment(\.displayScale) private var echelle
    @Environment(\.dynamicTypeSize) private var taille
    @State private var onglet = Onglet.recettes
    @State private var feuille: Feuille?
    @State private var traiterSuivant = false
    @State private var chemin: [UUID] = []
    @State private var cheminRecherche: [UUID] = []
    @State private var reception: ReceptionEntree
    @State private var bibliotheque: BibliothequeRecettes
    private let extracteur: Extracteur
    private let repliConsenti: Extracteur.RepliConsenti?

    init() {
        var dossier: URL?
        var moteur: (any MoteurIA)? = MoteurFondation()
        #if DEBUG
            let processus = ProcessInfo.processInfo
            if let nom = processus.environment["PERSILLADE_TEST_SESSION"], let id = UUID(uuidString: nom) {
                dossier = URL.temporaryDirectory.appending(path: id.uuidString)
                moteur = nil
            }
        #endif
        _reception = State(initialValue: ReceptionEntree(dossier: dossier))
        _bibliotheque = State(initialValue: BibliothequeRecettes(dossier: dossier))
        extracteur = Extracteur(telechargeur: TelechargeurURLSession(), moteurIA: moteur)
        repliConsenti = dossier == nil ? ReglagesFournisseur.partage.repliConsenti : nil
    }

    var body: some View {
        TabView(selection: $onglet) {
            Tab("Recettes", systemImage: "text.book.closed.fill", value: .recettes) {
                recettes(chemin: $chemin)
            }
            Tab("Semaine", systemImage: "calendar", value: .semaine) {
                ecran("Semaine", "Aucun repas prévu", icone: "calendar")
            }
            .badge(bibliotheque.selection.choix.count)
            Tab("Courses", systemImage: "basket.fill", value: .courses) {
                ecran("Courses", "Aucun article", icone: "basket")
            }
            Tab(value: .recherche, role: .search) {
                recettes(chemin: $cheminRecherche, recherche: true)
            }
        }
        .tint(CouleurPersillade.persil.couleur)
        .tabViewBottomAccessory(
            isEnabled: onglet == .recettes && chemin.isEmpty && feuille == nil && !reception.contenus.isEmpty
        ) {
            AccessoireReception(contenus: reception.contenus, ouvrir: ouvrirPremier)
        }
        .task(id: phase) {
            guard phase == .active else { return }
            #if DEBUG
                if ProcessInfo.processInfo.environment["PERSILLADE_TEST_SESSION"].flatMap(UUID.init(uuidString:))
                    != nil,
                    let texte = ProcessInfo.processInfo.environment["PERSILLADE_TEST_PRESSE_PAPIERS"]
                {
                    UIPasteboard.general.string = texte
                }
            #endif
            await reception.actualiser()
            if !Task.isCancelled, feuille == nil { ouvrirPremier() }
            await bibliotheque.actualiserSemaine()
        }
        .sheet(item: $feuille, onDismiss: apresFermeture) { contenu in
            contenuFeuille(contenu).environment(\.dynamicTypeSize, taille)
        }
        .alert(
            "Persillade",
            isPresented: Binding(
                get: { bibliotheque.erreur != nil }, set: { if !$0 { bibliotheque.erreur = nil } })
        ) {
            if !bibliotheque.selectionDisponible {
                Button("Réessayer") { Task { await bibliotheque.actualiserSemaine() } }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(bibliotheque.erreur ?? "")
        }
    }

    @ViewBuilder private func contenuFeuille(_ contenu: Feuille) -> some View {
        switch contenu {
        case .importation(let recu):
            ParcoursImport(
                initial: recu, reception: reception, bibliotheque: bibliotheque, extracteur: extracteur,
                repliConsenti: repliConsenti, fermer: { feuille = nil }, terminer: finImport)
        case .ecriture:
            NavigationStack {
                CorrectionRecette(
                    donnees: .init(), fermer: { feuille = nil }
                ) { recette in
                    try await bibliotheque.enregistrer(recette, modification: false, echelle: echelle)
                    feuille = nil
                    ouvrirFiche(recette.id)
                }
            }
            .presentationDetents([.large])
        case .modification(let recette):
            NavigationStack {
                CorrectionRecette(
                    donnees: .init(recette: recette), fermer: { feuille = nil }
                ) { modifiee in
                    try await bibliotheque.enregistrer(modifiee, modification: true, echelle: echelle)
                    feuille = nil
                }
            }
            .presentationDetents([.large])
        case .reglages:
            Reglages()
        }
    }

    private func recettes(chemin: Binding<[UUID]>, recherche: Bool = false) -> some View {
        OngletRecettes(
            chemin: chemin, bibliotheque: bibliotheque, rechercheActive: recherche, messageReception: reception.message,
            coller: { feuille = .importation(nil) }, ecrire: { feuille = .ecriture },
            reglages: { feuille = .reglages }, modifier: { feuille = .modification($0) })
    }

    private func ouvrirPremier() {
        if let premier = reception.contenus.first { feuille = .importation(premier) }
    }

    private func finImport(_ id: UUID?) {
        traiterSuivant = true
        feuille = nil
        if let id {
            onglet = .recettes
            ouvrirFiche(id)
        }
    }

    private func ouvrirFiche(_ id: UUID) {
        if onglet == .recherche {
            cheminRecherche = [id]
        } else {
            onglet = .recettes
            chemin = [id]
        }
    }

    private func apresFermeture() {
        guard traiterSuivant else { return }
        traiterSuivant = false
        ouvrirPremier()
    }

    private func ecran(_ titre: LocalizedStringKey, _ etat: LocalizedStringKey, icone: String) -> some View {
        NavigationStack {
            ContentUnavailableView(etat, systemImage: icone)
                .navigationTitle(titre)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Réglages", systemImage: "gear") { feuille = .reglages }
                    }
                }
        }
    }
}
