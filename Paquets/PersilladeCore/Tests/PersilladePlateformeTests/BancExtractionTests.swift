import Foundation
import FoundationModels
import PersilladeCore
import PersilladePlateforme
import Testing

@Suite(.serialized)
struct BancExtractionTests {
    @Test(arguments: [0, 90, 180, 270])
    func pageImprimeeDeuxColonnes(rotation: Int) async throws {
        let (corpus, cas) = try Self.chargerCorpus()
        let fiche = try #require(cas.first { $0.id == "photo-06" })
        let entree = try fiche.lire(dans: corpus, rotation: rotation)
        let depart = ContinuousClock.now
        let resultat = try await Extracteur(lecteurImage: LecteurImageVision()).extraire(
            entree.contenu, cible: .recette)
        print("Page en deux colonnes, \(rotation)° : \(depart.duration(to: .now))")
        let recette = try #require(resultat.recette)
        #expect(resultat.statut == .complet)
        #expect(resultat.moteur == .structure)
        #expect(try fiche.corrections(recette) == 0, "\(resultat.texteSource)")
    }

    @available(iOS 27.0, macOS 27.0, *)
    @Test(
        .enabled(
            if: ProcessInfo.processInfo.environment["PERSILLADE_BANC_EXTRACTION"] == "1",
            "Activer PERSILLADE_BANC_EXTRACTION pour mesurer l’extraction."),
        .timeLimit(.minutes(10)))
    func mesureExtractionLocale() async throws {
        let moteur = MoteurFondation()
        let indisponibilite = moteur.indisponibilite
        let disponibilite = indisponibilite.map { String(describing: $0) } ?? "disponible"
        let contexte = indisponibilite == nil ? String(SystemLanguageModel.default.contextSize) : "—"

        let (corpus, cas) = try Self.chargerCorpus()
        var rapport = [
            "# Banc d’extraction",
            "",
            "- Modèle local en français · \(disponibilite)",
            "- Fenêtre de contexte lue à l’exécution (jetons) · \(contexte)",
            "",
            "| Cas | Entrée | Variante | Statut | Cause | Moteur | Durée (ms) | Champs à corriger | Gain JSON-LD (ms) | Gain JSON-LD (champs) |",
            "| --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |",
        ]
        for fiche in cas {
            let entree = try fiche.lire(dans: corpus)
            let mesure = try await mesurer(entree, fiche: fiche, moteur: moteur)
            if fiche.jsonLD == true, let html = entree.page?.html {
                let sansJSONLD = html.replacingOccurrences(
                    of: #"<script type="application/ld\+json">[\s\S]*?</script>"#, with: "",
                    options: .regularExpression)
                try #require(sansJSONLD != html)
                let reference = EntreeBanc(contenu: entree.contenu, page: PageLocale(html: sansJSONLD))
                let mesureSans = try await mesurer(reference, fiche: fiche, moteur: moteur)
                rapport.append(mesure.ligne(fiche, variante: "avec JSON-LD", reference: mesureSans))
                rapport.append(mesureSans.ligne(fiche, variante: "JSON-LD retiré"))
            } else {
                let variante = fiche.type == .web ? "sans JSON-LD natif" : "nominale"
                rapport.append(mesure.ligne(fiche, variante: variante))
            }
            if fiche.id == "texte-01" {
                let repli = try await mesurer(entree, fiche: fiche, moteur: nil)
                #expect(repli.resultat.cause == .iaIndisponible)
                rapport.append(repli.ligne(fiche, variante: "sans modèle (forcé)"))
            }
        }

        let markdown = rapport.joined(separator: "\n") + "\n"
        let destination =
            ProcessInfo.processInfo.environment["PERSILLADE_RAPPORT_EXTRACTION"].map { URL(filePath: $0) }
            ?? URL.temporaryDirectory.appending(path: "extraction.md")
        try markdown.write(to: destination, atomically: true, encoding: .utf8)
        print(markdown)
    }

    private static func chargerCorpus() throws -> (URL, [CasExtraction]) {
        #if SWIFT_PACKAGE
            let paquet = Bundle.module
        #else
            let paquet = Bundle(for: RessourcesBancExtraction.self)
        #endif
        let corpus = try #require(paquet.url(forResource: "CorpusExtraction", withExtension: nil))
        let cas = try JSONDecoder().decode(
            [CasExtraction].self, from: Data(contentsOf: corpus.appending(path: "attendus.json")))
        return (corpus, cas)
    }

