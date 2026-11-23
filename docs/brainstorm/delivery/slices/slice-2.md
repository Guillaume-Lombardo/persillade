# slice-2 (vague 2)

Parcours courses complet : messages, catégories dans l'app, retouche, ajout manuel avant ou pendant les courses, et renvoi vers Rappels sans doublon ni rachat. Se termine par la semaine chronométrée et de vraies courses avec le foyer.

## Dépendances

slice-1

## Domaine possédé

- Renvoi vers Rappels (correspondance avec la liste partagée existante)

## Éléments du backlog

### s6_us4

En tant qu'utilisateur principal, j'ajoute des articles ou des recettes depuis des messages partagés ou copiés (SMS, WhatsApp, Messenger).

- Objectif : Intégrer les messages reçus comme sources de la liste de la semaine.
- Terminé quand : Un message partagé par la feuille de partage quand l'app source le permet, sinon collé, est traité selon le choix de l'utilisateur : articles (extraits et intégrés à la liste en cours selon ct-liste-courses) ou recette (import texte, s6_us2). Sans IA disponible, chaque ligne du message devient un article à corriger. Les articles extraits sont affichés pour validation avant intégration. Testé avec des messages réels de SMS, WhatsApp et Messenger ; le mode disponible (partage ou collage) est noté pour chaque app.
- `WHEN l'utilisateur partage ou colle un message THE SYSTEM SHALL en extraire les articles et les proposer comme source de la liste fusionnée`
- `WHEN l'IA embarquée est indisponible THE SYSTEM SHALL proposer un article par ligne du message`

### s6_us11

En tant qu'utilisateur principal, je vois les articles regroupés par catégorie selon une liste fixe, et je peux changer la catégorie d'un article.

- Objectif : Rendre la liste lisible dans l'app.
- Terminé quand : Chaque article reçoit une catégorie de la liste fixe (ct-categories), « Autres » par défaut. L'utilisateur peut la changer. Le regroupement est affiché dans l'app. Aucun regroupement n'est exigé dans Rappels : le tri automatique d'une liste Rappels de type Courses est un bonus, constaté ou non par s6_sp2.
- `WHEN un article est inconnu du dictionnaire THE SYSTEM SHALL le classer dans « Autres »`
- `WHEN l'utilisateur change la catégorie d'un article THE SYSTEM SHALL l'afficher dans la nouvelle catégorie`

### s6_us12

En tant qu'utilisateur principal, je retouche la liste avant l'envoi en retirant des articles ou en modifiant des quantités.

- Objectif : Ajuster la liste en quelques secondes sans la reconstruire.
- Terminé quand : Chaque ligne peut être retirée ou voir sa quantité modifiée. Les modifications sont conservées après relance de l'app et reflétées dans le prochain envoi. Après un premier envoi, retirer une ligne ou baisser une quantité ne change rien dans Rappels, et l'app le signale ; augmenter une quantité est couvert par le renvoi (s6_us16), qui ajoute le complément. Les ingrédients de base (sel, huile) se retirent ou se cochent à la main en V1.
- `WHEN l'utilisateur retire une ligne ou modifie une quantité avant l'envoi THE SYSTEM SHALL refléter ce changement dans la liste envoyée`

### s6_us13

En tant qu'utilisateur principal, j'ajoute un article oublié (nom, quantité facultative) par un champ simple, sans IA, avant ou après l'envoi.

