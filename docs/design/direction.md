# Direction de design : la planche

Aperçu : [`planche.png`](planche.png). Preuve du motif : [`preuve-motif.png`](preuve-motif.png). Écrans : [`maquettes/`](maquettes). Icône : [`icone/`](icone).
Maquettes par paramètre : `maquettes/maquettes.html?e=courses&m=sombre`. Les PNG d’écran ne sont pas versionnés : `maquettes/rendre.sh` les recrée (Chrome, macOS).

## 1. Idée directrice

1. Chaque recette se dessine avec ses propres ingrédients, taillés comme en cuisine (rondelles, dés, julienne, tranches, grains) et rangés en biais sur une planche de couleur. Le motif est calculé et remplace la photo.
2. Le reste est une affiche de marché tenue : titres étroits, une colonne de pesée commune où tombent toutes les quantités, des aplats pleine largeur plutôt que des cartes.
3. La navigation reste celle d’iOS 27 : Liquid Glass pour les barres, contenu opaque dessous, geste suivant sous le pouce.

Signature : le **trait de couteau** (liseré de la couleur du fond entre deux pièces) et les **pluches** (persil haché pour le salé, sucre glace pour le sucré, ton sur ton sans preuve).

## 2. Couleur

### Rôles (catalogue d’assets, une paire clair/sombre chacun)

| Rôle | Clair | Sombre | Usage | Contraste clair / sombre |
|---|---|---|---|---|
| `page` | `#FFFFFF` | `#0B120E` | fond de tout écran | |
| `page2` | `#F1F4EE` | `#16201A` | texte reçu, portions, rayons, avis, champs | |
| `trait` | `#DCE3D8` | `#2B3730` | filets 0,5 pt | décoratif |
| `encre` | `#12211A` | `#F0F5EC` | texte principal, **toutes les quantités** | 16,7 / 17,1 sur `page` ; 15,0 / 15,1 sur `page2` |
| `encre2` | `#53635A` | `#A6B6AA` | texte secondaire, ligne exclue, `minus.circle` | 6,4 / 8,9 ; 5,7 / 7,9 sur `page2` |
| `persil` (teinte) | `#0F6B3A` | `#7FD38B` | ce qui se touche, et rien d’autre | 6,6 / 10,5 ; 5,9 / 9,2 sur `page2` |
| `surPersil` | `#FFFFFF` | `#06210F` | texte sur `persil` | 6,6 / 9,4 |
| `tomate` | `#B8261B` | `#FF9285` | échec, suppression | 6,3 / 8,8 ; 5,7 / 7,7 sur `page2` |
| `surTomate` | `#FFFFFF` | `#3A0A05` | texte de l’action Supprimer | 6,3 / 7,9 |
| `beurre` | `#FFE48F` | `#4D3C08` | bandeau, bouton et surlignage « à vérifier » | |
| `surBeurre` | `#4A3800` | `#FFE7A0` | texte sur `beurre` | 9,0 / 8,7 |
| `beurreFond` | `#FFF8DF` | `#241E0B` | fond d’un champ à vérifier | |
| `beurreTexte` | `#7A5600` | `#FFDC7A` | motif de vérification | 6,3 / 12,5 sur `beurreFond` |
| `lu` | `#DDEFD3` | `#1F3A28` | surlignage du texte reconnu | encre 13,8 / 11,2 |

Dans les listes et formulaires, `beurre` signifie uniquement « à vérifier ». `tomate` : a échoué ou supprime.

### Fonds de recette

| Fond | Clair / encre | Sombre / encre | Pluches claires (2 tons) | Contraste |
|---|---|---|---|---|
| Persil | `#0F5B33` / `#F4F8EC` | `#0C4527` / `#E8F3E3` | `#7FD36B` `#B9E58A` | 7,6 / 9,7 |
| Rose d’ail | `#F7C9D4` / `#4A1029` | `#6A2440` / `#FFDDE6` | `#0F5B33` `#2E9E4F` | 10,2 / 8,6 |
| Beurre | `#FFDC63` / `#3A2A00` | `#42320A` / `#FFE9A3` | `#0F5B33` `#2E8B45` | 10,4 / 10,3 |
| Faïence | `#BCDDF5` / `#0B2E4D` | `#163F63` / `#D3EAFB` | `#0F5B33` `#2E8B45` | 9,8 / 8,8 |
| Petit pois | `#CBE38A` / `#1F3304` | `#39500F` / `#E2F3B4` | `#0F5B33` `#2F7A2E` | 9,7 / 7,6 |
| Aubergine | `#43214F` / `#FBEAF6` | `#371A42` / `#F3DDF0` | `#7FD36B` `#B9E58A` | 11,6 / 11,8 |

