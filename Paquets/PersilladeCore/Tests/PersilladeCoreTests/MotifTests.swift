import Foundation
import Testing

@testable import PersilladeCore

struct MotifTests {
    private let identifiant = UUID(
        uuid: (0xD9, 0x02, 0xB3, 0xB1, 0xA9, 0x84, 0x44, 0x49, 0xB7, 0xCD, 0x25, 0x9F, 0xE5, 0xEF, 0x68, 0xA2))

    @Test func vecteursSplitMix64() {
        let suffixe = identifiant.uuidString + "/"
        #expect(Planche.graine(suffixe + "fond") == 0x2902_8B85_AC62_3BA3)
        #expect(Planche.graine(suffixe + "fond") % 6 == 3)
        let cadre = Planche.graine(suffixe + "cadre")
        #expect(cadre == 0x5A3C_C2F8_FADA_D7CB)
        #expect(Planche.tirage(cadre, 0) == 0.39095529414799557)
        #expect(Planche.tirage(cadre, 1) == 0.8291660706341947)
        #expect(Planche.tirage(cadre, 2) == 0.2268449894585307)

        let repli = Planche.graine(suffixe + "repli")
        #expect(repli == 0x0318_24AC_6684_7A4E)
        #expect(Planche.tirage(repli, 0) == 0.9962414017160922)
        let rangee = Planche.graine(suffixe + "r0")
        #expect(rangee == 0x7877_7A4E_EDBC_C7A0)
        #expect(Planche.tirage(rangee, 0) == 0.294153628556033)
        let pluches = Planche.graine(suffixe + "pluches")
        #expect(pluches == 0x3D12_3A1F_C0D6_4D2A)
        #expect(Planche.tirage(pluches, 0) == 0.37692311378476295)
        #expect([0, -1, 1, -2, 2].map(Planche.rangPiece) == [0, 1, 2, 3, 4])
        #expect(Planche.rangGrille(-1, 1) == 8)
    }

    @Test(arguments: [
        ("Pommes de terre (petites)", "pdt"),
        ("pâte feuilletée", "pateTarte"),
        ("Oignon piqué de clous de girofle", "oignon"),
        ("tomate, oignon", "tomate"),
    ])
    func cleLaPlusLonguePuisLaPlusAGauche(nom: String, visuel: String) {
        guard case .piece(let resultat) = Planche.reconnaitre(nom) else {
            Issue.record("Ingrédient attendu : \(nom)")
            return
        }
        #expect(resultat.visuel == visuel)
    }

    @Test(arguments: ["huile d’olive", "bouillon de poulet", "noix de muscade", "Sel, poivre"])
    func ingredientsExclus(nom: String) {
        if case .exclu = Planche.reconnaitre(nom) { return }
        Issue.record("Exclusion attendue : \(nom)")
    }

    @Test func motsEntiersEtRepli() throws {
        let ingredient = try Ingredient(nom: "pommeau", texteOrigine: "pommeau")
        let motif = Planche(id: identifiant, ingredients: [ingredient])
        #expect(motif.rangees.map(\.visuel) == ["g-baton", "g-semis", "g-ruban"])
        #expect(motif.rangees.allSatisfy { $0.neutre })
        #expect(motif.fond == .faience)
        #expect(motif.pluches == .tonSurTon)
        #expect(motif.angle == -11)
    }

    @Test func peseEnGrammesEtLitLaBorneHauteImportee() throws {
        let farine = try Ingredient(
            nom: "farine", quantite: Quantite(200), unite: .g, texteOrigine: "200 à 250 g de farine")
        let creme = try Ingredient(
            nom: "crème", quantite: Quantite(2), unite: .autre("dl"), texteOrigine: "2 dl de crème")
        let tomate = try Ingredient(
            nom: "tomate", quantite: Quantite(1), unite: .autre("boîte"), texteOrigine: "1 boîte de tomates")
        #expect(Planche.masse(farine, piece: 100) == 250)
        #expect(farine.quantite == Quantite(200))
        #expect(Planche.masse(creme, piece: 200) == 200)
        #expect(Planche.masse(tomate, piece: 120) == 400)
    }

    @Test func pluchesAvecPreuveEtAliasFusionnes() throws {
        let sucre = try Ingredient(nom: "sucre", quantite: Quantite(40), unite: .g, texteOrigine: "40 g de sucre")
        let sel = try Ingredient(nom: "sel", texteOrigine: "sel")
        let poivre = try Ingredient(nom: "poivre", texteOrigine: "poivre")
        #expect(Planche(id: identifiant, ingredients: [sucre, sel]).pluches == .sucreGlace)
        #expect(Planche(id: identifiant, ingredients: [sucre, sel, poivre]).pluches == .vertes)

        let pdt = try Ingredient(nom: "pommes de terre", quantite: Quantite(10), unite: .g, texteOrigine: "")
        let patate = try Ingredient(nom: "patate", quantite: Quantite(10), unite: .g, texteOrigine: "")
        let carotte = try Ingredient(nom: "carotte", quantite: Quantite(18), unite: .g, texteOrigine: "")
        #expect(
            Planche(id: identifiant, ingredients: [pdt, patate, carotte]).rangees.map(\.visuel) == ["pdt", "carotte"])
    }

    @Test func compositionQuicheDeLaReference() throws {
        let ingredients: [(String, Int64, Unite?)] = [
            ("pâte brisée", 1, nil), ("lardons fumés", 200, .g), ("œufs", 3, nil),
            ("crème fraîche épaisse", 20, .cl), ("lait", 20, .cl), ("gruyère râpé", 100, .g),
        ]
        let planche = try Planche(
            id: identifiant,
            ingredients: ingredients.map { nom, quantite, unite in
                try Ingredient(nom: nom, quantite: Quantite(quantite), unite: unite, texteOrigine: "")
            })
        #expect(planche.fond == .pois)
        #expect(planche.rangees.map(\.visuel) == ["pateTarte", "lardon", "oeuf", "fromage"])
        #expect(abs(planche.rangees[1].hauteurRelative - 0.9325048082403138) < 1e-12)

        let preuve = try planche.primitives(largeur: 342, hauteur: 210, cadrage: .preuve, sombre: false)
        let sombre = try planche.primitives(largeur: 342, hauteur: 210, cadrage: .preuve, sombre: true)
        #expect(preuve.count == 161)
        #expect(preuve.map(\.geometrie) == sombre.map(\.geometrie))
        #expect(preuve.first?.remplissage == 0xD9A85A)
        #expect(preuve.first?.trait?.couleur == 0xCBE38A)
        #expect(sombre.first?.trait?.couleur == 0x39500F)
        let premierTrait = try #require(preuve.first)
        #expect(abs(premierTrait.angle - (-11 * .pi / 180)) < 1e-12)
        #expect(abs(premierTrait.origine.x - (-192.14)) < 0.05)
        let vignette = try planche.primitives(largeur: 96, hauteur: 96, cadrage: .vignette, sombre: false)
        #expect(vignette.count == 61)
        #expect(try planche.primitives(largeur: 22, hauteur: 22, cadrage: .miniature, sombre: false).count == 25)
    }
}