- Objectif : Garder la liste partagée à jour sans la reconstruire ni la dupliquer.
- Terminé quand : Un ajout avec quantité d'un article déjà présent fusionne la quantité si les unités se comparent, sinon crée une ligne distincte ; si la ligne existante est sans quantité, elle prend celle de l'ajout ; une ligne cochée est décochée. Un ajout sans quantité d'un article déjà présent conserve la ou les lignes existantes telles quelles, y compris leur état coché, que l'app signale en proposant de décocher. Après un envoi, seule la ligne concernée est envoyée, si elle est décochée (envoyerLigne, ct-renvoi ; sans quantité, chaque ligne décochée de ce nom) : aucune autre ligne n'est réexaminée. Chaque cas est testé.
- `WHEN l'utilisateur ajoute sans quantité un article déjà présent THE SYSTEM SHALL conserver la ligne existante sans créer de nouvelle ligne`
- `WHEN l'utilisateur ajoute un article après l'envoi THE SYSTEM SHALL envoyer uniquement cette ligne vers la liste Rappels selon la correspondance par nom normalisé`

### s6_us16

En tant qu'utilisateur principal, je renvoie la liste en cours vers la liste Rappels partagée sans doublon ni rachat.

- Objectif : Garder la liste partagée à jour pendant et après les courses, quels que soient les articles déjà présents.
- Terminé quand : Le renvoi suit la règle unique de ct-renvoi, y compris vers une liste contenant déjà des articles ouverts (la limite de s6_us14 disparaît). Chaque ligne de la table de décision a un test. Deux renvois successifs sans changement n'ajoutent rien. Un renvoi après un échec partiel n'ajoute que ce qui manque. Un article coché par le foyer depuis le premier envoi de la liste en cours n'est jamais remis à acheter au-delà de la quantité demandée.
- `WHEN l'utilisateur renvoie une liste vers une liste Rappels existante THE SYSTEM SHALL ajouter uniquement la quantité non couverte par les articles ouverts et par ceux cochés depuis le premier envoi de la liste en cours, sans supprimer ni modifier d'élément existant`
- `WHEN l'utilisateur renvoie deux fois la même liste sans changement THE SYSTEM SHALL ne rien ajouter au second renvoi`
- `WHEN un article a été coché avant le premier envoi de la liste en cours THE SYSTEM SHALL l'ignorer et ajouter la quantité non couverte par les articles ouverts`

### s6_sp3

Chronométrer une semaine type réelle (environ 5 recettes et 2 messages), de la sélection jusqu'à Rappels.

- Objectif : Vérifier que la liste fusionnée tient l'objectif de moins de 2 minutes, retouche comprise.
- Terminé quand : À la fin de slice-2, au moins une semaine réelle est chronométrée, de la sélection des recettes et des messages jusqu'à la liste visible dans Rappels. Les retouches nécessaires (dont ingrédients de base) sont notées et le résultat est comparé à la cible de 2 minutes. Le temps d'import des nouvelles recettes de la semaine est noté à part.

### s6_sp4

Faire faire de vraies courses au foyer avec la liste Rappels partagée dès que le parcours B fonctionne.

- Objectif : Valider tôt l'hypothèse H3 et pouvoir corriger avant la fin de la V1.
- Terminé quand : Une liste réelle est envoyée vers la liste partagée, puis complétée pendant les courses par un ajout manuel. Il est vérifié que l'autre membre du foyer coche la liste pendant les courses, qu'aucun article coché ne revient, et un éventuel retour au papier ou aux messages est noté.

## Contrats fournis

