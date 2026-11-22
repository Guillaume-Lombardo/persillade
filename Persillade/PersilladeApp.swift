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
                                apparenceEssai
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

        private var apparenceEssai: ColorScheme? {
            let arguments = ProcessInfo.processInfo.arguments
            return arguments.contains("-recettes-sombre") || arguments.contains("-courses-sombre") ? .dark : nil
        }

        private var tailleEssai: DynamicTypeSize {
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("-recettes-ax3") || arguments.contains("-courses-ax3") { return .accessibility3 }
            if arguments.contains("-recettes-ax5") || arguments.contains("-courses-ax5") { return .accessibility5 }
            return tailleSysteme
        }
    #endif
}

private struct Racine: View {
    private enum Onglet: Hashable { case recettes, semaine, courses, recherche }

    private enum Feuille: Identifiable {
        case importation(ContenuRecu?)
        case articles(ContenuRecu)
        case photo(SourcePhoto)
        case ecriture
        case modification(Recette)
        case reglages

        var id: String {
            switch self {
            case .importation: "importation"
            case .articles: "articles"
            case .photo: "photo"
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
    @State private var courses: SessionCourses
    private let extracteur: Extracteur
    private let repliConsenti: Extracteur.RepliConsenti?

    init() {
        var dossier: URL?
        var moteur: (any MoteurIA)? = MoteurFondation()
        var rappels: any MagasinRappels = MagasinRappelsEventKit()
        #if DEBUG
            let processus = ProcessInfo.processInfo
            if let nom = processus.environment["PERSILLADE_TEST_SESSION"], let id = UUID(uuidString: nom) {
                dossier = URL.temporaryDirectory.appending(path: id.uuidString)
                moteur = nil
            }
            if processus.arguments.contains("-courses-recettes") {
                let id = processus.environment["PERSILLADE_COURSES_SESSION"].flatMap(UUID.init(uuidString:)) ?? UUID()
                dossier = URL.temporaryDirectory.appending(path: "Courses-\(id.uuidString)")
                moteur = nil
                if !processus.arguments.contains("-courses-eventkit") {
                    rappels = MagasinRappelsMemoire(destinations: [
                        .init(id: "maison", titre: "Maison", compte: "Sur mon iPhone", modifiable: true),
                        .init(id: "archive", titre: "Archives", compte: "Sur mon iPhone", modifiable: false),
                    ])
                }
            }
        #endif
        let bibliotheque = BibliothequeRecettes(dossier: dossier, rappels: rappels)
        _reception = State(initialValue: ReceptionEntree(dossier: dossier))
        _bibliotheque = State(initialValue: bibliotheque)
        _courses = State(initialValue: SessionCourses(bibliotheque: bibliotheque))
        extracteur = Extracteur(
            telechargeur: TelechargeurURLSession(), moteurIA: moteur, lecteurImage: LecteurImageVision())
        repliConsenti = dossier == nil ? ReglagesFournisseur.partage.repliConsenti : nil
    }

    var body: some View {
        TabView(selection: $onglet) {
            Tab("Recettes", systemImage: "text.book.closed.fill", value: .recettes) {
                recettes(chemin: $chemin)
            }
            Tab("Semaine", systemImage: "calendar", value: .semaine) {
                OngletSemaine(
                    session: courses, voirRecettes: voirBibliotheque, voirCourses: { onglet = .courses },
                    reglages: { feuille = .reglages }, ouvrirFiche: ouvrirFiche
                )
                .erreurCourses(courses)
            }
            Tab("Courses", systemImage: "basket.fill", value: .courses) {
                OngletCourses(session: courses, reglages: { feuille = .reglages }, extracteur: extracteur)
                    .erreurCourses(courses)
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
            await actualiserCourses()
        }
        .sheet(item: $feuille, onDismiss: apresFermeture) { contenu in
            contenuFeuille(contenu)
                .environment(\.dynamicTypeSize, taille)
                .tint(CouleurPersillade.persil.couleur)
        }
        .alert(
            "Persillade",
            isPresented: Binding(
                get: { bibliotheque.erreur != nil }, set: { if !$0 { bibliotheque.erreur = nil } })
        ) {
            if !bibliotheque.selectionDisponible {
                Button("Réessayer") { Task { await actualiserCourses() } }
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
                repliConsenti: repliConsenti, fermer: { feuille = nil }, terminer: finImport,
                importerArticles: { feuille = .articles($0) })
        case .articles(let recu):
            ArticlesMessageCourses(session: courses, contenu: recu, extracteur: extracteur) {
                try await reception.retirer(recu)
                traiterSuivant = true
                onglet = .courses
            }
        case .photo(let source):
            ParcoursImport(
                initial: nil, reception: reception, bibliotheque: bibliotheque, extracteur: extracteur,
                repliConsenti: repliConsenti, fermer: { feuille = nil }, terminer: finImport, sourcePhoto: source)
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
            prendrePhoto: { feuille = .photo(.appareilPhoto) },
            choisirPhoto: { feuille = .photo(.phototheque) },
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

    private func voirBibliotheque() {
        chemin.removeAll()
        onglet = .recettes
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

    private func actualiserCourses() async {
        await courses.actualiser()
        if !bibliotheque.selectionDisponible, let erreur = courses.erreur {
            bibliotheque.erreur = erreur
            courses.erreur = nil
        }
    }
}
