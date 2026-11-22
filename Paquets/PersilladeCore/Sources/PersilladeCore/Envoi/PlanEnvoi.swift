import Foundation

public enum PlanEnvoi: Equatable, Sendable {
    case exclure
    case ignorer
    case ajouter(Quantite?)
    case completer(Quantite)

    public init(
        ligne: LigneCourses, rappels: [RappelCourses], journal: JournalEnvoi, premierEnvoiLe: Date,
        destinationId: String? = nil
    ) throws {
        guard !ligne.cochee else {
            self = .exclure
            return
        }
        let articles = rappels.lazy.filter { rappel in
            !rappel.coche || rappel.cocheLe.map { $0 >= premierEnvoiLe } == true
        }.map { journal.article(du: $0, destinationId: destinationId) }.filter { $0.nomNormalise == ligne.nomNormalise }

        guard let quantite = try ligne.quantiteArrondie, let unite = ligne.unite else {
            self = articles.first(where: { _ in true }) == nil ? .ajouter(nil) : .ignorer
            return
        }

        var reste = quantite
        for article in articles {
            guard let valeur = article.quantite, let source = article.unite,
                let couverture = try convertir(valeur, source, unite)
            else { continue }
            if couverture >= reste {
                self = .ignorer
                return
            }
            reste = try reste - couverture
        }
        self = reste == quantite ? .ajouter(quantite) : .completer(reste)
    }
}