En sombre, seuls le fond et le trait de couteau changent ; les pigments restent identiques.

### Rayons (ct-categories, dans cet ordre)

Bandeau `page2`, titre et nombre en `encre` et `encre2`. Seul le symbole est teinté. Contraste du symbole sur `page2`, toujours ≥ 3:1.

| Rayon | Symbole SF | Teinte claire / sombre | Contraste |
|---|---|---|---|
| Fruits et légumes | `carrot.fill` | `#3F7A1F` / `#A8D86A` | 4,7 / 10,1 |
| Boulangerie | `oven.fill` | `#8A5A16` / `#E3B56B` | 5,3 / 8,8 |
| Crèmerie et œufs | `oval.portrait.fill` | `#3A6FB0` / `#8FBDF0` | 4,6 / 8,5 |
| Viandes et charcuterie | `frying.pan.fill` | `#B03A5B` / `#F293AE` | 5,3 / 7,6 |
| Poissons | `fish.fill` | `#0E7C86` / `#6FCFD6` | 4,5 / 9,2 |
| Épicerie salée | `cylinder.fill` | `#7A5C3A` / `#D2B48C` | 5,5 / 8,5 |
| Épicerie sucrée | `birthday.cake.fill` | `#7A4FA8` / `#C6A4EE` | 5,4 / 7,9 |
| Surgelés | `snowflake` | `#2383A3` / `#7FCBE3` | 3,9 / 9,2 |
| Boissons | `waterbottle.fill` | `#B4542A` / `#F2A27C` | 4,5 / 8,2 |
| Hygiène et maison | `bubbles.and.sparkles.fill` | `#5A6B86` / `#AEBED6` | 4,9 / 8,9 |
| Autres | `tag.fill` | `#53635A` / `#A6B6AA` | 5,7 / 7,9 |

## 3. Typographie

**SF Pro seule, largeurs Compressed et Condensed, aucune police embarquée.**

| Rôle | Style Dynamic Type | Réglage | Taille par défaut |
|---|---|---|---|
| Titre d’onglet | `largeTitle` natif | heavy, condensed (voir règle) | 34/41 |
| Titre de fiche et de rapport | `.largeTitle` | heavy, `.compressed` | 46/46 |
| État vide | `.largeTitle` | heavy, `.compressed` | 54/50 |
| Numéro d’étape | `.largeTitle` | heavy, `.compressed`, chiffres tabulaires | 44, « sur 8 » 24 sur la même ligne |
| Consigne | `.largeTitle` à `.title` ; `.title2` dès AX1 | semibold, standard | 36 jusqu’à 110 caractères, 32 jusqu’à 180, 28 au-delà |
| Titre de recette en liste | `.title2` | heavy, `.condensed` | 22/23 |
| Section | `.title3` | heavy, `.condensed` | 20/24 |
| Rayon | `.headline` | heavy, `.condensed` | 18/22 |
| Quantité | `.title2` | heavy, `.compressed`, `.monospacedDigit()` | 22/24 |
| Unité | `.body` | heavy, `.condensed` | 17 |
| Texte, ingrédient | `.body` | regular, standard | 17/22 |
| Bouton | `.headline` | semibold, standard | 16 à 18 |
| Précision, état | `.footnote` | regular ; semibold si à vérifier ou en échec | 13/18 |

```swift
extension Font {
    static func affiche(_ style: TextStyle) -> Font { .system(style, weight: .heavy).width(.compressed) }
    static func etiquette(_ style: TextStyle) -> Font { .system(style, weight: .heavy).width(.condensed) }
}
```

