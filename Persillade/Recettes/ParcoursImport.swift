import PersilladeCore
import SwiftUI

struct ParcoursImport: View {
    private enum Etape {
        case coller, destination, lecture, echec, correction
    }

    let reception: ReceptionEntree
    let bibliotheque: BibliothequeRecettes
    let extracteur: Extracteur
    let fermer: () -> Void
    let terminer: (UUID?) -> Void
    let importerArticles: ((ContenuRecu) -> Void)?

    @Environment(\.displayScale) private var echelle
    @State private var etape: Etape
    @State private var recu: ContenuRecu?
    @State private var resultat: ResultatExtraction?
    @State private var recetteEnregistree: UUID?
    @State private var erreur: String?
    @State private var occupation = false
    @State private var confirmerAbandon = false

    init(
        initial: ContenuRecu?, reception: ReceptionEntree, bibliotheque: BibliothequeRecettes, extracteur: Extracteur,
        fermer: @escaping () -> Void, terminer: @escaping (UUID?) -> Void,
        importerArticles: ((ContenuRecu) -> Void)? = nil
    ) {
        self.reception = reception
        self.bibliotheque = bibliotheque
        self.extracteur = extracteur
        self.fermer = fermer
        self.terminer = terminer
        self.importerArticles = importerArticles
        _recu = State(initialValue: initial)
        _etape = State(initialValue: initial == nil ? .coller : .destination)
    }

