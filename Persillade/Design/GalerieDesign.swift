#if DEBUG
    import PersilladeCore
    import SwiftUI

    struct GalerieDesign: View {
        @Environment(\.dynamicTypeSize) private var tailleDynamique
        @State private var exclu = false
        @State private var quantite: Quantite? = Quantite(250)
        @State private var unite: Unite? = .g
        @State private var exemples: [ExempleMotif] = []
        @State private var erreurExemples = false
        @State private var ouvrirEditeur = false

        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: GrillePersillade.pas * 6) {
                        composants
                        if let exemple = exemples.first {
                            EtatVide(
                                titre: "La planche est vide",
                                message: "Importez une première recette."
                            ) {
                                EnTeteMotif(planche: exemple.planche, cadrage: .vide).frame(height: 200)
                            } actions: {
                                Button("Écrire une recette") { ouvrirEditeur = true }
                                    .buttonStyle(.glass)
                            }
                        }
                        section("Motifs de référence")
                        ForEach(exemples) { exemple in
                            ApercuMotif(exemple: exemple)
                        }
                        if erreurExemples {
                            Text("Impossible de charger les motifs de référence.")
                                .foregroundStyle(CouleurPersillade.tomate.couleur)
                                .padding(.horizontal, GrillePersillade.marge)
                        }
                    }
                    .padding(.vertical, GrillePersillade.pas * 3)
                }
                .background(CouleurPersillade.page.couleur)
                .navigationTitle("Galerie")
                .barreAction {
                    BoutonActionPersillade("Modifier la quantité") { ouvrirEditeur = true }
                }
                .sheet(isPresented: $ouvrirEditeur) {
                    NavigationStack {
                        ScrollView {
                            EditeurQuantite(quantite: quantite, unite: unite) {
                                quantite = $0
                                unite = $1
                                ouvrirEditeur = false
                            }
                            .padding(GrillePersillade.marge)
                        }
                        .background(CouleurPersillade.page.couleur)
                        .navigationTitle("Quantité")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fermer") { ouvrirEditeur = false }
                            }
                        }
                    }
                    .environment(\.dynamicTypeSize, tailleGalerie)
                }
            }
            .environment(\.dynamicTypeSize, tailleGalerie)
            .preferredColorScheme(ProcessInfo.processInfo.arguments.contains("-galerie-sombre") ? .dark : nil)
            .task {
                do {
                    exemples = try ExempleMotif.charger()
                } catch {
                    erreurExemples = true
                }
            }
        }

        private var tailleGalerie: DynamicTypeSize {
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("-galerie-ax3") { return .accessibility3 }
            if arguments.contains("-galerie-ax5") { return .accessibility5 }
            return tailleDynamique
        }

        private var composants: some View {
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
                BandeauRayon(categorie: .fruitsEtLegumes, nombre: 3)
                LigneArticle(
                    nom: "Pommes de terre", quantite: quantite?.texteFrancais, unite: unite?.libellePersillade,
                    precision: "À chair ferme", exclu: exclu, ouvrir: { ouvrirEditeur = true },
                    basculerExclusion: { exclu.toggle() })
                LigneArticle(nom: "Citrons", quantite: "1/3", unite: "pièce")
                LigneArticle(nom: "Persil plat", precision: "Au goût")
                PastilleAVerifier().padding(.horizontal, GrillePersillade.marge)
            }
        }

        private func section(_ titre: String) -> some View {
            Text(titre).typographie(.section).accessibilityAddTraits(.isHeader)
                .padding(.horizontal, GrillePersillade.marge)
                .frame(maxWidth: .infinity, minHeight: GrillePersillade.rayon, alignment: .leading)
                .foregroundStyle(CouleurPersillade.encre.couleur)
                .background(CouleurPersillade.page2.couleur)
        }
    }

    private struct ApercuMotif: View {
        let exemple: ExempleMotif

        var body: some View {
            let planche = exemple.planche
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
                VignetteMotif(planche: planche, cadrage: .preuve)
                    .frame(maxWidth: 342)
                    .frame(height: 210)
                HStack(alignment: .top, spacing: GrillePersillade.pas * 2) {
                    VignetteMotif(planche: planche).frame(width: 96, height: 96)
                    VignetteMotif(planche: planche, cadrage: .miniature).frame(width: 22, height: 22)
                    Text(exemple.titre)
                        .typographie(.recette)
                        .foregroundStyle(CouleurPersillade.encre.couleur)
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .padding(.horizontal, GrillePersillade.marge)
        }
    }
#endif
