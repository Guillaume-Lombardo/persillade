> **Révisé le 22/11/2026 :** découpage remplacé par delivery/. En cas d'écart, [revision.md](../revision.md) et `delivery/` l'emportent.

# Structured Summary

## Stage 7 - Delivery Slicing

Étape 7, découpage en tranches de livraison.

**Réponse à votre question : de mon côté, il ne reste rien à vous demander pour cette étape.** Je ne peux pas déclarer l'étape terminée : ce sont les règles du serveur qui décident du passage à l'étape suivante.

**Ce qui est confirmé :**
- **Cinq tranches** (décision s7_d1) :
  - slice-0 : socle et contrats partagés ;
  - slice-1 : recettes ;
  - slice-2 : extraction ;
  - slice-3 : liste de courses ;
  - slice-4 : envoi vers Rappels.
- **Cohérence du découpage :** chacun des 26 éléments du backlog est rattaché à une seule tranche. Chaque contrat a un seul propriétaire. Les dépendances sont sans cycle. Chaque tranche a au moins un scénario d'intégration complet.
- **Catégories :** vous arrêterez leur contenu pendant la construction de slice-0 (s7_d2). D'ici là, slice-3 travaille avec un bouchon.
- **Prototype Rappels (s6_sp2) :** il est avancé dans slice-0 (s7_d3), pour lever le risque s5_r2 avant le point des 6 semaines. slice-4 s'appuie ensuite sur ses résultats.

**Ce qui reste ouvert, sans question bloquante :**
- **Catégories :** le contenu de la liste fixe est à définir pendant slice-0, avant l'intégration avec slice-3.
- **Consentement de la clé d'IA :** le texte exact de l'écran (s6_us15) est à arrêter avant de livrer cette partie de slice-2.
- **Ordre de livraison :** l'ordre confirmé (import photo, puis suivi pas à pas, puis clé d'IA) et le plan de coupe s5_d1 / s5_d3 s'appliquent à l'intérieur de slice-1 et slice-2.

Aucune nouvelle question n'est posée. Si le serveur valide le passage, il s'agit de la dernière étape du cadrage.

# Open Questions and Uncertainties

