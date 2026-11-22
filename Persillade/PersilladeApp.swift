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
    @State private var afficherReglages = false

    var body: some View {
        TabView {
            Tab("Recettes", systemImage: "book.closed") {
                ecran("Recettes", "Aucune recette", icone: "book.closed")
            }
            Tab("Semaine", systemImage: "calendar") {
                ecran("Semaine", "Aucun repas prévu", icone: "calendar")
            }
            Tab("Courses", systemImage: "cart") {
                ecran("Courses", "Aucun article", icone: "cart")
            }
        }
        .sheet(isPresented: $afficherReglages) {
            NavigationStack {
                Form {}
                    .navigationTitle("Réglages")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Fermer") { afficherReglages = false }
                        }
                    }
            }
        }
    }

    private func ecran(_ titre: LocalizedStringKey, _ etat: LocalizedStringKey, icone: String) -> some View {
        NavigationStack {
            ContentUnavailableView(etat, systemImage: icone)
                .navigationTitle(titre)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Réglages", systemImage: "gear") { afficherReglages = true }
                    }
                }
        }
    }
}
