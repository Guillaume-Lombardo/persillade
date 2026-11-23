import PersilladeCore
import PersilladePlateforme
import SwiftUI

@MainActor
@Observable
final class ReceptionEntree {
    private let file: Result<FileEntree, any Error>
    private let magasinPhotos: MagasinPhotos
    private var numeroLecture = 0
    private var partages: [ContenuRecu] = []
    private var photos: [ContenuRecu] = []

    var contenus: [ContenuRecu] {
        var restantes = photos[...]
        var resultat: [ContenuRecu] = []
        for contenu in partages {
            while let premiere = restantes.first, premiere.recuLe < contenu.recuLe {
                resultat.append(premiere)
                restantes = restantes.dropFirst()
            }
            resultat.append(contenu)
        }
        return resultat + restantes
    }
    private(set) var textesDeRepli: [UUID: String] = [:]
    private(set) var message: String?

    init(dossier: URL? = nil) {
        file = Result {
            if let dossier { return FileEntree(dossier: dossier.appending(path: "Entree")) }
            return try FileEntree.groupeApplication()
        }
        magasinPhotos = dossier.map { MagasinPhotos(dossier: $0.appending(path: "PhotosImport")) } ?? MagasinPhotos()
    }

    func actualiser() async {
        numeroLecture += 1
        let numero = numeroLecture
        var lecturePartage: FileEntree.Lecture?
        var lecturePhotos: FileEntree.Lecture?
        var messages: [String] = []
        do {
            lecturePartage = try await file.get().lire()
        } catch {
            messages.append("Impossible de lire les éléments reçus.")
        }
        do {
            lecturePhotos = try await magasinPhotos.lire()
        } catch {
            messages.append("Impossible de lire les photos d’import.")
        }
        guard numero == numeroLecture else { return }
        if let lecture = lecturePartage {
            partages = lecture.contenus
            textesDeRepli = lecture.textesDeRepli
        }
        if let lecture = lecturePhotos { photos = lecture.contenus }
        if [lecturePartage, lecturePhotos].contains(where: { $0?.fichiersIllisibles.isEmpty == false }) {
            messages.append("Des éléments illisibles ont été mis de côté.")
        }
        message = messages.isEmpty ? nil : messages.joined(separator: " ")
    }

    func deposer(_ contenu: ContenuRecu) async throws {
        try await file.get().deposer(contenu)
        await actualiser()
    }

    func deposerPhoto(_ image: Data, origine: ContenuRecu.Origine) async throws -> ContenuRecu {
        let contenu = try await magasinPhotos.deposer(image, origine: origine)
        await actualiser()
        return contenu
    }

    func garderTexteDeRepli(_ texte: String, pour id: UUID) async throws {
        try await file.get().garderTexteDeRepli(texte, pour: id)
        textesDeRepli[id] = texte
        await actualiser()
    }

    func retirer(_ contenu: ContenuRecu) async throws {
        if photos.contains(where: { $0.id == contenu.id })
            || contenu.origine == .appareilPhoto || contenu.origine == .phototheque
        {
            try await magasinPhotos.retirer(id: contenu.id)
            photos.removeAll { $0.id == contenu.id }
        } else {
            try await file.get().retirer(id: contenu.id)
            partages.removeAll { $0.id == contenu.id }
            textesDeRepli[contenu.id] = nil
        }
        await actualiser()
    }
}

extension ContenuRecu {
    var texteRecu: String {
        type == .image ? "Image" : String(decoding: contenu, as: UTF8.self)
    }

    var libelleType: String {
        switch type {
        case .url: "Lien"
        case .texte: "Texte"
        case .image: "Photo"
        }
    }

    var libelleOrigine: String {
        switch origine {
        case .feuillePartage: "Partage iOS"
        case .pressePapiers: "Presse-papiers"
        case .appareilPhoto: "Appareil photo"
        case .phototheque: "Photothèque"
        }
    }
}

struct AccessoireReception: View {
    let contenus: [ContenuRecu]
    let ouvrir: () -> Void

    @Environment(\.tabViewBottomAccessoryPlacement) private var placement
    @Environment(\.dynamicTypeSize) private var taille

    var body: some View {
        if let premier = contenus.first {
            HStack(spacing: GrillePersillade.pas * 2) {
                Image(systemName: "tray.and.arrow.down")
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    let nombre = contenus.count
                    if placement == .inline || taille.isAccessibilitySize {
                        Text(nombre == 1 ? "1 reçu" : "\(nombre) reçus").typographie(.precision)
                    } else {
                        Text(nombre == 1 ? "1 contenu reçu" : "\(nombre) contenus reçus").typographie(.bouton)
                    }
                    if placement != .inline {
                        Text("\(premier.libelleType), \(premier.recuLe.formatted(date: .omitted, time: .shortened))")
                            .typographie(.precision)
                    }
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: 0)
                Button(action: ouvrir) {
                    Text("Ouvrir").typographie(.bouton)
                        .frame(minHeight: GrillePersillade.cible)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.regular)
                .accessibilityIdentifier("ouvrir-contenu-recu")
            }
            .padding(.horizontal, GrillePersillade.marge)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
    }
}
