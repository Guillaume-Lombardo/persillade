import SwiftUI
import UIKit

final class PartageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let contenu = UIHostingController(
            rootView: Partage { [weak self] in
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
    let fermer: () -> Void

    var body: some View {
        NavigationStack {
            ContentUnavailableView("Import indisponible", systemImage: "square.and.arrow.up")
                .navigationTitle("Persillade")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fermer", action: fermer)
                    }
                }
        }
    }
}
