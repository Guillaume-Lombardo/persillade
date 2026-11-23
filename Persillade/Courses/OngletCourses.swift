import PersilladeCore
import SwiftUI
import UIKit

struct OngletCourses: View {
    private enum Feuille: Identifiable {
        case ajout, destination, acces, rapport
        case detail(UUID)

        var id: String {
            switch self {
            case .ajout: "ajout"
            case .destination: "destination"
            case .acces: "acces"
            case .rapport: "rapport"
            case .detail(let id): id.uuidString
            }
        }
    }

    @Environment(\.accessibilityReduceMotion) private var reduireAnimations
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
    let importerMessage: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let etat = session.etat {
                    liste(etat)
                } else if session.occupee {
                    ProgressView("Lecture de la liste")
                } else {
                    ScrollView {
                        EtatVide(
                            titre: "Liste indisponible.", message: "La liste de courses n’a pas pu être lue."
                        ) {
                            EmptyView()
                        } actions: {
                            BoutonActionPersillade("Réessayer", symbole: "arrow.clockwise") {
                                Task { await session.actualiser() }
                            }
                        }
                    }
                }
            }
            .background(CouleurPersillade.page.couleur)
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Plus d’options", systemImage: "ellipsis") {
                        Button("Nouvelle liste", systemImage: "plus.rectangle") { nouvelleListe() }
                            .disabled(session.occupee || session.etat == nil)
                        if session.etat?.liste.lignes.isEmpty == true {
                            Button("Articles d’un message", systemImage: "text.bubble", action: importerMessage)
                                .disabled(session.occupee)
                        }
                        Button("Ouvrir Rappels", systemImage: "checklist", action: ouvrirRappels)
                        Button("Remettre les articles exclus", systemImage: "plus.circle", action: remettreExclus)
                            .disabled(session.occupee || session.etat?.liste.lignes.contains(where: \.cochee) != true)
                        Button("Réglages", systemImage: "gear", action: reglages)
                    }
                }
            }
            .confirmationDialog("Remplacer la liste ?", isPresented: $confirmerNouvelleListe, titleVisibility: .visible)
            {
                Button("Remplacer", role: .destructive) { nouvelleListe(confirmee: true) }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text(
                    """
                    Les \(session.etat?.liste.lignes.count ?? 0) lignes seront perdues dans Persillade. \
                    Rappels ne change pas. Les articles déjà achetés seront redemandés.
                    """
                )
            }
            .confirmationDialog(
                "Retirer « \(retirer?.libelle.lowercased() ?? "") » ?",
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
                Group {
                    switch choix {
                    case .ajout:
                        AjoutArticleCourses(session: session)
                    case .destination:
                        choixRappels
                    case .acces:
                        FeuilleCourses("Accès à Rappels") { AccesRappels() }.presentationDetents(detentesFeuille)
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
                .environment(\.dynamicTypeSize, taille)
            }
        }
        .task { await session.actualiser() }
    }

    private var detentesFeuille: Set<PresentationDetent> {
        taille.isAccessibilitySize ? [.large] : [.medium, .large]
    }

    private func liste(_ etat: EtatCourses) -> some View {
        let statuts = Dictionary(
            uniqueKeysWithValues: etat.liste.lignesAEnvoyer.map {
                ($0.id, PresentationEnvoi(etat: etat, ligne: $0))
            })
        let toutTraite = statuts.values.allSatisfy(\.traitee)
        return List {
            if etat.liste.envoyee {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Au magasin, cochez dans Rappels.").typographie(.texte)
                    Button("Ouvrir Rappels", systemImage: "arrow.up.forward", action: ouvrirRappels)
                        .buttonStyle(.borderless)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(CouleurPersillade.page2.couleur)
            }
            if etat.liste.lignes.isEmpty {
                EtatVide(
                    titre: "Pas encore de liste.",
                    message: "Elle se remplit avec les recettes de la semaine, un message ou un ajout."
                ) {
                    EmptyView()
                } actions: {
                    EmptyView()
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            ForEach(etat.liste.rayons, id: \.categorie) { rayon in
                Section {
                    ForEach(rayon.lignes) { ligne in
                        let statut = statuts[ligne.id]
                        ligneCourses(
                            ligne, statut: statut,
                            afficherMarque: !toutTraite && (etat.liste.envoyee || statut?.echec == true)
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(CouleurPersillade.page.couleur)
                        .swipeActions {
                            Button("Retirer", systemImage: "trash", role: .destructive) {
                                demanderRetrait(ligne)
                            }
                            .disabled(session.occupee)
                        }
                        .allowsHitTesting(!session.occupee)
                    }
                } header: {
                    BandeauRayon(categorie: rayon.categorie, nombre: rayon.lignes.count)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(0)
        .contentMargins(.top, 0, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .barreAction(tailleMax: .accessibility5) { barre(etat) }
        .sensoryFeedback(.impact(weight: .light), trigger: etat.liste.lignes.filter(\.cochee).map(\.id))
    }

    private func ligneCourses(
        _ ligne: LigneCourses, statut: PresentationEnvoi?, afficherMarque: Bool
    ) -> some View {
        let quantite = PresentationQuantite(ligne: ligne)
        return LigneArticle(
            nom: ligne.libelle.lowercased(), quantite: quantite.nombre, unite: quantite.unite,
            precisionPleineLargeur: quantite.precision,
            exclu: ligne.cochee, marque: statut?.marque, afficherMarque: afficherMarque,
            ouvrir: { if !session.occupee { feuille = .detail(ligne.id) } },
            identifiantOuverture: "article-\(ligne.nomNormalise)",
            basculerExclusion: { exclure(ligne) },
            retirer: { if !session.occupee { demanderRetrait(ligne) } }
        )
        .animation(reduireAnimations ? nil : .easeInOut(duration: 0.2), value: ligne.cochee)
    }

    private func barre(_ etat: EtatCourses) -> some View {
        Group {
            if etat.liste.lignes.isEmpty {
                BoutonActionPersillade("Ajouter un article", symbole: "plus", pleineLargeur: true) { feuille = .ajout }
            } else {
                DispositionActionsCourses {
                    menuAjout
                    if etat.destinationId != nil {
                        destinationActuelle(etat)
                    }
                    actionEnvoi(etat)
                }
            }
        }
        .disabled(session.occupee)
    }

    private var menuAjout: some View {
        Menu {
            Button("Ajouter un article", systemImage: "plus") { feuille = .ajout }
            Button("Articles d’un message", systemImage: "text.bubble", action: importerMessage)
        } label: {
            Image(systemName: "plus")
                .font(.headline)
                .frame(width: 52, height: 52)
                .background(CouleurPersillade.page2.couleur, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ajouter")
        .accessibilityShowsLargeContentViewer { Label("Ajouter", systemImage: "plus") }
    }

    private func destinationActuelle(_ etat: EtatCourses) -> some View {
        let titre = session.destination?.titre ?? "Liste Rappels"
        let symbole = etat.destinationVerrouillee ? "lock.fill" : "checklist"
        let libelle = etat.destinationVerrouillee ? "Liste Rappels verrouillée" : "Liste Rappels"
        return Button(action: preparerDestinations) {
            LabelActionCourses(libelle: titre, symbole: symbole)
        }
        .buttonStyle(StyleBoutonPersillade())
        .accessibilityLabel(libelle)
        .accessibilityValue(titre)
        .accessibilityShowsLargeContentViewer { Label(titre, systemImage: symbole) }
        .disabled(etat.destinationVerrouillee)
    }

    private func actionEnvoi(_ etat: EtatCourses) -> some View {
        let choisir = etat.destinationId == nil
        let renvoyer = etat.liste.envoyee
        let libelle =
            choisir ? "Choisir une liste" : renvoyer ? "Renvoyer" : "Envoyer \(etat.liste.lignesAEnvoyer.count)"
        return BoutonActionPersillade(
            libelle, symbole: choisir ? "checklist" : renvoyer ? "arrow.clockwise" : "arrow.up",
            progression: envoiEnCours ? session.progressionEnvoi ?? 0 : nil, pleineLargeur: true
        ) {
            if choisir { preparerDestinations() } else { envoyer() }
        }
        .disabled(!choisir && !renvoyer && etat.liste.lignesAEnvoyer.isEmpty)
        .accessibilityIdentifier(renvoyer ? "courses-renvoyer" : "courses-envoyer", isEnabled: !choisir)
    }

    private var choixRappels: some View {
        FeuilleCourses("Liste Rappels") {
            List {
                Section {
                    if session.destinations.isEmpty {
                        EtatVide(titre: "Aucune liste Rappels disponible.", message: "Créez une liste dans Rappels.") {
                            EmptyView()
                        } actions: {
                            BoutonActionPersillade(
                                "Ouvrir Rappels", symbole: "arrow.up.forward.app", action: ouvrirRappels)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(CouleurPersillade.page.couleur)
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
                                        ? "checkmark.circle.fill" : "circle.fill"
                                )
                                .font(.footnote)
                                .foregroundStyle(
                                    destination.modifiable
                                        ? CouleurPersillade.persil.couleur : CouleurPersillade.encre2.couleur)
                            }
                            .foregroundStyle(
                                destination.modifiable
                                    ? CouleurPersillade.encre.couleur : CouleurPersillade.encre2.couleur
                            )
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                            .contentShape(.rect)
                        }
                        .buttonStyle(StyleBoutonPersillade())
                        .listRowBackground(CouleurPersillade.page.couleur)
                        .accessibilityIdentifier("destination-rappels-\(destination.id)")
                        .disabled(!destination.modifiable || session.occupee)
                    }
                } footer: {
                    Text("La liste est fixée dès le premier article envoyé.")
                        .typographie(.precision)
                        .foregroundStyle(CouleurPersillade.encre2.couleur)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(GrillePersillade.marge)
                        .background(CouleurPersillade.page2.couleur)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(0)
            .scrollContentBackground(.hidden)
            .erreurCourses(session)
        }
        .presentationDetents(detentesFeuille)
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
