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
        case articles(ContenuRecu?, FormulaireMessage? = nil, integre: Bool = false)
        case photo(SourcePhoto)
        case correction(DonneesCorrection, repris: Bool = false, enregistree: Bool = false)
        case reglages

        var id: String {
            switch self {
            case .importation: "importation"
            case .articles: "articles"
            case .photo: "photo"
            case .correction(let donnees, _, _): donnees.contexte.id.uuidString
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
    @State private var suivi: SuiviBrouillonCorrection
    @State private var brouillonCharge = false
    @State private var erreurReprise: String?
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
                    let memoire = MagasinRappelsMemoire(destinations: [
                        .init(id: "maison", titre: "Maison", compte: "Sur mon iPhone", modifiable: true),
                        .init(id: "archive", titre: "Archives", compte: "Sur mon iPhone", modifiable: false),
                    ])
                    if processus.arguments.contains("-courses-envoi-echec") {
                        rappels = RappelsAvecEchecsPonctuels(memoire: memoire, titres: ["œufs 4", "farine 1,5 kg"])
                    } else if processus.arguments.contains("-courses-envoi-echec-partiel") {
                        rappels = RappelsAvecEchecsPonctuels(memoire: memoire, titres: ["farine 1,5 kg"])
                    } else {
                        rappels = memoire
                    }
                }
            }
        #endif
        let bibliotheque = BibliothequeRecettes(dossier: dossier, rappels: rappels)
        _suivi = State(initialValue: SuiviBrouillonCorrection(dossier: dossier))
        _reception = State(initialValue: ReceptionEntree(dossier: dossier))
        _bibliotheque = State(initialValue: bibliotheque)
        _courses = State(
            initialValue: SessionCourses(bibliotheque: bibliotheque, preferences: dossier == nil ? .standard : nil))
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
                OngletCourses(
                    session: courses, reglages: { feuille = .reglages }, importerMessage: { feuille = .articles(nil) }
                )
                .erreurCourses(courses)
            }
            Tab(value: .recherche, role: .search) {
                recettes(chemin: $cheminRecherche, recherche: true)
            }
        }
        .disabled(!brouillonCharge)
        .tint(CouleurPersillade.persil.couleur)
        .tabViewBottomAccessory(isEnabled: accessoireReceptionVisible) {
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
            guard !Task.isCancelled else { return }
            if !brouillonCharge {
                await reprendreBrouillon()
                guard !Task.isCancelled else { return }
                brouillonCharge = true
            }
            if feuille == nil && erreurReprise == nil { ouvrirPremier() }
            await actualiserCourses()
        }
        .sheet(item: $feuille, onDismiss: apresFermeture) { contenu in
            contenuFeuille(contenu)
                .environment(\.dynamicTypeSize, taille)
                .tint(CouleurPersillade.persil.couleur)
        }
        .environment(suivi)
        .alert(
            "Brouillon de correction",
            isPresented: Binding(get: { erreurReprise != nil }, set: { if !$0 { erreurReprise = nil } }),
            presenting: erreurReprise
        ) { _ in
            Button("OK", action: ouvrirPremier)
        } message: { message in
            Text(message)
        }
        .alert(
            bibliotheque.erreur ?? "",
            isPresented: Binding(
                get: { bibliotheque.erreur != nil }, set: { if !$0 { bibliotheque.erreur = nil } })
        ) {
            if !bibliotheque.selectionDisponible {
                Button("Réessayer") { Task { await actualiserCourses() } }
            }
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder private func contenuFeuille(_ contenu: Feuille) -> some View {
        switch contenu {
        case .importation(let recu):
            ParcoursImport(
                initial: recu, reception: reception, bibliotheque: bibliotheque, extracteur: extracteur,
                repliConsenti: repliConsenti, fermer: { feuille = nil }, terminer: finImport,
                importerArticles: { feuille = .articles($0) })
        case .articles(let recu, let brouillon, let integre):
            ArticlesMessageCourses(
                session: courses, contenu: recu, extracteur: extracteur, reception: reception, brouillon: brouillon,
                integre: integre
            ) {
                traiterSuivant = true
                onglet = .courses
            }
        case .photo(let source):
            ParcoursImport(
                initial: nil, reception: reception, bibliotheque: bibliotheque, extracteur: extracteur,
                repliConsenti: repliConsenti, fermer: { feuille = nil }, terminer: finImport, sourcePhoto: source)
        case .correction(let donnees, let repris, let enregistree):
            let recu = reception.contenus.first { $0.id == donnees.contexte.sourceId }
            NavigationStack {
                CorrectionRecette(
                    donnees: donnees, photo: recu?.type == .image ? recu?.contenu : nil, repris: repris,
                    enregistree: enregistree,
                    fermer: { feuille = nil },
                    enregistrer: {
                        try await bibliotheque.enregistrer(
                            $0, modification: donnees.contexte.modification, echelle: echelle)
                    },
                    retirerSource: {
                        if let recu { try await reception.retirer(recu) }
                    },
                    terminer: { id in
                        if donnees.contexte.sourceId != nil {
                            finImport(id)
                        } else {
                            feuille = nil
                            if !donnees.contexte.modification { ouvrirFiche(id) }
                        }
                    })
            }
            .presentationDetents([.large])
            .presentationBackground(CouleurPersillade.page.couleur)
        case .reglages:
            Reglages()
        }
    }

    private var accessoireReceptionVisible: Bool {
        onglet == .recettes && chemin.isEmpty && feuille == nil && !reception.contenus.isEmpty
    }

    private func recettes(chemin: Binding<[UUID]>, recherche: Bool = false) -> some View {
        OngletRecettes(
            chemin: chemin, bibliotheque: bibliotheque, rechercheActive: recherche, messageReception: reception.message,
            accessoireReceptionVisible: !recherche && accessoireReceptionVisible,
            coller: { feuille = .importation(nil) }, ecrire: { feuille = .correction(.init()) },
            prendrePhoto: { feuille = .photo(.appareilPhoto) },
            choisirPhoto: { feuille = .photo(.phototheque) },
            reglages: { feuille = .reglages }, modifier: { feuille = .correction(.init(recette: $0)) })
    }

    private func reprendreBrouillon() async {
        let brouillon: BrouillonCorrection?
        do {
            brouillon = try await suivi.lire()
        } catch MagasinBrouillonCorrection.Erreur.illisible {
            if !Task.isCancelled {
                erreurReprise =
                    "Le brouillon est illisible. Le contenu reçu et les recettes enregistrées sont conservés."
            }
            return
        } catch {
            if !Task.isCancelled { erreurReprise = "Impossible de lire le brouillon. Réessayez en rouvrant l’app." }
            return
        }
        guard !Task.isCancelled, let brouillon else { return }
        switch brouillon {
        case .recette(let contexte, let formulaire, let validation):
            let recu = reception.contenus.first { $0.id == contexte.sourceId }
            var source =
                contexte.texteDerive
                ?? recu.flatMap { recu in
                    recu.type == .texte ? recu.texteRecu : reception.textesDeRepli[recu.id]
                }
            var enregistree: Recette?
            do {
                let recette = try await bibliotheque.lire(contexte.id)
                if contexte.modification { source = recette?.texteSource }
                let modifiee =
                    contexte.modification && validation
                    ? try source.map { try formulaire.valider(contexte, source: $0) } : nil
                if let recette, !contexte.modification || modifiee == recette {
                    enregistree = recette
                    source = recette.texteSource
                    try Task.checkCancellation()
                    if let recu { try await reception.retirer(recu) }
                    try await suivi.effacer()
                    if !contexte.modification { ouvrirFiche(recette.id) }
                    return
                }
            } catch {
                // La correction reste accessible si la bibliothèque ou le nettoyage échoue.
                if !Task.isCancelled, enregistree == nil {
                    bibliotheque.erreur = "Impossible de vérifier l’enregistrement de la recette."
                }
            }
            guard !Task.isCancelled else { return }
            if contexte.modification || contexte.sourceId != nil, source == nil {
                erreurReprise = "Impossible de retrouver la source de la correction. Le brouillon est conservé."
                return
            }
            let formulaireAffiche = enregistree.map { DonneesCorrection(recette: $0).formulaire } ?? formulaire
            feuille = .correction(
                .init(contexte: contexte, source: source ?? "", formulaire: formulaireAffiche),
                repris: true, enregistree: enregistree != nil)
        case .message(let formulaire):
            let recu = reception.contenus.first { $0.id == formulaire.sourceId }
            var integre = false
            do {
                let etat = try await courses.envoi.lire()
                integre = etat.liste.contientMessage(id: formulaire.sourceId)
                if integre {
                    try Task.checkCancellation()
                    if let recu { try await reception.retirer(recu) }
                    try await suivi.effacer()
                    onglet = .courses
                    return
                }
            } catch {
                if !Task.isCancelled {
                    let message =
                        integre
                        ? "Les articles sont ajoutés. Impossible de clôturer la validation."
                        : "Impossible de vérifier l’ajout du message."
                    courses.signaler(message, erreur: error)
                }
            }
            guard !Task.isCancelled else { return }
            onglet = .courses
            feuille = .articles(recu, formulaire, integre: integre)
        }
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

#if DEBUG
    private actor RappelsAvecEchecsPonctuels: MagasinRappels {
        let memoire: MagasinRappelsMemoire
        private var titres: Set<String>

        init(memoire: MagasinRappelsMemoire, titres: Set<String>) {
            self.memoire = memoire
            self.titres = titres
        }

        func destinations() async throws -> [DestinationRappels] {
            try await memoire.destinations()
        }

        func lire(destinationId: String) async throws -> [RappelCourses] {
            try await memoire.lire(destinationId: destinationId)
        }

        func ajouter(titre: String, destinationId: String) async throws -> RappelCourses {
            if titres.remove(titre) != nil { throw CauseEchecEnvoi.ecriture }
            return try await memoire.ajouter(titre: titre, destinationId: destinationId)
        }
    }
#endif
