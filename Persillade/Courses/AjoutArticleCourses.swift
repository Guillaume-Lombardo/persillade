import PersilladeCore
import SwiftUI

struct AjoutArticleCourses: View {
    @Environment(\.dismiss) private var fermer
    @Environment(\.dynamicTypeSize) private var taille
    @State private var saisie = ""
    @State private var quantiteModifiee: ArticleCourses?
    @State private var categorie: Categorie?
    @State private var editerQuantite = false
    @State private var ajouts: [UUID] = []
    @State private var articleAjoute = false
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
        FeuilleCourses("Ajouter un article", afficherFermer: !articleAjoute) {
            List {
                if articleAjoute {
                    Label("Article ajouté", systemImage: "checkmark.circle")
                        .typographie(.precision)
                        .foregroundStyle(CouleurPersillade.encre2.couleur)
                        .listRowSeparator(.hidden)
                        .listRowBackground(CouleurPersillade.page.couleur)
                }
                if let etat = session.etat {
                    let ids = Set(ajouts.compactMap { etat.liste.ligne(id: $0)?.id })
                    ForEach(etat.liste.lignes.filter { ids.contains($0.id) }) { ligne in
                        let quantite = PresentationQuantite(ligne: ligne)
                        let statut =
                            etat.liste.envoyee && !ligne.cochee ? PresentationEnvoi(etat: etat, ligne: ligne) : nil
                        LigneArticle(
                            nom: ligne.libelle.lowercased(), quantite: quantite.nombre, unite: quantite.unite,
                            precisionPleineLargeur: quantite.precision,
                            exclu: ligne.cochee, marque: statut?.marque, ouvrir: { detail = ligne }
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        if echecEnvoi.contains(ligne.id) || statut?.echec == true {
                            Button("Réessayer") { envoyer([ligne.id]) }
                                .listRowBackground(CouleurPersillade.page.couleur)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .toolbar {
                if articleAjoute {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Terminé") { fermer() }
                            .disabled(session.occupee)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    if nomValide {
                        ViewThatFits(in: .horizontal) {
                            HStack { choix.fixedSize() }
                            VStack(alignment: .leading) { choix }
                        }
                    }
                    Text("Nom et quantité")
                        .typographie(.texte)
                        .foregroundStyle(CouleurPersillade.encre.couleur)
                        .accessibilityHidden(true)
                    TextField(
                        "Nom et quantité", text: $saisie,
                        prompt: Text("2 pommes").foregroundStyle(CouleurPersillade.encre2.couleur), axis: .vertical
                    )
                    .typographie(.texte)
                    .foregroundStyle(CouleurPersillade.encre.couleur)
                    .padding(GrillePersillade.pas * 3)
                    .background(CouleurPersillade.page2.couleur, in: .rect(cornerRadius: 8))
                    .focused($saisieActive)
                    .accessibilityIdentifier("ajout-saisie-courses")
                    BoutonActionPersillade("Ajouter", symbole: "plus", pleineLargeur: true, action: ajouter)
                        .disabled(!nomValide)
                        .accessibilityIdentifier("ajout-valider-courses")
                }
                .padding(.horizontal, GrillePersillade.marge)
                .padding(.vertical, 8)
                .background(CouleurPersillade.page.couleur)
                .disabled(session.occupee)
            }
            .task { saisieActive = true }
            .onChange(of: saisie) {
                quantiteModifiee = nil
                categorie = nil
            }
            .sheet(item: $detail) {
                DetailArticleCourses(id: $0.id, session: session)
                    .environment(\.dynamicTypeSize, taille)
            }
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
                .environment(\.dynamicTypeSize, taille)
                .presentationDetents(taille.isAccessibilitySize ? [.large] : [.medium, .large])
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
                articleAjoute = true
                saisie = ""
                exclus = effets.decochagePropose
                if !exclus.isEmpty { confirmerRemise = true }
                do {
                    try await session.relire()
                } catch {
                    session.signaler("L’article est enregistré. Impossible de relire les courses.", erreur: error)
                }
                if !effets.lignesAEnvoyer.isEmpty {
                    await envoyerArticles(effets.lignesAEnvoyer)
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
                if aEnvoyer { await envoyerArticles(ids) }
            }
        }
    }

    private func envoyer(_ ids: [UUID]) {
        Task {
            await session.effectuer("L’envoi des articles a été interrompu. Réessayez.") {
                await envoyerArticles(ids)
            }
        }
    }

    private func envoyerArticles(_ ids: [UUID]) async {
        echecEnvoi.removeAll { ids.contains($0) }
        do {
            let rapport = try await session.envoyer(ids)
            echecEnvoi.append(contentsOf: rapport.echecs.map(\.ligneId))
        } catch {
            echecEnvoi.append(contentsOf: ids)
            session.signaler("L’article est dans les courses. Son envoi a été interrompu.", erreur: error)
        }
    }
}