- **Titre d’onglet** : `.navigationTitle` et `largeTitle` système. La police passe par `UINavigationBarAppearance.largeTitleTextAttributes` avec `UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for:)`. Gardée seulement si elle suit Dynamic Type **et** le texte en gras app ouverte (test à écrire) ; sinon titre standard.
- Tailles hors style : `@ScaledMetric` **avant AX1** seulement. Dès AX1 : style système, sans multiplicateur.
- **Dès AX1** (`dynamicTypeSize >= .accessibility1`) : largeur standard partout, `.lineLimit(nil)`, aucun `minimumScaleFactor`. `ViewThatFits` passe une ligne en vertical dès qu’elle déborde, même avant AX1.

## 4. Grille

- Pas de 4 pt. Marge latérale 16. Barre d’onglets et barre d’action alignées à 21.
- **Colonne de pesée** : 92 pt en `@ScaledMetric`, marge 16, gouttière 14, soit **62 utiles**, alignée à droite. La même sur Fiche, Correction, Courses, Articles d’un message, Rapport. Le symbole de rayon s’y aligne, le titre du rayon sur les noms.
- `ViewThatFits` : unité en ligne, sinon sous le nombre. Dès AX1, la ligne entière passe en vertical.
- Hauteurs minimales : ingrédient 46, ingrédient annoté 60, ligne de courses 52, rayon 36, recette 96, bande de semaine 104. Cibles 44 ; en cuisine 80.
- Aplats bord à bord, rayon 0. Arrondis réservés au verre, aux boutons, aux champs en saisie et aux vignettes de 22 pt (rayon 5). Aucune ombre sur le contenu.
- Deux planches voisines de même fond : filet `page` de 2 pt.

## 5. Motif génératif

Référence exécutable, normative pour les valeurs absentes ici : [`maquettes/motif-reference.js`](maquettes/motif-reference.js) (dictionnaire, exclusions, tracés, coefficients). Modèle pur `Planche` dans `PersilladeCore`, testable sans écran.

### 5.1 Des lignes aux rangées

1. **Nom** : `normaliserNom` (ct-normalisation), parenthèses retirées. Aucune pièce inventée. On cherche la **plus longue clé en mots entiers** ; à longueur égale, la plus à gauche. « pomme de terre » l’emporte sur « pomme », « pâte feuilletée » n’est pas « pâtes », « pommeau » ne trouve rien.
2. **Exclusions** (50 entrées : eau, sel, poivre, huile, vinaigre, bouillon, jus, fond, sauce soja, épices, levure, bouquet garni…). L’exclusion gagne si elle commence avant la clé, ou au même endroit en étant au moins aussi longue : « huile d’olive », « bouillon de poulet », « noix de muscade » sont écartés ; « oignon piqué de clous de girofle » reste un oignon.
3. **Dictionnaire** : 197 clés, chacune avec visuel, classe (`s` solide, `l` liquide, `p` poudre) et masse d’une pièce. Les alias partagent un visuel ; leurs masses s’additionnent.
4. **Masse** : kg, g, l, dl, cl, ml convertis en grammes (1 ml = 1 g) **avant** classement ; cas 15, cac 5 ; gousse, tranche, botte, pot, boîte, pavé… ont leur masse ; pièce = masse du dictionnaire ; sans quantité 5. Fourchette : borne haute lue par ce module, sans effet sur la recette.
5. **Choix** : solides d’au moins 8 g, 4 plus lourds (3 en vignette, 2 en miniature). Moins de 2 solides : on ajoute herbes et petits solides, puis au plus un liquide (ruban ondulé) et une poudre (semis fin), 3 rangées au total. Encore moins de 2 : **coupe neutre**, rangées ton sur ton (fond mêlé à son encre, 10 % et 20 %) tirées parmi ruban, dés, rondelles, bâtonnets : une rangée s’il y a déjà un ingrédient, sinon deux séparées par un semis fin. Une rangée de persil n’existe que si le persil ou la ciboulette est listé.
6. **Hauteur** : `clamp(√masse / √masseMax, 0,55, 1)` ; ruban ≤ 0,8 ; semis ≤ 0,6.
7. **Pluches** : vertes **avec preuve de salé** (viande, poisson, alliacé, légume salé, fromage, légumineuse, herbe salée, ou nom écarté comme poivre, bouillon, vinaigre ; « sel » n’en est pas une) ; sucre glace sans cette preuve et avec sucre, chocolat, miel ou confiture ≥ 40 g ; sinon **ton sur ton** (fond mêlé à son encre, 22 % et 36 %).

### 5.2 Tirages