- **ct-articles-message** — Articles extraits d'un message partagé ou collé : [{nom, quantite, unite (facultatives), message_id}], validés par l'utilisateur puis intégrés par integrer(articles) de ct-liste-courses. Intégrer deux fois le même message_id est refusé.
- **ct-renvoi** — renvoyer(ListeCourses, liste_rappels) et envoyerLigne(ligne, liste_rappels) → RapportEnvoi. Règle unique, par ligne non cochée dans l'app, sur l'état de Rappels relu juste avant l'écriture. Rappels pris en compte : même nom normalisé, ouverts, ou cochés à une date ≥ premier_envoi_le. Cochés avant, ou sans date de coche : ignorés. Ligne avec quantité : couvert = somme des quantités comparables ; reste = quantité − couvert ; reste ≤ 0 → ignorée ; couvert = 0 → ajout complet ; sinon complément = reste. Ligne sans quantité : ignorée si un rappel est pris en compte, sinon ajoutée. Table (liste déjà envoyée) : rien → ajout ; « lait 1 l » ouvert, 2 l → 1 l ; « lait 1 l » deux fois ouvert, 2 l → rien ; « lait 1 l » coché depuis, 2 l → 1 l ; « œufs 6 » coché depuis, 6 → rien ; « œufs 6 » coché avant, 6 → 6 ; « lait 3 l » ouvert, 2 l → rien ; « tomates 3 » ouvert, 500 g → 500 g, puis rien au renvoi suivant ; « lait » ouvert sans quantité, 2 l → 2 l, puis rien ; « lait 1 l » ouvert, lait sans quantité → rien ; « tomates cerises » ouvert, tomates → ajout. Plusieurs lignes de même nom et d'unités non comparables sont traitées séparément. Dès slice-2, cette règle s'applique aussi au premier envoi. Cas à tester : « lait 2 l » déjà ouvert, premier envoi de lait 2 l → rien, seuil fixé ; lait coché ensuite, renvoi → rien. Limites acceptées : rien n'est supprimé ni modifié ; un article supprimé à la main dans Rappels peut être rajouté au renvoi complet ; une coche non encore synchronisée n'est pas vue.

## Contrats consommés

