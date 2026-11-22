import OSLog
import PersilladeCore
import SwiftUI
import UIKit

struct PresentationQuantite {
    var nombre: String?
    var unite: String?

    init(nombre: String?, unite: String?) {
        self.nombre = nombre
        self.unite = unite
    }

    init(_ quantite: Quantite?, _ unite: Unite?) throws {
        guard let quantite else { return }
        guard let unite else {
            nombre = quantite.texteFrancais
            return
        }
        let texte = try formaterQuantiteCourses(quantite, unite: unite)
        let morceaux = texte.split(separator: " ", maxSplits: 1).map(String.init)
        nombre = morceaux.first
        self.unite = morceaux.dropFirst().first
        if unite == .cac || unite == .cas { self.unite = unite.libellePersillade }
    }

    init(ligne: LigneCourses) {
        do {
            self = try Self(ligne.quantiteArrondie, ligne.unite)
        } catch {
            Logger(subsystem: "xyz.g1lom.persillade", category: "Courses").error(
                "Quantité de courses illisible : \(String(describing: error), privacy: .private)")
            self = Self(nombre: "Quantité indisponible", unite: nil)
        }
    }
}

struct PresentationEnvoi {
    let marque: LigneArticle.Marque
    private let etatLigne: EtatEnvoiLigne?
    var echec: Bool {
        guard let etatLigne else { return true }
        if case .echec = etatLigne { return true }
        return false
    }
    var traitee: Bool { etatLigne == .envoyee || etatLigne == .rienAAjouter }

    init(etat: EtatCourses, ligne: LigneCourses) {
        do {
            let etatLigne = try etat.etatEnvoi(de: ligne)
            switch etatLigne {
            case .aEnvoyer:
                marque = .init(libelle: "À envoyer", symbole: "arrow.up.circle", couleur: .persil)
            case .envoyee:
                marque = .init(libelle: "Envoyé", symbole: "arrow.up.circle.fill", couleur: .encre2, discrete: true)
            case .rienAAjouter:
                marque = .init(libelle: "Rien à ajouter", symbole: "checkmark.circle", couleur: .encre2, discrete: true)
            case .supplement(let quantite, let unite):
                let complement = try formaterQuantiteCourses(quantite, unite: unite)
                marque = .init(libelle: "\(complement) de plus à envoyer", symbole: "arrow.up.circle", couleur: .persil)
            case .echec:
                marque = .init(libelle: "Échec de l’envoi", symbole: "exclamationmark.triangle.fill", couleur: .tomate)
            }
            self.etatLigne = etatLigne
        } catch {
            etatLigne = nil
            Logger(subsystem: "xyz.g1lom.persillade", category: "Courses").error(
                "État d’envoi illisible : \(String(describing: error), privacy: .private)")
            marque = .init(
                libelle: "État d’envoi indisponible", symbole: "exclamationmark.triangle.fill", couleur: .tomate)
        }
    }
}

struct ActionSecondaireCourses: View {
    let libelle: String
    let symbole: String
    var couleur = CouleurPersillade.encre
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            LabelActionCourses(libelle: libelle, symbole: symbole, couleur: couleur)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(libelle)
        .accessibilityShowsLargeContentViewer { Label(libelle, systemImage: symbole) }
    }
}

struct LabelActionCourses: View {
    let libelle: String
    let symbole: String
    var couleur = CouleurPersillade.encre

    @Environment(\.dynamicTypeSize) private var taille
    @Environment(\.isEnabled) private var actif

    var body: some View {
        ViewThatFits(in: .horizontal) {
            if !taille.isAccessibilitySize {
                Label(libelle, systemImage: symbole)
                    .typographie(.bouton)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 14)
            }
            Image(systemName: symbole)
                .font(.headline)
                .frame(width: 52)
        }
        .frame(minHeight: 52)
        .foregroundStyle((actif ? couleur : .encre2).couleur)
        .background(CouleurPersillade.page2.couleur, in: .capsule)
        .contentShape(.capsule)
    }
}

struct FeuilleCourses<Contenu: View>: View {
    @Environment(\.dismiss) private var fermer
    let titre: String
    let fermetureInterdite: Bool
    @ViewBuilder var contenu: () -> Contenu

    init(
        _ titre: String, fermetureInterdite: Bool = false, @ViewBuilder contenu: @escaping () -> Contenu
    ) {
        self.titre = titre
        self.fermetureInterdite = fermetureInterdite
        self.contenu = contenu
    }