- `graine(texte)` : FNV-1a 64 bits des octets UTF-8 du texte en minuscules. `tirage(g, n)` : SplitMix64 **à accès direct**, état `g + (n+1)·0x9E3779B97F4A7C15`, sortie `(z >> 11) / 2^53`.
- Une graine par usage : `id/fond`, `id/cadre` (biais), `id/repli`, `id/r0`, `id/r1`… (une par rangée, dans l’ordre de dessin), `id/pluches`.
- Les pièces sont comptées depuis le centre de la rangée (0, −1, 1, −2, 2… → 0, 1, 2, 3, 4…) ; les grains et le haché par appariement de Cantor (colonne, ligne) ; 16 tirages réservés par fragment. Un tirage ne dépend ni de la taille du cadre, ni du nombre de pièces, ni des autres rangées.
- **Élagage** : toute pièce dont le cercle englobant est hors cadre n’est pas dessinée. Il ne change aucun tirage.

Vecteurs de test, `id = D902B3B1-A984-4449-B7CD-259FE5EF68A2` :

| Graine | Valeur | Premiers tirages |
|---|---|---|
| `id/fond` | `0x29028b85ac623ba3` | rang 3 (Faïence) |
| `id/cadre` | `0x5a3cc2f8fadad7cb` | 0,39095529414799557 ; 0,8291660706341947 ; 0,2268449894585307 |
| `id/repli` | `0x031824ac66847a4e` | 0,9962414017160922 |
| `id/r0` | `0x78777a4eedbcc7a0` | 0,294153628556033 |
| `id/pluches` | `0x3d123a1fc0d64d2a` | 0,37692311378476295 |

### 5.3 Dessin

1. **Fond** : partir de `graine(id/fond) mod 6` dans l’ordre Persil, Rose, Beurre, Faïence, Petit pois, Aubergine ; premier fond à un écart OKLab ≥ 0,14 de chacun des 3 premiers ingrédients (le plus grand de peau et chair), sinon le plus éloigné.
2. **Biais** : `[−18, −11, 11, 18][⌊tirage(id/cadre, 0) × 4⌋]`. Fiche −10° fixe ; état vide et icône −18°.
3. **Rangées** : rectangle englobant `H = w·|sin a| + h·cos a`, séquence répétée `max(1, round(H / (module·n·0,9)))` fois ; module 30 à 34 en vignette, 58 sur grand format.
4. **Pièces** : `R = 0,485 × hauteur`, pas `R × coefficient` (rondelle 1,18 ; tranche 1 ; bâtonnet 0,62 ; lanière 0,82 ; lardon 1,02 ; dé 1,86 ; coin et champignon 1,62 ; gousse 0,84 ; feuille 1,16 ; quartier, fleurette, crevette, noix, olive 1,5). Trait de couteau `max(1, min(w,h)/62)`.
5. **Semis de pluches** : `w·h/640` (petit) ou `w·h/1500`, 120 au plus, aucune sous 24 pt.
6. **Bornes** : par rangée, 90 pièces et 150 grains en petit format, 260 et 420 en grand (semis × 1,2 ; semis neutre × 0,8) ; au-delà le pas grossit. Mesuré sur la preuve, fond compris : 811 tracés au plus en 342 × 210, 242 en 96 × 96. Sur 30 recettes × 25 identifiants : 814 et 260 ; 280 en 112 × 96 ; 742 en fiche.
7. **Cadrage** : jamais de pièce coupée net sur son propre fond. Semaine : les pièces qui débordent à gauche ne sont pas dessinées. Fiche et état vide : la première rangée est entière et son biais forme le bord haut.

### 5.4 Rendu et cache

