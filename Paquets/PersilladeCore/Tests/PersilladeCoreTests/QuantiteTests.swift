import Foundation
import Testing

@testable import PersilladeCore

@Test(
    arguments: [
        ("0,5", 1, 2), ("0.50", 1, 2), ("1/2", 1, 2), ("½", 1, 2),
        ("⅓", 1, 3), ("−2,75", -11, 4), (" +0 ", 0, 1), (",5", 1, 2),
        ("-9223372036854775808", Int64.min, 1),
    ] as [(String, Int64, Int64)])
func lectureExacte(texte: String, numerateur: Int64, denominateur: Int64) throws {
    let quantite = try Quantite(texte: texte)
    #expect(quantite.numerateur == numerateur)
    #expect(quantite.denominateur == denominateur)
}

@Test(arguments: ["", "-", ".", "2/3/4", "1,2.3", "١", "1/−2"])
func refuseLesFormatsInvalides(texte: String) {
    #expect(throws: Quantite.Erreur.formatInvalide) { try Quantite(texte: texte) }
}

@Test func rationnelsReduitsEtCalculsExacts() throws {
    let unDemi = try Quantite(numerateur: -2, denominateur: -4)
    let unTiers = try Quantite(texte: "1/3")
    #expect(Set([unDemi, try Quantite(texte: "0,5")]).count == 1)
    #expect(unTiers < unDemi)
    #expect(try unDemi + unTiers == Quantite(texte: "5/6"))
    #expect(try unDemi - unTiers == Quantite(texte: "1/6"))
    #expect(try unDemi * unTiers == Quantite(texte: "1/6"))
    #expect(try unDemi / unTiers == Quantite(texte: "1,5"))
    #expect(try unTiers * Quantite(3) == Quantite(1))
    #expect(unDemi.texteFrancais == "0,5")
    #expect(unTiers.texteFrancais == "1/3")
}

@Test func bornesReduitesEtDepassements() throws {
    let petit = try Quantite(numerateur: 1, denominateur: 1 << 62)
    #expect(try Quantite(texte: petit.texteFrancais) == petit)
    let max = Quantite(Int64.max)
    let min = Quantite(Int64.min)
    #expect(try max * Quantite(numerateur: 1, denominateur: Int64.max) == Quantite(1))
    #expect(try Quantite(numerateur: Int64.min, denominateur: Int64.min) == Quantite(1))
    #expect(try Quantite(numerateur: 0, denominateur: Int64.min) == Quantite(0))
    #expect(throws: Quantite.Erreur.depassement) { try max + Quantite(1) }
    #expect(throws: Quantite.Erreur.depassement) { try min - Quantite(1) }
    #expect(throws: Quantite.Erreur.depassement) { try max * max }
    #expect(throws: Quantite.Erreur.depassement) { try min / Quantite(-1) }
    #expect(throws: Quantite.Erreur.depassement) { try Quantite(texte: "0,00000000000000000001") }
    #expect(throws: Quantite.Erreur.divisionParZero) { try Quantite(texte: "1/0") }
    #expect(throws: Quantite.Erreur.divisionParZero) { try max / Quantite(0) }
}