    var body: some View {
        NavigationStack {
            switch etape {
            case .coller:
                FeuilleCollage(
                    texteSeulement: recu != nil, texteInitial: texteDeRepli ?? "", valider: accepterCollage
                )
                .navigationTitle(recu == nil ? "Coller" : "Coller le texte")
                .toolbar { boutonFermer }
            case .destination:
                if let recu {
                    destination(recu)
                        .navigationTitle("Destination")
                        .toolbar { boutonFermer }
                }
            case .lecture:
                ProgressView("Lecture de la recette")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Import de la recette")
                    .barreAction { BoutonActionPersillade("Annuler") { etape = .destination } }
                    .task { await lire() }
            case .echec:
                ecranEchec
                    .navigationTitle("Import de la recette")
                    .toolbar { boutonFermer }
            case .correction:
                if let recu, let resultat {
                    CorrectionRecette(
                        donnees: .init(id: recu.id, resultat: resultat, url: lienRecu),
                        fermer: fermer
                    ) { recette in
                        if recetteEnregistree == nil {
                            try await bibliotheque.enregistrer(recette, modification: false, echelle: echelle)
                            recetteEnregistree = recette.id
                        }
                        do {
                            try await reception.retirer(recu)
                        } catch {
                            throw ErreurClotureImport.retrait
                        }
                        terminer(recette.id)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(CouleurPersillade.persil.couleur)
        .presentationDetents(etape == .correction ? [.large] : [.medium, .large])
        .interactiveDismissDisabled(occupation || etape == .lecture || etape == .correction)
        .alert(
            "Import de la recette",
            isPresented: Binding(get: { erreur != nil }, set: { if !$0 { erreur = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(erreur ?? "")
        }
    }

    private var texteDeRepli: String? {
        recu.flatMap { reception.textesDeRepli[$0.id] }
    }

    private var lienRecu: URL? {
        guard let recu, recu.type == .url else { return nil }
        return URL(string: recu.texteRecu)
    }

    private var boutonFermer: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Fermer") {
                if etape == .coller, recu != nil {
                    etape = .echec
                } else {
                    fermer()
                }
            }
            .disabled(occupation)
        }
    }

    private func destination(_ contenu: ContenuRecu) -> some View {
        let position = reception.contenus.firstIndex { $0.id == contenu.id }
        let suivant = reception.contenus.first { $0.id != contenu.id }
        return ScrollView {
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
                if let position, reception.contenus.count > 1 {
                    Text("\(position + 1) sur \(reception.contenus.count)").typographie(.precision)
                }
                Text(contenu.texteRecu)
                    .typographie(.section)
                    .lineLimit(3)
                    .accessibilityAddTraits(.isHeader)
                Text(
                    "\(contenu.libelleType) · \(contenu.libelleOrigine) · \(contenu.recuLe.formatted(date: .omitted, time: .shortened))"
                )
                .typographie(.precision)
                .foregroundStyle(CouleurPersillade.encre2.couleur)
                if texteDeRepli != nil {
                    Label("Texte collé disponible", systemImage: "doc.text")
                        .typographie(.precision)
                }
                BoutonActionPersillade("Recette") { etape = .lecture }
                    .disabled(occupation)
                if let importerArticles {
                    Button("Articles de courses") { importerArticles(contenu) }
                        .buttonStyle(.glass)
                        .controlSize(.large)
                        .disabled(occupation)
                }
                Button("Abandonner", role: .destructive) { confirmerAbandon = true }
                    .frame(minHeight: GrillePersillade.cible)
                    .tint(CouleurPersillade.tomate.couleur)
                    .disabled(occupation)
                if let suivant {
                    Text(
                        "Ensuite : \(suivant.libelleType), \(suivant.recuLe.formatted(date: .omitted, time: .shortened))"
                    )
                    .typographie(.precision)
                    .foregroundStyle(CouleurPersillade.encre2.couleur)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(GrillePersillade.marge)
        }
        .confirmationDialog("Abandonner ce contenu ?", isPresented: $confirmerAbandon, titleVisibility: .visible) {
            Button("Abandonner", role: .destructive) { Task { await abandonner(contenu) } }
        } message: {
            Text("Il sera retiré des contenus reçus.")
        }
    }

    private var ecranEchec: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
                Label(messageEchec, systemImage: "exclamationmark.circle")
                    .typographie(.alerte)
                    .foregroundStyle(CouleurPersillade.tomate.couleur)
                    .accessibilityAddTraits(.isHeader)
                if let texte = resultat?.texteSource, !texte.isEmpty {
                    Text(texte).typographie(.texte)
                        .textSelection(.enabled)
                }
                if recetteEnregistree != nil {
                    BoutonActionPersillade("Réessayer") { etape = .lecture }
                } else if resultat?.messageAccesPage != nil || resultat == nil {
                    if texteDeRepli != nil || resultat?.cause != .horsLigne {
                        Button("Réessayer") { etape = .lecture }
                            .frame(minHeight: GrillePersillade.cible)
                    }
                    if recu?.type == .url {
                        BoutonActionPersillade("Coller le texte") { etape = .coller }
                    }
                } else {
                    BoutonActionPersillade("Saisir") { etape = .correction }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(GrillePersillade.marge)
        }
        .background(CouleurPersillade.page2.couleur)
    }

    private var messageEchec: String {
        if recetteEnregistree != nil { return ErreurClotureImport.message }
        if let erreur = resultat?.erreurAccesPage?.errorDescription { return erreur }
        switch resultat?.cause {
        case .horsLigne: return "L’iPhone est hors ligne. Le lien est gardé."
        case .pageInaccessible, .delai: return "La page ne répond pas. Le lien est gardé."
        case .none: return "Impossible de lire la recette. Le contenu est gardé."
        default: return "Aucune recette trouvée dans ce texte. Il reste affiché pour la saisie."
        }
    }

    private func accepterCollage(_ contenu: ContenuRecu) async throws {
        if let recu {
            try await reception.garderTexteDeRepli(contenu.texteRecu, pour: recu.id)
            etape = .lecture
        } else {
            try await reception.deposer(contenu)
            recu = contenu
            etape = .destination
        }
    }

    private func lire() async {
        guard let recu else { return }
        do {
            if let dejaEnregistree = try await bibliotheque.lire(recu.id) {
                try Task.checkCancellation()
                recetteEnregistree = dejaEnregistree.id
                try await reception.retirer(recu)
                terminer(dejaEnregistree.id)
            } else {
                let entree =
                    texteDeRepli.map {
                        ContenuRecu(id: recu.id, type: .texte, contenu: Data($0.utf8), origine: .pressePapiers)
                    } ?? recu
                let lecture = try await extracteur.extraire(entree, cible: .recette)
                try Task.checkCancellation()
                resultat = lecture
                etape = lecture.statut == .echec ? .echec : .correction
            }
        } catch is CancellationError {
        } catch {
            if !Task.isCancelled {
                resultat = nil
                etape = .echec
            }
        }
    }

    private func abandonner(_ contenu: ContenuRecu) async {
        guard !occupation else { return }
        occupation = true
        defer { occupation = false }
        do {
            try await reception.retirer(contenu)
            terminer(nil)
        } catch {
            self.erreur = "Impossible d’abandonner ce contenu. Il est gardé."
        }
    }
}

enum ErreurClotureImport: Error {
    case retrait

    static let message = "La recette est enregistrée. Le contenu reçu reste dans la file."
}

private struct FeuilleCollage: View {
    let texteSeulement: Bool
    let valider: (ContenuRecu) async throws -> Void

    @State private var texte: String
    @State private var erreur: String?
    @State private var occupation = false

    init(texteSeulement: Bool, texteInitial: String, valider: @escaping (ContenuRecu) async throws -> Void) {
        self.texteSeulement = texteSeulement
        self.valider = valider
        _texte = State(initialValue: texteInitial)
    }

    private func contenu(_ valeur: String) -> ContenuRecu? {
        if texteSeulement {
            guard !valeur.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return ContenuRecu(type: .texte, contenu: Data(valeur.utf8), origine: .pressePapiers)
        }
        return ContenuRecu(texte: valeur, origine: .pressePapiers)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
                TextField(texteSeulement ? "Texte de la recette" : "Lien ou texte", text: $texte, axis: .vertical)
                    .lineLimit(3...7)
                    .padding(GrillePersillade.pas * 3)
                    .background(CouleurPersillade.page2.couleur, in: .rect(cornerRadius: 8))
                    .accessibilityIdentifier("texte-colle")
                PasteButton(supportedContentTypes: texteSeulement ? [.plainText, .text] : [.url, .plainText, .text]) {
                    fournisseurs in
                    Task {
                        do {
                            let recu = try await ContenuRecu.charger(fournisseurs, origine: .pressePapiers)
                            texte = recu.texteRecu
                            erreur = nil
                        } catch {
                            self.erreur = "Impossible de lire le presse-papiers."
                        }
                    }
                }
                .labelStyle(.titleAndIcon)
                .controlSize(.large)
                .accessibilityIdentifier("coller-presse-papiers")
                if let erreur {
                    Text(erreur).typographie(.alerte).foregroundStyle(CouleurPersillade.tomate.couleur)
                }
            }
            .padding(GrillePersillade.marge)
        }
        .background(CouleurPersillade.page.couleur)
        .barreAction {
            BoutonActionPersillade("Continuer") {
                guard !occupation, let recu = contenu(texte) else { return }
                occupation = true
                Task {
                    defer { occupation = false }
                    do {
                        try await valider(recu)
                    } catch {
                        self.erreur = "Impossible de garder le contenu. Réessayez."
                    }
                }
            }
            .disabled(occupation || texte.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .interactiveDismissDisabled(occupation)
    }
}
