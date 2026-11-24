import Foundation
import Testing

@testable import PersilladeCore

@Test(arguments: [
    ("Tomates", "tomate"), ("tomates cerises", "tomate cerise"), ("Œufs", "oeuf"),
    ("poireaux", "poireau"), ("choux", "chou"), ("choux-fleurs", "chou fleur"),
    ("noix", "noix"), ("radis", "radis"), ("maïs", "mais"), ("de la farine", "farine"),
    ("pommes de terre", "pomme de terre"), ("eaux", "eau"),
    ("  DES  L’ŒUFS\t", "oeuf"), ("d’ail", "ail"), ("d ail", "d ail"),
    ("de l’ huile d’olive", "huile d olive"), ("huile des noix", "huile des noix"),
    ("CHOUX‑FLEURS", "chou fleur"), (" \n", ""), ("les", ""),
])
func formesNormalisees(nom: String, attendu: String) {
    #expect(normaliserNom(nom) == attendu)
}

@Test(arguments: [
    "radis", "noix", "ananas", "mais", "anchois", "pois", "jus", "riz", "brebis",
    "cassis", "colis", "couscous", "houmous", "os", "frais", "gros", "bas",
])
func conserveLesExceptions(mot: String) {
    #expect(normaliserNom(mot) == mot)
}

@Test func conserveLesDistinctions() {
    #expect(normaliserNom("tomates cerises") != normaliserNom("tomates"))
    #expect(normaliserNom("cébettes") != normaliserNom("oignons nouveaux"))
}

@Test(
    arguments: [
        (1, .kg, 500, .g, 1_500), (25, .cl, 100, .ml, 350),
    ] as [(Int64, Unite, Int64, Unite, Int64)])
func fusionEnUniteCanonique(
    quantite: Int64, source: Unite, ajout: Int64, cible: Unite, total: Int64
) throws {
    let conversion = try convertir(Quantite(quantite), source, cible)
    let convertie = try #require(conversion)
    #expect(try convertie + Quantite(ajout) == Quantite(total))
}

@Test(
    arguments: [
        (.cas, .ml), (.piece, .g), (.cac, .cas), (.g, .ml), (.autre("un verre"), .autre("bol")),
    ] as [(Unite, Unite)])
func unitesNonComparables(a: Unite, b: Unite) throws {
    #expect(try convertir(Quantite(2), a, b) == nil)
    #expect(try convertir(Quantite(2), b, a) == nil)
}

@Test func autresConversions() throws {
    #expect(try convertir(Quantite(250), .ml, .l) == Quantite(texte: "0,25"))
    #expect(try convertir(Quantite(11), .cl, .l) == Quantite(texte: "0,11"))
    #expect(try convertir(Quantite(2), .l, .cl) == Quantite(200))
    #expect(try convertir(Quantite(7), .g, .kg) == Quantite(texte: "0,007"))
    #expect(try convertir(Quantite(2), .piece, .piece) == Quantite(2))
    #expect(try convertir(Quantite(2), .cas, .cas) == Quantite(2))
    #expect(try convertir(Quantite(2), .autre(" RÂMEQUINS "), .autre("ramequin")) == Quantite(2))
    #expect(try convertir(Quantite(Int64.max), .cl, .l) == Quantite(numerateur: Int64.max, denominateur: 100))
    #expect(throws: Quantite.Erreur.depassement) { try convertir(Quantite(Int64.max), .kg, .g) }
}

@Test func dictionnaireEmbarqueNormaliseEtSansDoublon() {
    var cles = Set<String>()
    #expect(Set(articlesParCategorie.keys) == Set(Categorie.allCases))
    for (categorie, articles) in articlesParCategorie {
        for article in articles.split(separator: "\n").map(String.init) {
            #expect(article == normaliserNom(article))
            #expect(cles.insert(article).inserted)
            #expect(categorieParDefaut(article) == categorie)
        }
    }
    #expect(cles.count >= 350)
    #expect(categorieParDefaut("tomate cerise") == .fruitsEtLegumes)
    #expect(categorieParDefaut("oeuf") == .cremier)
    #expect(categorieParDefaut("huile d olive") == .epicerie)
    #expect(categorieParDefaut("article inconnu") == .autres)
}

@Test func rayonsDansLOrdreDAffichage() {
    #expect(
        Categorie.allCases.map(\.rawValue) == [
            "Fruits et légumes", "Épicerie", "Boucher", "Poissonnier", "Crémier", "Boulangerie-pâtisserie", "Autres",
        ])
}

@Test(
    arguments: [
        ("beurre fondu", .cremier),
        ("crème entière liquide à 35% de matière grasse", .cremier),
        ("pommes de terre bintje ou charlotte", .fruitsEtLegumes),
        ("poudre d’amandes", .epicerie),
        ("abricots au sirop", .epicerie),
        ("fruits de la passion au sirop", .epicerie),
        ("abricots mûrs", .fruitsEtLegumes),
        ("tomates, coupées en dés", .fruitsEtLegumes),
        ("«pois chiches»", .epicerie),
        ("«anchois marinés»", .poissonnier),
        ("biscuits pépito® ronds", .epicerie),
        ("biscuits au beurre demi-sel", .epicerie),
        ("amandes", .epicerie),
        ("noix de beurre", .cremier),
        ("noix de Saint-Jacques", .poissonnier),
        ("sel", .epicerie),
        ("viande hachée", .boucher),
        ("chouquettes fraîches", .boulangeriePatisserie),
        ("fleur de sel", .epicerie),
        ("selsière", .autres),
        ("appareil photo", .autres),
        ("", .autres),
    ] as [(String, Categorie)])
func classeLesNomsQualifiesEtLesPluriels(nom: String, attendu: Categorie) {
    #expect(categorieParDefaut(normaliserNom(nom)) == attendu)
}

@Test(
    arguments: [
        ("Fruits et légumes", .fruitsEtLegumes),
        ("Boulangerie", .boulangeriePatisserie),
        ("Crèmerie et œufs", .cremier),
        ("Viandes et charcuterie", .boucher),
        ("Poissons", .poissonnier),
        ("Épicerie salée", .epicerie),
        ("Épicerie sucrée", .epicerie),
        ("Surgelés", .epicerie),
        ("Boissons", .epicerie),
        ("Hygiène et maison", .autres),
        ("Autres", .autres),
    ] as [(String, Categorie)])
func anciensRayonsRelusPuisReecritsAvecLeNouveauLibelle(libelle: String, attendu: Categorie) throws {
    let donnees = try JSONEncoder().encode(libelle)
    let rayon = try JSONDecoder().decode(Categorie.self, from: donnees)
    #expect(rayon == attendu)
    let encode = try JSONEncoder().encode(rayon)
    #expect(try JSONDecoder().decode(String.self, from: encode) == attendu.rawValue)
}