- Contenu de la liste fixe des catégories (ct-categories, s6_cc3) : il sera défini par le porteur pendant la construction de slice-0, avant l'intégration avec slice-3.
- Texte exact de l'écran de consentement de la clé d'IA (s6_us15), à arrêter avant de livrer cette partie de slice-2.
- Ordre de livraison confirmé (import photo, puis suivi pas à pas, puis clé d'IA) et plan de coupe s5_d1 / s5_d3 : ils s'appliquent à l'intérieur de slice-1 et slice-2.

## Open Questions

- None.

# Questions to Continue

- No further question required to complete this stage.

# Stage Deliverable

## Stage 7 - Delivery Slicing

### Facts

- L'utilisateur valide tel quel le découpage en cinq tranches (slice-0 à slice-4), avec ses contrats, ses dépendances, ses scénarios d'intégration et ses bouchons.
- L'utilisateur définira le contenu de la liste fixe des catégories (contrat ct-categories, s6_cc3) pendant la construction du socle (slice-0).
- L'utilisateur choisit d'avancer le prototype Rappels (s6_sp2) dans le socle (slice-0).

### Assumptions

- None explicitly recorded.

### Decisions

- Le découpage de livraison retenu comprend cinq tranches : slice-0 (socle et contrats partagés), slice-1 (recettes), slice-2 (extraction), slice-3 (liste de courses) et slice-4 (envoi vers Rappels). (L'utilisateur a validé explicitement le découpage tel quel.)
- Le contenu de la liste fixe des catégories exposée par ct-categories est arrêté par le porteur pendant la construction de slice-0 (chantier s6_cc3). En attendant, slice-3 travaille avec un bouchon de catégories. (Choix explicite de l'utilisateur en réponse à la question sur les catégories.)
- Le prototype Rappels s6_sp2 est rattaché à slice-0 et non plus à slice-4. Il vérifie tôt la lecture (articles existants, état coché) et l'écriture d'une liste Rappels partagée. slice-4 s'appuie ensuite sur ses résultats pour la règle de renvoi. (Choix explicite de l'utilisateur : lever le risque s5_r2 avant le point des 6 semaines plutôt qu'en fin de V1.)

### Risks

- No explicit risks recorded yet.

### Open Questions

- None.

### Stage Fields

- slices: [{'id': 'slice-0', 'goal': "Squelette de bout en bout sur iPhone 15 Pro : l'app reçoit un contenu par la feuille de partage iOS ou le presse-papiers et le route vers un écran d'import. Les contrats partagés sont posés : format de recette standardisé, normalisation des noms et des unités, liste fixe des catégories. Le prototype Rappels (s6_sp2) vérifie tôt la lecture (articles existants, état coché) et l'écriture d'une liste partagée. La double licence, le CLA et le point de contrôle des 6 semaines sont en place.", 'backlog_item_ids': ['s6_cc1', 's6_cc2', 's6_cc3', 's6_cc4', 's6_cc5', 's6_cc6', 's6_sp5', 's6_sp2'], 'owned_domain': ["Socle transverse (format de recette, normalisation, catégories, points d'entrée de partage, prototype d'accès à Apple Rappels)"], 'provided_contracts': [{'id': 'ct-recette-standard', 'specification': "Modèle Recette : id, titre, portions (entier > 0), ingredients [{nom, quantite (décimal, facultatif), unite (facultative), a_l_unite (booléen)}], etapes [texte ordonné], texte_source. Utilisé par tous les imports, la correction, la mise à l'échelle et la fusion (s6_cc1)."}, {'id': 'ct-normalisation', 'specification': 'normaliserNom(nom) → nom normalisé ; convertir(quantite, unite_source, unite_cible) → quantité convertie ou « non comparable ». Familles comparables : g et kg, cl et l. Les variantes de nom (« tomates », « tomates cerises ») donnent des noms normalisés distincts (s6_cc2).'}, {'id': 'ct-categories', 'specification': 'Liste fixe des catégories de la V1 (contenu à valider par le porteur, s6_cc3) et categorieParDefaut(nom normalisé) → catégorie de cette liste.'}, {'id': 'ct-entree-partage', 'specification': "ContenuRecu : type (url | texte | image), contenu, origine (feuille de partage | presse-papiers). Le contenu est routé vers l'import de recette ou vers l'import de message, selon le choix de l'utilisateur (s6_cc4)."}], 'consumed_contracts': [], 'dependencies': [], 'integration_scenarios': [{'given': "L'app est installée sur l'iPhone 15 Pro et une page de recette est ouverte dans Safari", 'when': "L'utilisateur partage la page vers l'app via la feuille de partage iOS", 'then': "L'app reçoit un ContenuRecu de type url, d'origine feuille de partage, et l'affiche sur l'écran d'import de recette du squelette", 'ears': "WHEN l'utilisateur partage un lien vers l'app THE SYSTEM SHALL produire un ContenuRecu de type url et le router vers l'import de recette"}, {'given': "Une liste Rappels partagée de test, sur l'iPhone 15 Pro, contient « lait 1 l » non coché et « œufs 6 » coché", 'when': "Le prototype s6_sp2 lit la liste puis y écrit l'article « pain »", 'then': 'Le prototype restitue les deux articles existants avec leur état coché, et « pain » apparaît dans la liste partagée sans suppression ni modification des éléments existants', 'ears': 'WHEN le prototype accède à une liste Rappels partagée THE SYSTEM SHALL lire les articles existants avec leur état coché et ajouter un article sans modifier les éléments existants'}], 'stubs': ["Écrans d'import de recette et de message factices, affichant le ContenuRecu reçu", "Liste Rappels partagée de test sur l'iPhone 15 Pro, pour le prototype s6_sp2"]}, {'id': 'slice-1', 'goal': "Gérer les recettes standardisées : bibliothèque minimale (liste, recherche par titre, suppression, sélection multiple avec portions), mise à l'échelle avec arrondi au supérieur des articles à l'unité, et suivi pas à pas.", 'backlog_item_ids': ['s6_us7', 's6_us8', 's6_us9'], 'owned_domain': ['Recette standardisée (ingrédients, quantités, unités, étapes, portions)'], 'provided_contracts': [{'id': 'ct-bibliotheque', 'specification': 'enregistrer(Recette) → id ; lister() ; rechercherParTitre(texte) ; supprimer(id). Les recettes respectent ct-recette-standard.'}, {'id': 'ct-selection-semaine', 'specification': "SelectionSemaine [{recette_id, portions}] → ingrédients mis à l'échelle [{nom, quantite, unite, recette_id}]. Les quantités sont recalculées au prorata des portions ; une fraction d'article à l'unité est arrondie au supérieur (1,5 œuf → 2)."}], 'consumed_contracts': ['ct-recette-standard'], 'dependencies': [], 'integration_scenarios': [{'given': "Une recette pour 4 portions contenant 2 œufs (article à l'unité) est enregistrée dans la bibliothèque", 'when': "L'utilisateur la sélectionne pour 3 portions", 'then': 'La sélection de la semaine fournit 2 œufs (1,5 arrondi au supérieur)', 'ears': "WHEN la mise à l'échelle produit une fraction pour un article à l'unité THE SYSTEM SHALL arrondir la quantité au supérieur"}], 'stubs': ["Recettes d'exemple saisies en dur au format ct-recette-standard, en attendant l'extraction (slice-2)"]}, {'id': 'slice-2', 'goal': "Transformer un contenu importé (lien web, texte, photo, message) en recette standardisée ou en articles. La chaîne de repli s'applique : IA embarquée Apple, puis clé de l'utilisateur vers un service compatible avec l'API OpenAI si elle est activée, sinon correction manuelle sur un écran pré-rempli avec le texte source visible. Cibles : moins de 1 minute (texte ou web) et moins de 2 minutes (photo), correction comprise.", 'backlog_item_ids': ['s6_us1', 's6_us2', 's6_us3', 's6_us4', 's6_us5', 's6_us6', 's6_us15', 's6_sp1'], 'owned_domain': ['Extraction (chaîne de repli IA embarquée, clé externe, correction manuelle)'], 'provided_contracts': [{'id': 'ct-extraction', 'specification': 'extraire(ContenuRecu, cible : recette | message) → ResultatExtraction {statut : complet | partiel | echec, moteur : embarque | cle_externe | manuel, texte_source, recette (ct-recette-standard) ou articles}. Aucun appel externe sans clé activée et consentement unique enregistré.'}, {'id': 'ct-articles-message', 'specification': "Articles extraits d'un message partagé ou collé (SMS, WhatsApp, Messenger) : [{nom, quantite (facultative), unite (facultative), message_id}], proposés comme source de la liste de la semaine."}], 'consumed_contracts': ['ct-entree-partage', 'ct-recette-standard', 'ct-bibliotheque'], 'dependencies': ['slice-1'], 'integration_scenarios': [{'given': "Aucune clé d'IA n'est activée et l'IA embarquée renvoie un résultat partiel pour un texte de recette partagé", 'when': "L'extraction se termine", 'then': "L'écran de correction pré-rempli s'affiche avec le texte source visible ; après correction, la recette est enregistrée dans la bibliothèque au format standard", 'ears': "WHEN l'extraction par l'IA embarquée échoue ou est partielle et qu'aucune clé n'est activée THE SYSTEM SHALL afficher l'écran de correction pré-rempli avec le texte source visible"}, {'given': "La clé de l'utilisateur est activée, avec une adresse d'API compatible OpenAI et le consentement unique enregistré", 'when': "L'IA embarquée échoue sur une photo de fiche manuscrite", 'then': "L'extraction est déléguée au service configuré, sans confirmation supplémentaire, puis l'écran de correction s'affiche", 'ears': "WHEN l'extraction par l'IA embarquée échoue ou est partielle et que la clé de l'utilisateur est activée THE SYSTEM SHALL déléguer l'extraction au fournisseur choisi"}], 'stubs': ["Bouchon de l'IA embarquée renvoyant des résultats fixes (complet, partiel, échec)", "Serveur factice compatible avec l'API OpenAI, pour tester la clé sans coût", 'Bouchon de ct-bibliotheque en mémoire, en attendant slice-1']}, {'id': 'slice-3', 'goal': "Générer la liste de courses unique et cochable d'une semaine type (environ 5 recettes et 2 messages), fusionnée selon les règles confirmées, regroupée par catégorie, retouchable, avec ajout manuel sans IA, pour tenir l'objectif de moins de 2 minutes.", 'backlog_item_ids': ['s6_us10', 's6_us11', 's6_us12', 's6_us13', 's6_sp3'], 'owned_domain': ['Liste de courses (lignes : nom normalisé, quantité, unité, catégorie, origine)'], 'provided_contracts': [{'id': 'ct-liste-courses', 'specification': 'ListeCourses : lignes [{nom_normalise, libelle, quantite (facultative), unite (facultative), categorie (ct-categories), origine : recette | message | manuel, cochee}]. Fusion : les unités comparables sont converties puis additionnées ; les variantes de nom restent sur des lignes distinctes. La liste intègre les retouches (retrait, quantité, catégorie).'}, {'id': 'ct-evt-article-ajoute', 'specification': "Événement ArticleAjouteManuellement {ligne, apres_envoi : booléen}. Ajout avec quantité d'un article présent : fusion si les unités se comparent, sinon ligne distincte. Ajout sans quantité d'un article présent : la ligne existante est conservée."}], 'consumed_contracts': ['ct-selection-semaine', 'ct-articles-message', 'ct-normalisation', 'ct-categories'], 'dependencies': ['slice-1', 'slice-2'], 'integration_scenarios': [{'given': "Deux recettes sélectionnées demandent 500 g et 1 kg de farine, et un message contient « tomates cerises » alors qu'une recette demande des « tomates »", 'when': "L'utilisateur génère la liste fusionnée", 'then': 'La liste contient une ligne « farine 1,5 kg », ainsi que deux lignes distinctes « tomates » et « tomates cerises », chacune dans sa catégorie par défaut', 'ears': 'WHEN deux lignes portent le même nom normalisé avec des unités comparables THE SYSTEM SHALL convertir puis additionner les quantités sur une seule ligne'}], 'stubs': ['Bouchon de ct-selection-semaine renvoyant une semaine type fixe', "Bouchon de ct-articles-message renvoyant deux messages d'exemple", 'Bouchon de ct-categories avec une liste provisoire, en attendant la liste validée par le porteur dans slice-0']}, {'id': 'slice-4', 'goal': "Envoyer la liste dans un seul sens vers la liste Apple Rappels partagée avec le foyer, puis la renvoyer sans doublons, en s'appuyant sur les résultats du prototype s6_sp2 livré dans slice-0. La correspondance se fait par nom normalisé : ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification.", 'backlog_item_ids': ['s6_us14', 's6_sp4'], 'owned_domain': ['Envoi vers Rappels (correspondance avec la liste partagée existante)'], 'provided_contracts': [{'id': 'ct-envoi-rappels', 'specification': "envoyer(ListeCourses, liste_rappels_cible) → RapportEnvoi {ajoutes, complements, ignores}. Le regroupement par catégorie est conservé. Les coches et ajouts du foyer dans Rappels ne remontent pas dans l'app."}], 'consumed_contracts': ['ct-liste-courses', 'ct-evt-article-ajoute', 'ct-normalisation'], 'dependencies': ['slice-3'], 'integration_scenarios': [{'given': 'La liste Rappels partagée contient déjà « lait 1 l » non coché et « œufs 6 » coché', 'when': "L'utilisateur renvoie une liste contenant « lait 2 l », « œufs 6 » et « pain »", 'then': 'Rappels reçoit « lait 1 l » (complément), « œufs 6 » (article seulement coché) et « pain » (article absent), sans suppression ni modification des éléments existants', 'ears': "WHEN l'utilisateur renvoie une liste vers une liste Rappels existante THE SYSTEM SHALL ajouter uniquement les articles absents, les articles seulement cochés et les compléments de quantité, sans supprimer ni modifier d'élément existant"}, {'given': 'La liste a déjà été envoyée vers Rappels', 'when': "L'utilisateur ajoute « clémentines » par le champ simple", 'then': "L'article est renvoyé vers la liste partagée selon la correspondance par nom normalisé", 'ears': "WHEN l'utilisateur ajoute un article après l'envoi THE SYSTEM SHALL le renvoyer vers la liste Rappels selon la correspondance par nom normalisé"}], 'stubs': ['Magasin de rappels en mémoire simulant une liste partagée (articles existants, état coché), pour les tests de chaque branche de la règle', 'Bouchon de ct-liste-courses renvoyant une liste fixe, en attendant slice-3']}]

### Readiness

- 11/11 passed/total
- [x] field:slices: Required field slices: clear
- [x] walking_skeleton: Include exactly one slice-0 walking skeleton with shared contracts.
- [x] mvp_assignment: Assign every MVP backlog item to exactly one slice.
- [x] backlog_references: Slice backlog references must exist in stage 6.
- [x] acyclic_dependencies: Dependencies must reference existing slices and form an acyclic graph.
- [x] contract_ownership: Every contract needs one owner; every consumed contract must exist.
- [x] integration_scenarios: Every slice needs at least one complete GWT or EARS integration scenario.
- [x] cross_cutting_foundation: Assign all cross-cutting backlog work exactly once to slice-0.
- [x] domain_ownership: Own distinct stage 3 aggregates, or stage 2 capabilities only when stage 3 is not relevant.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- slices: clear

### Clarifications

- 2026-11-22T14:11:21.890502+01:00: Validez-vous le découpage en cinq tranches (socle, recettes, extraction, liste de courses, envoi vers Rappels), avec ses contrats et ses dépendances ? -> Validez-vous le découpage en cinq tranches (socle, recettes, extraction, liste de courses, envoi vers Rappels), avec ses contrats et ses dépendances ?
Je valide le découpage tel quel
- 2026-11-22T14:11:58.693946+01:00: Quelles catégories doivent figurer dans la liste fixe exposée par le contrat ct-categories du socle ? -> Quelles catégories doivent figurer dans la liste fixe exposée par le contrat ct-categories du socle ?
Je la définirai pendant la construction du socle (slice-0)
- 2026-11-22T14:13:02.336947+01:00: Le découpage validé tel quel laisse le prototype Rappels (s6_sp2) dans slice-4, qui arrivera en dernier. Confirmez-vous ce choix, ou préférez-vous l'avancer dans le socle (slice-0) pour vérifier tôt la lecture et l'écriture d'une liste partagée ? -> Le découpage validé tel quel laisse le prototype Rappels (s6_sp2) dans slice-4, qui arrivera en dernier. Confirmez-vous ce choix, ou préférez-vous l'avancer dans le socle (slice-0) pour vérifier tôt la lecture et l'écriture d'une liste partagée ?
Avancer s6_sp2 dans slice-0

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.

### Delivery slices

| Slice | Goal | Backlog |
| --- | --- | --- |
| slice-0 | Squelette de bout en bout sur iPhone 15 Pro : l'app reçoit un contenu par la feuille de partage iOS ou le presse-papiers et le route vers un écran d'import. Les contrats partagés sont posés : format de recette standardisé, normalisation des noms et des unités, liste fixe des catégories. Le prototype Rappels (s6_sp2) vérifie tôt la lecture (articles existants, état coché) et l'écriture d'une liste partagée. La double licence, le CLA et le point de contrôle des 6 semaines sont en place. | s6_cc1, s6_cc2, s6_cc3, s6_cc4, s6_cc5, s6_cc6, s6_sp5, s6_sp2 |
| slice-1 | Gérer les recettes standardisées : bibliothèque minimale (liste, recherche par titre, suppression, sélection multiple avec portions), mise à l'échelle avec arrondi au supérieur des articles à l'unité, et suivi pas à pas. | s6_us7, s6_us8, s6_us9 |
| slice-2 | Transformer un contenu importé (lien web, texte, photo, message) en recette standardisée ou en articles. La chaîne de repli s'applique : IA embarquée Apple, puis clé de l'utilisateur vers un service compatible avec l'API OpenAI si elle est activée, sinon correction manuelle sur un écran pré-rempli avec le texte source visible. Cibles : moins de 1 minute (texte ou web) et moins de 2 minutes (photo), correction comprise. | s6_us1, s6_us2, s6_us3, s6_us4, s6_us5, s6_us6, s6_us15, s6_sp1 |
| slice-3 | Générer la liste de courses unique et cochable d'une semaine type (environ 5 recettes et 2 messages), fusionnée selon les règles confirmées, regroupée par catégorie, retouchable, avec ajout manuel sans IA, pour tenir l'objectif de moins de 2 minutes. | s6_us10, s6_us11, s6_us12, s6_us13, s6_sp3 |
| slice-4 | Envoyer la liste dans un seul sens vers la liste Apple Rappels partagée avec le foyer, puis la renvoyer sans doublons, en s'appuyant sur les résultats du prototype s6_sp2 livré dans slice-0. La correspondance se fait par nom normalisé : ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification. | s6_us14, s6_sp4 |

### Delivery waves

- Wave 0: slice-0
- Wave 1: slice-1
- Wave 2: slice-2
- Wave 3: slice-3
- Wave 4: slice-4

### Contract matrix

| Contract | Owner | Consumers | Specification |
| --- | --- | --- | --- |
| ct-recette-standard | slice-0 | slice-1, slice-2 | Modèle Recette : id, titre, portions (entier > 0), ingredients [{nom, quantite (décimal, facultatif), unite (facultative), a_l_unite (booléen)}], etapes [texte ordonné], texte_source. Utilisé par tous les imports, la correction, la mise à l'échelle et la fusion (s6_cc1). |
| ct-normalisation | slice-0 | slice-3, slice-4 | normaliserNom(nom) → nom normalisé ; convertir(quantite, unite_source, unite_cible) → quantité convertie ou « non comparable ». Familles comparables : g et kg, cl et l. Les variantes de nom (« tomates », « tomates cerises ») donnent des noms normalisés distincts (s6_cc2). |
| ct-categories | slice-0 | slice-3 | Liste fixe des catégories de la V1 (contenu à valider par le porteur, s6_cc3) et categorieParDefaut(nom normalisé) → catégorie de cette liste. |
| ct-entree-partage | slice-0 | slice-2 | ContenuRecu : type (url \| texte \| image), contenu, origine (feuille de partage \| presse-papiers). Le contenu est routé vers l'import de recette ou vers l'import de message, selon le choix de l'utilisateur (s6_cc4). |
| ct-bibliotheque | slice-1 | slice-2 | enregistrer(Recette) → id ; lister() ; rechercherParTitre(texte) ; supprimer(id). Les recettes respectent ct-recette-standard. |
| ct-selection-semaine | slice-1 | slice-3 | SelectionSemaine [{recette_id, portions}] → ingrédients mis à l'échelle [{nom, quantite, unite, recette_id}]. Les quantités sont recalculées au prorata des portions ; une fraction d'article à l'unité est arrondie au supérieur (1,5 œuf → 2). |
| ct-extraction | slice-2 |  | extraire(ContenuRecu, cible : recette \| message) → ResultatExtraction {statut : complet \| partiel \| echec, moteur : embarque \| cle_externe \| manuel, texte_source, recette (ct-recette-standard) ou articles}. Aucun appel externe sans clé activée et consentement unique enregistré. |
| ct-articles-message | slice-2 | slice-3 | Articles extraits d'un message partagé ou collé (SMS, WhatsApp, Messenger) : [{nom, quantite (facultative), unite (facultative), message_id}], proposés comme source de la liste de la semaine. |
| ct-liste-courses | slice-3 | slice-4 | ListeCourses : lignes [{nom_normalise, libelle, quantite (facultative), unite (facultative), categorie (ct-categories), origine : recette \| message \| manuel, cochee}]. Fusion : les unités comparables sont converties puis additionnées ; les variantes de nom restent sur des lignes distinctes. La liste intègre les retouches (retrait, quantité, catégorie). |
| ct-evt-article-ajoute | slice-3 | slice-4 | Événement ArticleAjouteManuellement {ligne, apres_envoi : booléen}. Ajout avec quantité d'un article présent : fusion si les unités se comparent, sinon ligne distincte. Ajout sans quantité d'un article présent : la ligne existante est conservée. |
| ct-envoi-rappels | slice-4 |  | envoyer(ListeCourses, liste_rappels_cible) → RapportEnvoi {ajoutes, complements, ignores}. Le regroupement par catégorie est conservé. Les coches et ajouts du foyer dans Rappels ne remontent pas dans l'app. |

## Slice slice-0

### Goal

Squelette de bout en bout sur iPhone 15 Pro : l'app reçoit un contenu par la feuille de partage iOS ou le presse-papiers et le route vers un écran d'import. Les contrats partagés sont posés : format de recette standardisé, normalisation des noms et des unités, liste fixe des catégories. Le prototype Rappels (s6_sp2) vérifie tôt la lecture (articles existants, état coché) et l'écriture d'une liste partagée. La double licence, le CLA et le point de contrôle des 6 semaines sont en place.
### Backlog items

s6_cc1, s6_cc2, s6_cc3, s6_cc4, s6_cc5, s6_cc6, s6_sp5, s6_sp2
### Owned domain

Socle transverse (format de recette, normalisation, catégories, points d'entrée de partage, prototype d'accès à Apple Rappels)
### Provided contracts

- ct-recette-standard: Modèle Recette : id, titre, portions (entier > 0), ingredients [{nom, quantite (décimal, facultatif), unite (facultative), a_l_unite (booléen)}], etapes [texte ordonné], texte_source. Utilisé par tous les imports, la correction, la mise à l'échelle et la fusion (s6_cc1).
- ct-normalisation: normaliserNom(nom) → nom normalisé ; convertir(quantite, unite_source, unite_cible) → quantité convertie ou « non comparable ». Familles comparables : g et kg, cl et l. Les variantes de nom (« tomates », « tomates cerises ») donnent des noms normalisés distincts (s6_cc2).
- ct-categories: Liste fixe des catégories de la V1 (contenu à valider par le porteur, s6_cc3) et categorieParDefaut(nom normalisé) → catégorie de cette liste.
- ct-entree-partage: ContenuRecu : type (url | texte | image), contenu, origine (feuille de partage | presse-papiers). Le contenu est routé vers l'import de recette ou vers l'import de message, selon le choix de l'utilisateur (s6_cc4).
### Consumed contracts

None
### Declared dependencies

None
### Integration scenarios

WHEN l'utilisateur partage un lien vers l'app THE SYSTEM SHALL produire un ContenuRecu de type url et le router vers l'import de recette
WHEN le prototype accède à une liste Rappels partagée THE SYSTEM SHALL lire les articles existants avec leur état coché et ajouter un article sans modifier les éléments existants
### Required stubs

- Écrans d'import de recette et de message factices, affichant le ContenuRecu reçu
- Liste Rappels partagée de test sur l'iPhone 15 Pro, pour le prototype s6_sp2
## Slice slice-1

### Goal

Gérer les recettes standardisées : bibliothèque minimale (liste, recherche par titre, suppression, sélection multiple avec portions), mise à l'échelle avec arrondi au supérieur des articles à l'unité, et suivi pas à pas.
### Backlog items

s6_us7, s6_us8, s6_us9
### Owned domain

Recette standardisée (ingrédients, quantités, unités, étapes, portions)
### Provided contracts

- ct-bibliotheque: enregistrer(Recette) → id ; lister() ; rechercherParTitre(texte) ; supprimer(id). Les recettes respectent ct-recette-standard.
- ct-selection-semaine: SelectionSemaine [{recette_id, portions}] → ingrédients mis à l'échelle [{nom, quantite, unite, recette_id}]. Les quantités sont recalculées au prorata des portions ; une fraction d'article à l'unité est arrondie au supérieur (1,5 œuf → 2).
### Consumed contracts

ct-recette-standard
### Declared dependencies

None
### Integration scenarios

WHEN la mise à l'échelle produit une fraction pour un article à l'unité THE SYSTEM SHALL arrondir la quantité au supérieur
### Required stubs

- Recettes d'exemple saisies en dur au format ct-recette-standard, en attendant l'extraction (slice-2)
## Slice slice-2

### Goal

Transformer un contenu importé (lien web, texte, photo, message) en recette standardisée ou en articles. La chaîne de repli s'applique : IA embarquée Apple, puis clé de l'utilisateur vers un service compatible avec l'API OpenAI si elle est activée, sinon correction manuelle sur un écran pré-rempli avec le texte source visible. Cibles : moins de 1 minute (texte ou web) et moins de 2 minutes (photo), correction comprise.
### Backlog items

s6_us1, s6_us2, s6_us3, s6_us4, s6_us5, s6_us6, s6_us15, s6_sp1
### Owned domain

Extraction (chaîne de repli IA embarquée, clé externe, correction manuelle)
### Provided contracts

- ct-extraction: extraire(ContenuRecu, cible : recette | message) → ResultatExtraction {statut : complet | partiel | echec, moteur : embarque | cle_externe | manuel, texte_source, recette (ct-recette-standard) ou articles}. Aucun appel externe sans clé activée et consentement unique enregistré.
- ct-articles-message: Articles extraits d'un message partagé ou collé (SMS, WhatsApp, Messenger) : [{nom, quantite (facultative), unite (facultative), message_id}], proposés comme source de la liste de la semaine.
### Consumed contracts

ct-entree-partage, ct-recette-standard, ct-bibliotheque
### Declared dependencies

slice-1
### Integration scenarios

WHEN l'extraction par l'IA embarquée échoue ou est partielle et qu'aucune clé n'est activée THE SYSTEM SHALL afficher l'écran de correction pré-rempli avec le texte source visible
WHEN l'extraction par l'IA embarquée échoue ou est partielle et que la clé de l'utilisateur est activée THE SYSTEM SHALL déléguer l'extraction au fournisseur choisi
### Required stubs

- Bouchon de l'IA embarquée renvoyant des résultats fixes (complet, partiel, échec)
- Serveur factice compatible avec l'API OpenAI, pour tester la clé sans coût
- Bouchon de ct-bibliotheque en mémoire, en attendant slice-1
## Slice slice-3

### Goal

Générer la liste de courses unique et cochable d'une semaine type (environ 5 recettes et 2 messages), fusionnée selon les règles confirmées, regroupée par catégorie, retouchable, avec ajout manuel sans IA, pour tenir l'objectif de moins de 2 minutes.
### Backlog items

s6_us10, s6_us11, s6_us12, s6_us13, s6_sp3
### Owned domain

Liste de courses (lignes : nom normalisé, quantité, unité, catégorie, origine)
### Provided contracts

- ct-liste-courses: ListeCourses : lignes [{nom_normalise, libelle, quantite (facultative), unite (facultative), categorie (ct-categories), origine : recette | message | manuel, cochee}]. Fusion : les unités comparables sont converties puis additionnées ; les variantes de nom restent sur des lignes distinctes. La liste intègre les retouches (retrait, quantité, catégorie).
- ct-evt-article-ajoute: Événement ArticleAjouteManuellement {ligne, apres_envoi : booléen}. Ajout avec quantité d'un article présent : fusion si les unités se comparent, sinon ligne distincte. Ajout sans quantité d'un article présent : la ligne existante est conservée.
### Consumed contracts

ct-selection-semaine, ct-articles-message, ct-normalisation, ct-categories
### Declared dependencies

slice-1, slice-2
### Integration scenarios

WHEN deux lignes portent le même nom normalisé avec des unités comparables THE SYSTEM SHALL convertir puis additionner les quantités sur une seule ligne
### Required stubs

- Bouchon de ct-selection-semaine renvoyant une semaine type fixe
- Bouchon de ct-articles-message renvoyant deux messages d'exemple
- Bouchon de ct-categories avec une liste provisoire, en attendant la liste validée par le porteur dans slice-0
## Slice slice-4

### Goal

Envoyer la liste dans un seul sens vers la liste Apple Rappels partagée avec le foyer, puis la renvoyer sans doublons, en s'appuyant sur les résultats du prototype s6_sp2 livré dans slice-0. La correspondance se fait par nom normalisé : ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification.
### Backlog items

s6_us14, s6_sp4
### Owned domain

Envoi vers Rappels (correspondance avec la liste partagée existante)
### Provided contracts

- ct-envoi-rappels: envoyer(ListeCourses, liste_rappels_cible) → RapportEnvoi {ajoutes, complements, ignores}. Le regroupement par catégorie est conservé. Les coches et ajouts du foyer dans Rappels ne remontent pas dans l'app.
### Consumed contracts

ct-liste-courses, ct-evt-article-ajoute, ct-normalisation
### Declared dependencies

slice-3
### Integration scenarios

WHEN l'utilisateur renvoie une liste vers une liste Rappels existante THE SYSTEM SHALL ajouter uniquement les articles absents, les articles seulement cochés et les compléments de quantité, sans supprimer ni modifier d'élément existant
WHEN l'utilisateur ajoute un article après l'envoi THE SYSTEM SHALL le renvoyer vers la liste Rappels selon la correspondance par nom normalisé
### Required stubs

- Magasin de rappels en mémoire simulant une liste partagée (articles existants, état coché), pour les tests de chaque branche de la règle
- Bouchon de ct-liste-courses renvoyant une liste fixe, en attendant slice-3
