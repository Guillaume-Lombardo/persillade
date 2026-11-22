import PersilladeCore
import SwiftUI
import UIKit

struct PasAPas: View {
    let recette: Recette
    let portions: Int
    let fond: Planche.Fond
    let memoriserPosition: (Int) -> Void

    @Environment(\.colorScheme) private var apparence
    @Environment(\.dismiss) private var fermer
    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.scenePhase) private var phase
    @Environment(\.accessibilityReduceTransparency) private var transparenceReduite
    @AppStorage("cuisine.ensuite") private var ensuite = false
    @State private var session: SessionCuisine
    @State private var ingredientsVisibles = false
    @State private var minuteurInitial: Bool?

    init(
        recette: Recette, portions: Int, fond: Planche.Fond, session: SessionCuisine,
        memoriserPosition: @escaping (Int) -> Void
    ) {
        self.recette = recette
        self.portions = portions
        self.fond = fond
        self.memoriserPosition = memoriserPosition
        _session = State(initialValue: session)
    }

    private var sombre: Bool { apparence == .dark }
    private var couleurFond: Color { Color(motif: fond.couleur(sombre: sombre)) }
    private var encre: Color { Color(motif: fond.encre(sombre: sombre)) }
    private var derniereEtape: Bool { session.etapeSuivante == nil }

    var body: some View {
        NavigationStack {
            consignes
                .safeAreaInset(edge: .bottom, spacing: 0) { commandes }
                .foregroundStyle(encre)
                .background(couleurFond.ignoresSafeArea())
                .tint(encre)
                .navigationTitle(recette.titre)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(
                    sombre || fond == .persil || fond == .aubergine ? .dark : .light, for: .navigationBar
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer", systemImage: "xmark", action: quitter)
                            .accessibilityIdentifier("fermer-cuisine")
                    }
                }
        }
        .onChange(of: phase, initial: true) { _, phase in garderEcranAllume(phase == .active) }
        .onDisappear { garderEcranAllume(false) }
        .sensoryFeedback(.impact(weight: .medium), trigger: session.position)
        .sheet(isPresented: $ingredientsVisibles) {
            IngredientsCuisine(recette: recette, portions: portions)
                .environment(\.dynamicTypeSize, taille)
                .presentationDetents([.large])
        }
    }

    private var consignes: some View {
        ScrollViewReader { defilement in
            ScrollView {
                VStack(alignment: .leading, spacing: GrillePersillade.marge) {
                    Text("\(session.position) sur \(session.etapes.count)")
                        .typographie(.etape)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .accessibilityLabel("Étape \(session.position) sur \(session.etapes.count)")
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("position-cuisine")
                        .id("debut")

                    Text(session.etapeCourante)
                        .typographie(.consigne(session.etapeCourante.count))
                        .accessibilityIdentifier("consigne-cuisine")
                        .id(session.position)
                        .transition(.opacity)

                    if let suivante = session.etapeSuivante {
                        Rectangle().frame(height: GrillePersillade.filet).accessibilityHidden(true)
                        DisclosureGroup("Ensuite", isExpanded: $ensuite) {
                            Text(suivante).typographie(.texte)
                        }
                        .font(.headline)
                    }
                }
                .padding(GrillePersillade.marge)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 32).onEnded { geste in
                    let horizontal = geste.translation.width
                    guard abs(horizontal) > max(44, abs(geste.translation.height) * 1.5) else { return }
                    if horizontal > 0 {
                        changerEtape(versSuivante: false)
                    } else {
                        changerEtape(versSuivante: true)
                    }
                }
            )
            .onChange(of: session.position) { defilement.scrollTo("debut", anchor: .top) }
        }
    }

    private var commandes: some View {
        let cible = GrillePersillade.cibleCuisine
        let action = derniereEtape ? "Terminer" : "Suivante"
        let symbole = derniereEtape ? "checkmark" : "chevron.right"
        return HStack(spacing: GrillePersillade.pas * 2) {
            boutonSecondaire("Précédente", symbole: "chevron.left", identifiant: "precedente-cuisine", iconeSeule: true)
            {
                changerEtape(versSuivante: false)
            }
            .disabled(session.position == 1)
            .opacity(session.position == 1 ? 0.5 : 1)

            boutonSecondaire(
                "Ingrédients", symbole: "list.bullet", identifiant: "ingredients-cuisine",
                iconeSeule: taille.isAccessibilitySize
            ) { ingredientsVisibles = true }

            Button {
                if derniereEtape {
                    memoriserPosition(0)
                    quitter()
                } else {
                    changerEtape(versSuivante: true)
                }
            } label: {
                ViewThatFits(in: .horizontal) {
                    Label(action, systemImage: symbole).fixedSize()
                    Image(systemName: symbole)
                }
                .font(.headline)
                .padding(.horizontal, GrillePersillade.pas * 2)
                .frame(minWidth: cible, maxWidth: .infinity, minHeight: cible)
                .background(encre, in: .capsule)
                .foregroundStyle(couleurFond)
                .contentShape(.capsule)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(action)
            .accessibilityShowsLargeContentViewer { Label(action, systemImage: symbole) }
            .accessibilityIdentifier("suivante-cuisine")
        }
        .padding(.horizontal, GrillePersillade.marge)
        .padding(.vertical, GrillePersillade.pas * 2)
        .background(couleurFond)
    }

    private func boutonSecondaire(
        _ titre: String, symbole: String, identifiant: String, iconeSeule: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: GrillePersillade.pas) {
                Image(systemName: symbole).font(.system(size: 22, weight: .semibold))
                if !iconeSeule {
                    Text(titre).font(.footnote.weight(.semibold))
                }
            }
            .padding(.horizontal, GrillePersillade.pas * 2)
            .frame(minWidth: GrillePersillade.cibleCuisine, minHeight: GrillePersillade.cibleCuisine)
            .background(encre.opacity(transparenceReduite ? 0.14 : 0), in: .capsule)
            .glassEffect(transparenceReduite ? .identity : .regular.interactive(), in: .capsule)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(titre)
        .accessibilityShowsLargeContentViewer { Label(titre, systemImage: symbole) }
        .accessibilityIdentifier(identifiant)
    }

    private func changerEtape(versSuivante: Bool) {
        let position = session.position
        withAnimation(.easeInOut(duration: 0.2)) {
            if versSuivante { session.suivante() } else { session.precedente() }
        }
        if session.position != position { memoriserPosition(session.position) }
    }

    private func quitter() {
        garderEcranAllume(false)
        fermer()
    }

    private func garderEcranAllume(_ actif: Bool) {
        let application = UIApplication.shared
        if actif, minuteurInitial == nil {
            minuteurInitial = application.isIdleTimerDisabled
            application.isIdleTimerDisabled = true
        } else if !actif, let minuteurInitial {
            application.isIdleTimerDisabled = minuteurInitial
            self.minuteurInitial = nil
        }
    }
}

private struct IngredientsCuisine: View {
    let recette: Recette
    let portions: Int

    @Environment(\.dismiss) private var fermer

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Pour \(portions) ; les étapes sont rédigées pour \(recette.portions)")
                        .typographie(.texte)
                        .padding(GrillePersillade.marge)
                        .accessibilityIdentifier("portions-cuisine")
                    if recette.ingredients.isEmpty {
                        Text("Aucun ingrédient")
                            .typographie(.texte)
                            .padding(.horizontal, GrillePersillade.marge)
                    } else {
                        IngredientsRecette(recette: recette, portions: portions)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(CouleurPersillade.page.couleur)
            .foregroundStyle(CouleurPersillade.encre.couleur)
            .navigationTitle("Ingrédients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") { fermer() }
                        .accessibilityIdentifier("fermer-ingredients-cuisine")
                }
            }
        }
    }
}
