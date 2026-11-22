import PersilladeCore
import SwiftUI

struct EditeurQuantite: View {
    private enum Choix: Hashable {
        case unite(Unite)
        case personnalisee, sansUnite
    }

    private static let standards: [Unite] = [.g, .kg, .ml, .cl, .l, .piece, .cas, .cac]

    let enregistrer: (Quantite?, Unite?) -> Void

    @State private var texte: String
    @State private var choix: Choix
    @State private var autre: String
    @State private var erreur: String?
    @FocusState private var saisieQuantite: Bool

    init(quantite: Quantite?, unite: Unite?, enregistrer: @escaping (Quantite?, Unite?) -> Void) {
        self.enregistrer = enregistrer
        _texte = State(initialValue: quantite?.texteFrancais ?? "")
        if case .autre(let libelle) = unite {
            _choix = State(initialValue: .personnalisee)
            _autre = State(initialValue: libelle)
        } else {
            _choix = State(initialValue: unite.map(Choix.unite) ?? .sansUnite)
            _autre = State(initialValue: "")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
            TextField("Quantité", text: $texte)
                .typographie(.quantite)
                .keyboardType(.decimalPad)
                .focused($saisieQuantite)
                .accessibilityIdentifier("editeur-quantite")
                .padding(GrillePersillade.pas * 3)
                .background(CouleurPersillade.page2.couleur, in: .rect(cornerRadius: 8))
            Picker("Unité", selection: $choix) {
                Text("Sans unité").tag(Choix.sansUnite)
                ForEach(Self.standards, id: \.self) { unite in
                    Text(unite.libellePersillade).tag(Choix.unite(unite))
                }
                Text("Autre…").tag(Choix.personnalisee)
            }
            .pickerStyle(.menu)
            if choix == .personnalisee {
                TextField("Nom de l’unité", text: $autre)
                    .textFieldStyle(.roundedBorder)
            }
            if let erreur {
                Text(erreur).typographie(.alerte)
                    .foregroundStyle(CouleurPersillade.tomate.couleur)
                    .accessibilityAddTraits(.updatesFrequently)
            }
            ViewThatFits(in: .horizontal) {
                HStack { actions.fixedSize() }
                VStack(alignment: .leading) { actions }
            }
        }
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .tint(CouleurPersillade.persil.couleur)
    }

    @ViewBuilder private var actions: some View {
        BoutonActionPersillade("Valider", action: valider)
        Button("Effacer la quantité") {
            texte = ""
            erreur = nil
            saisieQuantite = false
            enregistrer(nil, nil)
        }
        .typographie(.bouton)
        .buttonStyle(.glass)
        .controlSize(.large)
    }

    private func valider() {
        guard let nombre = try? Quantite(texte: texte), nombre > Quantite(0) else {
            erreur = "Saisissez une quantité supérieure à zéro."
            saisieQuantite = true
            return
        }
        let unite: Unite?
        switch choix {
        case .sansUnite:
            unite = nil
        case .unite(let valeur):
            unite = valeur
        case .personnalisee:
            let nom = autre.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normaliserNom(nom).isEmpty else {
                erreur = "Indiquez le nom de l’unité."
                return
            }
            unite = .autre(nom)
        }
        erreur = nil
        saisieQuantite = false
        texte = nombre.texteFrancais
        enregistrer(nombre, unite)
    }
}
