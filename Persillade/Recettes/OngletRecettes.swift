import PersilladeCore
import SwiftUI

struct OngletRecettes: View {
    @Binding var chemin: [UUID]
    let bibliotheque: BibliothequeRecettes
    let rechercheActive: Bool
    let messageReception: String?
    let coller: () -> Void
    let ecrire: () -> Void
    let prendrePhoto: () -> Void
    let choisirPhoto: () -> Void
    let reglages: () -> Void
    let modifier: (Recette) -> Void

    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @Environment(\.colorScheme) private var apparence
    @Namespace private var transition
    @State private var recherche = ""
    @State private var resultats: [ResumeRecette]?
    @State private var fonds: [UUID: Planche.Fond] = [:]
    @State private var erreurLecture = false
    @State private var supprimer: ResumeRecette?
    @State private var essai = 0

    private struct Chargement: Equatable {
        let recherche: String
        let revision: Int
        let essai: Int
    }

    private var bibliothequeVide: Bool {
        resultats?.isEmpty == true && recherche.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !erreurLecture
    }

    private var couleurPlancheVide: Color { Color(motif: Planche.Fond.rose.couleur(sombre: apparence == .dark)) }

    var body: some View {
        NavigationStack(path: $chemin) {
            Group {
                if rechercheActive {
                    contenu.searchable(text: $recherche, prompt: "Rechercher une recette")
                } else {
                    contenu
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CouleurPersillade.page.couleur.ignoresSafeArea())
            .navigationTitle("Recettes")
            .navigationBarTitleDisplayMode(bibliothequeVide ? .inline : .large)
            .toolbarBackground(
                bibliothequeVide ? couleurPlancheVide : CouleurPersillade.page.couleur, for: .navigationBar
            )
            .toolbarBackgroundVisibility(bibliothequeVide ? .visible : .automatic, for: .navigationBar)
            .tint(
                bibliothequeVide
                    ? Color(motif: Planche.Fond.rose.encre(sombre: apparence == .dark))
                    : CouleurPersillade.persil.couleur
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Coller un lien ou un texte", systemImage: "document.on.clipboard", action: coller)
                        Button("Écrire", systemImage: "pencil", action: ecrire)
                        Button("Prendre une photo", systemImage: "camera", action: prendrePhoto)
                        Button("Choisir une photo", systemImage: "photo", action: choisirPhoto)
                            .accessibilityIdentifier("import-choisir-photo")
                    } label: {
                        Label("Ajouter une recette", systemImage: "plus")
                    }
                    .accessibilityIdentifier("import-ajouter-recette")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Réglages", systemImage: "gear", action: reglages)
                    } label: {
                        Label("Plus d’options", systemImage: "ellipsis")
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                let fiche = FicheRecette(id: id, bibliotheque: bibliotheque, modifier: modifier)
                if mouvementReduit {
                    fiche
                } else {
                    fiche.navigationTransition(.zoom(sourceID: id, in: transition))
                }
            }
            .alert(
                "Supprimer cette recette ?",
                isPresented: Binding(get: { supprimer != nil }, set: { if !$0 { supprimer = nil } }),
                presenting: supprimer
            ) { recette in
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    Task { _ = await bibliotheque.supprimer(recette.id) }
                }
            } message: { recette in
                if bibliotheque.portionsChoisies(recette.id) != nil {
                    Text("Retirée aussi de la semaine.")
                }
            }
            .task(id: Chargement(recherche: recherche, revision: bibliotheque.revision, essai: essai)) {
                await charger()
            }
        }
    }

    @ViewBuilder private var contenu: some View {
        VStack(spacing: 0) {
            if let messageReception {
                Text(messageReception)
                    .typographie(.precision)
                    .padding(GrillePersillade.marge)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CouleurPersillade.page2.couleur)
            }
            if erreurLecture {
                ContentUnavailableView {
                    Label("Impossible de lire les recettes", systemImage: "exclamationmark.circle")
                } actions: {
                    Button("Réessayer") { essai += 1 }
                }
            } else if let resultats {
                if !resultats.isEmpty {
                    liste(resultats)
                } else if !recherche.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ContentUnavailableView("Aucun titre ne contient « \(recherche) ».", systemImage: "magnifyingglass")
                } else {
                    plancheVide
                }
            } else {
                ProgressView("Lecture des recettes").frame(maxHeight: .infinity)
            }
        }
    }

    private var plancheVide: some View {
        ScrollView {
            EtatVide(
                titre: "La planche\nest vide",
                message: "Importez une première recette. Depuis Safari ou Messages : Partager, puis Persillade."
            ) {
                Image(decorative: "PlancheVide")
                    .resizable()
                    .frame(height: 352)
            } actions: {
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: GrillePersillade.pas * 2) {
                CommandeRecettes(
                    titre: "Coller un lien ou un texte", symbole: "document.on.clipboard", principale: true,
                    action: coller)
                CommandeRecettes(titre: "Prendre une photo", symbole: "camera", action: prendrePhoto)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .tint(CouleurPersillade.persil.couleur)
            .padding(.horizontal, GrillePersillade.margeBarre)
            .padding(.vertical, GrillePersillade.pas)
            .background(CouleurPersillade.page.couleur)
        }
    }

    private func liste(_ recettes: [ResumeRecette]) -> some View {
        List(Array(recettes.enumerated()), id: \.element.id) { index, recette in
            let fondPrecedent = index > 0 ? fonds[recettes[index - 1].id] : nil
            LigneRecette(
                recette: recette, bibliotheque: bibliotheque, transition: transition, fondPrecedent: fondPrecedent
            ) { fonds[recette.id] = $0 }
            .listRowInsets(.init())
            .listRowBackground(CouleurPersillade.page.couleur)
            .listRowSeparator(.hidden)
            .swipeActions(allowsFullSwipe: false) {
                Button("Supprimer", systemImage: "trash", role: .destructive) { supprimer = recette }
                    .disabled(bibliotheque.operationSemaine)
            }
            .accessibilityAction(named: "Supprimer") {
                if !bibliotheque.operationSemaine { supprimer = recette }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(CouleurPersillade.page.couleur)
        .accessibilityIdentifier("liste-recettes")
    }

    private func charger() async {
        do {
            let recettes = try await bibliotheque.lister(recherche: recherche)
            try Task.checkCancellation()
            resultats = recettes
            erreurLecture = false
        } catch is CancellationError {
        } catch {
            if !Task.isCancelled { erreurLecture = true }
        }
    }
}

private struct LigneRecette: View {
    let recette: ResumeRecette
    let bibliotheque: BibliothequeRecettes
    let transition: Namespace.ID
    let fondPrecedent: Planche.Fond?
    let noterFond: (Planche.Fond) -> Void

    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @State private var planche: Planche?
    @State private var retour = 0

    private var choisie: Bool { bibliotheque.portionsChoisies(recette.id) != nil }

    var body: some View {
        let nomAction = choisie ? "Retirer de la semaine" : "Ajouter à la semaine"
        let symbole = choisie ? "checkmark.circle.fill" : "plus.circle"
        HStack(spacing: 0) {
            NavigationLink(value: recette.id) {
                HStack(spacing: 0) {
                    if taille < .accessibility3 {
                        ZStack {
                            CouleurPersillade.page2.couleur
                            if let planche { VignetteMotif(planche: planche) }
                        }
                        .frame(width: taille.isAccessibilitySize ? 64 : 112, height: GrillePersillade.recette)
                        .overlay(alignment: .top) {
                            if let planche, planche.fond == fondPrecedent {
                                CouleurPersillade.page.couleur.frame(height: 2)
                            }
                        }
                        .accessibilityHidden(true)
                        .matchedTransitionSource(id: recette.id, in: transition)
                    }
                    VStack(alignment: .leading, spacing: GrillePersillade.pas) {
                        Text(recette.titre).typographie(.recette)
                            .lineLimit(taille.isAccessibilitySize ? nil : 2)
                            .foregroundStyle(CouleurPersillade.encre.couleur)
                        Text(
                            "\(recette.nombreIngredients) \(recette.nombreIngredients == 1 ? "ingrédient" : "ingrédients"), \(recette.nombreEtapes) \(recette.nombreEtapes == 1 ? "étape" : "étapes")"
                        )
                        .typographie(.precision)
                        .foregroundStyle(CouleurPersillade.encre2.couleur)
                    }
                    .padding(.horizontal, GrillePersillade.marge)
                    .padding(.vertical, GrillePersillade.pas * 2)
                    .frame(maxWidth: .infinity, minHeight: GrillePersillade.recette, alignment: .leading)
                    .accessibilityElement(children: .combine)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .navigationLinkIndicatorVisibility(.hidden)
            .accessibilityIdentifier("ouvrir-recette")
            Button {
                Task {
                    do {
                        if choisie {
                            await bibliotheque.choisir(recette.id, portions: nil)
                        } else if let complete = try await bibliotheque.lire(recette.id) {
                            await bibliotheque.choisir(recette.id, portions: complete.portions)
                        } else {
                            bibliotheque.erreur = "Cette recette a été supprimée."
                        }
                    } catch {
                        bibliotheque.erreur = "Impossible de lire la recette."
                    }
                }
            } label: {
                Image(systemName: symbole)
                    .font(.title3)
                    .contentTransition(mouvementReduit ? .opacity : .symbolEffect(.replace))
                    .frame(width: GrillePersillade.cible, height: GrillePersillade.cible)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .foregroundStyle(CouleurPersillade.persil.couleur)
            .disabled(!bibliotheque.selectionDisponible || bibliotheque.operationSemaine)
            .accessibilityLabel("\(nomAction) : \(recette.titre)")
            .accessibilityShowsLargeContentViewer { Label(nomAction, systemImage: symbole) }
            .padding(.trailing, GrillePersillade.pas)
        }
        .overlay(alignment: .bottom) {
            CouleurPersillade.trait.couleur.frame(height: GrillePersillade.filet)
        }
        .task(id: recette.modifieLe) {
            guard taille < .accessibility3 else { return }
            do {
                let lue = try await bibliotheque.lire(recette.id)
                try Task.checkCancellation()
                if let lue {
                    let motif = await Task.detached { Planche(recette: lue) }.value
                    try Task.checkCancellation()
                    planche = motif
                    noterFond(motif.fond)
                }
            } catch is CancellationError {
            } catch {
                if !Task.isCancelled { bibliotheque.erreur = "Impossible de lire la recette « \(recette.titre) »." }
            }
        }
        .onChange(of: choisie) { _, _ in retour += 1 }
        .sensoryFeedback(.selection, trigger: retour)
        .animation(mouvementReduit ? .easeInOut(duration: 0.2) : .default, value: choisie)
    }
}
