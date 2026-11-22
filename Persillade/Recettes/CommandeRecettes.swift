import SwiftUI

struct CommandeRecettes: View {
    let titre: String
    var symbole: String?
    var principale = false
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var taille

    var body: some View {
        Group {
            if principale {
                bouton
                    .buttonStyle(.glassProminent)
                    .tint(CouleurPersillade.persil.couleur)
            } else {
                bouton.buttonStyle(.glass)
            }
        }
        .controlSize(.large)
        .accessibilityShowsLargeContentViewer()
    }

    private var bouton: some View {
        Button(action: action) {
            HStack(spacing: GrillePersillade.pas * 2) {
                if let symbole, !taille.isAccessibilitySize {
                    Image(systemName: symbole)
                        .accessibilityHidden(true)
                }
                Text(titre)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .typographie(.bouton)
            .frame(maxWidth: .infinity, minHeight: GrillePersillade.cible)
        }
    }
}
