import Foundation

public actor FileEntree {
    public enum Erreur: Error, Equatable, Sendable {
        case groupeIndisponible
        case ordreEpuise
        case lienAbsent
    }

    public struct Lecture: Sendable {
        public let contenus: [ContenuRecu]
        public let textesDeRepli: [UUID: String]
        public let fichiersIllisibles: [URL]
    }

    private struct Depot: Codable {
        let contenu: ContenuRecu
        var texteDeRepli: String?

        private enum CodingKeys: String, CodingKey {
            case texteDeRepli = "texte_de_repli"
        }

        init(from decoder: any Decoder) throws {
            contenu = try ContenuRecu(from: decoder)
            let champs = try decoder.container(keyedBy: CodingKeys.self)
            texteDeRepli = try champs.decodeIfPresent(String.self, forKey: .texteDeRepli)
        }

        func encode(to encoder: any Encoder) throws {
            try contenu.encode(to: encoder)
            var champs = encoder.container(keyedBy: CodingKeys.self)
            try champs.encodeIfPresent(texteDeRepli, forKey: .texteDeRepli)
        }
    }

    private let dossier: URL

    public init(dossier: URL) {
        self.dossier = dossier
    }

    public static func groupeApplication() throws -> FileEntree {
        guard
            let groupe = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.xyz.g1lom.persillade")
        else {
            throw Erreur.groupeIndisponible
        }
        return FileEntree(dossier: groupe.appending(path: "Entree", directoryHint: .isDirectory))
    }

    public func deposer(_ contenu: ContenuRecu) throws {
        let donnees = try JSONEncoder().encode(contenu)
        try avecDossier { dossier, fichiers in
            let suffixe = "-\(contenu.id.uuidString).json"
            guard !fichiers.contains(where: { $0.lastPathComponent.hasSuffix(suffixe) }) else { return }
            let dernier = fichiers.compactMap(Self.ordre).max() ?? 0
            guard dernier < UInt64.max else { throw Erreur.ordreEpuise }
            let nom = String(format: "%020llu", dernier + 1) + suffixe
            try donnees.write(to: dossier.appending(path: nom), options: .atomic)
        }
    }

    public func lire() throws -> Lecture {
        try avecDossier { dossier, fichiers in
            var contenus: [ContenuRecu] = []
            var replis: [UUID: String] = [:]
            var illisibles: [URL] = []
            // Le préfixe attribué sous coordination suit l'ordre de dépôt des deux processus.
            for fichier in fichiers.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                if let depot = try Self.decoder(fichier) {
                    contenus.append(depot.contenu)
                    replis[depot.contenu.id] = depot.texteDeRepli
                    continue
                }
                let quarantaine = dossier.appending(path: "Illisibles", directoryHint: .isDirectory)
                try FileManager.default.createDirectory(at: quarantaine, withIntermediateDirectories: true)
                let copie = quarantaine.appending(path: "\(UUID().uuidString)-\(fichier.lastPathComponent)")
                try FileManager.default.moveItem(at: fichier, to: copie)
                illisibles.append(copie)
            }
            return Lecture(contenus: contenus, textesDeRepli: replis, fichiersIllisibles: illisibles)
        }
    }

    public func garderTexteDeRepli(_ texte: String, pour id: UUID) throws {
        try avecDossier { _, fichiers in
            let suffixe = "-\(id.uuidString).json"
            guard let fichier = fichiers.first(where: { $0.lastPathComponent.hasSuffix(suffixe) }),
                var depot = try Self.decoder(fichier), depot.contenu.type == .url
            else { throw Erreur.lienAbsent }
            depot.texteDeRepli = texte
            try JSONEncoder().encode(depot).write(to: fichier, options: .atomic)
        }
    }

    public func retirer(id: UUID) throws {
        try avecDossier { _, fichiers in
            let suffixe = "-\(id.uuidString).json"
            if let fichier = fichiers.first(where: { $0.lastPathComponent.hasSuffix(suffixe) }) {
                try FileManager.default.removeItem(at: fichier)
            }
        }
    }

    private func avecDossier<Resultat>(
        _ operation: (URL, [URL]) throws -> Resultat
    ) throws -> Resultat {
        try coordonnerEcriture(dossier) { dossier in
            let gestionnaire = FileManager.default
            try gestionnaire.createDirectory(at: dossier, withIntermediateDirectories: true)
            let fichiers = try gestionnaire.contentsOfDirectory(
                at: dossier, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]
            )
            .filter { $0.pathExtension == "json" }
            return try operation(dossier, fichiers)
        }
    }

    private static func decoder(_ fichier: URL) throws -> Depot? {
        guard ordre(fichier) != nil,
            try fichier.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true
        else { return nil }
        let donnees = try Data(contentsOf: fichier)
        do {
            let depot = try JSONDecoder().decode(Depot.self, from: donnees)
            return fichier.lastPathComponent.hasSuffix("-\(depot.contenu.id.uuidString).json") ? depot : nil
        } catch is DecodingError {
            return nil
        }
    }

    private static func ordre(_ fichier: URL) -> UInt64? {
        let prefixe = fichier.lastPathComponent.prefix(while: { $0 != "-" })
        guard prefixe.count == 20 else { return nil }
        return UInt64(prefixe)
    }
}
