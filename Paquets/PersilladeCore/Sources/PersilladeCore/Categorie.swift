public enum Categorie: String, CaseIterable, Codable, Hashable, Sendable {
    case fruitsEtLegumes = "Fruits et légumes"
    case epicerie = "Épicerie"
    case boucher = "Boucher"
    case poissonnier = "Poissonnier"
    case cremier = "Crémier"
    case boulangeriePatisserie = "Boulangerie-pâtisserie"
    case autres = "Autres"

    public init(from decoder: any Decoder) throws {
        let valeur = try decoder.singleValueContainer()
        let libelle = try valeur.decode(String.self)
        switch libelle {
        case "Boulangerie": self = .boulangeriePatisserie
        case "Crèmerie et œufs": self = .cremier
        case "Viandes et charcuterie": self = .boucher
        case "Poissons": self = .poissonnier
        case "Épicerie salée", "Épicerie sucrée", "Surgelés", "Boissons": self = .epicerie
        case "Hygiène et maison": self = .autres
        default:
            guard let categorie = Self(rawValue: libelle) else {
                throw DecodingError.dataCorruptedError(in: valeur, debugDescription: "Rayon inconnu")
            }
            self = categorie
        }
    }
}

public func categorieParDefaut(_ nomNormalise: String) -> Categorie {
    let mots = nomNormalise.split { !$0.isLetter && !$0.isNumber }.map { mot in
        // La ponctuation accolée peut avoir masqué le pluriel à la normalisation.
        if mot.endIndex < nomNormalise.endIndex, !nomNormalise[mot.endIndex].isWhitespace {
            return singulariserMot(mot)
        }
        if mot.startIndex > nomNormalise.startIndex,
            !nomNormalise[nomNormalise.index(before: mot.startIndex)].isWhitespace
        {
            return retablirMotInvariable(mot)
        }
        return mot
    }
    if zip(mots, mots.dropFirst()).contains(where: { $0 == "au" && $1 == "sirop" }) {
        return .epicerie
    }
    let tailleMax = min(mots.count, longueurMaxArticle)
    guard tailleMax > 0 else { return .autres }

    for taille in (1...tailleMax).reversed() {
        for debut in 0...(mots.count - taille) {
            let extrait = mots[debut..<(debut + taille)].joined(separator: " ")
            if let categorie = categoriesParNom[extrait] { return categorie }
        }
    }
    return .autres
}

private let categoriesParNom = Dictionary(
    uniqueKeysWithValues: articlesParCategorie.flatMap { categorie, articles in
        articles.split(separator: "\n").map { (String($0), categorie) }
    })

private let longueurMaxArticle = categoriesParNom.keys.map { $0.split(separator: " ").count }.max() ?? 0

