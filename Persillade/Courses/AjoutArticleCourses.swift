import PersilladeCore
import SwiftUI

struct AjoutArticleCourses: View {
    @State private var saisie = ""
    @State private var quantiteModifiee: ArticleCourses?
    @State private var categorie: Categorie?
    @State private var editerQuantite = false
    @State private var ajouts: [UUID] = []
    @State private var detail: LigneCourses?
    @State private var exclus: [UUID] = []
    @State private var confirmerRemise = false
    @State private var echecEnvoi: [UUID] = []
    @FocusState private var saisieActive: Bool

    let session: SessionCourses

    private var analyse: BrouillonIngredient { AnalyseIngredient.analyser(saisie) }
    private var nomValide: Bool { !normaliserNom(quantiteModifiee?.nom ?? analyse.nom).isEmpty }
    private var rayon: Categorie { categorie ?? categorieParDefaut(normaliserNom(analyse.nom)) }

    var body: some View {
        FeuilleCourses("Ajouter un article") {
            List {
                ForEach(ajouts, id: \.self) { id in
                    if let etat = session.etat, let ligne = etat.liste.ligne(id: id) {
                        let quantite = PresentationQuantite(ligne: ligne)
                        VStack(alignment: .leading) {
                            LigneArticle(
                                nom: ligne.libelle, quantite: quantite.nombre, unite: quantite.unite,
                                exclu: ligne.cochee, ouvrir: { detail = ligne })
                            if etat.liste.envoyee, !ligne.cochee {
                                let statut = PresentationEnvoi(etat: etat, ligne: ligne)
                                statut.marque
                                if echecEnvoi.contains(ligne.id) || statut.echec {
                                    Button("Réessayer") { envoyer([ligne.id]) }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    if nomValide {
                        ViewThatFits(in: .horizontal) {
                            HStack { choix.fixedSize() }
                            VStack(alignment: .leading) { choix }
                        }
                    }
                    TextField("Nom et quantité", text: $saisie, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($saisieActive)
                        .accessibilityIdentifier("ajout-saisie-courses")
                    BoutonActionPersillade("Ajouter", action: ajouter)
                        .disabled(!nomValide)
                        .accessibilityIdentifier("ajout-valider-courses")
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .padding(.horizontal, GrillePersillade.marge)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .disabled(session.occupee)
            }
            .task { saisieActive = true }
            .onChange(of: saisie) {
                quantiteModifiee = nil
                categorie = nil
            }
            .sheet(item: $detail) { DetailArticleCourses(id: $0.id, session: session) }
            .sheet(isPresented: $editerQuantite) {
                let quantite = quantiteModifiee == nil ? analyse.quantite : quantiteModifiee?.quantite
                let unite = quantiteModifiee == nil ? analyse.unite : quantiteModifiee?.unite
                FeuilleCourses("Modifier la quantité") {
                    ScrollView {
                        EditeurQuantite(quantite: quantite, unite: unite) { valeur, unite in
                            do {
                                quantiteModifiee = try ArticleCourses(nom: analyse.nom, quantite: valeur, unite: unite)
                                editerQuantite = false
                            } catch {
                                session.erreur = "Vérifiez la quantité et le nom de l’article."
                            }
                        }
                        .padding()
                    }
                    .erreurCourses(session)
                }
                .presentationDetents([.medium, .large])
            }
            .confirmationDialog(
                "Remettre les articles exclus ?", isPresented: $confirmerRemise, titleVisibility: .visible
            ) {
                Button("Remettre", action: remettre)
            } message: {
                let noms = exclus.compactMap { session.etat?.liste.ligne(id: $0)?.libelle }.joined(separator: ", ")
                Text("Articles exclus de l’envoi. \(noms).")
            }
            .erreurCourses(session)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(session.occupee)
    }

    @ViewBuilder
    private var choix: some View {
        let nombre = quantiteModifiee == nil ? analyse.quantite : quantiteModifiee?.quantite
        let unite = quantiteModifiee == nil ? analyse.unite : quantiteModifiee?.unite
        let texte = [nombre?.texteFrancais, unite?.libellePersillade].compactMap { $0 }.joined(separator: " ")
        Button(texte.isEmpty ? "Sans quantité" : texte) { editerQuantite = true }
            .buttonStyle(.glass)
            .accessibilityHint("Modifier la quantité")
        Menu(rayon.rawValue) {
            ForEach(Categorie.allCases, id: \.self) { categorie in
                Button(categorie.rawValue) { self.categorie = categorie }
            }
        }
        .buttonStyle(.glass)
        .accessibilityHint("Changer le rayon")
    }

    private func ajouter() {
        Task {
            await session.effectuer("Impossible d’ajouter cet article. Vérifiez la saisie et réessayez.") {
                let article =
                    try quantiteModifiee
                    ?? ArticleCourses(
                        nom: analyse.nom, quantite: analyse.quantite, unite: analyse.unite)
                let ref = UUID()
                let categorieChoisie = categorie
                let (effets, lignes) = try await session.envoi.modifier { liste, _ in
                    let effets = try liste.ajouter(article, ref: ref)
                    let creeesOuCompletees = liste.lignes.filter { ligne in
                        ligne.origines.contains { $0.ref == ref }
                    }
                    if let categorieChoisie {
                        for ligne in creeesOuCompletees {
                            try liste.changerCategorie(ligne.id, categorie: categorieChoisie)
                        }
                    }
                    let concernees = liste.lignes.filter { $0.nomNormalise == normaliserNom(article.nom) }
                    return (effets, (creeesOuCompletees.isEmpty ? concernees : creeesOuCompletees).map(\.id))
                }
                ajouts.append(contentsOf: lignes.filter { !ajouts.contains($0) })
                saisie = ""
                exclus = effets.decochagePropose
                if !exclus.isEmpty { confirmerRemise = true }
                try await session.relire()
                if !effets.lignesAEnvoyer.isEmpty {
                    try await envoyerArticles(effets.lignesAEnvoyer)
                }
            }
        }
    }

    private func remettre() {
        Task {
            await session.effectuer("Impossible de remettre ces articles. Réessayez.") {
                let ids = exclus
                let aEnvoyer = try await session.envoi.modifier { liste, _ in
                    for id in ids { try liste.cocher(id, cochee: false) }
                    return liste.envoyee
                }
                try await session.relire()
                if aEnvoyer { try await envoyerArticles(ids) }
            }
        }
    }

    private func envoyer(_ ids: [UUID]) {
        Task {
            await session.effectuer("L’envoi des articles a été interrompu. Réessayez.") {
                try await envoyerArticles(ids)
            }
        }
    }

    private func envoyerArticles(_ ids: [UUID]) async throws {
        echecEnvoi.removeAll { ids.contains($0) }
        do {
            let rapport = try await session.envoyer(ids)
            echecEnvoi.append(contentsOf: rapport.echecs.map(\.ligneId))
        } catch {
            echecEnvoi.append(contentsOf: ids)
            session.erreur = "L’article est dans les courses. Son envoi a été interrompu."
            throw error
        }
    }
}
