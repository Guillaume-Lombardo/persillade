import PersilladeCore
import SwiftUI
import UIKit

final class PartageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let elements = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        let contenu = UIHostingController(
            rootView: Partage(fournisseurs: elements.flatMap { $0.attachments ?? [] }) { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil)
            })
        addChild(contenu)
        contenu.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contenu.view)
        NSLayoutConstraint.activate([
            contenu.view.topAnchor.constraint(equalTo: view.topAnchor),
            contenu.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contenu.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contenu.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        contenu.didMove(toParent: self)
    }
}

private struct Partage: View {
    private enum Etat {
        case chargement, ajoute, erreur
    }

    let fournisseurs: [NSItemProvider]
    let fermer: () -> Void
    @State private var etat = Etat.chargement

    var body: some View {
        NavigationStack {
            Group {
                switch etat {
                case .chargement:
                    ProgressView("Ajout en cours…")
                case .ajoute:
                    ContentUnavailableView("Ajouté à Persillade", systemImage: "checkmark.circle")
                case .erreur:
                    ContentUnavailableView(
                        "Impossible d’ajouter le contenu", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Persillade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if etat == .erreur {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fermer", action: fermer)
                    }
                }
            }
        }
        .task {
            guard etat == .chargement else { return }
            do {
                let contenu = try await ContenuRecu.charger(fournisseurs, origine: .feuillePartage)
                try await FileEntree.groupeApplication().deposer(contenu)
                etat = .ajoute
                try await Task.sleep(for: .milliseconds(650))
                fermer()
            } catch is CancellationError {
                return
            } catch {
                etat = .erreur
            }
        }
    }
}