let articlesParCategorie: [Categorie: String] = [
    .fruitsEtLegumes: """
    abricot
    ail
    ananas
    aneth
    artichaut
    asperge
    aubergine
    avocat
    banane
    basilic
    batavia
    betterave
    blette
    brocoli
    butternut
    carotte
    cebette
    celeri
    celeri branche
    celeri rave
    cerise
    champignon
    champignon de pari
    chataigne
    chou
    chou blanc
    chou de bruxelle
    chou fleur
    chou frise
    chou rouge
    chou vert
    ciboulette
    citron
    citron vert
    clementine
    concombre
    coriandre
    courge
    courge spaghetti
    courgette
    cresson
    echalote
    endive
    epinard
    estragon
    fenouil
    feuille de chene
    figue
    fraise
    framboise
    fruit de la passion
    gingembre
    girolle
    goyave
    grenade
    haricot beurre
    haricot vert
    kaki
    kiwi
    laitue
    litchi
    mache
    mandarine
    mangue
    melon
    menthe
    mirabelle
    morille
    mure
    myrtille
    navet
    nectarine
    noix de coco
    oignon
    oignon blanc
    oignon jaune
    oignon rouge
    orange
    oseille
    pamplemousse
    panai
    papaye
    pasteque
    patate douce
    peche
    persil
    persil plat
    petit pois
    physali
    piment
    poire
    poireau
    poivron
    poivron jaune
    poivron rouge
    poivron vert
    pomme
    pomme de terre
    potimarron
    potiron
    prune
    radis
    radis noir
    raisin
    raisin blanc
    raisin noir
    rhubarbe
    romarin
    roquette
    salade
    sauge
    thym
    tomate
    tomate ancienne
    tomate cerise
    tomate verte
    topinambour
    bleuet
    citrouille
    echalote grise
    feve
    fruit rouge
    oignon nouveau
    pomme bintje
    pomme charlotte
    radicchio
    rutabaga
    shiitake
    """,
    .boulangeriePatisserie: """
    bagel
    baguette
    biscotte
    boule de pain
    bretzel
    brioche
    bun
    chausson au pomme
    croissant
    crouton
    focaccia
    fougasse
    galette de sarrasin
    gressin
    muffin anglai
    naan
    pain
    pain a hamburger
    pain au chocolat
    pain au raisin
    pain complet
    pain de campagne
    pain de mie
    pain de seigle
    pain pita
    pain san gluten
    petit pain
    tortilla
    wrap
    baba au rhum
    chou a la creme
    chouquette
    eclair au chocolat
    flan patissier
    gateau
    mille feuille
    pain au cereale
    pain burger
    palmier
    viennoiserie
    """,
    .cremier: """
    beurre
    beurre demi sel
    beurre dou
    bleu
    brie
    burrata
    camembert
    cantal
    chevre frais
    comte
    creme anglaise
    creme entiere
    creme epaisse
    creme fleurette
    creme fraiche
    creme liquide
    dessert lacte
    emmental
    faisselle
    feta
    fromage
    fromage a raclette
    fromage blanc
    fromage de chevre
    fromage frais
    fromage rape
    gouda
    gruyere
    kefir
    lait
    lait de chevre
    lait demi ecreme
    lait ecreme
    lait entier
    lait fermente
    lait ribot
    lait san lactose
    mascarpone
    mimolette
    mozzarella
    munster
    oeuf
    oeuf de caille
    parmesan
    pecorino
    petit suisse
    reblochon
    ricotta
    roquefort
    saint nectaire
    skyr
    tomme
    yaourt
    yaourt grec
    yaourt nature
    yaourt vanille
    creme
    creme entiere liquide
    creme liquide entiere
    lait cru
    noix de beurre
    oeuf de cane
    pont l eveque
    tomme de brebis
    """,
    .boucher: """
    agneau
    andouille
    andouillette
    bacon
    bavette
    bifteck
    blanc de dinde
    blanc de poulet
    boeuf
    boudin blanc
    boudin noir
    canard
    chair a saucisse
    chipolata
    chorizo
    cote de porc
    cote de veau
    cuisse de poulet
    dinde
    entrecote
    escalope de dinde
    escalope de veau
    filet mignon
    foie de veau
    foie gra
    jambon
    jambon blanc
    jambon cru
    joue de boeuf
    lapin
    lardon
    magret de canard
    merguez
    mortadelle
    pate de campagne
    pintade
    porc
    poulet
    rillette
    roti de boeuf
    roti de porc
    salami
    saucisse
    saucisson
    steak
    steak hache
    veau
    viande hachee
    cotelette d agneau
    escalope de poulet
    hachi de boeuf
    jarret de veau
    paleron
    poitrine fumee
    traver de porc
    """,
    .poissonnier: """
    anchois
    bar
    barbue
    baudroie
    cabillaud
    calamar
    carrelet
    colin
    coquille saint jacque
    crabe
    crevette
    daurade
    eglefin
    espadon
    filet de saumon
    fletan
    gamba
    hareng
    homard
    huitre
    lieu jaune
    lieu noir
    lotte
    maquereau
    merlan
    merlu
    morue
    moule
    mulet
    palourde
    petoncle
    poisson
    poulpe
    rouget
    saint pierre
    sardine
    saumon
    saumon fume
    sole
    surimi
    thon
    truite
    truite fumee
    turbot
    bulot
    encornet
    langoustine
    noix de petoncle
    noix de saint jacque
    petite seiche
    seiche
    thon frais
    tourteau
    """,
    .epicerie: """
    agar agar
    ail en poudre
    amande
    arachide
    bouillon de legume
    bouillon de volaille
    boulgour
    capre
    chapelure
    chip
    concentre de tomate
    cornichon
    couli de tomate
    couscous
    creme de coco
    cube de bouillon
    cumin
    curcuma
    curry
    farine
    farine de ble
    farine de pois chiche
    farine de riz
    farine de sarrasin
    fecule de mais
    fecule de pomme de terre
    flageolet
    garam masala
    graine de courge
    graine de lin
    graine de sesame
    graine de tournesol
    gros sel
    haricot blanc
    haricot rouge
    harissa
    herbe de provence
    houmous
    huile
    huile d arachide
    huile d olive
    huile de coco
    huile de colza
    huile de sesame
    huile de tournesol
    ketchup
    lait de coco
    lasagne
    laurier
    lentille
    lentille corail
    lentille verte
    levure boulangere
    macaroni
    mais
    mayonnaise
    miso
    moutarde
    moutarde de dijon
    noisette
    noix
    noix de cajou
    nouille
    olive
    olive noire
    olive verte
    origan
    paprika
    paprika fume
    pate
    pate a pizza
    pate brisee
    pate de curry
    pate feuilletee
    penne
    pesto
    pignon de pin
    piment d espelette
    pois casse
    pois chiche
    poivre
    poivre noir
    polenta
    quinoa
    risotto
    riz
    riz basmati
    riz complet
    riz rond
    safran
    sarrasin
    sauce barbecue
    sauce soja
    sauce tomate
    sel
    sel fin
    semoule
    spaghetti
    tagliatelle
    tahini
    tapenade
    thon en boite
    tofu
    tomate concassee
    tomate pelee
    tomate sechee
    vermicelle
    vinaigre
    vinaigre balsamique
    vinaigre de cidre
    vinaigre de vin
    abricot sec
    amande en poudre
    biscuit
    biscuit a la cuillere
    biscuit au beurre
    biscuit pur beurre
    bonbon
    cacao
    cacao en poudre
    cannelle
    caramel
    cassonade
    cereale
    chocolat
    chocolat au lait
    chocolat blanc
    chocolat noir
    clou de girofle
    compote
    compote de pomme
    confiture
    confiture de fraise
    corn flake
    datte
    extrait de vanille
    figue seche
    flocon d avoine
    gelatine
    gousse de vanille
    granola
    levure chimique
    marron glace
    miel
    muesli
    noix de muscade
    pain d epice
    pate a tartiner
    pepite de chocolat
    pistache
    praline
    pruneau
    raisin sec
    sable
    sirop d agave
    sirop d erable
    sucre
    sucre blanc
    sucre en poudre
    sucre glace
    sucre rou
    sucre vanille
    vanille
    boulette surgelee
    brocoli surgele
    cabillaud surgele
    creme glacee
    crevette surgelee
    epinard surgele
    frite surgelee
    fruit rouge surgele
    glace
    glace a la vanille
    glace au chocolat
    haricot vert surgele
    legume surgele
    myrtille surgelee
    petit pois surgele
    pizza surgelee
    poisson pane
    poisson surgele
    potatoe surgelee
    saumon surgele
    sorbet
    steak hache surgele
    biere
    biere san alcool
    boisson a l avoine
    boisson au soja
    cafe
    cafe en grain
    cafe moulu
    cafe soluble
    champagne
    cidre
    eau
    eau de source
    eau gazeuse
    eau minerale
    eau petillante
    eau plate
    grenadine
    infusion
    jus
    jus d abricot
    jus d ananas
    jus d orange
    jus de citron
    jus de pomme
    jus de raisin
    jus de tomate
    limonade
    nectar
    rhum
    sirop
    sirop de menthe
    soda
    the
    the noir
    the vert
    tisane
    vin
    vin blanc
    vin rose
    vin rouge
    whisky
    amidon de ble
    biscuit pepito
    boulgour complet
    cacao amer
    chocolat patissier
    conserve
    creme de soja
    creme de marron
    fruit confit
    lait concentre
    lait d amande
    lait d avoine
    lait en poudre
    pain grille
    poudre d amande
    puree d amande
    puree de tomate
    sauce huitre
    sucre perle
    tortilla de mais
    vermicelle de riz
    """,
    .autres: """
    alcool menager
    allumette
    assouplissant
    bicarbonate de soude
    boite de conservation
    bougie
    brosse a dent
    coton
    coton tige
    couche
    dentifrice
    deodorant
    detartrant
    detergent
    eponge
    essuie tout
    film alimentaire
    filtre a cafe
    gant menager
    gel douche
    lessive
    lingette
    liquide de rincage
    liquide vaisselle
    mouchoir
    papier aluminium
    papier cuisson
    papier sulfurise
    papier toilette
    pastille lave vaisselle
    pile
    rasoir
    sac congelation
    sac poubelle
    savon
    savon de marseille
    serviette en papier
    serviette hygienique
    shampooing
    vinaigre menager
    etiquette
    gobelet
    papier cadeau
    papier kraft
    sac reutilisable
    sachet de congelation
    """,
]
