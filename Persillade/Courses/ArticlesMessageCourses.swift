import PersilladeCore
import SwiftUI

struct FormulaireMessage: Codable, Equatable, Sendable {
    struct Proposition: Codable, Equatable, Identifiable, Sendable {
        var id = UUID()
        var nom: String
        var quantite: Quantite?
        var unite: Unite?
        var exclue = false
        var texteNonCompris: String?

        var article: ArticleCourses? { try? ArticleCourses(nom: nom, quantite: quantite, unite: unite) }
    }

    struct Edition: Codable, Equatable, Sendable {
        let id: UUID
        var saisie: SaisieQuantite
    }

    let sourceId: UUID
    let texte: String
    let cause: CauseExtraction?
    var propositions: [Proposition]
    var edition: Edition?
}

struct ArticlesMessageCourses: View {
    @Environment(SuiviBrouillonCorrection.self) private var suivi
    @Environment(\.scenePhase) private var phase
    @Environment(\.dismiss) private var fermer
    @Environment(\.dynamicTypeSize) private var taille
    @State private var contenu: ContenuRecu?
    @State private var saisie = ""
    @State private var formulaire: FormulaireMessage?
    @State private var confirmerAbandon = false
    @State private var clotureEnCours = false
    @State private var conserverSourceEnCours = false
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
    let reception: ReceptionEntree
    let receptionTraitee: () -> Void

    init(
        session: SessionCourses, contenu: ContenuRecu?, extracteur: Extracteur, reception: ReceptionEntree,
        brouillon: FormulaireMessage? = nil, receptionTraitee: @escaping () -> Void
    ) {
        self.session = session
        self.extracteur = extracteur
        self.reception = reception
        self.receptionTraitee = receptionTraitee
        _contenu = State(initialValue: contenu)
        _formulaire = State(initialValue: brouillon)
    }

