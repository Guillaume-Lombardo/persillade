# slice-1 (vague 1)

Première vraie course : importer une recette par lien ou texte, la corriger ou la modifier plus tard, choisir des recettes et leurs portions, obtenir la liste fusionnée et l'envoyer une première fois vers la liste Rappels partagée.

## Dépendances

slice-0

## Domaine possédé

- Recette standardisée (ingrédients, quantités, unités, étapes, portions)
- Extraction (IA embarquée puis correction manuelle ; repli par clé externe ajouté en slice-5)
- Liste de courses (lignes : nom normalisé, quantité, unité, catégorie, origine)
- Envoi vers Rappels (premier envoi et journal d'envoi)

## Éléments du backlog

### s6_us1

En tant qu'utilisateur principal, j'importe une recette depuis un lien web pour l'enregistrer au format standard.

- Objectif : Importer une recette web, de la saisie du lien jusqu'à l'enregistrement, en moins de 1 minute, correction comprise.
- Terminé quand : Un lien web, partagé ou collé, est téléchargé par l'app (pas par l'extension). Si la page contient des données structurées de recette (JSON-LD schema.org/Recipe), elles sont utilisées d'abord ; sinon le texte nettoyé de la page passe par la chaîne d'extraction (ct-extraction). L'écran de correction pré-rempli s'affiche toujours avant l'enregistrement. Page inaccessible, hors ligne ou délai de 15 s dépassé : message clair et collage du texte proposé, lien conservé. Le temps est inférieur à 1 minute, correction comprise, sur des recettes web réelles du foyer ; les échecs complets sont chronométrés et rapportés à part (jalon J1).
- `WHEN l'utilisateur partage ou colle un lien web de recette THE SYSTEM SHALL lancer l'extraction et afficher l'écran de correction pré-rempli avec le texte source visible`
- `WHEN la page contient des données structurées de recette THE SYSTEM SHALL les utiliser avant tout appel à l'IA`
- `WHEN la page est inaccessible ou l'iPhone hors ligne THE SYSTEM SHALL afficher la cause, conserver le lien et proposer de coller le texte`

### s6_us2

En tant qu'utilisateur principal, j'importe une recette depuis un texte collé ou partagé via l'extension de partage iOS.

- Objectif : Importer une recette texte en moins de 1 minute, correction comprise.
- Terminé quand : Un texte collé, ou partagé via l'extension de partage iOS, est extrait, corrigeable et enregistré. Le temps est inférieur à 1 minute, correction comprise, sur des recettes texte réelles ; les échecs complets sont chronométrés et rapportés à part (jalon J1).
- `WHEN l'utilisateur partage un texte vers l'app via l'extension de partage iOS THE SYSTEM SHALL lancer l'extraction de la recette`

### s6_us5

En tant qu'utilisateur principal, je fais extraire et standardiser les ingrédients et les étapes par l'IA embarquée Apple, avec repli par clé utilisateur, sinon correction manuelle.

- Objectif : Produire automatiquement une recette standardisée (ingrédients, quantités, unités, étapes, portions) sans appel externe payé par le porteur.
- Terminé quand : L'extraction locale suit ct-extraction : analyse déterministe d'abord, IA embarquée ensuite, sans envoi hors de l'iPhone. Les statuts complet, partiel et échec suivent les critères écrits du contrat et chacun a un test. IA indisponible (désactivée, modèle non téléchargé, appareil non compatible) et contenu trop long sont testés. Aucun appel externe n'existe dans cette tranche ; le repli par clé est ajouté par s6_us15.
- `WHEN l'extraction par l'IA embarquée échoue ou est partielle et qu'aucune clé n'est activée THE SYSTEM SHALL afficher l'écran de correction pré-rempli avec le texte source visible`
- `WHEN l'IA embarquée est indisponible THE SYSTEM SHALL l'indiquer et poursuivre avec l'analyse déterministe puis la correction manuelle`

### s6_us6

En tant qu'utilisateur principal, je corrige la recette standardisée à l'import, et je modifie plus tard une recette enregistrée, sur le même écran, champ par champ.

