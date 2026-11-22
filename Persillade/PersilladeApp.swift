import SwiftUI
import UIKit

@main
struct PersilladeApp: App {
    var body: some Scene {
        WindowGroup {
            Group {
                #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-galerie") {
                        GalerieDesign()
                    } else {
                        Racine()
                    }
                #else
                    Racine()
                #endif
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) {
                _ in
                Task { await RenduPlanche.partage.vider() }
            }
        }
    }
}

private struct Racine: View {
    @Environment(\.scenePhase) private var phase
    @State private var afficherReglages = false
    @State private var reception = ReceptionEntree()

    var body: some View {
        @Bindable var reception = reception

        TabView {
            Tab("Recettes", systemImage: "book.closed") {
                ecran("Recettes", "Aucune recette", icone: "book.closed", accueil: true)
            }
            Tab("Semaine", systemImage: "calendar") {
                ecran("Semaine", "Aucun repas prévu", icone: "calendar")
            }
            Tab("Courses", systemImage: "cart") {
                ecran("Courses", "Aucun article", icone: "cart")
            }
        }
        .task(id: phase) {
            if phase == .active { await reception.actualiser() }
        }
        .sheet(item: $reception.affiche) { contenu in
            ChoixReception(contenu: contenu, message: reception.message) {
                try await reception.abandonner(id: contenu.id)
            }
        }
        .sheet(isPresented: $afficherReglages) {
            Reglages()
        }
    }

    private func ecran(
        _ titre: LocalizedStringKey, _ etat: LocalizedStringKey, icone: String, accueil: Bool = false
    ) -> some View {
        NavigationStack {
            ContentUnavailableView(etat, systemImage: icone)
                .safeAreaInset(edge: .bottom) {
                    if accueil { ActionsReception(reception: reception) }
                }
                .navigationTitle(titre)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Réglages", systemImage: "gear") { afficherReglages = true }
                    }
                }
        }
    }
}
