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
    private let libelle: String
    private let symbole: String
    private let couleur: CouleurPersillade
    var echec = false

    init(etat: EtatCourses, ligne: LigneCourses) {
        do {
            switch try etat.etatEnvoi(de: ligne) {
            case .aEnvoyer:
                (libelle, symbole, couleur) = ("À envoyer", "arrow.up.circle", .persil)
            case .envoyee:
                (libelle, symbole, couleur) = ("Envoyé", "arrow.up.circle.fill", .encre2)
            case .rienAAjouter:
                (libelle, symbole, couleur) = ("Rien à ajouter", "checkmark.circle", .encre2)
            case .supplement(let quantite, let unite):
                let complement = try formaterQuantiteCourses(quantite, unite: unite)
                (libelle, symbole, couleur) = ("\(complement) de plus à envoyer", "arrow.up.circle", .persil)
            case .echec:
                (libelle, symbole, couleur) = ("Échec de l’envoi", "exclamationmark.triangle.fill", .tomate)
                echec = true
            }
        } catch {
            Logger(subsystem: "xyz.g1lom.persillade", category: "Courses").error(
                "État d’envoi illisible : \(String(describing: error), privacy: .private)")
            (libelle, symbole, couleur) = ("État d’envoi indisponible", "exclamationmark.triangle.fill", .tomate)
            echec = true
        }
    }

    @MainActor
    var marque: some View {
        Label(libelle, systemImage: symbole)
            .typographie(.precision)
            .foregroundStyle(couleur.couleur)
    }
}

struct ActionPrincipaleCourses: View {
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
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(CouleurPersillade.persil.couleur)
    }
}

struct FeuilleCourses<Contenu: View>: View {
    @Environment(\.dismiss) private var fermer
    let titre: String
    @ViewBuilder var contenu: () -> Contenu

    init(_ titre: String, @ViewBuilder contenu: @escaping () -> Contenu) {
        self.titre = titre
        self.contenu = contenu
    }

    var body: some View {
        NavigationStack {
            contenu()
                .navigationTitle(titre)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer") { fermer() }
                    }
                }
        }
        .tint(CouleurPersillade.persil.couleur)
    }
}

struct AccesRappels: View {
    @Environment(\.dismiss) private var fermer
    @Environment(\.openURL) private var ouvrirURL

    var body: some View {
        Form {
            Section {
                Label("Persillade n’a pas accès à Rappels.", systemImage: "lock.circle")
                Text("Autorisez l’accès complet dans Réglages. La liste de courses est conservée.")
                Button("Ouvrir Réglages", action: ouvrirReglages)
                Button("Plus tard", role: .cancel) { fermer() }
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
            "Persillade",
            isPresented: Binding(
                get: { session.erreur != nil }, set: { if !$0 { session.erreur = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(session.erreur ?? "")
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

    var body: some View {
        List {
            Section {
                let ecritures = rapport.ajoutes.count + rapport.complements.count
                Text(ecritures == 1 ? "1 rappel écrit" : "\(ecritures) rappels écrits")
                    .typographie(.rayon)
                    .accessibilityAddTraits(.isHeader)
                if let destination = session.destination {
                    Label(destination.titre, systemImage: "checklist")
                }
                if let cause = rapport.causeGenerale {
                    Text(explication(cause))
                    if cause == .accesRefuse {
                        Button("Ouvrir Réglages") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { ouvrirURL(url) }
                        }
                    } else if cause != .ecriture {
                        if session.etat?.destinationVerrouillee == false, let choisir {
                            Button("Choisir une liste", action: choisir)
                        } else if cause == .listeIntrouvable, let nouvelleListe {
                            Button("Nouvelle liste", action: nouvelleListe)
                        } else if cause == .listeNonModifiable, let ouvrirRappels {
                            Button("Ouvrir Rappels", action: ouvrirRappels)
                        }
                    }
                } else {
                    Text("Au magasin, cochez dans Rappels.")
                }
            }
            if !rapport.echecs.isEmpty {
                Section("À réessayer") {
                    ForEach(rapport.echecs, id: \.ligneId) { echec in
                        Label {
                            VStack(alignment: .leading) {
                                Text(session.etat?.liste.ligne(id: echec.ligneId)?.libelle ?? "Article")
                                Text(explication(echec.cause)).typographie(.precision)
                            }
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(CouleurPersillade.tomate.couleur)
                        }
                    }
                }
            }
            articles("Compléments", ids: rapport.complements, complement: true)
            articles("Aucun ajout nécessaire", ids: rapport.ignores)
            articles("Ajoutés", ids: rapport.ajoutes)
        }
        .listStyle(.insetGrouped)
        .barreAction {
            if envoiEnCours {
                ProgressView("Envoi vers Rappels", value: session.progressionEnvoi ?? 0)
            } else {
                ActionPrincipaleCourses(
                    rapport.echecs.isEmpty && rapport.causeGenerale == nil ? "Terminé" : "Réessayer",
                    action: rapport.echecs.isEmpty && rapport.causeGenerale == nil ? terminer : reessayer
                )
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
        }
        .sensoryFeedback(
            rapport.echecs.isEmpty && rapport.causeGenerale == nil ? .success : .warning,
            trigger: rapport
        )
        .erreurCourses(session)
    }

    @ViewBuilder
    private func articles(_ titre: String, ids: [UUID], complement: Bool = false) -> some View {
        if !ids.isEmpty {
            Section(titre) {
                ForEach(ids, id: \.self) { id in
                    if let ligne = session.etat?.liste.ligne(id: id) {
                        let quantite = PresentationQuantite(ligne: ligne)
                        LigneArticle(
                            nom: ligne.libelle, quantite: quantite.nombre, unite: quantite.unite,
                            precision: complement ? couverture(ligne) : nil
                        )
                        .listRowInsets(EdgeInsets())
                    }
                }
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