- Objectif : Rendre la correction assez rapide pour tenir les cibles de 1 minute (texte ou web) et de 2 minutes (photo), et permettre de modifier facilement une recette enregistrée.
- Terminé quand : L'écran affiche le texte source à côté des champs pré-remplis : titre, portions, ingrédients avec quantité et unité, étapes. Chaque champ est modifiable ; ingrédients et étapes peuvent être ajoutés, supprimés et réordonnés. Une valeur supposée (portions absentes) est signalée. L'enregistrement produit une recette au format standard. Depuis la bibliothèque, le même écran rouvre une recette enregistrée et l'enregistre sans changer son identifiant. Quitter avec des changements non enregistrés demande confirmation. Modifier une recette ne change pas une liste déjà générée.
- `WHEN l'utilisateur enregistre l'écran de correction THE SYSTEM SHALL enregistrer une recette conforme à ct-recette-standard`
- `WHEN l'utilisateur modifie une recette de la bibliothèque THE SYSTEM SHALL la mettre à jour sans créer de doublon`

### s6_us7

En tant qu'utilisateur principal, je consulte, recherche par titre, supprime et sélectionne plusieurs recettes avec leurs portions pour la liste.

- Objectif : Choisir rapidement les recettes de la semaine (environ 5) et leurs portions.
- Terminé quand : La bibliothèque liste les recettes enregistrées. Elle permet la recherche par titre (sans tenir compte des accents ni de la casse), l'ouverture, la suppression avec confirmation et la sélection multiple avec un nombre de portions par recette. La sélection alimente la génération de la liste. Les recettes survivent à la fermeture et à la mise à jour de l'app.
- `WHEN l'utilisateur sélectionne des recettes et leurs portions THE SYSTEM SHALL fournir la sélection de la semaine à la génération de la liste`
- `WHEN l'app est relancée THE SYSTEM SHALL restituer toutes les recettes enregistrées`

### s6_us8

En tant qu'utilisateur principal, j'adapte les quantités d'une recette au nombre de portions choisi.

- Objectif : Obtenir des quantités justes dans la liste sans calcul manuel.
- Terminé quand : Les quantités sont recalculées au prorata des portions, en fractions exactes et sans arrondi. L'arrondi se fait après la fusion (s6_us10). Dans l'affichage d'une recette seule, un article à la pièce est arrondi au supérieur. Des tests couvrent 1,5 œuf affiché 2 dans la recette, deux recettes à 1,5 œuf qui donnent 3 dans la liste, trois contributions de 1/3 œuf qui donnent 1, et un ajout à une ligne déjà affichée arrondie.
- `WHEN la mise à l'échelle produit une fraction pour un article à l'unité THE SYSTEM SHALL conserver la fraction jusqu'à la fusion puis arrondir la ligne fusionnée au supérieur`

### s6_us10

En tant qu'utilisateur principal, j'obtiens une liste de courses unique et cochable, fusionnée depuis les recettes sélectionnées, et prête à recevoir d'autres sources (messages, ajouts manuels).

- Objectif : Générer automatiquement la liste d'une semaine type et la rendre prête en moins de 2 minutes.
- Terminé quand : La liste fusionne les recettes après mise à l'échelle selon ct-liste-courses : unités comparables converties puis additionnées, variantes de nom sur des lignes distinctes, arrondi après fusion. Les messages sont intégrés par s6_us4. Cocher une ligne dans l'app signifie « à ne pas envoyer » (par exemple déjà à la maison). Les messages et ajouts intégrés avant les recettes sont conservés à la génération si la liste n'est pas envoyée. L'écran de la liste propose « Nouvelle liste ». Une génération qui remplace des lignes de recettes ou une liste envoyée demande confirmation (ct-liste-courses). Des tests couvrent chaque ligne de la table de fusion.
- `WHEN deux lignes portent le même nom normalisé avec des unités comparables THE SYSTEM SHALL convertir puis additionner les quantités sur une seule ligne`
- `WHEN deux articles sont des variantes de nom THE SYSTEM SHALL les conserver sur des lignes distinctes`
- `WHEN une ligne est cochée dans l'app THE SYSTEM SHALL l'exclure des envois vers Rappels`

### s6_us14

En tant qu'utilisateur principal, j'envoie pour la première fois la liste en cours, dans un seul sens, vers une liste Apple Rappels partagée avec le foyer.