    var body: some View {
        FeuilleCourses(
            "Articles d’un message", fermetureInterdite: session.occupee || clotureEnCours || conserverSourceEnCours,
            fermer: demanderFermeture
        ) {
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
                } else if let formulaire {
                    validation(formulaire)
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
                        Button("Lire le message", action: conserverSource)
                            .disabled(
                                conserverSourceEnCours || saisie.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            )
                    }
                }
            }
            .task { if contenu != nil && formulaire == nil && !integre { lireMessage = true } }
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
            .confirmationDialog("Abandonner la validation ?", isPresented: $confirmerAbandon, titleVisibility: .visible)
            {
                Button("Abandonner", role: .destructive, action: abandonner)
                Button("Continuer", role: .cancel) {}
            } message: {
                Text("Les corrections seront perdues. Le message est conservé.")
            }
            .erreurCourses(session)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(session.occupee || formulaire != nil || conserverSourceEnCours)
        .onChange(of: formulaire) { _, formulaire in
            if let formulaire, !integre, !clotureEnCours { suivi.programmer(.message(formulaire)) }
        }
        .onChange(of: phase) { _, phase in
            if let formulaire, phase != .active, !integre, !clotureEnCours {
                suivi.enArrierePlan(.message(formulaire))
            }
        }
    }

    private var articles: [ArticleCourses] {
        formulaire?.propositions.filter { !$0.exclue }.compactMap(\.article) ?? []
    }

    private func validation(_ brouillon: FormulaireMessage) -> some View {
        List {
            if suivi.erreurEcriture {
                Label("Impossible de garder le brouillon sur l’iPhone.", systemImage: "exclamationmark.circle")
                    .foregroundStyle(CouleurPersillade.tomate.couleur)
                Button("Réessayer") { suivi.programmer(.message(brouillon)) }
            }
            DisclosureGroup("Texte reçu") {
                Text(brouillon.texte).textSelection(.enabled)
            }
            if let cause = brouillon.cause {
                Text(explication(cause)).typographie(.precision)
                    .foregroundStyle(CouleurPersillade.beurreTexte.couleur)
            }
            ForEach(brouillon.propositions) { proposition in
                let rayon = categorieParDefaut(normaliserNom(proposition.nom))
                let nom =
                    proposition.nom.isEmpty ? proposition.texteNonCompris ?? "Article à préciser" : proposition.nom
                LigneArticle(
                    nom: nom, quantite: proposition.quantite?.texteFrancais,
                    unite: proposition.unite?.libelleLecturePersillade,
                    precision: proposition.article == nil
                        ? "Corriger · Cette ligne ne sera pas ajoutée." : rayon.rawValue,
                    exclu: proposition.exclue,
                    ouvrir: { ouvrirEdition(proposition) },
                    basculerExclusion: {
                        if let index = brouillon.propositions.firstIndex(where: { $0.id == proposition.id }) {
                            self.formulaire?.propositions[index].exclue.toggle()
                        }
                    }
                )
                .listRowInsets(EdgeInsets())
            }
            Button("Ajouter une ligne", systemImage: "plus") {
                let nouvelle = FormulaireMessage.Proposition(nom: "", quantite: nil, unite: nil)
                self.formulaire?.propositions.append(nouvelle)
                ouvrirEdition(nouvelle)
            }
        }
        .listStyle(.plain)
        .disabled(clotureEnCours || session.occupee)
        .barreAction(tailleMax: .accessibility5) {
            BoutonActionPersillade(
                articles.count == 1 ? "Ajouter 1 article" : "Ajouter \(articles.count) articles",
                symbole: "plus", action: { integrer() }
            )
            .disabled(articles.isEmpty || session.occupee)
        }
        .sheet(
            isPresented: Binding(
                get: { self.formulaire?.edition != nil },
                set: { if !$0 { self.formulaire?.edition = nil } })
        ) {
            if let liaison = Binding($formulaire), let edition = liaison.wrappedValue.edition,
                let index = liaison.wrappedValue.propositions.firstIndex(where: { $0.id == edition.id })
            {
                let saisie = Binding(
                    get: { formulaire?.edition?.saisie ?? edition.saisie },
                    set: { formulaire?.edition?.saisie = $0 })
                modifier(liaison.propositions[index], saisie: saisie)
                    .environment(\.dynamicTypeSize, taille)
            }
        }
    }

    private func ouvrirEdition(_ proposition: FormulaireMessage.Proposition) {
        formulaire?.edition = .init(
            id: proposition.id, saisie: .init(quantite: proposition.quantite, unite: proposition.unite))
    }

    private func modifier(
        _ proposition: Binding<FormulaireMessage.Proposition>, saisie: Binding<SaisieQuantite>
    ) -> some View {
        FeuilleCourses("Corriger l’article") {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Nom de l’article", text: proposition.nom)
                        .textFieldStyle(.roundedBorder)
                    EditeurQuantite(saisie: saisie, uniteLue: proposition.wrappedValue.unite) { valeur, unite in
                        proposition.wrappedValue.quantite = valeur
                        proposition.wrappedValue.unite = unite
                        formulaire?.edition = nil
                    }
                }
                .padding()
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func conserverSource() {
        conserverSourceEnCours = true
        let nouveau = ContenuRecu(type: .texte, contenu: Data(saisie.utf8), origine: .pressePapiers)
        Task {
            defer { conserverSourceEnCours = false }
            do {
                try await reception.deposer(nouveau)
                contenu = nouveau
                lireMessage = true
            } catch {
                session.signaler("Impossible de garder le message sur l’iPhone. Réessayez.", erreur: error)
            }
        }
    }

    private func demanderFermeture() {
        if integre {
            terminer()
        } else if formulaire != nil {
            confirmerAbandon = true
        } else {
            fermer()
        }
    }

    private func abandonner() {
        clotureEnCours = true
        Task {
            defer { clotureEnCours = false }
            do {
                try await suivi.effacer()
                fermer()
            } catch {
                session.signaler("Impossible d’abandonner le brouillon.", erreur: error)
            }
        }
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
            var propositions = extraction.articles.map {
                FormulaireMessage.Proposition(nom: $0.nom, quantite: $0.quantite, unite: $0.unite)
            }
            if extraction.moteur == .manuel {
                let incomprises: [FormulaireMessage.Proposition] = extraction.texteSource.split(
                    whereSeparator: \.isNewline
                ).compactMap {
                    ligne in
                    let texte = String(ligne).trimmingCharacters(in: .whitespaces)
                    guard !texte.isEmpty, AnalyseIngredient.analyser(texte).ligneNonComprise else { return nil }
                    return FormulaireMessage.Proposition(nom: "", quantite: nil, unite: nil, texteNonCompris: texte)
                }
                propositions.append(contentsOf: incomprises)
            }
            formulaire = FormulaireMessage(
                sourceId: contenu.id, texte: extraction.texteSource, cause: extraction.cause, propositions: propositions
            )
        } catch is CancellationError {
            return
        } catch {
            session.erreur = "La lecture du message a échoué. Le texte est conservé."
        }
    }

    private func integrer(_ choix: ListeCourses.ChoixIntegration? = nil) {
        guard let formulaire, !clotureEnCours else { return }
        let id = formulaire.sourceId
        let articles = articles
        Task {
            await session.effectuer("Impossible d’ajouter les articles. Le message est conservé.") {
                try await suivi.forcer(.message(formulaire))
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
        guard !receptionRetiree else { return }
        if let contenu { try await reception.retirer(contenu) }
        try await suivi.effacer()
        receptionRetiree = true
        receptionTraitee()
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
