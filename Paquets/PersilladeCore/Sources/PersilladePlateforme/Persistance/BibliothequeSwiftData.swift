import Foundation
import PersilladeCore
import SwiftData

enum SchemaBibliothequeV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [RecetteStockee.self] }

    @Model
    final class RecetteStockee {
        #Index<RecetteStockee>([\.titreRecherche])

        @Attribute(.unique) var id: UUID
        var titre: String
        var titreRecherche: String
        var nombreIngredients: Int
        var nombreEtapes: Int
        var creeLe: Date
        var modifieLe: Date
        var json: Data

        init(_ recette: Recette, json: Data, date: Date) {
            id = recette.id
            titre = recette.titre
            titreRecherche = Self.normaliserTitre(recette.titre)
            nombreIngredients = recette.ingredients.count
            nombreEtapes = recette.etapes.count
            creeLe = date
            modifieLe = date
            self.json = json
        }

        func modifier(_ recette: Recette, json: Data) {
            titre = recette.titre
            titreRecherche = Self.normaliserTitre(recette.titre)
            nombreIngredients = recette.ingredients.count
            nombreEtapes = recette.etapes.count
            modifieLe = Date()
            self.json = json
        }

        var resume: ResumeRecette {
            ResumeRecette(
                id: id, titre: titre, nombreIngredients: nombreIngredients, nombreEtapes: nombreEtapes,
                creeLe: creeLe, modifieLe: modifieLe)
        }

        static func normaliserTitre(_ titre: String) -> String {
            titre.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: locale)
        }

        static let locale = Locale(identifier: "fr_FR")
    }
}

enum MigrationBibliotheque: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaBibliothequeV1.self] }
    static var stages: [MigrationStage] { [] }
}

@ModelActor
public actor BibliothequeSwiftData: Bibliotheque {
    private typealias RecetteStockee = SchemaBibliothequeV1.RecetteStockee

    public init(url: URL? = nil) throws {
        let schema = Schema(versionedSchema: SchemaBibliothequeV1.self)
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        } else {
            configuration = ModelConfiguration(
                "Bibliotheque", schema: schema, groupContainer: .none, cloudKitDatabase: .none)
        }
        let conteneur = try ModelContainer(
            for: schema, migrationPlan: MigrationBibliotheque.self, configurations: [configuration])
        self.init(modelContainer: conteneur)
    }

    public func enregistrer(_ recette: Recette) throws -> UUID {
        guard try trouver(id: recette.id) == nil else {
            throw ErreurBibliotheque.recetteDejaEnregistree(recette.id)
        }
        let json = try recette.encoderJSON()
        modelContext.insert(RecetteStockee(recette, json: json, date: Date()))
        try sauvegarder()
        return recette.id
    }

    public func lire(id: UUID) throws -> Recette? {
        guard let stockee = try trouver(id: id) else { return nil }
        return try JSONDecoder().decode(Recette.self, from: stockee.json)
    }

    public func modifier(_ recette: Recette) throws {
        guard let stockee = try trouver(id: recette.id) else {
            throw ErreurBibliotheque.recetteIntrouvable(recette.id)
        }
        let json = try recette.encoderJSON()
        stockee.modifier(recette, json: json)
        try sauvegarder()
    }

    public func lister() throws -> [ResumeRecette] {
        try resumes(FetchDescriptor<RecetteStockee>())
    }

    public func rechercherParTitre(_ texte: String) throws -> [ResumeRecette] {
        let titre = RecetteStockee.normaliserTitre(texte.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !titre.isEmpty else { return try lister() }
        let filtre = #Predicate<RecetteStockee> { $0.titreRecherche.contains(titre) }
        return try resumes(FetchDescriptor(predicate: filtre))
    }

    public func supprimer(id: UUID) throws {
        guard let stockee = try trouver(id: id) else { return }
        modelContext.delete(stockee)
        try sauvegarder()
    }

    private func trouver(id: UUID) throws -> RecetteStockee? {
        var filtre = FetchDescriptor<RecetteStockee>(predicate: #Predicate { $0.id == id })
        filtre.fetchLimit = 1
        return try modelContext.fetch(filtre).first
    }

    private func resumes(_ filtre: FetchDescriptor<RecetteStockee>) throws -> [ResumeRecette] {
        try modelContext.fetch(filtre).map(\.resume).sorted { gauche, droite in
            let ordre = gauche.titre.compare(droite.titre, options: [.caseInsensitive], locale: RecetteStockee.locale)
            if ordre == .orderedSame { return gauche.id.uuidString < droite.id.uuidString }
            return ordre == .orderedAscending
        }
    }

    private func sauvegarder() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