- Objectif : Permettre au foyer de cocher la liste dans Rappels, sans installer l'app.
- Terminé quand : L'utilisateur choisit une liste Rappels modifiable ; l'app en garde le choix. En slice-1, le premier envoi n'est accepté que si la liste choisie n'a aucun article ouvert (les articles cochés sont ignorés) ; sinon l'app demande de la vider ou d'en choisir une autre. Ce contrôle s'applique tant que premier_envoi_le n'est pas fixé ; un nouvel essai après refus est contrôlé de nouveau. Testé : refus, second essai refusé, autre liste acceptée. Ensuite, si premier_envoi_le est fixé, envoyer (même après relance de l'app) n'écrit que les lignes non cochées absentes du journal, sans condition sur les articles ouverts. Avant d'écrire, l'app relit la liste : un rappel hors journal, créé depuis premier_envoi_le et portant exactement le titre à écrire, vaut écriture réussie et est inscrit au journal (interruption entre l'écriture et le journal). Testé : interruption à cet instant puis reprise sans doublon, échec partiel puis reprise, et second envoi quand tout est coché (rien n'est écrit). Cette limite est levée par s6_us16. Chaque article suit le format de titre de ct-envoi-rappels et est inscrit au journal d'envoi. Accès refusé, liste introuvable ou non modifiable, échec d'une ligne : signalés dans le rapport, sans perte de la liste. Les coches du foyer ne remontent pas dans l'app. À la fin de slice-1, une vraie liste est envoyée et vue sur l'iPhone 11.
- `WHEN l'utilisateur envoie la liste pour la première fois THE SYSTEM SHALL créer un rappel par ligne non cochée sans modifier ni supprimer d'élément existant`
- `WHEN une ligne échoue à l'écriture THE SYSTEM SHALL continuer les autres lignes et signaler l'échec avec sa cause`
- `WHEN l'accès complet à Rappels est refusé THE SYSTEM SHALL expliquer comment l'autoriser et conserver la liste`

## Contrats fournis

- **ct-bibliotheque** — enregistrer(Recette) → id ; lire(id) ; modifier(Recette) ; lister() ; rechercherParTitre(texte) ; supprimer(id). Stockage local persistant dans l'app (SwiftData), conservé entre lancements et mises à jour, sans copie réseau. Sauvegarde : celle de l'iPhone ; pas d'export propre en V1. Échec d'écriture : signalé, saisie conservée à l'écran.
- **ct-selection-semaine** — SelectionSemaine [{recette_id, portions (entier > 0)}] → [{nom, quantite, unite, recette_id}] au prorata, en fractions exactes, sans arrondi. Une recette supprimée entre-temps est retirée de la sélection et signalée.
- **ct-extraction** — extraire(ContenuRecu, cible : recette | message) → {statut, cause (facultative), moteur (structure | embarque | cle_externe | manuel), texte_source, recette partielle ou articles}. Statut recette — complet : titre, au moins un ingrédient, tous les ingrédients nommés, au moins une étape ; partiel : au moins un titre, un ingrédient ou une étape, sans être complet ; echec : rien d'exploitable. Portions absentes : n'affecte pas le statut. Statut message — complet : au moins un article, tous nommés, extraits par l'IA ; partiel : au moins un article, sans être complet, y compris par découpage par ligne (ia_indisponible, ia_en_erreur ou contenu_trop_long) ; echec : aucun article. Causes : ia_indisponible, ia_en_erreur, hors_ligne, page_inaccessible, delai, contenu_trop_long, rien_trouve, fournisseur_en_erreur. Ordre : 1) données structurées (JSON-LD) et analyse déterministe des lignes d'ingrédients ; 2) IA embarquée sur ce qui manque ; 3) clé externe (slice-5 seulement), si activée, consentie, et si le statut est partiel ou echec avec un texte ou une image à envoyer ; 4) écran de correction, toujours. Contexte : taille lue à l'exécution ; un texte trop long est réduit au bloc recette, puis découpé en 3 morceaux au plus, extraits dans l'ordre et concaténés ; au-delà, partiel avec contenu_trop_long. Annulable par l'utilisateur à tout moment. Pour les recettes, « quantité nom ou quantité nom » forme un ingrédient et une alternative. « Chocolat noir ou au lait » avec une seule quantité reprend cette mesure pour le chocolat au lait. Les autres formulations sans seconde mesure, comme « sel ou poivre » ou « pommes de terre bintje ou charlotte », conservent leur libellé.
- **ct-liste-courses** — ListeCourses (une seule en cours, persistante) : version_schema (3), id, premier_envoi_le (facultatif), lignes [{id, nom_normalise, libelle, quantite et unite (facultatives), categorie, origines [{type : recette | message | manuel, ref}], alternatives [{nom, quantite, unite}], cochee}]. Opérations : nouvelleListe, generer(selection), integrer(articles), ajouter, retirer, modifierQuantite, changerCategorie, cocher. integrer et ajouter créent une liste vide si aucune n'existe. Envoyée ⇔ premier_envoi_le fixé. Sur une liste envoyée, integrer demande : compléter cette liste ou commencer une nouvelle liste (nouvelleListe). nouvelleListe : nouvel id, aucune ligne, aucun envoi ; confirmation si la liste contient des lignes. generer fusionne dans la liste en cours si elle n'est pas envoyée et n'a aucune origine recette ; sinon elle crée une nouvelle liste après confirmation, qui annonce la perte des lignes actuelles et que les articles déjà achetés seront redemandés. modifierQuantite (valeur, unité, ou effacement) réapplique la table de fusion : deux lignes de même nom n'ont jamais des unités comparables, et une ligne sans quantité n'existe jamais à côté d'une ligne avec quantité de même nom. Ajouter ou intégrer avec quantité sur une ligne cochée la décoche ; sans quantité, la ligne reste telle quelle et l'app propose de la décocher. Table de fusion, même nom normalisé — unités comparables : addition ; non comparables : lignes distinctes ; deux sans quantité : une ligne sans quantité ; une seule avec quantité : la ligne avec quantité. Les origines sont réunies ; le libellé est celui de la première source. Le total exact (fraction) est conservé et sert aux ajouts ultérieurs ; la valeur arrondie est celle qui est affichée, envoyée, journalisée et comparée par ct-renvoi. Arrondi : piece au supérieur ; g et ml à l'entier le plus proche, minimum 1 ; cas, cac et autre au quart supérieur. Affichage exact, sans nouvel arrondi : kg à partir de 1 000 g, l à partir de 1 000 ml, 3 décimales au plus (1 125 g → 1,125 kg) ; au-delà, la valeur reste en g ou en ml. Un complément de ct-renvoi est écrit exactement, sans réarrondi. cochee = à ne pas envoyer. La fusion et l’envoi utilisent le choix principal. La ligne conserve en sous-titre les alternatives distinctes, mises à l’échelle par recette avec des fractions exactes puis réunies sans addition. Les listes v1 et v2 sont relues avec des alternatives vides.
- **ct-envoi-rappels** — envoyer(ListeCourses, liste_rappels) → RapportEnvoi {ajoutes, complements, ignores, echecs [{ligne_id, cause : acces_refuse | liste_introuvable | liste_non_modifiable | ecriture}]}. Accès complet à Rappels requis. Lignes cochées dans l'app exclues. Titre : « <libellé> <quantité> <unité> », sans unité pour piece, virgule décimale (« farine 1,5 kg », « œufs 6 », « sel »). Le journal d'envoi, persistant, garde pour chaque rappel créé : identifiants EventKit, liste_id, ligne_id, nom normalisé, quantité, unité, titre écrit, date. Lire un rappel : si son identifiant est au journal et son titre inchangé, données du journal ; sinon analyse du titre : en fin, un nombre > 0 puis au plus un mot (aucun mot → piece ; g, kg, ml, cl, l, cac, cas → cette unité ; autre mot → autre:<mot normalisé>) : « lait 1 l », « tomates pelées 2 boîtes » ; en tête, un nombre > 0 puis une unité connue facultative, sinon piece : « 2 laits », « 1 l de lait » ; sinon nom seul, sans quantité. premier_envoi_le = heure prise juste avant la première lecture réussie de la liste Rappels, enregistrée avant toute écriture ; conservée même si rien n'est à écrire ou si toutes les écritures échouent. Un envoi refusé par le contrôle de s6_us14 ne fixe ni premier_envoi_le ni la destination. Tant qu'aucune écriture n'a réussi, l'utilisateur peut changer de destination : premier_envoi_le est effacé puis repris à la première lecture de la nouvelle liste. Après une écriture réussie, la destination ne change plus pour cette liste de courses. Aucun regroupement ni ordre garanti dans Rappels.