    var body: some View {
        NavigationStack {
            contenu()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CouleurPersillade.page.couleur)
                .navigationTitle(titre)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer") { fermer() }
                            .disabled(fermetureInterdite)
                    }
                }
        }
        .tint(CouleurPersillade.persil.couleur)
        .presentationBackground(CouleurPersillade.page.couleur)
    }
}

struct AccesRappels: View {
    @Environment(\.dismiss) private var fermer
    @Environment(\.openURL) private var ouvrirURL

    var body: some View {
        ScrollView {
            EtatVide(
                titre: "Persillade n’a pas accès à Rappels.",
                message: "Autorisez l’accès complet dans Réglages. La liste de courses est conservée."
            ) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(CouleurPersillade.tomate.couleur)
                    .padding(.horizontal, GrillePersillade.marge)
            } actions: {
                EmptyView()
            }
            .padding(.top, GrillePersillade.marge)
        }
        .barreAction(tailleMax: .accessibility5) {
            HStack {
                ActionSecondaireCourses(libelle: "Plus tard", symbole: "clock", action: { fermer() })
                BoutonActionPersillade("Ouvrir Réglages", symbole: "gear", action: ouvrirReglages)
            }
        }
    }

    private func ouvrirReglages() {
        if let url = URL(string: UIApplication.openSettingsURLString) { ouvrirURL(url) }
    }
}

extension View {
    func erreurCourses(_ session: SessionCourses) -> some View {
        alert(
            session.erreur ?? "",
            isPresented: Binding(
                get: { session.erreur != nil }, set: { if !$0 { session.erreur = nil } })
        ) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct BilanEnvoiCourses: View {
    let rapport: RapportEnvoi
    let session: SessionCourses
    let envoiEnCours: Bool
    let terminer: () -> Void
    let reessayer: () -> Void
    var choisir: (() -> Void)?
    var nouvelleListe: (() -> Void)?
    var ouvrirRappels: (() -> Void)?

    @Environment(\.openURL) private var ouvrirURL

    private var ecritures: Int { rapport.ajoutes.count + rapport.complements.count }
    private var aEchoue: Bool { !rapport.echecs.isEmpty || rapport.causeGenerale != nil }

    private var titre: String {
        let echecs = rapport.echecs.count
        if echecs > 0 {
            return "\(ecritures) envoyé\(ecritures > 1 ? "s" : ""), \(echecs) échec\(echecs > 1 ? "s" : "")"
        }
        if aEchoue { return "Envoi interrompu" }
        if ecritures == 0 { return "Rien à ajouter" }
        return ecritures == 1 ? "1 article envoyé" : "\(ecritures) articles envoyés"
    }

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 8) {
                Text(titre).typographie(.fiche)
                    .accessibilityAddTraits(.isHeader)
                if let destination = session.destination {
                    Label(destination.titre, systemImage: "checklist")
                        .typographie(.texte)
                }
                if let cause = rapport.causeGenerale {
                    Text(explication(cause)).typographie(.precision)
                    actionCause(cause)
                } else {
                    Text("Au magasin, cochez dans Rappels.").typographie(.precision)
                }
            }
            .foregroundStyle(CouleurPersillade.encre.couleur)
            .listRowSeparator(.hidden)
            .listRowBackground(CouleurPersillade.page.couleur)

            if aEchoue {
                Section {
                    ForEach(rapport.echecs, id: \.ligneId) { echec in
                        if let ligne = session.etat?.liste.ligne(id: echec.ligneId) {
                            let quantite = PresentationQuantite(ligne: ligne)
                            LigneArticle(
                                nom: ligne.libelle.lowercased(), quantite: quantite.nombre, unite: quantite.unite,
                                marque: .init(
                                    libelle: explication(echec.cause), symbole: "exclamationmark.triangle.fill",
                                    couleur: .tomate)
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(CouleurPersillade.page.couleur)
                        }
                    }
                    ActionSecondaireCourses(libelle: "Réessayer", symbole: "arrow.clockwise", action: reessayer)
                        .disabled(envoiEnCours)
                        .listRowBackground(CouleurPersillade.page.couleur)
                } header: {
                    bandeau("À réessayer", symbole: "exclamationmark.triangle.fill", nombre: rapport.echecs.count)
                }
            }

            if !rapport.complements.isEmpty {
                Section {
                    articles(rapport.complements, complement: true)
                } header: {
                    bandeau("Compléments", symbole: "plus.circle", nombre: rapport.complements.count)
                }
            }
            groupe("Déjà là", ids: rapport.ignores)
            groupe("Ajoutés", ids: rapport.ajoutes)
        }
        .listStyle(.plain)
        .listSectionSpacing(0)
        .scrollContentBackground(.hidden)
        .barreAction(tailleMax: .accessibility5) {
            HStack {
                ActionSecondaireCourses(
                    libelle: "Ouvrir Rappels", symbole: "arrow.up.forward.app", action: ouvrirListeRappels
                )
                BoutonActionPersillade(
                    "Terminé", symbole: "checkmark",
                    progression: envoiEnCours ? session.progressionEnvoi ?? 0 : nil, action: terminer)
            }
            .disabled(envoiEnCours)
        }
        .sensoryFeedback(aEchoue ? .warning : .success, trigger: rapport)
        .erreurCourses(session)
    }