- **ct-entree-partage** — ContenuRecu {id, type (url | texte | image), contenu, origine (feuille_partage | presse_papiers | appareil_photo | phototheque), recu_le}. L'extension accepte url et texte, écrit dans l'App Group puis se ferme, sans réseau ni IA. L'app traite la file à l'ouverture, demande la destination (recette | message), et retire l'élément une fois enregistré ou abandonné explicitement. Les origines appareil_photo et phototheque sont branchées en slice-3.
- **ct-extraction** — extraire(ContenuRecu, cible : recette | message) → {statut, cause (facultative), moteur (structure | embarque | cle_externe | manuel), texte_source, recette partielle ou articles}. Statut recette — complet : titre, au moins un ingrédient, tous les ingrédients nommés, au moins une étape ; partiel : au moins un titre, un ingrédient ou une étape, sans être complet ; echec : rien d'exploitable. Portions absentes : n'affecte pas le statut. Statut message — complet : au moins un article, tous nommés, extraits par l'IA ; partiel : au moins un article, sans être complet, y compris par découpage par ligne (ia_indisponible, ia_en_erreur ou contenu_trop_long) ; echec : aucun article. Causes : ia_indisponible, ia_en_erreur, hors_ligne, page_inaccessible, delai, contenu_trop_long, rien_trouve, fournisseur_en_erreur. Ordre : 1) données structurées (JSON-LD) et analyse déterministe des lignes d'ingrédients ; 2) IA embarquée sur ce qui manque ; 3) clé externe (slice-5 seulement), si activée, consentie, et si le statut est partiel ou echec avec un texte ou une image à envoyer ; 4) écran de correction, toujours. Contexte : taille lue à l'exécution ; un texte trop long est réduit au bloc recette, puis découpé en 3 morceaux au plus, extraits dans l'ordre et concaténés ; au-delà, partiel avec contenu_trop_long. Annulable par l'utilisateur à tout moment.
- **ct-bibliotheque** — enregistrer(Recette) → id ; lire(id) ; modifier(Recette) ; lister() ; rechercherParTitre(texte) ; supprimer(id). Stockage local persistant dans l'app (SwiftData), conservé entre lancements et mises à jour, sans copie réseau. Sauvegarde : celle de l'iPhone ; pas d'export propre en V1. Échec d'écriture : signalé, saisie conservée à l'écran.
- **ct-liste-courses** — ListeCourses (une seule en cours, persistante) : id, premier_envoi_le (facultatif), lignes [{id, nom_normalise, libelle, quantite et unite (facultatives), categorie, origines [{type : recette | message | manuel, ref}], cochee}]. Opérations : nouvelleListe, generer(selection), integrer(articles), ajouter, retirer, modifierQuantite, changerCategorie, cocher. integrer et ajouter créent une liste vide si aucune n'existe. Envoyée ⇔ premier_envoi_le fixé. Sur une liste envoyée, integrer demande : compléter cette liste ou commencer une nouvelle liste (nouvelleListe). nouvelleListe : nouvel id, aucune ligne, aucun envoi ; confirmation si la liste contient des lignes. generer fusionne dans la liste en cours si elle n'est pas envoyée et n'a aucune origine recette ; sinon elle crée une nouvelle liste après confirmation, qui annonce la perte des lignes actuelles et que les articles déjà achetés seront redemandés. modifierQuantite (valeur, unité, ou effacement) réapplique la table de fusion : deux lignes de même nom n'ont jamais des unités comparables, et une ligne sans quantité n'existe jamais à côté d'une ligne avec quantité de même nom. Ajouter ou intégrer avec quantité sur une ligne cochée la décoche ; sans quantité, la ligne reste telle quelle et l'app propose de la décocher. Table de fusion, même nom normalisé — unités comparables : addition ; non comparables : lignes distinctes ; deux sans quantité : une ligne sans quantité ; une seule avec quantité : la ligne avec quantité. Les origines sont réunies ; le libellé est celui de la première source. Le total exact (fraction) est conservé et sert aux ajouts ultérieurs ; la valeur arrondie est celle qui est affichée, envoyée, journalisée et comparée par ct-renvoi. Arrondi : piece au supérieur ; g et ml à l'entier le plus proche, minimum 1 ; cas, cac et autre au quart supérieur. Affichage exact, sans nouvel arrondi : kg à partir de 1 000 g, l à partir de 1 000 ml, 3 décimales au plus (1 125 g → 1,125 kg) ; au-delà, la valeur reste en g ou en ml. Un complément de ct-renvoi est écrit exactement, sans réarrondi. cochee = à ne pas envoyer.
- **ct-envoi-rappels** — envoyer(ListeCourses, liste_rappels) → RapportEnvoi {ajoutes, complements, ignores, echecs [{ligne_id, cause : acces_refuse | liste_introuvable | liste_non_modifiable | ecriture}]}. Accès complet à Rappels requis. Lignes cochées dans l'app exclues. Titre : « <libellé> <quantité> <unité> », sans unité pour piece, virgule décimale (« farine 1,5 kg », « œufs 6 », « sel »). Le journal d'envoi, persistant, garde pour chaque rappel créé : identifiants EventKit, liste_id, ligne_id, nom normalisé, quantité, unité, titre écrit, date. Lire un rappel : si son identifiant est au journal et son titre inchangé, données du journal ; sinon analyse du titre : en fin, un nombre > 0 puis au plus un mot (aucun mot → piece ; g, kg, ml, cl, l, cac, cas → cette unité ; autre mot → autre:<mot normalisé>) : « lait 1 l », « tomates pelées 2 boîtes » ; en tête, un nombre > 0 puis une unité connue facultative, sinon piece : « 2 laits », « 1 l de lait » ; sinon nom seul, sans quantité. premier_envoi_le = heure prise juste avant la première lecture réussie de la liste Rappels, enregistrée avant toute écriture ; conservée même si rien n'est à écrire ou si toutes les écritures échouent. Un envoi refusé par le contrôle de s6_us14 ne fixe ni premier_envoi_le ni la destination. Tant qu'aucune écriture n'a réussi, l'utilisateur peut changer de destination : premier_envoi_le est effacé puis repris à la première lecture de la nouvelle liste. Après une écriture réussie, la destination ne change plus pour cette liste de courses. Aucun regroupement ni ordre garanti dans Rappels.
- **ct-normalisation** — normaliserNom(nom) : casse, accents, ligatures (œ → oe), espaces, apostrophes, trait d'union → espace ; retrait des articles initiaux successifs (de, d', du, des, le, la, l', les), mots internes conservés ; singulier mot à mot (s ou x final retiré, « eaux » → « eau »), sauf exceptions (radis, noix, ananas, mais, anchois, pois, jus, riz, brebis, cassis, colis, couscous, houmous, os, frais, gros, bas). Aucun synonyme en V1. convertir(quantite, source, cible) → quantité ou « non comparable ». Comparables : g et kg ; ml, cl et l ; sinon seulement l'unité identique (piece avec piece, cas avec cas, autre avec le même texte normalisé). Calcul canonique en g et ml, décimal exact. Jeu de cas obligatoire : Tomates = tomate ; tomates cerises ≠ tomates ; Œufs = oeuf ; poireaux = poireau ; choux = chou ; choux-fleurs = chou fleur ; noix = noix ; radis = radis ; maïs = mais ; « de la farine » = farine ; pommes de terre = pomme de terre ; 1 kg + 500 g = 1 500 g ; 25 cl + 100 ml = 350 ml ; 2 cas et 10 ml non comparables ; 2 pièces et 300 g non comparables.
- **ct-categories** — Liste fixe validée par le porteur le 23/11/2026 (G1L-839), dans l'ordre d'affichage : Fruits et légumes ; Épicerie ; Boucher ; Poissonnier ; Crémier ; Boulangerie-pâtisserie ; Autres (obligatoire et par défaut). categorieParDefaut(nom normalisé) choisit la plus longue suite de mots reconnue dans le dictionnaire embarqué et privilégie Épicerie en présence de « au sirop ». Le rayon est modifiable et affiché dans l'app seulement. Le schéma de la liste et de son enveloppe passe en version 2. En lecture de la version 1, Boulangerie devient Boulangerie-pâtisserie, Crèmerie et œufs devient Crémier, Viandes et charcuterie devient Boucher, Poissons devient Poissonnier, Épicerie salée, Épicerie sucrée, Surgelés et Boissons deviennent Épicerie, Hygiène et maison devient Autres.