    @available(iOS 27.0, macOS 27.0, *)
    private func mesurer(_ entree: EntreeBanc, fiche: CasExtraction, moteur: MoteurFondation?) async throws -> Mesure {
        let extracteur = Extracteur(telechargeur: entree.page, moteurIA: moteur, lecteurImage: LecteurImageVision())
        let depart = ContinuousClock.now
        let resultat = try await extracteur.extraire(entree.contenu, cible: .recette)
        let duree = depart.duration(to: .now).components
        let millisecondes = Double(duree.seconds) * 1_000 + Double(duree.attoseconds) / 1e15
        return Mesure(
            resultat: resultat, millisecondes: millisecondes,
            corrections: try fiche.corrections(resultat.recette ?? BrouillonRecette()))
    }

    private struct Mesure {
        let resultat: ResultatExtraction
        let millisecondes: Double
        let corrections: Int

        func ligne(_ fiche: CasExtraction, variante: String, reference: Self? = nil) -> String {
            let gainDuree = reference.map { Self.decimale($0.millisecondes - millisecondes) } ?? "—"
            let gainChamps = reference.map { String($0.corrections - corrections) } ?? "—"
            let valeurs = [
                fiche.id, fiche.type.rawValue, variante, resultat.statut.rawValue, resultat.cause?.rawValue ?? "—",
                resultat.moteur.rawValue, Self.decimale(millisecondes), String(corrections), gainDuree, gainChamps,
            ]
            return "| " + valeurs.joined(separator: " | ") + " |"
        }

        private static func decimale(_ valeur: Double) -> String {
            String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), valeur)
        }
    }
}

#if !SWIFT_PACKAGE
    private final class RessourcesBancExtraction: NSObject {}
#endif

private struct CasExtraction: Decodable {
    enum TypeEntree: String, Decodable {
        case web, texte, imprime, manuscrit
    }

    struct IngredientAttendu: Decodable {
        let nom: String
        let quantite: String?
        let unite: Unite?

        func champ() throws -> ChampIngredient {
            ChampIngredient(
                nom: normaliserNom(nom), quantite: try quantite.map { try Quantite(texte: $0) }, unite: unite)
        }
    }

    struct ChampIngredient: Equatable {
        let nom: String
        let quantite: Quantite?
        let unite: Unite?
    }

    let id: String
    let type: TypeEntree
    let titre: String
    let portions: Int?
    let ingredients: [IngredientAttendu]
    let etapes: [String]
    let jsonLD: Bool?
    let rotation: Int?

    func lire(dans corpus: URL, rotation: Int? = nil) throws -> EntreeBanc {
        let fichier = corpus.appending(path: id).appendingPathExtension(type == .web ? "html" : "txt")
        let source = try String(contentsOf: fichier, encoding: .utf8)
        switch type {
        case .web:
            return EntreeBanc(
                contenu: ContenuRecu(
                    type: .url, contenu: Data("https://recettes.invalid/\(id)".utf8), origine: .feuillePartage),
                page: PageLocale(html: source))
        case .texte:
            return EntreeBanc(
                contenu: ContenuRecu(type: .texte, contenu: Data(source.utf8), origine: .pressePapiers))
        case .imprime, .manuscrit:
            let image = try PageCorpusExtraction.rendre(
                source, manuscrite: type == .manuscrit, rotation: rotation ?? self.rotation ?? 0)
            return EntreeBanc(contenu: ContenuRecu(type: .image, contenu: image, origine: .phototheque))
        }
    }

    func corrections(_ recette: BrouillonRecette) throws -> Int {
        let titreDifferent = Self.normaliserTexte(titre) != Self.normaliserTexte(recette.titre)
        let portionsDifferentes = portions != recette.portions
        let mesures = recette.ingredients.map {
            ChampIngredient(nom: normaliserNom($0.nom), quantite: $0.quantite, unite: $0.unite)
        }
        let cibles = try ingredients.map { try $0.champ() }
        return (titreDifferent ? 1 : 0) + (portionsDifferentes ? 1 : 0)
            + Self.distance(mesures, cibles)
            + Self.distance(recette.etapes.map(Self.normaliserTexte), etapes.map(Self.normaliserTexte))
    }

    private static func normaliserTexte(_ texte: String) -> String {
        texte.lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .trimmingCharacters(in: CharacterSet(charactersIn: ".!?").union(.whitespacesAndNewlines))
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private static func distance<T: Equatable>(_ obtenu: [T], _ attendu: [T]) -> Int {
        var precedente = Array(0...attendu.count)
        for (indice, champ) in obtenu.enumerated() {
            var courante = [indice + 1]
            for (colonne, cible) in attendu.enumerated() {
                courante.append(
                    min(
                        precedente[colonne + 1] + 1, courante[colonne] + 1,
                        precedente[colonne] + (champ == cible ? 0 : 1)))
            }
            precedente = courante
        }
        return precedente[attendu.count]
    }
}

private struct EntreeBanc {
    let contenu: ContenuRecu
    var page: PageLocale?
}

private struct PageLocale: TelechargeurPage {
    let html: String

    func telecharger(_ url: URL) async throws -> String { html }
}