## Contrats consommés

- **ct-recette-standard** — Recette : version_schema (2) ; id (UUID) ; titre (non vide) ; portions (entier > 0 ; 4 si absent à l'import, valeur signalée à corriger) ; ingredients [{nom (non vide), quantite (décimal exact > 0, facultatif), unite (g | kg | ml | cl | l | cac | cas | piece | autre:<texte> ; absente si quantite absente), texte_origine, alternatives [{nom, quantite, unite}]}] ; etapes [texte, ordonné] ; texte_source ; url_source (facultative). « 3 œufs » → quantite 3, unite piece. « 2 à 3 carottes » → 3 (borne haute). « 1/2 » et « ½ » → 0,5. « une pincée de sel », « sel, au goût » → sans quantité. a_l_unite ⇔ unite = piece. Les alternatives suivent les mêmes invariants que le choix principal et sont facultatives à la lecture. Les recettes v1 sont relues en v2 avec une liste d’alternatives vide.
- **ct-normalisation** — normaliserNom(nom) : casse, accents, ligatures (œ → oe), espaces, apostrophes, trait d'union → espace ; retrait des articles initiaux successifs (de, d', du, des, le, la, l', les), mots internes conservés ; singulier mot à mot (s ou x final retiré, « eaux » → « eau »), sauf exceptions (radis, noix, ananas, mais, anchois, pois, jus, riz, brebis, cassis, colis, couscous, houmous, os, frais, gros, bas). Aucun synonyme en V1. convertir(quantite, source, cible) → quantité ou « non comparable ». Comparables : g et kg ; ml, cl et l ; sinon seulement l'unité identique (piece avec piece, cas avec cas, autre avec le même texte normalisé). Calcul canonique en g et ml, décimal exact. Jeu de cas obligatoire : Tomates = tomate ; tomates cerises ≠ tomates ; Œufs = oeuf ; poireaux = poireau ; choux = chou ; choux-fleurs = chou fleur ; noix = noix ; radis = radis ; maïs = mais ; « de la farine » = farine ; pommes de terre = pomme de terre ; 1 kg + 500 g = 1 500 g ; 25 cl + 100 ml = 350 ml ; 2 cas et 10 ml non comparables ; 2 pièces et 300 g non comparables.
- **ct-categories** — Liste fixe validée par le porteur le 23/11/2026 (G1L-839), dans l'ordre d'affichage : Fruits et légumes ; Épicerie ; Boucher ; Poissonnier ; Crémier ; Boulangerie-pâtisserie ; Autres (obligatoire et par défaut). categorieParDefaut(nom normalisé) choisit la plus longue suite de mots reconnue dans le dictionnaire embarqué et privilégie Épicerie en présence de « au sirop ». Le rayon est modifiable et affiché dans l'app seulement. Le changement des rayons a introduit la version 2 de la liste et de son enveloppe. En lecture de la version 1, Boulangerie devient Boulangerie-pâtisserie, Crèmerie et œufs devient Crémier, Viandes et charcuterie devient Boucher, Poissons devient Poissonnier, Épicerie salée, Épicerie sucrée, Surgelés et Boissons deviennent Épicerie, Hygiène et maison devient Autres.
- **ct-entree-partage** — ContenuRecu {id, type (url | texte | image), contenu, origine (feuille_partage | presse_papiers | appareil_photo | phototheque), recu_le}. L'extension accepte url et texte, écrit dans l'App Group puis se ferme, sans réseau ni IA. L'app traite la file à l'ouverture, demande la destination (recette | message), et retire l'élément une fois enregistré ou abandonné explicitement. Les origines appareil_photo et phototheque sont branchées en slice-3.

## Scénarios d'intégration

1. Étant donné : Deux recettes pour 4 portions contenant chacune 2 œufs, l'une avec 500 g de farine et l'autre 1 kg, sont dans la bibliothèque
   Quand : L'utilisateur les sélectionne pour 3 portions chacune, génère la liste et l'envoie vers une liste Rappels vide
   Alors : Rappels contient « œufs 3 » et « farine 1,125 kg », une seule fois chacun
   `WHEN deux lignes portent le même nom normalisé avec des unités comparables THE SYSTEM SHALL additionner les quantités exactes puis arrondir la ligne fusionnée`

2. Étant donné : L'IA embarquée est indisponible et un texte de recette est partagé
   Quand : L'extraction se termine
   Alors : L'écran de correction s'affiche avec le texte source, la cause ia_indisponible et les ingrédients trouvés par l'analyse déterministe
   `WHEN l'IA embarquée est indisponible THE SYSTEM SHALL l'indiquer et poursuivre avec l'analyse déterministe puis la correction manuelle`

3. Étant donné : Une recette est enregistrée dans la bibliothèque
   Quand : L'utilisateur la rouvre, change une quantité, enregistre, puis relance l'app
   Alors : La recette modifiée est présente une seule fois avec la nouvelle quantité
   `WHEN l'utilisateur modifie une recette de la bibliothèque THE SYSTEM SHALL la mettre à jour sans créer de doublon`

## Bouchons

- Bouchon de l'IA embarquée (complet, partiel, échec, indisponible) pour les tests
- Magasin de rappels en mémoire pour les tests
