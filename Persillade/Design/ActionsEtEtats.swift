import SwiftUI

extension EnvironmentValues {
    @Entry fileprivate var dansBarreAction = false
}

struct BoutonActionPersillade: View {
    let libelle: String
    let symbole: String?
    let progression: Double?
    let pleineLargeur: Bool
    let action: () -> Void

    @Environment(\.dansBarreAction) private var dansBarre
    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.isEnabled) private var actif

    init(
        _ libelle: String, symbole: String? = nil, progression: Double? = nil,
        pleineLargeur: Bool = false, action: @escaping () -> Void
    ) {
        self.libelle = libelle
        self.symbole = symbole
        self.progression = progression
        self.pleineLargeur = pleineLargeur
        self.action = action
    }

    var body: some View {
        if symbole == nil, !pleineLargeur, actif, progression == nil {
            Button(action: action) {
                libelleAction
                    .frame(maxWidth: dansBarre ? .infinity : nil)
                    .foregroundStyle(CouleurPersillade.surPersil.couleur)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(CouleurPersillade.persil.couleur)
        } else {
            boutonCapsule
        }
    }

    private var boutonCapsule: some View {
        Button(action: action) {
            libelleAction
                .opacity(progression == nil ? 1 : 0)
                .overlay {
                    if let progression {
                        ProgressView(value: progression)
                            .tint(CouleurPersillade.surPersil.couleur)
                            .padding(.horizontal, GrillePersillade.pas * 2)
                    }
                }
                .padding(.horizontal, taille.isAccessibilitySize ? GrillePersillade.pas : GrillePersillade.marge)
                .padding(.vertical, 6)
                .frame(minHeight: 52)
                .frame(maxWidth: pleineLargeur || dansBarre ? .infinity : nil)
                .foregroundStyle(
                    actif || progression != nil ? CouleurPersillade.surPersil.couleur : CouleurPersillade.encre2.couleur
                )
                .background(
                    actif || progression != nil ? CouleurPersillade.persil.couleur : CouleurPersillade.page2.couleur,
                    in: .capsule
                )
                .contentShape(.capsule)
        }
        .buttonStyle(StyleBoutonPersillade())
        .accessibilityLabel(progression == nil ? libelle : "Envoi vers Rappels")
        .accessibilityValue(progression?.formatted(.percent.precision(.fractionLength(0))) ?? "")
        .accessibilityShowsLargeContentViewer {
            if let symbole { Label(libelle, systemImage: symbole) } else { Text(libelle) }
        }
    }

    private var libelleAction: some View {
        HStack(spacing: GrillePersillade.pas * 2) {
            if let symbole, !taille.isAccessibilitySize {
                Image(systemName: symbole).accessibilityHidden(true)
            }
            Text(libelle)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .typographie(.bouton)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct StyleBoutonPersillade: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.84 : 1)
    }
}

struct BarreAction<Actions: View>: ViewModifier {
    let tailleMax: DynamicTypeSize
    @ViewBuilder let actions: () -> Actions

    func body(content: Content) -> some View {
        content.safeAreaBar(edge: .bottom, spacing: 0) {
            actions()
                .environment(\.dansBarreAction, true)
                .dynamicTypeSize(...tailleMax)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, GrillePersillade.margeBarre)
                .padding(.vertical, GrillePersillade.pas * 2)
                .tint(CouleurPersillade.persil.couleur)
        }
    }
}

extension View {
    func barreAction(
        tailleMax: DynamicTypeSize = .accessibility1, @ViewBuilder _ actions: @escaping () -> some View
    ) -> some View {
        modifier(BarreAction(tailleMax: tailleMax, actions: actions))
    }
}

struct EtatVide<Illustration: View, Actions: View>: View {
    let titre: String
    let message: String
    @ViewBuilder var illustration: () -> Illustration
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
            illustration().accessibilityHidden(true)
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
                Text(titre).typographie(.etatVide)
                    .foregroundStyle(CouleurPersillade.encre.couleur)
                    .accessibilityAddTraits(.isHeader)
                Text(message).typographie(.texte).foregroundStyle(CouleurPersillade.encre2.couleur)
                actions().tint(CouleurPersillade.persil.couleur)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GrillePersillade.marge)
        }
        .background(CouleurPersillade.page.couleur)
    }
}