    private func bandeau(_ titre: String, symbole: String, nombre: Int) -> some View {
        HStack {
            Label(titre, systemImage: symbole).typographie(.rayon)
            Spacer()
            if nombre > 0 { Text(nombre.formatted()).typographie(.precision) }
        }
        .foregroundStyle(CouleurPersillade.encre.couleur)
        .padding(.horizontal, GrillePersillade.marge)
        .frame(minHeight: GrillePersillade.rayon)
        .background(CouleurPersillade.page2.couleur)
        .listRowInsets(EdgeInsets())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private func groupe(_ titre: String, ids: [UUID]) -> some View {
        if !ids.isEmpty {
            DisclosureGroup {
                articles(ids)
            } label: {
                Text("\(titre) · \(ids.count)").typographie(.rayon)
            }
            .listRowBackground(CouleurPersillade.page2.couleur)
        }
    }

    @ViewBuilder
    private func articles(_ ids: [UUID], complement: Bool = false) -> some View {
        ForEach(ids, id: \.self) { id in
            if let ligne = session.etat?.liste.ligne(id: id) {
                let quantite = PresentationQuantite(ligne: ligne)
                LigneArticle(
                    nom: ligne.libelle.lowercased(), quantite: quantite.nombre, unite: quantite.unite,
                    precision: complement ? couverture(ligne) : nil
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(CouleurPersillade.page.couleur)
            }
        }
    }

    @ViewBuilder
    private func actionCause(_ cause: CauseEchecEnvoi) -> some View {
        if cause == .accesRefuse {
            Button("Ouvrir Réglages") {
                if let url = URL(string: UIApplication.openSettingsURLString) { ouvrirURL(url) }
            }
        } else if cause != .ecriture {
            if session.etat?.destinationVerrouillee == false, let choisir {
                Button("Choisir une liste", action: choisir)
            } else if cause == .listeIntrouvable, let nouvelleListe {
                Button("Nouvelle liste", action: nouvelleListe)
            }
        }
    }

    private func ouvrirListeRappels() {
        if let ouvrirRappels {
            ouvrirRappels()
        } else if let url = URL(string: "x-apple-reminderkit://") {
            ouvrirURL(url) { ouvert in
                if !ouvert { session.erreur = "Ouvrez l’app Rappels pour voir la liste." }
            }
        }
    }

    private func couverture(_ ligne: LigneCourses) -> String? {
        guard let etat = session.etat, let unite = ligne.unite,
            let dernier = etat.journal.entrees.last(where: { $0.listeId == etat.liste.id && $0.ligneId == ligne.id }),
            let complement = dernier.article.quantite
        else { return nil }
        do {
            guard let souhaite = try ligne.quantiteArrondie else { return nil }
            let couvert = try souhaite - complement
            let demande = try formaterQuantiteCourses(souhaite, unite: unite)
            let deja = try formaterQuantiteCourses(couvert, unite: unite)
            return "\(demande) voulus, \(deja) déjà demandés ou achetés"
        } catch {
            Logger(subsystem: "xyz.g1lom.persillade", category: "Courses").error(
                "Couverture illisible : \(String(describing: error), privacy: .private)")
            return "Complément ajouté"
        }
    }

    private func explication(_ cause: CauseEchecEnvoi) -> String {
        switch cause {
        case .accesRefuse: "Autorisez l’accès complet à Rappels dans Réglages."
        case .listeIntrouvable: "La liste choisie n’existe plus dans Rappels."
        case .listeNonModifiable: "La liste choisie est en lecture seule."
        case .ecriture: "Rappels a refusé l’écriture."
        }
    }
}
