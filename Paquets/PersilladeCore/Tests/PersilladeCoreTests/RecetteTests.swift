import Foundation
import Testing

@testable import PersilladeCore

private func fixture() throws -> Data {
    let url = try #require(
        Bundle.module.url(forResource: "recette-v1", withExtension: "json", subdirectory: "Fixtures"))
    return try Data(contentsOf: url)
}

@Test func lectureEtEncodageStableDeLaRecetteV1() throws {
    let lecteur = JSONDecoder()
    let donnees = try fixture()
    let recette = try lecteur.decode(Recette.self, from: donnees)
    #expect(recette.versionSchema == 1)
    #expect(recette.id.uuidString == "12345678-1234-1234-1234-123456789ABC")
    #expect(recette.titre == "Omelette aux fines herbes")
    #expect(recette.portions == 4)
    #expect(
        recette.etapes == ["Battre les œufs.", "Ajouter le lait et assaisonner.", "Cuire séparément les carottes."])
    #expect(recette.urlSource?.absoluteString == "https://example.org/omelette")
    #expect(
        recette.ingredients.map(\.quantite) == [
            Quantite(3), Quantite(3), try Quantite(texte: "1/2"), nil, nil, Quantite(1),
        ])
    #expect(recette.ingredients.map(\.aLUnite) == [true, true, false, false, false, false])
    #expect(recette.ingredients.map(\.unite) == [.piece, .piece, .l, nil, nil, .autre("bouquet")])

    let attendu = try JSONSerialization.data(
        withJSONObject: JSONSerialization.jsonObject(with: donnees),
        options: [.sortedKeys, .withoutEscapingSlashes])
    let encode = try recette.encoderJSON()
    #expect(encode == attendu)
    #expect(try lecteur.decode(Recette.self, from: encode) == recette)
}

@Test func invariantsDesModeles() throws {
    #expect(throws: Ingredient.Erreur.nomVide) { try Ingredient(nom: " \t", texteOrigine: "") }
    #expect(throws: Ingredient.Erreur.quantiteNonPositive) {
        try Ingredient(nom: "Sel", quantite: Quantite(0), texteOrigine: "")
    }
    #expect(throws: Ingredient.Erreur.uniteSansQuantite) {
        try Ingredient(nom: "Sel", unite: .g, texteOrigine: "")
    }
    #expect(throws: Recette.Erreur.titreVide) {
        try Recette(titre: "\n", portions: 4, ingredients: [], etapes: [], texteSource: "")
    }
    #expect(throws: Recette.Erreur.portionsNonPositives) {
        try Recette(titre: "Omelette", portions: 0, ingredients: [], etapes: [], texteSource: "")
    }
    #expect(Recette.portionsImportees(nil) == (4, true))
    #expect(Recette.portionsImportees(2) == (2, false))
}

@Test(arguments: ["", "  ", "de l’"])
func uneUnitePersonnaliseeExigeUnLibelle(libelle: String) throws {
    let unite = Unite.autre(libelle)
    #expect(throws: Ingredient.Erreur.uniteSansLibelle) {
        try Ingredient(nom: "Sel", quantite: Quantite(1), unite: unite, texteOrigine: "")
    }
    #expect(throws: EncodingError.self) { try JSONEncoder().encode(unite) }
    let json = try JSONEncoder().encode("autre:" + libelle)
    #expect(throws: DecodingError.self) { try JSONDecoder().decode(Unite.self, from: json) }
    #expect(try convertir(Quantite(1), unite, unite) == nil)
}

@Test func leDecodageRevalideLesDonnees() throws {
    let lecteur = JSONDecoder()
    let source = String(decoding: try fixture(), as: UTF8.self)
    let nouvelleVersion = source.replacingOccurrences(of: "\"version_schema\": 1", with: "\"version_schema\": 2")
    #expect(throws: Recette.Erreur.versionNonPriseEnCharge(2)) {
        try lecteur.decode(Recette.self, from: Data(nouvelleVersion.utf8))
    }
    let portionsInvalides = source.replacingOccurrences(of: "\"portions\": 4", with: "\"portions\": -1")
    #expect(throws: Recette.Erreur.portionsNonPositives) {
        try lecteur.decode(Recette.self, from: Data(portionsInvalides.utf8))
    }
    let uniteSeule = Data(#"{"nom":"Sel","unite":"g","texte_origine":"sel"}"#.utf8)
    #expect(throws: Ingredient.Erreur.uniteSansQuantite) {
        try lecteur.decode(Ingredient.self, from: uniteSeule)
    }
    let quantiteInvalide = Data(#"{"numerateur":1,"denominateur":0}"#.utf8)
    #expect(throws: Quantite.Erreur.divisionParZero) {
        try lecteur.decode(Quantite.self, from: quantiteInvalide)
    }
}

@Test(
    arguments: [
        (.url, .feuillePartage, "url", "feuille_partage"),
        (.texte, .pressePapiers, "texte", "presse_papiers"),
        (.image, .appareilPhoto, "image", "appareil_photo"),
        (.image, .phototheque, "image", "phototheque"),
    ] as [(ContenuRecu.TypeContenu, ContenuRecu.Origine, String, String)])
func encodageContenuRecu(
    type: ContenuRecu.TypeContenu, origine: ContenuRecu.Origine, cleType: String, cleOrigine: String
) throws {
    let contenu = ContenuRecu(
        type: type, contenu: Data([0xC3, 0xA9]), origine: origine, recuLe: Date(timeIntervalSinceReferenceDate: 42))
    let donnees = try JSONEncoder().encode(contenu)
    #expect(try JSONDecoder().decode(ContenuRecu.self, from: donnees) == contenu)
    let json = try #require(JSONSerialization.jsonObject(with: donnees) as? [String: Any])
    #expect(Set(json.keys) == ["id", "type", "contenu", "origine", "recu_le"])
    #expect(json["type"] as? String == cleType)
    #expect(json["origine"] as? String == cleOrigine)
}