- `RenduPlanche`, `actor` hors acteur principal : `CGContext` sRGB 8 bits, opaque, tracés Core Graphics, sortie `CGImage`. Ni `Canvas`, ni `ImageRenderer` (acteur principal).
- Clé : `id, empreinte des ingrédients, type de cadrage (vignette, semaine, fiche, miniature, vide), taille en pixels, apparence, version du moteur`. Deux demandes identiques partagent la tâche ; une cellule qui sort n’annule que **son attente**, la tâche s’arrête quand plus personne n’attend.
- `NSCache` borné **en octets** : `totalCostLimit = 24 Mo`, coût `bytesPerRow × height` (vignette 112 × 96 @3x = 387 ko, fiche 393 × 238 @3x = 3,4 Mo). Vidé sur alerte mémoire.
- À l’enregistrement d’une recette, la vignette 112 × 96 est rendue dans les deux apparences et écrite dans `Caches`. Elle est recréée si elle manque.
- En attente : **aplat du fond** (connu sans dessin), puis l’image sans fondu au défilement, fondu 0,15 s hors défilement.
- Budget à mesurer sur l’iPhone le plus ancien pris en charge : vignette ≤ 8 ms, fiche ≤ 30 ms, et un défilement de 60 recettes **à cache froid, décodage des fichiers compris**, sans image perdue.

### 5.5 Preuve

[`preuve-motif.png`](preuve-motif.png) : 20 recettes ordinaires, lignes telles qu’importées, UUID tirés une fois et gardés dans l’ordre, aucune retouche. Béchamel, velouté, gâteau au yaourt et trois recettes mal reconnues comprises. Les maquettes suivent le même chemin.

## 6. Navigation iOS 27

- `TabView` : Recettes `text.book.closed.fill`, Semaine `calendar` (badge = nombre de recettes), Courses `basket.fill`, `Tab(role: .search)`.
- **`safeAreaBar(edge: .bottom)` par écran** pour l’action principale : « Faire la liste » (Semaine), ajout, liste Rappels et « Envoyer » (Courses), « Coller un lien ou un texte » (Recettes vide).
- **Contenu reçu** : la feuille Destination s’ouvre au passage au premier plan, sauf si une autre feuille est ouverte. `tabViewBottomAccessory` ne sert qu’après sa fermeture, **sur Recettes seul** : « 1 contenu reçu », « Lien, 17:40 », « Ouvrir » ; plusieurs, « 2 contenus reçus » et le plus ancien. Forme réduite (`.inline`) : symbole, « 1 reçu », « Ouvrir ».
- « + » de Recettes : Coller un lien ou un texte, Écrire. « … » de Recettes : Réglages.
- « + » de Semaine : ouvre l’onglet Recettes. « … » de Semaine : Vider la semaine (confirmation).
- « … » de Courses : Nouvelle liste, Ouvrir Rappels, Remettre les articles exclus.
- Fiche : barre d’onglets masquée, « Ajouter à la semaine » ou « Retirer de la semaine » et « Cuisiner » en bas. Correction, Articles d’un message et Rapport : feuilles `.large`. Coller, Destination, Liste Rappels, détail, accès refusé : `.medium`. Pas à pas : `fullScreenCover`.
- **Photo** : absente de la base. Slice-3 : troisième entrée du menu « + » (« Prendre une photo », `camera`) et second bouton de l’état vide.

## 7. Écrans et composants

### Recettes
Planche 112 × 96 collée au bord, sans espace entre les lignes. Titre 2 lignes, « 10 ingrédients, 8 étapes ». À droite, 44 : `plus` cerclé ou `checkmark` plein si choisie. Balayage : supprimer ; la confirmation annonce « Retirée aussi de la semaine ». **Recherche** : même ligne, bouton + compris.

### Fiche
Pas de pictogramme dans les lignes. **Dans la semaine** : « Dans la semaine », −/+ modifie la sélection, et le bouton devient « Retirer de la semaine ». **Sinon** : « Affichage seul, la recette ne change pas ». « Cuisiner » seulement avec au moins une étape, aux portions affichées. `toolbarColorScheme` suit le fond de l’en-tête et se rétablit quand il sort de l’écran. Sans lien, pas de ligne de source.

### Coller, réception, destination
- **Coller** : petite feuille, champ multiligne et `PasteButton` natif, puis Destination. Même feuille pour « Coller le texte » après une erreur.
- **Destination** : titre ou premiers mots, origine, heure, « 1 sur 2 ». « Recette », « Articles de courses », « Abandonner » (confirmation si le texte n’est pas ailleurs). Le choix que suggère le contenu est plein. L’élément suivant est annoncé en bas et s’ouvre ensuite. Fermer garde la file.

