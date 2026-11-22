import PersilladeCore
import SwiftUI
import UIKit

struct OngletCourses: View {
    private enum Feuille: Identifiable {
        case ajout, message, destination, acces, rapport
        case detail(UUID)

        var id: String {
            switch self {
            case .ajout: "ajout"
            case .message: "message"
            case .destination: "destination"
            case .acces: "acces"
            case .rapport: "rapport"
            case .detail(let id): id.uuidString
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.openURL) private var ouvrirURL
    @State private var feuille: Feuille?
    @State private var rapport: RapportEnvoi?
    @State private var retirer: LigneCourses?
    @State private var confirmerNouvelleListe = false
    @State private var rappelsInchanges = false
    @State private var envoiEnCours = false

    let session: SessionCourses
    let reglages: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let etat = session.etat {
                    liste(etat)
                } else if session.occupee {
                    ProgressView("Lecture de la liste")
                } else {
                    ContentUnavailableView {
                        Label("Liste indisponible", systemImage: "basket")
                    } actions: {
                        Button("Réessayer") { Task { await session.actualiser() } }
                    }
                }
            }
            .background(CouleurPersillade.page.couleur)
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Réglages", systemImage: "gear", action: reglages)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Plus d’options", systemImage: "ellipsis") {
                        Button("Nouvelle liste", systemImage: "plus.rectangle") { nouvelleListe() }
                            .disabled(session.occupee || session.etat == nil)
                        Button("Ouvrir Rappels", systemImage: "checklist", action: ouvrirRappels)
                        Button("Remettre les articles exclus", systemImage: "plus.circle", action: remettreExclus)
                            .disabled(session.occupee || session.etat?.liste.lignes.contains(where: \.cochee) != true)
                    }
                }
            }
            .confirmationDialog("Remplacer la liste ?", isPresented: $confirmerNouvelleListe, titleVisibility: .visible)
            {
                Button("Remplacer", role: .destructive) { nouvelleListe(confirmee: true) }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text(
                    "Les \(session.etat?.liste.lignes.count ?? 0) lignes seront perdues dans Persillade. Rappels ne change pas."
                )
            }
            .confirmationDialog(
                "Retirer « \(retirer?.libelle ?? "") » ?",
                isPresented: Binding(get: { retirer != nil }, set: { if !$0 { retirer = nil } }),
                titleVisibility: .visible, presenting: retirer
            ) { ligne in
                Button("Retirer", role: .destructive) { retirerLigne(ligne.id) }
                Button("Annuler", role: .cancel) {}
            } message: { _ in
                Text("Rappels ne change pas.")
            }
            .alert("Rappels ne change pas", isPresented: $rappelsInchanges) {
                Button("OK", role: .cancel) {}
            }
            .sheet(item: $feuille) { choix in
                switch choix {
                case .ajout:
                    AjoutArticleCourses(session: session)
                case .message:
                    ArticlesMessageCourses(session: session)
                case .destination:
                    choixRappels
                case .acces:
                    FeuilleCourses("Accès à Rappels") { AccesRappels() }.presentationDetents([.medium, .large])
                case .rapport:
                    if let rapport {
                        FeuilleCourses("Rapport d’envoi") {
                            BilanEnvoiCourses(
                                rapport: rapport, session: session, envoiEnCours: envoiEnCours,
                                terminer: { feuille = nil },
                                reessayer: {
                                    envoyer(rapport.echecs.isEmpty ? nil : rapport.echecs.map(\.ligneId))
                                },
                                choisir: {
                                    feuille = nil
                                    preparerDestinations()
                                },
                                nouvelleListe: {
                                    feuille = nil
                                    nouvelleListe()
                                },
                                ouvrirRappels: ouvrirRappels)
                        }
                        .presentationDetents([.large])
                        .interactiveDismissDisabled(envoiEnCours)
                    }
                case .detail(let id):
                    DetailArticleCourses(id: id, session: session)
                }
            }
        }
        .task { await session.actualiser(semaine: true) }
    }

    private func liste(_ etat: EtatCourses) -> some View {
        List {
            if etat.liste.envoyee {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Au magasin, cochez dans Rappels.").typographie(.texte)
                    Button("Ouvrir Rappels", systemImage: "arrow.up.forward", action: ouvrirRappels)
                        .buttonStyle(.borderless)
                }
                .listRowBackground(CouleurPersillade.page2.couleur)
            }
            if etat.liste.lignes.isEmpty {
                EtatVide(
                    titre: "Pas encore de liste.",
                    message: "Elle se remplit avec les recettes de la semaine, un message ou un ajout."
                ) {
                    EmptyView()
                } actions: {
                    ActionPrincipaleCourses("Ajouter un article") { feuille = .ajout }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            ForEach(etat.liste.rayons, id: \.categorie) { rayon in
                Section {
                    ForEach(rayon.lignes) { ligne in
                        ligneCourses(ligne, etat: etat)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .swipeActions {
                                Button("Retirer", systemImage: "trash", role: .destructive) {
                                    demanderRetrait(ligne)
                                }
                                .disabled(session.occupee)
                            }
                            .accessibilityAction(named: "Retirer") { demanderRetrait(ligne) }
                            .accessibilityAction(named: "Détail") { feuille = .detail(ligne.id) }
                    }
                } header: {
                    BandeauRayon(categorie: rayon.categorie, nombre: rayon.lignes.count)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .barreAction { barre(etat) }
        .sensoryFeedback(.impact(weight: .light), trigger: etat.liste.lignes.filter(\.cochee).map(\.id))
    }

    private func ligneCourses(_ ligne: LigneCourses, etat: EtatCourses) -> some View {
        let quantite = PresentationQuantite(ligne: ligne)
        let statut = PresentationEnvoi(etat: etat, ligne: ligne)
        return VStack(alignment: .leading, spacing: 0) {
            LigneArticle(
                nom: ligne.libelle, quantite: quantite.nombre, unite: quantite.unite, exclu: ligne.cochee,
                ouvrir: { feuille = .detail(ligne.id) },
                basculerExclusion: { exclure(ligne) })
            if !ligne.cochee, etat.liste.envoyee || statut.echec {
                statut.marque
                    .padding(.horizontal, GrillePersillade.marge)
                    .padding(.vertical, GrillePersillade.pas)
            }
        }
        .disabled(session.occupee)
        .background(CouleurPersillade.page.couleur)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("article-\(ligne.nomNormalise)")
    }

    private func barre(_ etat: EtatCourses) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                menuAjout
                choixOuEnvoi(etat)
            }
            .fixedSize(horizontal: true, vertical: false)
            VStack(alignment: .leading, spacing: 4) {
                menuAjout
                choixOuEnvoi(etat)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .disabled(session.occupee)
    }

    private var menuAjout: some View {
        Menu {
            Button("Ajouter un article", systemImage: "plus") { feuille = .ajout }
            Button("Articles d’un message", systemImage: "text.bubble") { feuille = .message }
        } label: {
            Image(systemName: "plus").frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(.glass)
        .accessibilityLabel("Ajouter")
        .accessibilityShowsLargeContentViewer { Label("Ajouter", systemImage: "plus") }
    }

    @ViewBuilder
    private func choixOuEnvoi(_ etat: EtatCourses) -> some View {
        if etat.destinationId != nil {
            Button {
                preparerDestinations()
            } label: {
                let symbole = etat.destinationVerrouillee ? "lock.fill" : "checklist"
                if taille.isAccessibilitySize || session.destination == nil {
                    Image(systemName: symbole).frame(minWidth: 44, minHeight: 44)
                } else {
                    Label(session.destination?.titre ?? "Liste Rappels", systemImage: symbole)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .disabled(etat.destinationVerrouillee)
            .accessibilityLabel(etat.destinationVerrouillee ? "Liste Rappels verrouillée" : "Liste Rappels")
            .accessibilityShowsLargeContentViewer { Label("Liste Rappels", systemImage: "checklist") }
        }
        if envoiEnCours {
            ProgressView("Envoi vers Rappels", value: session.progressionEnvoi ?? 0)
        } else if etat.destinationId == nil {
            ActionPrincipaleCourses("Choisir une liste") { preparerDestinations() }
        } else if etat.liste.envoyee {
            ActionPrincipaleCourses("Renvoyer") { envoyer() }.accessibilityIdentifier("courses-renvoyer")
        } else {
            ActionPrincipaleCourses("Envoyer \(etat.liste.lignesAEnvoyer.count)") { envoyer() }
                .disabled(etat.liste.lignesAEnvoyer.isEmpty)
                .accessibilityIdentifier("courses-envoyer")
        }
    }

    private var choixRappels: some View {
        FeuilleCourses("Liste Rappels") {
            List {
                Section {
                    if session.destinations.isEmpty {
                        Text("Aucune liste Rappels disponible.")
                    }
                    ForEach(session.destinations) { destination in
                        Button {
                            Task {
                                await session.effectuer("Impossible de choisir cette liste. Réessayez.") {
                                    try await session.choisirDestination(destination.id)
                                    feuille = nil
                                }
                            }
                        } label: {
                            Label {
                                VStack(alignment: .leading) {
                                    Text(destination.titre)
                                    Text(
                                        destination.modifiable
                                            ? destination.compte : "\(destination.compte) · Lecture seule"
                                    )
                                    .typographie(.precision).foregroundStyle(CouleurPersillade.encre2.couleur)
                                }
                            } icon: {
                                Image(
                                    systemName: session.etat?.destinationId == destination.id
                                        ? "checkmark.circle.fill" : "checklist")
                            }
                        }
                        .disabled(!destination.modifiable || session.occupee)
                    }
                } footer: {
                    Text("La liste est fixée dès le premier article envoyé.")
                }
            }
            .erreurCourses(session)
        }
        .presentationDetents([.medium, .large])
    }

    private func preparerDestinations() {
        Task {
            await session.effectuer("Impossible de lire les listes Rappels. Réessayez.") {
                do {
                    try await session.chargerDestinations()
                    feuille = .destination
                } catch CauseEchecEnvoi.accesRefuse {
                    feuille = .acces
                }
            }
        }
    }

    private func envoyer(_ ids: [UUID]? = nil) {
        Task {
            await session.effectuer("L’envoi a été interrompu. Réessayez depuis la liste de courses.") {
                envoiEnCours = true
                defer { envoiEnCours = false }
                rapport = try await session.envoyer(ids)
                feuille = .rapport
            }
        }
    }

    private func nouvelleListe(confirmee: Bool = false) {
        Task {
            await session.effectuer("Impossible de commencer une nouvelle liste. Réessayez.") {
                let resultat = try await session.envoi.modifier { liste, _ in liste.nouvelleListe(confirmee: confirmee)
                }
                try await session.relire()
                if case .confirmationRequise = resultat { confirmerNouvelleListe = true }
            }
        }
    }

    private func exclure(_ ligne: LigneCourses) {
        Task {
            await session.effectuer("Impossible de modifier l’exclusion. Réessayez.") {
                let avertir = !ligne.cochee && session.etat?.liste.envoyee == true
                try await session.envoi.modifier { liste, _ in try liste.cocher(ligne.id, cochee: !ligne.cochee) }
                try await session.relire()
                rappelsInchanges = avertir
            }
        }
    }

    private func remettreExclus() {
        Task {
            await session.effectuer("Impossible de remettre les articles exclus. Réessayez.") {
                try await session.envoi.modifier { liste, _ in
                    for ligne in liste.lignes where ligne.cochee { try liste.cocher(ligne.id, cochee: false) }
                }
                try await session.relire()
            }
        }
    }

    private func demanderRetrait(_ ligne: LigneCourses) {
        if session.etat?.liste.envoyee == true {
            retirer = ligne
        } else {
            retirerLigne(ligne.id)
        }
    }

    private func retirerLigne(_ id: UUID) {
        Task {
            await session.effectuer("Impossible de retirer cet article. Réessayez.") {
                _ = try await session.envoi.modifier { liste, _ in try liste.retirer(id) }
                try await session.relire()
            }
        }
    }

    private func ouvrirRappels() {
        if let url = URL(string: "x-apple-reminderkit://") {
            ouvrirURL(url) { ouvert in
                if !ouvert { session.erreur = "Ouvrez l’app Rappels pour voir la liste." }
            }
        }
    }
}
