import PersilladeCore
import SwiftUI

struct ArticlesMessageCourses: View {
    private struct Proposition: Identifiable {
        let id = UUID()
        var nom: String
        var quantite: Quantite?
        var unite: Unite?
        var exclue = false
        var texteNonCompris: String?

        var article: ArticleCourses? { try? ArticleCourses(nom: nom, quantite: quantite, unite: unite) }
    }

    @Environment(\.dismiss) private var fermer
    @State private var contenu: ContenuRecu?
    @State private var saisie = ""
    @State private var resultat: ResultatExtraction?
    @State private var propositions: [Proposition] = []
    @State private var edition: UUID?
    @State private var extraireEnCours = false
    @State private var lireMessage = false
    @State private var confirmerIntegration = false
    @State private var integre = false
    @State private var receptionRetiree = false
    @State private var rapport: RapportEnvoi?
    @State private var aEnvoyer: [UUID] = []
    @State private var exclus: [UUID] = []
    @State private var confirmerRemise = false

    let session: SessionCourses
    let extracteur: Extracteur
    private let retirerReception: (() async throws -> Void)?

    init(
        session: SessionCourses, contenu: ContenuRecu? = nil, extracteur: Extracteur,
        retirerReception: (() async throws -> Void)? = nil
    ) {
        self.session = session
        self.extracteur = extracteur
        _contenu = State(initialValue: contenu)
        self.retirerReception = retirerReception
    }