### Correction
- **Alertes (`beurre`)** : portions supposées, nom vide, ligne non comprise. Rien d’autre. Fourchette, « sel, au goût », quantité absente : **note neutre** en `encre2`, non comptée.
- « Enregistrer » en toutes lettres, toujours visible. Possible malgré les alertes, sauf titre vide ou ingrédient sans nom : le bouton reste actif, amène au champ fautif et l’annonce. Une « ligne non comprise » garde son texte comme nom ; « Corriger » l’ouvre.
- **Texte reçu** : volet `page2` repliable, 5 lignes puis défilement. `lu` = repris, `beurre` = à vérifier ; toucher un extrait va au champ. **En saisie, réduit à l’extrait actif**, deux lignes au plus. Sans correspondance exacte de `texte_origine`, aucun surlignage.
- **Ligne en édition** : quantité (pavé décimal) et nom, corbeille 44, unités en puces au-dessus du clavier (unité lue d’abord, puis g, kg, ml, cl, l, pièce, c. à s., c. à c., « Autre… »), « Suivant ».
- **Étapes** : toucher pour modifier, balayer pour supprimer (annulable), « Ajouter ». **Réordonner** ingrédients et étapes sans mode édition : `reorderable()` si le SDK l’a, sinon `onMove`, poignée de 44 ; compatibilité avec `swipeActions` à vérifier d’abord. Actions VoiceOver « Monter », « Descendre », « Supprimer ».
- **Bandeau d’extraction** : en cours, `ProgressView`, « Lecture de la recette », Annuler ; complet sans alerte, pas de bandeau ; à vérifier, `beurre`, nombre, « Suivant » ; dégradé, `beurre` et cause ; échec, `tomate` sur `page2`, cause et action.
- **Échec d’enregistrement** : « La recette n’a pas été enregistrée. Rien n’est perdu. », « Réessayer ». Brouillon et contenu reçu conservés.

### Articles d’un message
Même volet de texte. Chaque article : quantité, nom, rayon, `minus.circle` ; toucher la ligne ouvre l’éditeur. Sans IA : cause affichée (§ 9), une proposition par ligne, toutes modifiables avant intégration. Ligne trop vague : `beurre`, « Corriger ». « Ajouter 3 articles » ne compte que les lignes valides ; la ligne non corrigée n’est pas ajoutée, et c’est écrit.

### Ajout manuel
Champ et « Ajouter » **collés au clavier**, sous le pouce. La quantité lue et le rayon proposé apparaissent en puces, modifiables. Les brouillons s’empilent au-dessus ; les retirer ne touche que Persillade. Sur une liste envoyée, chaque ligne montre le résultat de son envoi ciblé (« Envoyé », « Aucun ajout nécessaire », « Échec », « Réessayer ») et la retirer dit que le rappel reste. Sans quantité sur une ligne exclue : « oignons ne sera pas envoyé. Remettre ? ».

### Semaine
Bande de 104 sur le fond de la recette : titre, − portions +, planche à droite. Toucher la bande ouvre la fiche. − désactivé à 1. Balayage et action VoiceOver « Retirer de la semaine ». Pas de total. Avis neutre (`page2`) : « **Liste faite avant ce changement** » et le changement ; « Refaire la liste ». Il compare la semaine à la **copie de la sélection conservée à la génération**.

### Courses
- **Ligne** : quantité, nom, commande 44 × 44 à droite. Toucher la ligne ouvre le détail. Balayage : retirer.
- **Exclure** : `minus.circle` en `encre2`. Ligne exclue : atténuée, **ni barrée ni cochée**, « Ne sera pas envoyé », `plus.circle` en `persil`, libellé « Remettre ». Jamais « déjà à la maison ».
- **Barre** : « + », liste Rappels, « Envoyer 22 ». Sans liste choisie : « Choisir une liste ».
- **Après envoi** : en tête « Au magasin, cochez dans Rappels. » et « Ouvrir ». « Renvoyer » toujours présent. **Seule la première écriture réussie verrouille la destination** (`lock.fill`), jamais une lecture réussie.
- **État** : dérivé du **dernier résultat persisté par ligne** (issue et quantité traitée), jamais de l’existence actuelle du rappel.

| État après envoi | Dérivation | Marque |
|---|---|---|
| À envoyer | aucun résultat | `arrow.up.circle`, `persil` semibold |
| Envoyé | ajoutée ou complétée, quantité ≤ traitée | `arrow.up.circle.fill`, `encre2` |
| Rien à ajouter | couverte par un rappel existant, quantité ≤ traitée | `checkmark.circle`, `encre2` |
| 3 de plus à envoyer | quantité > traitée | `arrow.up.circle`, `persil` semibold |
| Échec | dernier essai en échec | `exclamationmark.triangle.fill`, `tomate` semibold |

