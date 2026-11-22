import SwiftUI

struct BoutonActionPersillade: View {
    let libelle: String
    let action: () -> Void

    init(_ libelle: String, action: @escaping () -> Void) {
        self.libelle = libelle
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(libelle)
                .typographie(.bouton)
                .multilineTextAlignment(.center)
                .foregroundStyle(CouleurPersillade.surPersil.couleur)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .tint(CouleurPersillade.persil.couleur)
    }
}

struct BarreAction<Actions: View>: ViewModifier {
    @ViewBuilder let actions: () -> Actions

    func body(content: Content) -> some View {
        content.safeAreaBar(edge: .bottom, spacing: 0) {
            actions()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, GrillePersillade.margeBarre)
                .padding(.vertical, GrillePersillade.pas * 2)
                .tint(CouleurPersillade.persil.couleur)
        }
    }
}

extension View {
    func barreAction(@ViewBuilder _ actions: @escaping () -> some View) -> some View {
        modifier(BarreAction(actions: actions))
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
