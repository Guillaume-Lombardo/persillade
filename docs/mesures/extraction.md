# Banc d’extraction G1L-821

## Méthode

Le [corpus](../../Paquets/PersilladeCore/Tests/PersilladePlateformeTests/CorpusExtraction/) contient
18 recettes originales et leurs attendus structurés. Il comprend cinq pages HTML complètes,
dont trois avec JSON-LD, cinq textes ou messages et huit images JPEG générées par le test
à partir de pages originales. Cinq images imitent une page imprimée et trois fiches utilisent
une police manuscrite. Les fiches sont des simulations typographiques. Le corpus ne contient
aucune écriture manuscrite réelle ou photo prise avec un appareil.

Le banc utilise `Extracteur` avec `MoteurFondation` et `LecteurImageVision`. Il charge les
pages depuis des fichiers locaux pour que la latence réseau soit indépendante du résultat.
Pour les trois paires web, il rejoue le même document en retirant seulement son script JSON-LD.
Le gain est la mesure sans JSON-LD moins celle avec JSON-LD. Une passe supplémentaire sur
`texte-01` sans moteur mesure le repli local. Le banc ne configure aucun fournisseur externe.

Un passage séquentiel par variante est chronométré de l’appel à `extraire` jusqu’au
brouillon. Vision est compris. Le rendu du corpus, le téléchargement réseau, l’interaction
et l’enregistrement sont hors chronométrage. Le nombre de corrections est une distance
d’édition. Compter une correction pour un titre ou des portions différents, puis une par
ligne d’ingrédient ou d’étape à ajouter, retirer ou remplacer. Pour les ingrédients, comparer
le nom normalisé, la fraction exacte et l’unité. Pour les étapes, ignorer la casse, les
différences d’espacement, d’apostrophe typographique et de ponctuation finale.
Le statut `complet` indique la présence des champs requis et peut coexister avec des corrections.

Le rapport Markdown contient le statut, la cause éventuelle, le moteur et la durée de chaque
cas, la distance à l’attendu et le gain des trois paires web. La disponibilité du modèle en
français et sa fenêtre totale en jetons sont lues au début du test. La fenêtre reste non
mesurée si le modèle est indisponible. L’adaptateur local actuel reçoit du texte. Pour les
images, l’entrée mesurée est Vision puis texte. Voir [SystemLanguageModel](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel).

## Rejouer

Le test reste désactivé par défaut. Depuis la racine du dépôt sur macOS 27 ou plus récent :

```sh
mkdir -p .build
PERSILLADE_BANC_EXTRACTION=1 PERSILLADE_RAPPORT_EXTRACTION="$PWD/.build/extraction-mac.md" \
  swift test --package-path Paquets/PersilladeCore --filter BancExtractionTests
```

Sur simulateur iOS 27 :

```sh
(
  cd Paquets/PersilladeCore
  TEST_RUNNER_PERSILLADE_BANC_EXTRACTION=1 xcodebuild -scheme PersilladeCore-Package \
    -destination "platform=iOS Simulator,id=$PERSILLADE_SIMULATEUR" \
    -derivedDataPath ../../.build/DerivedData -parallel-testing-enabled NO -jobs 4 \
    -only-testing:PersilladePlateformeTests/BancExtractionTests test
)
```

Le test écrit et affiche le Markdown. Sans chemin explicite, il l’écrit dans le dossier
temporaire du processus de test. Sur iOS, récupérer le tableau dans la sortie de test.

## Mesures Mac et simulateur

Un passage Mac sur macOS 27.2.1, modèle en français disponible, contexte de 8 192 jetons.
Le tableau regroupe les variantes nominales. Les durées sont des intervalles observés.

| Entrée | Cas | Mac · complets / partiels / échecs | Mac · durée (ms) | Mac · corrections cumulées |
| --- | ---: | ---: | ---: | ---: |
| Web | 5 | 5 / 0 / 0 | 8,1–2 218,6 | 2 |
| Texte | 5 | 5 / 0 / 0 | 4,0–2 003,5 | 2 |
| Page imprimée simulée | 5 | 5 / 0 / 0 | 142,0–2 530,7 | 0 |
| Fiche en police manuscrite | 3 | 3 / 0 / 0 | 145,8–164,1 | 6 |

Sur Mac, les trois gains JSON-LD sont de 4 949,1 ms, −2,3 ms et 2 541,7 ms pour
`web-01`, `web-02` et `web-03` respectivement, avec la même distance à l’attendu.
Sans JSON-LD, deux de ces cas appellent le modèle et le troisième reste déterministe.
Sur `texte-01`, le repli forcé est partiel (`ia_indisponible`) avec trois lignes à corriger,
contre zéro avec le modèle.

Un passage sur simulateur iPhone 15 Pro, iOS 27.0, a signalé `modeleEnAttente`.
La fenêtre de contexte est donc à mesurer sur iPhone.