Baisser, exclure ou retirer une ligne traitée : « Rappels ne change pas », au moment du geste.

- **Détail** (feuille) : toucher la quantité ouvre l’éditeur de Correction (quantité libre, unité, effacer) ; −/+ n’est qu’un raccourci. La fusion contractuelle s’applique à la validation : le `ligne_id` peut changer, la feuille suit la ligne fusionnée. Rayon, **provenance** (noms des sources, vignettes 22 pt), « Ne pas envoyer », « Retirer ».
- Rayon vide absent, en-têtes épinglés.

### Liste Rappels, accès
- Liste : pastille de Rappels, nom, compte, partage ; lecture seule grisée et nommée. « La liste est fixée dès le premier article envoyé. »
- Accès refusé : « Ouvrir Réglages », « Plus tard ». La liste est conservée.

### Compléter ou nouvelle liste (dialogue natif, sans maquette)
`confirmationDialog` à l’intégration d’articles sur une liste déjà envoyée :
- Titre : **Cette liste est déjà dans Rappels.** Message : « Compléter garde ses articles. Une nouvelle liste efface ses 26 lignes dans Persillade, Rappels ne change pas. »
- « Compléter cette liste », « Nouvelle liste » (destructif), « Annuler » (le contenu reçu reste en attente).

### Rapport d’envoi
Titre chiffré, liste, « Au magasin, cochez dans Rappels. » Sections : À réessayer (`exclamationmark.triangle.fill`, `tomate`, forme et couleur), Compléments (« 9 voulus, 6 déjà demandés ou achetés »), **Aucun ajout nécessaire**, Ajoutés. Les deux premières ouvertes. « Réessayer » si échec, sinon « Terminé ».

### Pas à pas
Fond de la recette. Titre en barre, « 3 sur 8 » sur une ligne, consigne 36 → 28 selon la longueur, « Ensuite » repliable (état mémorisé). Barre basse de 80 pt : précédente, **Ingrédients**, Suivante. Balayage horizontal aussi. Dernière étape : « Terminer ». Ingrédients : quantités aux portions choisies et « Pour 6 ; les étapes sont rédigées pour 4 ». Fermer garde la position, bornée si la recette change ; la fiche affiche « Reprendre à l’étape 3 ». `isIdleTimerDisabled` pendant la session seulement.

## 8. Mouvement et haptique

- **Un seul effet d’ouverture** : `.navigationTransition(.zoom)` natif, de la vignette à la fiche.
- Choisir une recette : `plus` devient `checkmark` (`.symbolEffect(.replace)`), haptique `.selection`.
- Portions : `.contentTransition(.numericText())`, haptique `.selection`.
- Exclure ou remettre : fondu d’opacité 0,2 s, haptique `.impact(.light)`.
- Régler une alerte : fond `beurre` effacé en 0,25 s, défilement au suivant ; dernière : `.success`.
- Envoi : progression déterminée dans le bouton, puis `.success` ou `.warning`.
- Étape : fondu 0,2 s, haptique `.impact(.medium)`.
- « Réduire les animations » : fondus de 0,2 s seulement.

## 9. Ton

Vouvoiement ou tournure neutre, phrases courtes, le fait puis l’action. Ni point d’exclamation, ni excuses, ni humour sur une erreur.

