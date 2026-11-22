import OSLog
import PersilladeCore
import SwiftUI

struct VignetteMotif: View {
    let planche: Planche
    var cadrage: Planche.Cadrage = .vignette

    var body: some View {
        ImagePlanche(planche: planche, cadrage: cadrage, animer: false)
            .clipShape(.rect(cornerRadius: cadrage == .miniature ? 5 : 0))
    }
}

struct EnTeteMotif: View {
    let planche: Planche
    var cadrage: Planche.Cadrage = .fiche

    var body: some View {
        ImagePlanche(planche: planche, cadrage: cadrage, animer: true)
    }
}

private struct ImagePlanche: View {
    let planche: Planche
    let cadrage: Planche.Cadrage
    let animer: Bool

    @Environment(\.colorScheme) private var apparence
    @Environment(\.colorSchemeContrast) private var contraste
    @Environment(\.displayScale) private var echelle
    @Environment(\.accessibilityReduceMotion) private var mouvementReduit
    @State private var rendu: (demande: DemandePlanche, image: CGImage)?

    var body: some View {
        GeometryReader { geometrie in
            let demande = DemandePlanche(
                planche: planche, cadrage: cadrage, largeur: geometrie.size.width, hauteur: geometrie.size.height,
                echelle: echelle, sombre: apparence == .dark, contrasteAccru: contraste == .increased)
            Color(motif: planche.fond.couleur(sombre: apparence == .dark))
                .overlay {
                    if let rendu, rendu.demande == demande {
                        Image(decorative: rendu.image, scale: echelle)
                            .resizable()
                            .transition(.opacity)
                    }
                }
                .task(id: demande) {
                    guard let demande else {
                        rendu = nil
                        return
                    }
                    do {
                        let image = try await RenduPlanche.partage.image(demande)
                        try Task.checkCancellation()
                        withAnimation(animer && !mouvementReduit ? .easeInOut(duration: 0.15) : nil) {
                            rendu = (demande, image)
                        }
                    } catch is CancellationError {
                    } catch {
                        Logger(subsystem: "xyz.g1lom.persillade", category: "Motif")
                            .error("Rendu du motif impossible : \(error.localizedDescription)")
                    }
                }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

extension Color {
    init(motif valeur: UInt32) {
        let c = composantesSRGB(valeur)
        self.init(.sRGB, red: c.rouge, green: c.vert, blue: c.bleu)
    }
}