| Entrée | Cas | Simulateur · complets / partiels / échecs | Simulateur · durée (ms) | Simulateur · corrections cumulées |
| --- | ---: | ---: | ---: | ---: |
| Web | 5 | 4 / 1 / 0 | 11,3–47,7 | 5 |
| Texte | 5 | 4 / 1 / 0 | 7,5–33,7 | 5 |
| Page imprimée simulée | 5 | 4 / 1 / 0 | 805,5–4 928,7 | 3 |
| Fiche en police manuscrite | 3 | 3 / 0 / 0 | 1 186,6–1 267,7 | 6 |

Sur simulateur, le JSON-LD évite trois corrections dans chacun des cas `web-01` et
`web-03`. Pour `web-02`, le résultat reste exact dans les deux variantes. Les gains de
temps observés sont de −27,8 ms, −4,4 ms et −8,6 ms respectivement. Sans modèle
disponible, ces écarts comparent deux traitements déterministes sur un seul passage.

## iPhone physique

L’iPhone appairé est resté verrouillé au second essai, espacé de plus de dix minutes.
L’installation et les mesures restent à faire. Vérifier l’état de l’appareil avec
`xcrun devicectl device info lockState --device "$PERSILLADE_IPHONE" --timeout 10`.

| Mesure sur iPhone 15 Pro | Résultat |
| --- | --- |
| Extraction, modèle local et fenêtre de contexte | À mesurer |
| Motif, médiane vignette et fiche à cache vidé | À mesurer |
| Démarrage à froid | À mesurer |
| Correction et enregistrement chronométrés | À mesurer |

Pour le banc seul, utiliser le paquet avec une équipe de développement existante. Avec
`PERSILLADE_IPHONE` et `PERSILLADE_EQUIPE` renseignés localement :

```sh
(
  cd Paquets/PersilladeCore
  TEST_RUNNER_PERSILLADE_BANC_EXTRACTION=1 xcodebuild -scheme PersilladeCore-Package \
    -destination "platform=iOS,id=$PERSILLADE_IPHONE" \
    -derivedDataPath ../../.build/DerivedData -parallel-testing-enabled NO -jobs 4 \
    -only-testing:PersilladePlateformeTests/BancExtractionTests \
    DEVELOPMENT_TEAM="$PERSILLADE_EQUIPE" CODE_SIGN_ENTITLEMENTS= test
)
```

Pour l’app et son test de rendu, la signature automatique peut utiliser le profil générique
déjà présent, s’il couvre les cibles et l’appareil. Avec les entitlements vidés, la feuille
de partage ne peut pas transmettre de recette à l’app via l’App Group.

```sh
xcodebuild -scheme Persillade -destination "platform=iOS,id=$PERSILLADE_IPHONE" \
  -derivedDataPath .build/DerivedData -jobs 4 \
  DEVELOPMENT_TEAM="$PERSILLADE_EQUIPE" CODE_SIGN_ENTITLEMENTS= build
xcrun devicectl device install app --device "$PERSILLADE_IPHONE" \
  .build/DerivedData/Build/Products/Debug-iphoneos/Persillade.app
xcrun devicectl device process launch --device "$PERSILLADE_IPHONE" xyz.g1lom.persillade
xcodebuild -scheme Persillade -configuration Release -destination "platform=iOS,id=$PERSILLADE_IPHONE" \
  -derivedDataPath .build/DerivedData -parallel-testing-enabled NO -jobs 4 \
  -only-testing:PersilladeTests/RenduPlancheTests/mesureRendusFroidsSurSimulateur \
  ENABLE_TESTABILITY=YES DEVELOPMENT_TEAM="$PERSILLADE_EQUIPE" CODE_SIGN_ENTITLEMENTS= test
```

Le test de motif remet son cache à zéro avant chaque rendu, écarte deux passages puis
rapporte la médiane de 40 rendus pour chaque format. Pour mesurer le démarrage à froid,
arrêter Persillade et relever le temps jusqu’à la première image dans le modèle
**App Launch** d’Instruments. Répéter sur l’iPhone et rapporter la médiane.

## Risque s5_r1

L’extraction seule reste sous les cibles sur Mac et simulateur avec ce corpus court. Le
risque s5_r1 reste ouvert pour les imports en moins de 60 s (web et texte) ou 120 s (photo),
correction et enregistrement compris. Pour vérifier ces cibles, chronométrer l’import jusqu’à
l’enregistrement sur l’iPhone, avec des contenus réels et du papier réellement manuscrit.
Consigner séparément les échecs complets et inclure la correction manuelle dans leur durée.

Vision donne des brouillons exploitables sur ces pages rendues. Les écarts sont plus
élevés sur les fiches avec ingrédients regroupés sur une ligne. Le découpage sans
en-têtes reste fragile. Par exemple, `fiche-03` contient trois ingrédients séparés par
des barres obliques et une première étape non numérotée. L’analyse peut déclarer le
brouillon complet malgré ces omissions. `texte-02` expose un rendement en bols pris
pour un ingrédient et une ligne citée avec `>` mal interprétée. Ces cas restent dans
le rapport pour suivre les évolutions. Ce corpus ne stresse pas la réduction au bloc
recette ni sa limite de trois morceaux.

Le seul changement du parseur accepte le tiret cadratin comme séparateur avant les
portions. Le test de régression vérifie le titre de `texte-04`.
