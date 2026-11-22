import Foundation
import PersilladeCore
import Testing

@testable import Persillade

struct RenduPlancheTests {
    @Test func rendEtReutiliseUneImageParApparence() async throws {
        let rendu = RenduPlanche()
        let planche = try plancheDeTest()
        let clair = try #require(
            DemandePlanche(planche: planche, cadrage: .vignette, largeur: 112, hauteur: 96, echelle: 3, sombre: false))
        let sombre = try #require(
            DemandePlanche(planche: planche, cadrage: .vignette, largeur: 112, hauteur: 96, echelle: 3, sombre: true))

        async let premiere = rendu.image(clair)
        async let seconde = rendu.image(clair)
        let (image, partagee) = try await (premiere, seconde)
        #expect(image === partagee)
        #expect(image.width == 336)
        #expect(image.height == 288)
        #expect(image.bitsPerComponent == 8)
        #expect(try await rendu.image(sombre) !== image)
        await rendu.vider()
        #expect(try await rendu.image(clair) !== image)
    }

    @Test func annulationSansEffetSurUnAutreConsommateur() async throws {
        let rendu = RenduPlanche()
        let demande = try #require(
            DemandePlanche(
                planche: plancheDeTest(), cadrage: .fiche, largeur: 393, hauteur: 238, echelle: 3, sombre: false))

        let gardee = Task { try await rendu.image(demande) }
        let annulee = Task { try await rendu.image(demande) }
        annulee.cancel()
        await #expect(throws: CancellationError.self) { try await annulee.value }
        #expect(try await gardee.value.width == 1_179)
    }

    #if !DEBUG
        @Test func mesureRendusFroidsSurSimulateur() async throws {
            let rendu = RenduPlanche()
            let planche = try plancheDeTest()
            let horloge = ContinuousClock()
            for (cadrage, largeur, hauteur) in [(Planche.Cadrage.vignette, 112.0, 96.0), (.fiche, 393, 238)] {
                var mesures: [Duration] = []
                for i in 0..<42 {
                    await rendu.vider()
                    let demande = try #require(
                        DemandePlanche(
                            planche: planche, cadrage: cadrage, largeur: largeur, hauteur: hauteur, echelle: 3,
                            sombre: i.isMultiple(of: 2)))
                    let depart = horloge.now
                    _ = try await rendu.image(demande)
                    if i >= 2 { mesures.append(depart.duration(to: horloge.now)) }
                }
                let valeurs = mesures.sorted()
                let mediane = (valeurs[19] + valeurs[20]) / 2
                print("MOTIF RELEASE \(cadrage) médiane sur \(valeurs.count) rendus froids : \(mediane)")
            }
        }
    #endif

    private func plancheDeTest() throws -> Planche {
        let ingredients = try [
            Ingredient(nom: "tomates", quantite: Quantite(4), unite: .piece, texteOrigine: "4 tomates"),
            Ingredient(nom: "carottes", quantite: Quantite(2), unite: .piece, texteOrigine: "2 carottes"),
            Ingredient(nom: "lentilles", quantite: Quantite(120), unite: .g, texteOrigine: "120 g de lentilles"),
            Ingredient(nom: "oignons", quantite: Quantite(1), unite: .piece, texteOrigine: "1 oignon"),
        ]
        let id = try #require(UUID(uuidString: "D902B3B1-A984-4449-B7CD-259FE5EF68A2"))
        return Planche(id: id, ingredients: ingredients)
    }
}
