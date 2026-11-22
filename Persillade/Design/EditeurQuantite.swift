import PersilladeCore
import SwiftUI

struct SaisieQuantite: Equatable {
    static let standards: [Unite] = [.g, .kg, .ml, .cl, .l, .piece, .cas, .cac]

    var texte: String
    var unite: Unite?
    var autre: String

    init(quantite: Quantite?, unite: Unite?) {
        texte = quantite?.texteFrancais ?? ""
        self.unite = unite
        if case .autre(let libelle) = unite {
            autre = libelle
        } else {
            autre = ""
        }
    }

    enum Erreur: LocalizedError {
        case nombre, unite

        var errorDescription: String? {
            switch self {
            case .nombre: "Saisissez une quantité supérieure à zéro."
            case .unite: "Indiquez le nom de l’unité."
            }
        }
    }

    func valider() throws -> (Quantite?, Unite?) {
        guard !texte.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return (nil, nil) }
        guard let nombre = try? Quantite(texte: texte), nombre > Quantite(0) else { throw Erreur.nombre }
        if case .autre = unite {
            let libelle = autre.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normaliserNom(libelle).isEmpty else { throw Erreur.unite }
            return (nombre, .autre(libelle))
        }
        return (nombre, unite)
    }
}

struct ChampQuantite: View {
    @Binding var texte: String

    var body: some View {
        TextField("Quantité", text: $texte)
            .typographie(.quantite)
            .keyboardType(.decimalPad)
            .accessibilityIdentifier("editeur-quantite")
            .padding(GrillePersillade.pas * 3)
            .background(CouleurPersillade.page2.couleur, in: .rect(cornerRadius: 8))
    }
}

struct ChoixUnite: View {
    @Binding var saisie: SaisieQuantite
    var uniteLue: Unite?

    private var unites: [Unite] {
        if let uniteLue { return [uniteLue] + SaisieQuantite.standards.filter { $0 != uniteLue } }
        return SaisieQuantite.standards
    }

    var body: some View {
        Picker("Unité", selection: $saisie.unite) {
            Text("Sans unité").tag(nil as Unite?)
            ForEach(unites, id: \.self) { unite in
                Text(unite.libellePersillade).tag(unite as Unite?)
            }
            Text("Autre…").tag(Unite.autre("") as Unite?)
        }
        .pickerStyle(.menu)
    }
}

struct ChampNomUnite: View {
    @Binding var nom: String

    var body: some View {
        TextField("Nom de l’unité", text: $nom)
            .textFieldStyle(.roundedBorder)
            .frame(minHeight: GrillePersillade.cible)
    }
}

struct EditeurQuantite: View {
    let enregistrer: (Quantite?, Unite?) -> Void

    @State private var saisie: SaisieQuantite
    @State private var erreur: String?
    @FocusState private var saisieQuantite: Bool
    @FocusState private var saisieUnite: Bool
    private let uniteLue: Unite?

    init(quantite: Quantite?, unite: Unite?, enregistrer: @escaping (Quantite?, Unite?) -> Void) {
        self.enregistrer = enregistrer
        uniteLue = unite
        _saisie = State(initialValue: SaisieQuantite(quantite: quantite, unite: unite))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
            ChampQuantite(texte: $saisie.texte).focused($saisieQuantite)
            ChoixUnite(saisie: $saisie, uniteLue: uniteLue)
            if case .autre = saisie.unite { ChampNomUnite(nom: $saisie.autre).focused($saisieUnite) }
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
            saisie.texte = ""
            erreur = nil
            saisieQuantite = false
            saisieUnite = false
            enregistrer(nil, nil)
        }
        .typographie(.bouton)
        .buttonStyle(.glass)
        .controlSize(.large)
    }

    private func valider() {
        do {
            let (nombre, unite) = try saisie.valider()
            guard let nombre else { throw SaisieQuantite.Erreur.nombre }
            erreur = nil
            saisieQuantite = false
            saisieUnite = false
            saisie.texte = nombre.texteFrancais
            enregistrer(nombre, unite)
        } catch {
            self.erreur = error.localizedDescription
            if case SaisieQuantite.Erreur.unite = error {
                saisieUnite = true
            } else {
                saisieQuantite = true
            }
        }
    }
}