| Situation | Texte | Action |
|---|---|---|
| Recettes vide | **La planche est vide.** Importez une première recette. Depuis Safari ou Messages : Partager, puis Persillade. | Coller un lien ou un texte |
| Semaine vide | **Rien de choisi.** Touchez + devant une recette pour l’ajouter à la semaine. | Voir les recettes |
| Courses vide | **Pas encore de liste.** Elle se remplit avec les recettes de la semaine, un message ou un ajout. | Ajouter un article |
| Recherche sans résultat | Aucun titre ne contient « blanquete ». | |
| `hors_ligne` | **L’iPhone est hors ligne.** Le lien est gardé. | Coller le texte |
| `page_inaccessible`, `delai` | **La page ne répond pas.** Le lien est gardé. | Réessayer, Coller le texte |
| `ia_indisponible` | Apple Intelligence est indisponible. Les ingrédients ont été lus ligne par ligne, vérifiez les étapes. | Suivant |
| `ia_en_erreur` | La lecture s’est interrompue. Les ingrédients ont été lus ligne par ligne. | Suivant |
| `contenu_trop_long` | Le texte est trop long, la fin n’a pas été lue. | Voir le texte |
| `rien_trouve` | **Aucune recette trouvée dans ce texte.** Il reste affiché pour la saisie. | Saisir |
| Portions supposées | Absent du texte, 4 par défaut | Garder 4 |
| Quitter avec des changements | **Quitter sans enregistrer ?** Les corrections seront perdues. | Continuer, Quitter |
| Nouvelle liste | **Remplacer la liste ?** Ses 26 lignes seront perdues et les articles déjà achetés seront redemandés. | Remplacer, Annuler |
| Vider la semaine | **Vider la semaine ?** La liste de courses ne change pas. | Vider, Annuler |
| Retirer une ligne envoyée | **Retirer « carottes » ?** Rappels ne change pas. | Retirer, Annuler |
| `acces_refuse` | **Persillade n’a pas accès à Rappels.** Autorisez l’accès complet dans Réglages. | Ouvrir Réglages |
| `liste_introuvable` | **La liste « Maison » n’existe plus dans Rappels.** | Choisir une liste si rien n’est écrit, sinon Nouvelle liste |
| `liste_non_modifiable` | « Maison » est en lecture seule. | Choisir une liste si rien n’est écrit, sinon Ouvrir Rappels |
| `ecriture` | Rappels a refusé l’écriture | Réessayer |

## 10. Icône

Trois gousses d’ail rosé entières en biais entre deux semis de persil, cernées par le trait de couteau. Fragments larges (rayon moyen 76 sur 1024), trait de 40. Trois calques pour Icon Composer (`fond`, `persil`, `ail`), variantes claire, sombre et teintée. L’ail est le seul calque à recevoir le relief du verre. Vérifiée à 60, 40 et 29 pt : [`icone/icone-tailles.png`](icone/icone-tailles.png).

## 11. Accessibilité

- Contrastes calculés ci-dessus (WCAG 2.2) : tout texte ≥ 5,4:1, graphismes porteurs de sens ≥ 3:1.
- **Contraste accru** : `encre2` → `encre`, `trait` → `encre2`, symboles de rayon en `encre`, ligne exclue en `encre` (son état reste écrit), boutons `beurre` cernés de 2 pt `surBeurre`.
- **Transparence réduite** : verre remplacé par `page2` opaque et filet `trait` ; sur fond de recette, par le fond mêlé à 14 % de son encre.
- Aucune information par la couleur seule.
- **Dynamic Type** jusqu’à AX5. Dès AX1 : quantité au-dessus du nom ; planche de ligne 64 pt, absente à AX3 ; bandes de semaine sans planche à AX3 ; texte reçu et « Ensuite » repliés ; nom de liste réduit à son symbole dans la barre. Le contenu défile. **AX5 sur le plus petit iPhone** : action principale et dernière ligne atteignables ; les boutons icône gardent libellé, agrandissement (`accessibilityShowsLargeContentViewer`) et Commande vocale. Maquettes AX3 : Courses, Correction, Pas à pas.
- **VoiceOver et Commande vocale** : libellés visibles = libellés d’accessibilité ; « 9 œufs, article à envoyer », actions « Ne pas envoyer », « Retirer », « Détail » ; exclue, « 4 oignons, ne sera pas envoyé », action « Remettre » ; après envoi, « chocolat noir, échec de l’envoi » ; « Étape 3 sur 8 » puis consigne ; rayons en en-têtes ; motif masqué.
- Une main : actions principales dans les 200 pt du bas, sauf « + » de Recettes et « Enregistrer » (barre de navigation).

## 12. Limites des maquettes

Verre, clavier, ombres et bord de défilement sont approchés en CSS : le rendu système fait foi. En cas d’écart, ce texte fait foi. Le lecteur de lignes de `motif-reference.js` est simplifié : dans l’app, les quantités viennent de ct-recette-standard. Le rendu Core Graphics et ses temps ne sont pas mesurés.
