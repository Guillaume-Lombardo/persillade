# slice-0 (vague 0)

Preuves et socle, sur iPhone 15 Pro sous iOS 27 (SwiftUI, SwiftData, sans dépendance tierce). Les deux risques majeurs sont testés avant tout écran définitif : extraction locale (s6_sp1) et liste Rappels partagée sur les deux iPhone (s6_sp2). Les contrats partagés sont posés et testés : recette, normalisation, catégories, entrée de partage. Squelette : un lien partagé depuis Safari arrive sur un écran d'import factice. Licence, CLA et date du point des 6 semaines en place.

## Dépendances

Aucune

## Domaine possédé

- Socle transverse (format de recette, normalisation, catégories, points d'entrée de partage, prototypes)

## Éléments du backlog

### s6_cc1

Définir le format de recette standardisé : titre, portions, ingrédients avec quantité et unité, étapes.

- Objectif : Fournir le socle commun à l'extraction, à la correction, à la mise à l'échelle et à la fusion.
- Terminé quand : Le modèle ct-recette-standard est implémenté, versionné et couvert par des tests d'encodage et de relecture. Il est utilisé ensuite par tous les imports, l'écran de correction et la génération de la liste.

### s6_cc2

Construire un module partagé de normalisation des noms et de conversion des unités comparables.

- Objectif : Appliquer les mêmes règles à la fusion, à l'ajout manuel et au renvoi vers Rappels.
- Terminé quand : Le module implémente ct-normalisation et passe le jeu de cas français du contrat. Il est utilisé ensuite par s6_us10, s6_us13, s6_us14 et s6_us16.

### s6_cc3

Arrêter la liste fixe prédéfinie des catégories de la V1.

- Objectif : Permettre le regroupement par catégorie décidé en s2_d8.
- Terminé quand : La liste des catégories validée par le porteur dans ct-categories est intégrée avec un dictionnaire d'articles courants et le rayon « Autres » obligatoire. L'affichage arrive avec s6_us11.

### s6_cc4

Mettre en place l'extension de partage iOS et la lecture du presse-papiers comme points d'entrée communs.

- Objectif : Servir les imports de liens web, de textes et de messages par un même mécanisme.
- Terminé quand : L'app apparaît dans la feuille de partage iOS pour les liens et les textes, et accepte le collage. L'extension dépose le contenu dans un espace partagé (App Group) et se ferme ; l'app le reprend à son ouverture, dans l'ordre d'arrivée, sans perte si elle est fermée entre-temps. L'utilisateur choisit la destination : recette ou message. Le partage depuis Safari, Messages, WhatsApp et Messenger est essayé et le résultat consigné.

### s6_cc5

Mettre en place la double licence GPLv3 et licence commerciale, avec CLA.

- Objectif : Préserver la double licence et la possibilité d'une distribution sur l'App Store.
- Terminé quand : Les fichiers de licence GPLv3 et la mention de la licence commerciale sont présents dans le dépôt. Le CLA est en place avant toute contribution externe.

### s6_cc6

Préparer le point de contrôle des 6 semaines et réserver des créneaux réguliers de plus de 10 heures par semaine (s5_r9).

- Objectif : Livrer une V1 utile dans environ 3 mois malgré un porteur seul sur son temps libre.
- Terminé quand : La date de démarrage et la date du point (démarrage + 6 semaines, jalon J1) sont fixées. La charge de chaque tranche est estimée en heures et comparée au temps disponible. La grille de décision est écrite (revision.md, jalon J1). La tenue du point est le jalon J1, hors tranche.

### s6_sp1

Tester tôt l'extraction locale sur l'iPhone 15 Pro sous iOS 27 avec des recettes réelles du foyer (texte, web, photo, manuscrit).

- Objectif : Savoir, avant de construire les écrans d'import, si l'extraction locale peut tenir les cibles de 1 et 2 minutes.
- Terminé quand : Au moins 5 recettes web, 5 textes, 5 photos imprimées et 3 fiches manuscrites sont passées dans un prototype sans interface finale. Sont notés pour chacune : statut, durée d'extraction, nombre de champs à corriger. Sont aussi mesurés : taille de contexte réelle du modèle, disponibilité de l'entrée image sur l'iPhone 15 Pro, gain du JSON-LD sur les recettes web, comportement modèle indisponible. Statuts : voir ct-extraction dans slice-1.md. La conclusion (photo via Vision ou image, découpage du texte, risque s5_r1) est consignée. La correction des photos est chronométrée sur le prototype avec un formulaire minimal ; celle des textes et du web en slice-1.

### s6_sp2

Vérifier sur les deux iPhone la lecture et l'écriture d'une liste Apple Rappels partagée, pour appliquer la règle de renvoi.

- Objectif : Lever tôt l'incertitude technique sur le renvoi sans doublons ni quantités surestimées.
- Terminé quand : Un prototype écrit dans une liste iCloud partagée depuis l'iPhone 15 Pro et la relit après coche depuis l'iPhone 11. Sont vérifiés et consignés : état coché et date de coche (completionDate) après synchronisation, stabilité des identifiants après synchronisation, relecture des titres (écrits par l'app, saisis à la main, modifiés), tri automatique ou non d'une liste de type Courses en français pour des articles ajoutés par l'app, accès refusé, liste supprimée ou en lecture seule. Chaque ligne de la table de décision de ct-renvoi (voir slice-2.md) est rejouée à la main. Si la date de coche n'est pas fiable, la règle de ct-renvoi est revue avant slice-2.

## Contrats fournis

- **ct-recette-standard** — Recette : version_schema (2) ; id (UUID) ; titre (non vide) ; portions (entier > 0 ; 4 si absent à l'import, valeur signalée à corriger) ; ingredients [{nom (non vide), quantite (décimal exact > 0, facultatif), unite (g | kg | ml | cl | l | cac | cas | piece | autre:<texte> ; absente si quantite absente), texte_origine, alternatives [{nom, quantite, unite}]}] ; etapes [texte, ordonné] ; texte_source ; url_source (facultative). « 3 œufs » → quantite 3, unite piece. « 2 à 3 carottes » → 3 (borne haute). « 1/2 » et « ½ » → 0,5. « une pincée de sel », « sel, au goût » → sans quantité. a_l_unite ⇔ unite = piece. Les alternatives suivent les mêmes invariants que le choix principal et sont facultatives à la lecture. Les recettes v1 sont relues en v2 avec une liste d’alternatives vide.
- **ct-normalisation** — normaliserNom(nom) : casse, accents, ligatures (œ → oe), espaces, apostrophes, trait d'union → espace ; retrait des articles initiaux successifs (de, d', du, des, le, la, l', les), mots internes conservés ; singulier mot à mot (s ou x final retiré, « eaux » → « eau »), sauf exceptions (radis, noix, ananas, mais, anchois, pois, jus, riz, brebis, cassis, colis, couscous, houmous, os, frais, gros, bas). Aucun synonyme en V1. convertir(quantite, source, cible) → quantité ou « non comparable ». Comparables : g et kg ; ml, cl et l ; sinon seulement l'unité identique (piece avec piece, cas avec cas, autre avec le même texte normalisé). Calcul canonique en g et ml, décimal exact. Jeu de cas obligatoire : Tomates = tomate ; tomates cerises ≠ tomates ; Œufs = oeuf ; poireaux = poireau ; choux = chou ; choux-fleurs = chou fleur ; noix = noix ; radis = radis ; maïs = mais ; « de la farine » = farine ; pommes de terre = pomme de terre ; 1 kg + 500 g = 1 500 g ; 25 cl + 100 ml = 350 ml ; 2 cas et 10 ml non comparables ; 2 pièces et 300 g non comparables.
- **ct-categories** — Liste fixe validée par le porteur le 23/11/2026 (G1L-839), dans l'ordre d'affichage : Fruits et légumes ; Épicerie ; Boucher ; Poissonnier ; Crémier ; Boulangerie-pâtisserie ; Autres (obligatoire et par défaut). categorieParDefaut(nom normalisé) choisit la plus longue suite de mots reconnue dans le dictionnaire embarqué et privilégie Épicerie en présence de « au sirop ». Le rayon est modifiable et affiché dans l'app seulement. Le changement des rayons a introduit la version 2 de la liste et de son enveloppe. En lecture de la version 1, Boulangerie devient Boulangerie-pâtisserie, Crèmerie et œufs devient Crémier, Viandes et charcuterie devient Boucher, Poissons devient Poissonnier, Épicerie salée, Épicerie sucrée, Surgelés et Boissons deviennent Épicerie, Hygiène et maison devient Autres.
- **ct-entree-partage** — ContenuRecu {id, type (url | texte | image), contenu, origine (feuille_partage | presse_papiers | appareil_photo | phototheque), recu_le}. L'extension accepte url et texte, écrit dans l'App Group puis se ferme, sans réseau ni IA. L'app traite la file à l'ouverture, demande la destination (recette | message), et retire l'élément une fois enregistré ou abandonné explicitement. Les origines appareil_photo et phototheque sont branchées en slice-3.

## Contrats consommés

Aucun

## Scénarios d'intégration

1. Étant donné : L'app est installée sur l'iPhone 15 Pro, fermée, et une page de recette est ouverte dans Safari
   Quand : L'utilisateur partage la page vers l'app puis ouvre l'app
   Alors : L'app reprend un ContenuRecu de type url, d'origine feuille_partage, demande la destination et l'affiche sur l'écran d'import factice
   `WHEN l'utilisateur partage un lien vers l'app THE SYSTEM SHALL produire un ContenuRecu de type url et le router vers la destination choisie à l'ouverture`

2. Étant donné : Une liste Rappels partagée de test contient « lait 1 l » ouvert et « œufs 6 », coché depuis l'iPhone 11
   Quand : Le prototype s6_sp2 relit la liste sur l'iPhone 15 Pro puis y écrit « pain »
   Alors : Les deux articles sont relus avec leur état et la date de coche, et « pain » apparaît sur l'iPhone 11 sans autre changement
   `WHEN le prototype accède à une liste Rappels partagée THE SYSTEM SHALL lire les articles, leur état et leur date de coche, et ajouter un article sans modifier les éléments existants`

## Bouchons

- Écrans d'import de recette et de message factices
- Liste Rappels partagée de test, visible sur l'iPhone 15 Pro et l'iPhone 11
