import PersilladeCore
import PersilladePlateforme
import SwiftUI

struct Reglages: View {
    private enum Champ: Hashable {
        case adresse, modele, cle
    }

    @Environment(\.dismiss) private var fermer
    @FocusState private var champActif: Champ?
    @State private var brouillon = ConfigurationFournisseur()
    @State private var cle = ""
    @State private var hoteAvecCle: HoteFournisseur?
    @State private var afficherConsentement = false
    @State private var confirmerSuppression = false
    @State private var messageErreur: String?

    private let stockage = ReglagesFournisseur.partage

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Utiliser un fournisseur externe", isOn: activationFournisseur)
                        .accessibilityIdentifier("fournisseur-actif")
                        .listRowBackground(CouleurPersillade.page2.couleur)
                } header: {
                    Text("Extraction de recettes et de messages")
                        .typographie(.section)
                        .textCase(nil)
                } footer: {
                    Text("Ce service intervient si l’extraction sur l’iPhone reste incomplète.")
                        .foregroundStyle(CouleurPersillade.encre2.couleur)
                }

                if brouillon.active {
                    Section {
                        champsFournisseur
                            .listRowBackground(CouleurPersillade.page2.couleur)
                    } header: {
                        Text("Fournisseur d’IA")
                            .typographie(.section)
                            .textCase(nil)
                    }

                    Section {
                        Toggle("Le modèle accepte les photos", isOn: $brouillon.accepteImages)
                            .accessibilityIdentifier("fournisseur-images")
                            .listRowBackground(CouleurPersillade.page2.couleur)
                    } footer: {
                        Text("Sans cette option, seul le texte lu sur les photos est envoyé.")
                            .foregroundStyle(CouleurPersillade.encre2.couleur)
                    }
                }

                if hoteAvecCle != nil {
                    Section {
                        Button("Supprimer la clé enregistrée", role: .destructive) { confirmerSuppression = true }
                            .foregroundStyle(CouleurPersillade.tomate.couleur)
                            .listRowBackground(CouleurPersillade.page2.couleur)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(CouleurPersillade.page.couleur.ignoresSafeArea())
            .foregroundStyle(CouleurPersillade.encre.couleur)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Réglages")
            .tint(CouleurPersillade.persil.couleur)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { fermer() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { enregistrer() }
                        .disabled(brouillon == stockage.configuration && cle.isEmpty)
                }
            }
            .task { recharger() }
            .sheet(isPresented: $afficherConsentement) {
                ConsentementFournisseur(
                    adresse: brouillon.adresseAPI,
                    accepteImages: brouillon.accepteImages,
                    accepter: {
                        brouillon.consentir()
                        afficherConsentement = false
                        enregistrer()
                    },
                    refuser: {
                        afficherConsentement = false
                        recharger()
                    }
                )
                .presentationBackground(CouleurPersillade.page.couleur)
            }
            .confirmationDialog(
                "Supprimer la clé d’API ?", isPresented: $confirmerSuppression, titleVisibility: .visible
            ) {
                Button("Supprimer la clé", role: .destructive) {
                    do {
                        try stockage.supprimerCle()
                        recharger()
                    } catch {
                        brouillon.active = stockage.configuration.active
                        signaler(error)
                    }
                }
            } message: {
                Text("Le fournisseur externe sera désactivé.")
            }
            .alert(
                "Réglages du fournisseur",
                isPresented: Binding(
                    get: { messageErreur != nil },
                    set: { if !$0 { messageErreur = nil } })
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(messageErreur ?? "")
            }
        }
        .presentationBackground(CouleurPersillade.page.couleur)
    }

    @ViewBuilder private var champsFournisseur: some View {
        TextField("Adresse de l’API (HTTPS)", text: $brouillon.adresse)
            .focused($champActif, equals: .adresse)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .accessibilityIdentifier("fournisseur-adresse")
        TextField("Nom du modèle", text: $brouillon.modele)
            .focused($champActif, equals: .modele)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .accessibilityIdentifier("fournisseur-modele")
        SecureField(cleEnregistree ? "Nouvelle clé d’API" : "Clé d’API", text: $cle)
            .focused($champActif, equals: .cle)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .accessibilityIdentifier("fournisseur-cle")
    }

    private var cleEnregistree: Bool {
        hoteAvecCle != nil && hoteAvecCle == brouillon.hote && hoteAvecCle == stockage.configuration.hote
    }

    private var activationFournisseur: Binding<Bool> {
        Binding {
            brouillon.active
        } set: { active in
            do {
                if !active { try stockage.desactiver() }
                brouillon.active = active
            } catch {
                signaler(error)
            }
        }
    }

    private func recharger() {
        cle = ""
        brouillon = stockage.configuration
        hoteAvecCle = nil
        do {
            hoteAvecCle = try stockage.hoteCleEnregistree()
        } catch {
            signaler(error)
        }
    }

    private func enregistrer() {
        champActif = nil
        do {
            try stockage.enregistrer(brouillon, nouvelleCle: cle)
            recharger()
        } catch ErreurReglagesFournisseur.consentement {
            afficherConsentement = true
        } catch {
            signaler(error)
        }
    }

    private func signaler(_ erreur: any Error) {
        messageErreur =
            switch erreur as? ErreurReglagesFournisseur {
            case .adresse: "Saisissez une adresse HTTPS, sans identifiants, paramètres ni fragment."
            case .modele: "Saisissez le nom du modèle."
            case .cle: "Saisissez une clé d’API valide pour cette adresse."
            case .trousseau: "Impossible d’accéder à la clé dans le trousseau de l’iPhone."
            default: "Impossible d’enregistrer ces réglages."
            }
    }
}

private struct ConsentementFournisseur: View {
    let adresse: URL?
    let accepteImages: Bool
    let accepter: () -> Void
    let refuser: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: GrillePersillade.pas * 4) {
                    information("Fournisseur", adresse?.absoluteString ?? "")
                    information(
                        "Données envoyées",
                        accepteImages
                            ? "Le texte des recettes et des messages, ainsi que les photos et le texte lu sur ces photos."
                            : "Le texte des recettes et des messages, y compris le texte lu sur les photos.")
                    information("Facturation", "Les frais éventuels du fournisseur sont à votre charge.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(GrillePersillade.marge)
            }
            .foregroundStyle(CouleurPersillade.encre.couleur)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: GrillePersillade.pas * 3) {
                    CommandeRecettes(titre: "Accepter et activer", principale: true, action: accepter)
                        .accessibilityIdentifier("fournisseur-accepter")
                    CommandeRecettes(titre: "Refuser", action: refuser)
                        .accessibilityIdentifier("fournisseur-refuser")
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .padding(.horizontal, GrillePersillade.margeBarre)
                .padding(.vertical, GrillePersillade.pas * 2)
                .background(CouleurPersillade.page.couleur)
            }
            .background(CouleurPersillade.page.couleur.ignoresSafeArea())
            .navigationTitle("Autoriser l’envoi")
            .navigationBarTitleDisplayMode(.large)
        }
        .interactiveDismissDisabled()
    }

    private func information(_ titre: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: GrillePersillade.pas) {
            Text(titre).typographie(.section).accessibilityAddTraits(.isHeader)
            Text(detail).typographie(.texte)
        }
    }
}
