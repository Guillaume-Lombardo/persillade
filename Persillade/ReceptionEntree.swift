import PersilladeCore
import SwiftUI
import UniformTypeIdentifiers

@Observable
@MainActor
final class ReceptionEntree {
    private let file = Result { try FileEntree.groupeApplication() }

    private(set) var premier: ContenuRecu?
    private(set) var message: String?
    var affiche: ContenuRecu?

    func actualiser() async {
        do {
            let lecture = try await file.get().lire()
            premier = lecture.contenus.first
            affiche = premier
            message =
                lecture.fichiersIllisibles.isEmpty
                ? nil : "Des éléments illisibles ont été mis de côté."
        } catch {
            message = "Impossible de lire les éléments reçus."
        }
    }

    func coller(_ fournisseurs: [NSItemProvider]) async {
        do {
            let contenu = try await ContenuRecu.charger(fournisseurs, origine: .pressePapiers)
            try await file.get().deposer(contenu)
            await actualiser()
        } catch {
            message = "Impossible d’ajouter le contenu du presse-papiers."
        }
    }

    func abandonner(id: UUID) async throws {
        try await file.get().retirer(id: id)
        await actualiser()
    }
}

struct ChoixReception: View {
    private enum Destination: String {
        case recette = "Recette"
        case courses = "Articles de courses"
    }

    @Environment(\.dismiss) private var fermer
    @State private var destination: Destination?
    @State private var echecAbandon = false

    let contenu: ContenuRecu
    let message: String?
    let abandonner: () async throws -> Void

    var body: some View {
        NavigationStack {
            Form {
                if let message {
                    Text(message)
                }
                Section(contenu.type == .url ? "Lien reçu" : "Contenu reçu") {
                    if contenu.type == .image {
                        Label("Image", systemImage: "photo")
                    } else {
                        Text(String(decoding: contenu.contenu, as: UTF8.self))
                    }
                }
                if let destination {
                    Section(destination.rawValue) {
                        Text("L’élément reste dans la file de réception.")
                    }
                } else {
                    Section("Destination") {
                        Button("Recette") { destination = .recette }
                        Button("Articles de courses") { destination = .courses }
                    }
                }
                Button("Abandonner", role: .destructive) {
                    Task {
                        do {
                            try await abandonner()
                        } catch {
                            echecAbandon = true
                        }
                    }
                }
            }
            .navigationTitle("Élément reçu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { fermer() }
                }
            }
            .alert("Impossible d’abandonner cet élément", isPresented: $echecAbandon) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

struct ActionsReception: View {
    let reception: ReceptionEntree

    var body: some View {
        VStack {
            if let message = reception.message {
                Text(message)
            }
            if let prochain = reception.premier {
                Button("Reprendre l’import") { reception.affiche = prochain }
            }
            PasteButton(supportedContentTypes: [.url, .plainText, .text]) { fournisseurs in
                Task { await reception.coller(fournisseurs) }
            }
        }
        .padding()
    }
}
