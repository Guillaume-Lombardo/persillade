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
    @ScaledMetric(relativeTo: .largeTitle) private var tailleNombreEtapes = 24.0
    @ScaledMetric(relativeTo: .title3) private var tailleAction = 20.0
    @AppStorage("cuisine.ensuite") private var ensuite = true
    @State private var ensuiteAccessible = false
    @State private var session: SessionCuisine
    @State private var ingredientsVisibles = false
    @State private var visible = false
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
    private var apparenceDuFond: ColorScheme { sombre || fond == .persil || fond == .aubergine ? .dark : .light }
    private var derniereEtape: Bool { session.etapeSuivante == nil }
    private var positionAnnoncee: String { "Étape \(session.position) sur \(session.etapes.count)" }

    var body: some View {
        NavigationStack {
            consignes
                .safeAreaInset(edge: .bottom, spacing: 0) { commandes }
                .foregroundStyle(encre)
                .background(couleurFond.ignoresSafeArea())
                .navigationTitle(recette.titre)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(apparenceDuFond, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer", systemImage: "xmark", action: quitter)
                            .tint(encre)
                            .accessibilityIdentifier("fermer-cuisine")
                    }
                }
        }
        .onAppear {
            visible = true
            garderEcranAllume(phase == .active)
        }
        .onChange(of: phase) { _, phase in garderEcranAllume(visible && phase == .active) }
        .onChange(of: taille.isAccessibilitySize) { _, accessible in
            if accessible { ensuiteAccessible = false }
        }
        .onDisappear {
            visible = false
            garderEcranAllume(false)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: session.position)
        .sheet(isPresented: $ingredientsVisibles) {
            IngredientsCuisine(recette: recette, portions: portions)
                .environment(\.dynamicTypeSize, taille)
                .presentationDetents([.medium, .large])
                .presentationBackground(CouleurPersillade.page.couleur)
        }
    }

    private var consignes: some View {
        GeometryReader { cadre in
            ScrollViewReader { defilement in
                ScrollView {
                    VStack(alignment: .leading, spacing: GrillePersillade.marge) {
                        indicateurEtape.id("debut")

                        Text(session.etapeCourante)
                            .typographie(.consigne(session.etapeCourante.count))
                            .accessibilityIdentifier("consigne-cuisine")
                            .id(session.position)
                            .transition(.opacity)

                        if let suivante = session.etapeSuivante {
                            Spacer(minLength: 0)
                            VStack(alignment: .leading, spacing: 0) {
                                Rectangle().frame(height: GrillePersillade.filet).accessibilityHidden(true)
                                apercu(suivante)
                            }
                        }
                    }
                    .frame(
                        maxWidth: .infinity, minHeight: max(0, cadre.size.height - GrillePersillade.marge * 2),
                        alignment: .topLeading
                    )
                    .padding(GrillePersillade.marge)
                    .contentShape(.rect)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 32).onEnded { geste in
                        let horizontal = geste.translation.width
                        guard abs(horizontal) > max(44, abs(geste.translation.height) * 1.5) else { return }
                        changerEtape(versSuivante: horizontal < 0)
                    }
                )
                .onChange(of: session.position) { defilement.scrollTo("debut", anchor: .top) }
            }
        }
    }

    private var indicateurEtape: some View {
        let police: Font =
            taille.isAccessibilitySize
            ? .system(.title2, weight: .heavy)
            : .system(size: tailleNombreEtapes, weight: .heavy).width(.condensed)
        let total = Text("sur \(session.etapes.count)").font(police)
        return Text("\(session.position) \(total)")
            .typographie(.etape)
            .accessibilityLabel(positionAnnoncee)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("position-cuisine")
    }

    private func apercu(_ consigne: String) -> some View {
        let deplie = taille.isAccessibilitySize ? $ensuiteAccessible : $ensuite
        return VStack(alignment: .leading, spacing: GrillePersillade.pas * 2) {
            Button {
                deplie.wrappedValue.toggle()
            } label: {
                HStack {
                    Text("Ensuite").font(.headline)
                    Spacer()
                    Image(systemName: deplie.wrappedValue ? "chevron.down" : "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .accessibilityHidden(true)
                }
                .frame(minHeight: GrillePersillade.cible)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityValue(deplie.wrappedValue ? "Déplié" : "Replié")

            if deplie.wrappedValue { Text(consigne).typographie(.texte) }
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

            ViewThatFits(in: .horizontal) {
                if !taille.isAccessibilitySize {
                    boutonSecondaire(
                        "Ingrédients", symbole: "list.bullet", identifiant: "ingredients-cuisine", iconeSeule: false
                    ) { ingredientsVisibles = true }
                    .fixedSize()
                }
                boutonSecondaire(
                    "Ingrédients", symbole: "list.bullet", identifiant: "ingredients-cuisine", iconeSeule: true
                ) { ingredientsVisibles = true }
            }

            Button {
                if derniereEtape {
                    memoriserPosition(0)
                    quitter()
                } else {
                    changerEtape(versSuivante: true)
                }
            } label: {
                ViewThatFits(in: .horizontal) {
                    if !taille.isAccessibilitySize {
                        HStack(spacing: GrillePersillade.pas * 2) {
                            Text(action)
                            Image(systemName: symbole).accessibilityHidden(true)
                        }
                        .fixedSize()
                    }
                    Text(action)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(.system(size: min(tailleAction, 32), weight: .semibold))
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
            .background(encre.opacity(0.14), in: .capsule)
            .glassEffect(transparenceReduite ? .identity : .regular.tint(couleurFond).interactive(), in: .capsule)
            .environment(\.colorScheme, apparenceDuFond)
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
        guard session.position != position else { return }
        memoriserPosition(session.position)
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: "\(positionAnnoncee). \(session.etapeCourante)")
        }
    }

    private func quitter() {
        visible = false
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
                    Text("Quantités pour \(libellePortions(portions)). Étapes prévues pour \(recette.portions).")
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
            .background(CouleurPersillade.page.couleur.ignoresSafeArea())
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

    private func libellePortions(_ nombre: Int) -> String {
        nombre == 1 ? "1 portion" : "\(nombre) portions"
    }
}
