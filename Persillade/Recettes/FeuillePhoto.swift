import AVFoundation
import CoreTransferable
import PersilladeCore
import PersilladePlateforme
import PhotosUI
import SwiftUI
import UIKit

enum SourcePhoto {
    case appareilPhoto, phototheque
}

struct FeuillePhoto: View {
    let source: SourcePhoto
    @Binding var occupation: Bool
    let saisir: () -> Void
    let valider: (Data, ContenuRecu.Origine) async throws -> Void

    @Environment(\.openURL) private var ouvrirURL
    @Environment(\.scenePhase) private var phase
    @State private var ouvertureDemandee = false
    @State private var phototheque = false
    @State private var selection: PhotosPickerItem?
    @State private var camera = false
    @State private var photoPrise: Result<Data, ErreurCapture>?
    @State private var message: String?
    @State private var proposerReglages = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GrillePersillade.pas * 3) {
                if occupation {
                    ProgressView("Préparation de la photo")
                } else {
                    if let message {
                        Label {
                            Text(message)
                        } icon: {
                            Image(systemName: "exclamationmark.circle").accessibilityHidden(true)
                        }
                        .typographie(.texte)
                        .foregroundStyle(CouleurPersillade.tomate.couleur)
                        .accessibilityIdentifier("photo-erreur")
                    }
                    if cameraDisponible {
                        CommandeRecettes(titre: "Prendre une photo", symbole: "camera", principale: true) {
                            Task { await ouvrirCamera() }
                        }
                    }
                    CommandeRecettes(titre: "Choisir une photo", symbole: "photo", principale: !cameraDisponible) {
                        phototheque = true
                    }
                    if proposerReglages {
                        CommandeRecettes(titre: "Ouvrir Réglages", symbole: "gear") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { ouvrirURL(url) }
                        }
                    }
                    if message != nil {
                        Button("Saisir la recette", systemImage: "pencil", action: saisir)
                            .frame(minHeight: GrillePersillade.cible)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(GrillePersillade.marge)
        }
        .background(CouleurPersillade.page.couleur.ignoresSafeArea())
        .photosPicker(
            isPresented: $phototheque, selection: $selection, matching: .images, preferredItemEncoding: .current
        )
        .onChange(of: selection) { _, element in
            guard let element else { return }
            selection = nil
            importer(.phototheque) {
                guard let photo = try await element.loadTransferable(type: PhotoSelectionnee.self) else {
                    throw ErreurCapture.imageIllisible
                }
                return photo.donnees
            }
        }
        .onChange(of: phase) { _, nouvellePhase in
            if nouvellePhase == .active, proposerReglages, cameraDisponible { effacerMessage() }
        }
        .fullScreenCover(isPresented: $camera, onDismiss: recevoirPhotoPrise) {
            AppareilPhoto { resultat in
                photoPrise = resultat
                camera = false
            }
            .ignoresSafeArea()
        }
        .task {
            guard !ouvertureDemandee else { return }
            ouvertureDemandee = true
            switch source {
            case .appareilPhoto: await ouvrirCamera()
            case .phototheque: phototheque = true
            }
        }
    }

    private var cameraDisponible: Bool {
        let statut = AVCaptureDevice.authorizationStatus(for: .video)
        return UIImagePickerController.isSourceTypeAvailable(.camera)
            && (statut == .authorized || statut == .notDetermined)
    }

    private func ouvrirCamera() async {
        guard !occupation else { return }
        effacerMessage()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            message = "L’appareil photo est indisponible."
            return
        }
        occupation = true
        defer { occupation = false }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            camera = true
        case .notDetermined:
            let autorise = await AVCaptureDevice.requestAccess(for: .video)
            guard !Task.isCancelled else { return }
            if autorise {
                camera = true
            } else {
                signalerAccesRefuse(reglages: true)
            }
        case .denied:
            signalerAccesRefuse(reglages: true)
        default:
            signalerAccesRefuse(reglages: false)
        }
    }

    private func signalerAccesRefuse(reglages: Bool) {
        message = "Persillade n’a pas accès à l’appareil photo."
        proposerReglages = reglages
    }

    private func recevoirPhotoPrise() {
        guard let resultat = photoPrise else { return }
        photoPrise = nil
        importer(.appareilPhoto) { try resultat.get() }
    }

    private func importer(_ origine: ContenuRecu.Origine, charger: @escaping () async throws -> Data) {
        guard !occupation else { return }
        effacerMessage()
        occupation = true
        Task {
            defer { occupation = false }
            do {
                let photo = try await charger()
                try await valider(photo, origine)
            } catch is CancellationError {
            } catch {
                message = (error as? ErreurCapture)?.errorDescription ?? "Impossible de charger cette photo."
            }
        }
    }

    private func effacerMessage() {
        message = nil
        proposerReglages = false
    }
}

private struct PhotoSelectionnee: Transferable {
    let donnees: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { PhotoSelectionnee(donnees: $0) }
    }
}

private struct AppareilPhoto: UIViewControllerRepresentable {
    let terminer: (Result<Data, ErreurCapture>?) -> Void

    func makeCoordinator() -> Coordinateur { Coordinateur(terminer: terminer) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controleur = UIImagePickerController()
        controleur.sourceType = .camera
        controleur.cameraCaptureMode = .photo
        controleur.delegate = context.coordinator
        return controleur
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinateur: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let terminer: (Result<Data, ErreurCapture>?) -> Void

        init(terminer: @escaping (Result<Data, ErreurCapture>?) -> Void) {
            self.terminer = terminer
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            terminer(nil)
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let image = info[.originalImage] as? UIImage, let photo = image.jpegData(compressionQuality: 0.95)
            else {
                terminer(.failure(.imageIllisible))
                return
            }
            terminer(.success(photo))
        }
    }
}