## Scénarios d'intégration

1. Étant donné : La liste en cours (œufs 6, lait 2 l) a été envoyée, puis le foyer a coché « œufs 6 »
   Quand : L'utilisateur ajoute « clémentines » par le champ simple pendant les courses
   Alors : Seul « clémentines » est ajouté à Rappels ; œufs et lait ne sont pas réexaminés
   `WHEN l'utilisateur ajoute un article après l'envoi THE SYSTEM SHALL envoyer uniquement cette ligne vers la liste Rappels selon la correspondance par nom normalisé`

2. Étant donné : La liste partagée contient « lait 1 l » ouvert, « œufs 6 » coché depuis le premier envoi et « riz 1 kg » coché la semaine précédente
   Quand : L'utilisateur renvoie deux fois de suite la liste lait 2 l, œufs 6, riz 1 kg, pain
   Alors : Le premier renvoi ajoute « lait 1 l », « riz 1 kg » et « pain » ; le second n'ajoute rien
   `WHEN l'utilisateur renvoie deux fois la même liste sans changement THE SYSTEM SHALL ne rien ajouter au second renvoi`

3. Étant donné : Une semaine passée, « lait 2 l » a été coché après l'envoi de l'ancienne liste
   Quand : L'utilisateur génère une nouvelle liste contenant « lait 2 l » et l'envoie
   Alors : « lait 2 l » est ajouté
   `WHEN un article a été coché avant le premier envoi de la liste en cours THE SYSTEM SHALL l'ignorer et ajouter la quantité non couverte par les articles ouverts`

## Bouchons

- Magasin de rappels en mémoire avec états et dates de coche, pour chaque ligne de la table de ct-renvoi
