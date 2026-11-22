import PersilladeCore
import SwiftUI

@MainActor
@Observable
final class ReceptionEntree {
    private let file: Result<FileEntree, any Error>
    private var numeroLecture = 0

    private(set) var contenus: [ContenuRecu] = []
    private(set) var message: String?

    init(dossier: URL? = nil) {
        file = Result {
            if let dossier { return FileEntree(dossier: dossier.appending(path: "Entree")) }
            return try FileEntree.groupeApplication()
        }
    }

    func actualiser() async {
        numeroLecture += 1
        let numero = numeroLecture
        do {
            let lecture = try await file.get().lire()
            guard numero == numeroLecture else { return }
            contenus = lecture.contenus
            message = lecture.fichiersIllisibles.isEmpty ? nil : "Des éléments illisibles ont été mis de côté."
        } catch {
            if numero == numeroLecture { message = "Impossible de lire les éléments reçus." }
        }
    }

    func deposer(_ contenu: ContenuRecu) async throws {
        try await file.get().deposer(contenu)
        await actualiser()
    }

    func retirer(_ contenu: ContenuRecu) async throws {
        try await file.get().retirer(id: contenu.id)
        contenus.removeAll { $0.id == contenu.id }
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
        case .image: "Image"
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

    var body: some View {
        if let premier = contenus.first {
            HStack(spacing: GrillePersillade.pas * 2) {
                Image(systemName: "tray.and.arrow.down")
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    let nombre = contenus.count
                    if placement == .inline {
                        Text(nombre == 1 ? "1 reçu" : "\(nombre) reçus").typographie(.precision)
                    } else {
                        Text(nombre == 1 ? "1 contenu reçu" : "\(nombre) contenus reçus").typographie(.bouton)
                        Text("\(premier.libelleType), \(premier.recuLe.formatted(date: .omitted, time: .shortened))")
                            .typographie(.precision)
                    }
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: 0)
                Button("Ouvrir", action: ouvrir)
                    .frame(minHeight: GrillePersillade.cible)
            }
            .padding(.horizontal, GrillePersillade.marge)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        }
    }
}