    var body: some View {
        FeuilleCourses("Articles d’un message") {
            Group {
                if let rapport {
                    BilanEnvoiCourses(
                        rapport: rapport, session: session, envoiEnCours: session.occupee,
                        terminer: terminer,
                        reessayer: { envoyer(rapport.echecs.map(\.ligneId)) })
                } else if integre {
                    ContentUnavailableView {
                        Label("Articles ajoutés", systemImage: "checkmark.circle")
                    } actions: {
                        if !aEnvoyer.isEmpty {
                            Button("Réessayer l’envoi") { envoyer(aEnvoyer) }
                        }
                        Button("Terminé", action: terminer)
                    }
                } else if let resultat {
                    validation(resultat)
                } else if contenu != nil {
                    if extraireEnCours {
                        ProgressView("Lecture du message")
                    } else {
                        Button("Lire le message") { lireMessage = true }
                    }
                } else {
                    Form {
                        TextField("Collez le texte du message", text: $saisie, axis: .vertical)
                            .lineLimit(4...10)
                        Button("Lire le message") {
                            contenu = ContenuRecu(type: .texte, contenu: Data(saisie.utf8), origine: .pressePapiers)
                            lireMessage = true
                        }
                        .disabled(saisie.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .task { if contenu != nil && resultat == nil && !integre { lireMessage = true } }
            .task(id: lireMessage) {
                if lireMessage, let contenu { await extraire(contenu) }
            }
            .confirmationDialog(
                "Cette liste est déjà dans Rappels.", isPresented: $confirmerIntegration, titleVisibility: .visible
            ) {
                Button("Compléter cette liste") { integrer(.completer) }
                Button("Nouvelle liste", role: .destructive) { integrer(.nouvelleListe) }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text(
                    "Compléter garde ses articles. Une nouvelle liste efface ses \(session.etat?.liste.lignes.count ?? 0) lignes dans Persillade. Rappels ne change pas."
                )
            }
            .confirmationDialog(
                "Remettre les articles exclus ?", isPresented: $confirmerRemise, titleVisibility: .visible
            ) {
                Button("Remettre", action: remettre)
                Button("Annuler", role: .cancel) {}
            } message: {
                let noms = exclus.compactMap { session.etat?.liste.ligne(id: $0)?.libelle }.joined(separator: ", ")
                Text("Articles exclus de l’envoi. \(noms).")
            }
            .erreurCourses(session)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(session.occupee)
    }

    private var articles: [ArticleCourses] {
        propositions.filter { !$0.exclue }.compactMap(\.article)
    }

    private func validation(_ resultat: ResultatExtraction) -> some View {
        List {
            DisclosureGroup("Texte reçu") {
                Text(resultat.texteSource).textSelection(.enabled)
            }
            if let cause = resultat.cause {
                Text(explication(cause)).typographie(.precision)
                    .foregroundStyle(CouleurPersillade.beurreTexte.couleur)
            }
            ForEach(propositions) { proposition in
                let rayon = categorieParDefaut(normaliserNom(proposition.nom))
                let nom =
                    proposition.nom.isEmpty ? proposition.texteNonCompris ?? "Article à préciser" : proposition.nom
                LigneArticle(
                    nom: nom, quantite: proposition.quantite?.texteFrancais,
                    unite: proposition.unite?.libellePersillade,
                    precision: proposition.article == nil
                        ? "Corriger · Cette ligne ne sera pas ajoutée." : rayon.rawValue,
                    exclu: proposition.exclue,
                    ouvrir: { edition = proposition.id },
                    basculerExclusion: {
                        if let index = propositions.firstIndex(where: { $0.id == proposition.id }) {
                            propositions[index].exclue.toggle()
                        }
                    }
                )
                .listRowInsets(EdgeInsets())
            }
            Button("Ajouter une ligne", systemImage: "plus") {
                let nouvelle = Proposition(nom: "", quantite: nil, unite: nil)
                propositions.append(nouvelle)
                edition = nouvelle.id
            }
        }
        .listStyle(.plain)
        .barreAction {
            ActionPrincipaleCourses(articles.count == 1 ? "Ajouter 1 article" : "Ajouter \(articles.count) articles") {
                integrer()
            }
            .disabled(articles.isEmpty || session.occupee)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
        .sheet(
            isPresented: Binding(get: { edition != nil }, set: { if !$0 { edition = nil } })
        ) {
            if let edition, let index = propositions.firstIndex(where: { $0.id == edition }) {
                modifier($propositions[index])
            }
        }
    }

    private func modifier(_ proposition: Binding<Proposition>) -> some View {
        FeuilleCourses("Corriger l’article") {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Nom de l’article", text: proposition.nom)
                        .textFieldStyle(.roundedBorder)
                    EditeurQuantite(quantite: proposition.wrappedValue.quantite, unite: proposition.wrappedValue.unite)
                    {
                        valeur, unite in
                        proposition.wrappedValue.quantite = valeur
                        proposition.wrappedValue.unite = unite
                        edition = nil
                    }
                }
                .padding()
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func extraire(_ contenu: ContenuRecu) async {
        extraireEnCours = true
        defer {
            extraireEnCours = false
            lireMessage = false
        }
        do {
            let extraction = try await extracteur.extraire(contenu, cible: .message)
            try Task.checkCancellation()
            resultat = extraction
            propositions = extraction.articles.map {
                Proposition(nom: $0.nom, quantite: $0.quantite, unite: $0.unite)
            }
            if extraction.moteur == .manuel {
                let incomprises: [Proposition] = extraction.texteSource.split(whereSeparator: \.isNewline).compactMap {
                    ligne in
                    let texte = String(ligne).trimmingCharacters(in: .whitespaces)
                    guard !texte.isEmpty, AnalyseIngredient.analyser(texte).ligneNonComprise else { return nil }
                    return Proposition(nom: "", quantite: nil, unite: nil, texteNonCompris: texte)
                }
                propositions.append(contentsOf: incomprises)
            }
        } catch is CancellationError {
            return
        } catch {
            session.erreur = "La lecture du message a échoué. Le texte est conservé."
        }
    }

    private func integrer(_ choix: ListeCourses.ChoixIntegration? = nil) {
        guard let id = contenu?.id else { return }
        Task {
            await session.effectuer("Impossible d’ajouter les articles. Le message est conservé.") {
                let articles = articles
                let action: ListeCourses.Resultat
                do {
                    action = try await session.envoi.modifier { liste, _ in
                        try liste.integrer(articles, messageId: id, choix: choix)
                    }
                } catch ListeCourses.Erreur.messageDejaIntegre {
                    integre = true
                    session.erreur = "Les articles de ce message ont déjà été ajoutés."
                    await retirerApresIntegration()
                    return
                }
                guard case .applique(let effets) = action else {
                    confirmerIntegration = true
                    return
                }
                integre = true
                aEnvoyer = effets.lignesAEnvoyer
                exclus = effets.decochagePropose
                do {
                    try await session.relire()
                    if !exclus.isEmpty { confirmerRemise = true }
                } catch {
                    session.signaler("Les articles sont ajoutés. Impossible de relire les courses.", erreur: error)
                }
                await retirerApresIntegration()
                if !aEnvoyer.isEmpty { await envoyerArticlesIntegres(aEnvoyer) }
            }
        }
    }

    private func retirerApresIntegration() async {
        do {
            try await retirerContenuRecu()
        } catch {
            session.signaler("Les articles sont ajoutés. Le message reste dans la file de réception.", erreur: error)
        }
    }

    private func remettre() {
        Task {
            await session.effectuer("Impossible de remettre ces articles. Réessayez.") {
                let ids = exclus
                let envoyer = try await session.envoi.modifier { liste, _ in
                    for id in ids { try liste.cocher(id, cochee: false) }
                    return liste.envoyee
                }
                try await session.relire()
                if envoyer {
                    let reste = Set(ids + aEnvoyer + (rapport?.echecs.map(\.ligneId) ?? []))
                    await envoyerArticlesIntegres(Array(reste))
                }
            }
        }
    }

    private func envoyer(_ ids: [UUID]) {
        Task {
            await session.effectuer("L’envoi des articles a été interrompu. Réessayez.") {
                await envoyerArticlesIntegres(ids)
            }
        }
    }

    private func envoyerArticlesIntegres(_ ids: [UUID]) async {
        aEnvoyer = ids
        do {
            rapport = try await session.envoyer(ids)
            aEnvoyer = []
        } catch {
            rapport = nil
            session.signaler("Les articles sont ajoutés. Leur envoi a été interrompu.", erreur: error)
        }
    }

    private func terminer() {
        Task {
            await session.effectuer("Les articles sont ajoutés. Le message reste dans la file de réception.") {
                try await retirerContenuRecu()
                fermer()
            }
        }
    }

    private func retirerContenuRecu() async throws {
        if !receptionRetiree, let retirerReception {
            try await retirerReception()
            receptionRetiree = true
        }
    }

    private func explication(_ cause: CauseExtraction) -> String {
        switch cause {
        case .iaIndisponible: "Apple Intelligence est indisponible. Vérifiez les propositions lues ligne par ligne."
        case .iaEnErreur, .fournisseurEnErreur:
            "La lecture s’est interrompue. Vérifiez les propositions lues ligne par ligne."
        case .contenuTropLong: "Le texte est trop long. Vérifiez les propositions et ajoutez les articles manquants."
        case .horsLigne: "L’iPhone est hors ligne."
        case .pageInaccessible, .delai: "Le lien ne répond pas. Vous pouvez saisir les articles."
        case .rienTrouve: "Aucun article trouvé. Vous pouvez les saisir."
        }
    }
}
