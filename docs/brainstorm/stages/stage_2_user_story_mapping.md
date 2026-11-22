> **Révisé le 22/11/2026 :** arrondi après fusion, modification d'une recette enregistrée. En cas d'écart, [revision.md](../revision.md) et `delivery/` l'emportent.

# Structured Summary

## Stage 2 - User Story Mapping

Étape 2, cartographie des parcours utilisateurs.

**Périmètre de la V1 confirmé : proposition A, la V1 consolidée (15 capacités).** Votre réponse « A » est enregistrée comme un choix explicite (s2_d9). Elle lève la dernière incertitude de l'étape.
- **Imports :** lien web, texte collé ou partagé, photo, messages.
- **Traitement des recettes :**
  - extraction et standardisation par l'IA embarquée Apple ;
  - correction manuelle ;
  - bibliothèque minimale ;
  - mise à l'échelle simple.
- **Liste de courses :**
  - liste fusionnée et cochable ;
  - regroupement par catégorie selon une liste fixe ;
  - retouche avant l'envoi ;
  - ajout manuel ;
  - envoi dans un seul sens vers Rappels.
- **Cuisine et réglages :**
  - suivi pas à pas ;
  - clé d'IA optionnelle avec écran de consentement unique.

YouTube et Paprika restent en itération 1 (s2_d11).

**Votre liste de capacités de référence.** Elle reste une base de travail (s2_f1) et ne modifie pas le découpage :
- **Regroupement par rayon :** couvert en V1 par le regroupement par catégorie, selon une liste fixe.
- **Chat de modification par IA :** itération 2+. La mise à l'échelle simple reste en V1.
- **Lien YouTube et import Paprika :** itération 1.
- **Listes par magasin ou par lieu :** itération 1.
- **Partage iCloud et planification des repas :** itération 2+.
- **Traitement local et outillage de modèles embarqués :** contraintes techniques de la V1.

**Ce qui reste incertain :** aucun point bloquant identifié pour cette étape. Les risques s2_r1 (échéance d'environ 3 mois) et s2_r2 (temps de correction en cas d'échec de l'IA locale) restent suivis au point des 6 semaines.

**Prochaine étape :** le passage à l'étape suivante est décidé par les règles du serveur.

# Open Questions and Uncertainties

- None currently identified.

## Open Questions

- None.

# Questions to Continue

- No further question required to complete this stage.

# Stage Deliverable

## Stage 2 - User Story Mapping

### Facts

- Le porteur a fourni une liste de capacités candidates de référence. Ce ne sont pas des stories validées : import multi-sources, import photo, extraction IA, import depuis les messages, chat de modification et mise à l'échelle, liste fusionnée, synchronisation Rappels, regroupement par catégorie, partage iCloud, traitement local, outillage de modèles embarqués, import Paprika, listes par magasin, planification des repas.

### Assumptions

- None explicitly recorded.

### Decisions

- Parcours V1 validés : A import de recette, B préparation de la liste de la semaine, C cuisine en suivi pas à pas, D le foyer consulte et coche la liste Rappels partagée, E ajout manuel d'un article à la liste (ex. « ajoute des clémentines »). (Validation explicite de l'utilisateur, qui a ajouté le parcours E.)
- L'audio passe après la V1 : dictée de recette, et audio ou chat enregistré dans l'app pour alimenter les listes. (Choix explicite de l'utilisateur, pour tenir l'échéance d'environ 3 mois.)
- La liste générée peut être retouchée avant l'envoi vers Rappels : retrait d'articles, modification de quantité et ajout manuel. (Réponse « oui » de l'utilisateur. Évite d'envoyer des articles déjà à la maison, puisque le suivi des stocks est hors V1.)
- Parcours E : l'ajout manuel se fait par un champ de saisie simple (nom et quantité facultative), sans IA, avant ou après l'envoi vers Rappels. Après l'envoi, l'article est renvoyé vers la liste Rappels partagée selon la règle de correspondance par nom normalisé. (Choix explicite de l'utilisateur, qui retient l'option recommandée. Le coût reste faible et reste cohérent avec le report du chat et de l'audio après la V1.)
- Règles des cas limites de quantité et de fusion :
- Mise à l'échelle : les articles à l'unité sont arrondis au supérieur (1,5 œuf devient 2 œufs).
- Unités comparables : g et kg, cl et l sont convertis puis additionnés.
- Variantes de nom : « tomates » et « tomates cerises » restent des lignes distinctes.
- Ajout manuel avec quantité d'un article déjà présent dans la liste de l'app : fusion si les unités se comparent, sinon ligne distincte.
- Ajout manuel sans quantité d'un article déjà présent : aucune nouvelle ligne, la ligne existante est conservée telle quelle.
- Après l'envoi : la règle de correspondance par nom normalisé s'applique. (Confirmation explicite de l'utilisateur (« ok ») de l'hypothèse s2_a1.)
- Découpage après la V1 :
- Itération 1 : listes séparées par magasin ou par lieu ; dictée audio de recette et alimentation de la liste par audio ou chat ; import YouTube ; import Paprika.
- Itération 2+ : chat de modification des recettes par IA ; partage iCloud dans l'app ; planification des repas avec catalogue ; ordre de visite optimisé (dépend des listes par lieu) ; suivi des stocks avec ajustement par photo. (Confirmation explicite de l'utilisateur (« ok ») de l'hypothèse s2_a2, mise à jour avec la décision s2_d11 qui place YouTube et Paprika en itération 1.)
- Ordre de livraison de la V1 :
1. Socle : format de recette standardisé, import par lien web et par texte collé ou partagé via l'IA embarquée, correction manuelle, bibliothèque minimale.
2. Parcours B de bout en bout (rend aussi utilisables D et E) : mise à l'échelle, import depuis les messages, liste fusionnée regroupée par catégorie, retouche et ajout manuel, envoi vers Rappels avec la règle de correspondance.
3. Import photo.
4. Suivi pas à pas.
5. Clé d'IA optionnelle avec l'écran de consentement. (Confirmation explicite de l'utilisateur (« ok ») de l'hypothèse s2_a3. L'étape 6 (YouTube et Paprika) est retirée à la suite de la décision s2_d11. Cet ordre mesure tôt l'objectif des 2 minutes et permet de tester l'IA embarquée avant le point des 6 semaines.)
- Manques fonctionnels comblés pour la V1 :
- Bibliothèque de recettes minimale : liste, recherche par titre, suppression, sélection multiple avec portions pour la liste.
- Catégories : liste fixe prédéfinie en V1 ; l'utilisateur peut changer la catégorie d'un article.
- Échec de l'IA locale sans clé branchée : écran de correction pré-rempli, texte source visible, édition champ par champ. (Confirmation explicite de l'utilisateur (« ok pour ta reco ») de l'hypothèse s2_a4, option recommandée.)
- Le périmètre MVP est validé selon la proposition A : la V1 consolidée est retenue avec 15 capacités fermes.
- Capacités : import web, import texte collé ou partagé, import photo, import depuis les messages, extraction et standardisation par l'IA embarquée, correction manuelle, bibliothèque minimale, mise à l'échelle, liste fusionnée et cochable, regroupement par catégorie, retouche avant l'envoi, ajout manuel, envoi vers Rappels, suivi pas à pas, clé d'IA optionnelle avec consentement.
- YouTube et Paprika sont hors V1 et passent à l'itération 1 (s2_d11). (Choix explicite de l'utilisateur, confirmé à nouveau (« A ») après la présentation des options A à D. Il s'agit de l'option recommandée, complétée par la décision s2_d11. Ce périmètre couvre les trois objectifs mesurables de l'étape 1 et les parcours A à E validés.)
- Effort de correction manuelle acceptable quand l'IA locale échoue et qu'aucune clé n'est branchée : les objectifs de l'étape 1 s'appliquent aussi dans ce cas, correction comprise (moins de 1 minute pour une recette texte ou web, moins de 2 minutes pour une recette photo). (Choix explicite de l'utilisateur, qui retient l'option recommandée. Les objectifs mesurables de l'étape 1 incluent déjà la correction.)
- L'import YouTube et l'import Paprika sont exclus de la V1. Ils passent à l'itération 1 et ne sont plus conditionnels au point des 6 semaines. (Choix explicite de l'utilisateur (« youtube et paprika après la v1 »). Ce choix lève la dernière incertitude du périmètre et protège l'échéance d'environ 3 mois.)

### Risks

- [périmètre] La V1 s'élargit avec l'écran de retouche et l'ajout manuel, en plus de quatre sources d'import, pour une échéance d'environ 3 mois. | impact: moyen | probability: moyenne | mitigation: Plusieurs choix limitent ce risque :
- L'ajout manuel reste un champ simple, sans IA (décidé).
- YouTube et Paprika sont sortis de la V1 (s2_d11).
- L'ordre de livraison confirmé (s2_d7) obtient tôt le parcours B de bout en bout et place la photo et la clé d'IA en fin de V1.
- Les fonctionnalités reportées sont réparties entre l'itération 1 et l'itération 2+ (s2_d6). | action: Découper les stories selon l'ordre s2_d7. Faire un point d'avancement aux 6 semaines.
- [expérience utilisateur] Sur les contenus bruités (photo floue, fiche manuscrite), quand l'IA locale échoue sans clé branchée, la correction manuelle pourrait dépasser les cibles de 1 minute (texte ou web) et de 2 minutes (photo), désormais exigées aussi dans le cas d'échec. | impact: moyen | probability: moyenne | mitigation: L'écran de correction est pré-rempli, avec le texte source visible et une édition champ par champ (s2_d8). La clé d'IA optionnelle sert de repli. | action: Mesurer le temps de correction des cas d'échec pendant les tests sur l'iPhone 15 Pro, avant le point des 6 semaines, puis ajuster l'écran de correction ou mettre davantage en avant la clé d'IA si les cibles ne sont pas tenues.

### Open Questions

- None.

### Stage Fields

- actors_personas: ["Utilisateur principal (porteur du projet), sur iPhone 15 Pro ou ultérieur : importe les recettes, prépare la liste de courses dans l'app, cuisine en suivi pas à pas", "L'autre membre du foyer, sur iPhone 11 : consulte et coche la liste Apple Rappels partagée, sans installer l'app en V1", "Grand public via l'App Store : cible éventuelle, après la V1", 'Système : IA embarquée Apple (standardisation locale)', "Système : fournisseur d'IA externe, via la clé de l'utilisateur (désactivé par défaut, consentement unique)", 'Système : Apple Rappels (réception des listes et partage avec le foyer)', "Système : iCloud (partage dans l'app, après la V1)"]
- user_journeys: ["A. Importer une recette : lien web, texte collé ou partagé, ou photo → extraction et standardisation par l'IA embarquée (repli par clé utilisateur, sinon correction manuelle) → correction → enregistrement", 'B. Préparer la semaine : choisir environ 5 recettes et leurs portions, ajouter environ 2 messages → liste fusionnée, cochable, regroupée par catégorie → retouche (retrait, modification de quantité, ajout) → envoi dans un seul sens vers la liste Rappels partagée', 'C. Cuisiner une recette en suivi pas à pas', "D. Le foyer (autre membre, iPhone 11) consulte et coche la liste Apple Rappels partagée, sans installer l'app", "E. Ajouter manuellement un article (ex. clémentines) : champ de saisie simple (nom et quantité facultative), sans IA → avant l'envoi, ajout dans la liste en retouche ; après l'envoi, renvoi vers la liste Rappels partagée selon la règle de correspondance par nom normalisé"]
- capabilities: ['Import de recette par lien web', 'Import de recette par texte collé ou partagé (extension de partage iOS)', 'Import de recette par photo (page de livre, magazine, fiche manuscrite)', "Import d'articles ou de recettes depuis des messages partagés ou copiés (SMS, WhatsApp, Messenger)", "Extraction et standardisation des ingrédients et des étapes par l'IA embarquée Apple (repli par clé utilisateur, sinon correction manuelle)", 'Correction manuelle de la recette standardisée, avec écran pré-rempli, texte source visible et édition champ par champ', 'Bibliothèque de recettes minimale : liste, recherche par titre, suppression, sélection multiple avec portions pour la liste', "Mise à l'échelle simple selon le nombre de portions", 'Suivi pas à pas de la recette', 'Liste de courses unique, fusionnée depuis plusieurs recettes et messages, cochable', "Regroupement des articles par catégorie (liste fixe prédéfinie), avec changement de catégorie d'un article", "Retouche de la liste avant l'envoi vers Rappels : retrait d'articles et modification de quantité", "Ajout manuel d'un article par champ de saisie simple (nom et quantité facultative), sans IA, avant ou après l'envoi vers Rappels", 'Envoi de la liste dans un seul sens vers une liste Apple Rappels partagée, avec la règle de correspondance par nom normalisé', "Activation optionnelle d'une clé de fournisseur d'IA, avec écran de consentement unique", 'Import YouTube (itération 1)', 'Import Paprika (itération 1)', 'Listes séparées par magasin ou par lieu (itération 1)', 'Dictée audio de recette (itération 1)', "Alimentation de la liste par audio ou chat enregistré dans l'app (itération 1)", 'Chat de modification des recettes par IA (itération 2+)', "Partage de recettes et de listes via iCloud dans l'app (itération 2+)", 'Planification des repas avec catalogue de recettes (itération 2+)', 'Ordre de visite optimisé des magasins (itération 2+)', 'Suivi des stocks de la maison, avec ajustement par photo (itération 2+)']
- mvp_scope: ['Import de recette par lien web', 'Import de recette par texte collé ou partagé (extension de partage iOS)', 'Import de recette par photo (page de livre, magazine, fiche manuscrite)', "Import d'articles ou de recettes depuis des messages partagés ou copiés (SMS, WhatsApp, Messenger)", "Extraction et standardisation des ingrédients et des étapes par l'IA embarquée Apple (repli par clé utilisateur, sinon correction manuelle)", 'Correction manuelle de la recette standardisée, avec écran pré-rempli, texte source visible et édition champ par champ', 'Bibliothèque de recettes minimale : liste, recherche par titre, suppression, sélection multiple avec portions pour la liste', "Mise à l'échelle simple selon le nombre de portions", 'Suivi pas à pas de la recette', 'Liste de courses unique, fusionnée depuis plusieurs recettes et messages, cochable', "Regroupement des articles par catégorie (liste fixe prédéfinie), avec changement de catégorie d'un article", "Retouche de la liste avant l'envoi vers Rappels : retrait d'articles et modification de quantité", "Ajout manuel d'un article par champ de saisie simple (nom et quantité facultative), sans IA, avant ou après l'envoi vers Rappels", 'Envoi de la liste dans un seul sens vers une liste Apple Rappels partagée, avec la règle de correspondance par nom normalisé', "Activation optionnelle d'une clé de fournisseur d'IA, avec écran de consentement unique"]
- dependencies: ["IA embarquée Apple, disponible sur iPhone 15 Pro et ultérieur sous l'iOS actuel : nécessaire à l'extraction et à la standardisation", "Accès à Apple Rappels et liste partagée avec le foyer : nécessaires à l'envoi de la liste (parcours B, D et E)", "Extension de partage iOS et presse-papiers : nécessaires à l'import de texte et de messages", "La liste fusionnée dépend de recettes standardisées (ingrédients, quantités, unités) et de la mise à l'échelle", "La retouche et l'ajout manuel avant l'envoi dépendent de la liste fusionnée générée", "L'ajout manuel après l'envoi dépend de la règle de correspondance par nom normalisé et de l'envoi vers Rappels", "Le regroupement par catégorie dépend d'une liste fixe prédéfinie de catégories, à définir dans le socle (décidé, s2_d8)", "Le repli par clé externe dépend de l'écran de consentement et du choix des fournisseurs pris en charge", "Ordre de livraison de la V1 (confirmé) : 1) socle recette (format standardisé, imports web et texte, correction, bibliothèque minimale) ; 2) parcours B de bout en bout, qui rend utilisables D et E ; 3) import photo ; 4) suivi pas à pas ; 5) clé d'IA optionnelle", 'Le parcours B dépend du socle recette et de la bibliothèque minimale (sélection multiple des recettes enregistrées avec portions)', "Après la V1 : l'import YouTube et l'import Paprika (itération 1) dépendent du format de recette standardisé et du pipeline d'extraction du socle", "Après la V1 : l'ordre de visite optimisé (itération 2+) dépend des listes par magasin ou par lieu (itération 1)"]
- functional_gaps: ['Bibliothèque de recettes : comblé (s2_d8). Bibliothèque minimale en V1, avec liste, recherche par titre, suppression et sélection multiple avec portions.', "Catégories : comblé (s2_d8). Liste fixe prédéfinie en V1, avec changement de catégorie d'un article par l'utilisateur.", "Échec de l'IA locale sans clé branchée : comblé (s2_d8, s2_d10). Écran de correction pré-rempli, avec le texte source visible et une édition champ par champ. L'effort acceptable reste dans les objectifs de l'étape 1, correction comprise : moins de 1 minute pour une recette texte ou web, moins de 2 minutes pour une recette photo."]
- edge_cases: ["Nouvel envoi vers une liste Rappels existante : correspondance par nom normalisé ; ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification (règle confirmée à l'étape 1)", "Mise à l'échelle d'articles à l'unité donnant des fractions (1,5 œuf pour 3 portions au lieu de 4) : arrondi au supérieur (confirmé)", "Fusion d'ingrédients dont les unités sont comparables (g et kg, cl et l) : conversion puis addition (confirmé)", 'Variantes de nom lors de la fusion (« tomates » et « tomates cerises ») : lignes distinctes (confirmé)', "Ajout manuel avec quantité d'un article déjà présent dans la liste de l'app (ex. clémentines déjà issues d'une recette) : fusion si les unités se comparent, sinon ligne distincte (confirmé)", "Ajout manuel sans quantité d'un article déjà présent : aucune nouvelle ligne, la ligne existante est conservée telle quelle (confirmé)", "Ajout manuel après l'envoi : renvoi vers Rappels selon la règle de correspondance par nom normalisé (confirmé)", "Échec ou résultat partiel de l'IA embarquée sur un contenu bruité (photo floue, fiche manuscrite) sans clé branchée : correction manuelle, à réaliser dans les objectifs de l'étape 1 (moins de 1 minute pour une recette texte ou web, moins de 2 minutes pour une recette photo, correction comprise) (confirmé, s2_d10)"]

### Readiness

- 10/10 passed/total
- [x] field:actors_personas: Required field actors_personas: clear
- [x] field:user_journeys: Required field user_journeys: clear
- [x] field:capabilities: Required field capabilities: clear
- [x] field:mvp_scope: Required field mvp_scope: clear
- [x] field:dependencies: Required field dependencies: clear
- [x] field:functional_gaps: Required field functional_gaps: clear
- [x] field:edge_cases: Required field edge_cases: clear
- [x] mvp_capabilities: MVP scope items must exist in capabilities.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- actors_personas: clear
- user_journeys: clear
- capabilities: clear
- mvp_scope: clear
- dependencies: clear
- functional_gaps: clear
- edge_cases: clear

### Clarifications

- 2026-11-22T10:58:53.677564+01:00: Validez-vous ces quatre parcours de bout en bout pour la V1 ?
- A. Importer une recette (lien, texte, partage ou photo), extraction par l'IA, correction, enregistrement.
- B. Préparer la semaine : choisir environ 5 recettes et leurs portions, ajouter environ 2 messages, obtenir une liste fusionnée par catégorie, l'envoyer vers Rappels.
- C. Cuisiner une recette en suivi pas à pas.
- D. Le foyer consulte et coche la liste Rappels partagée. -> 1. je valide les 4 parcours plus un parcours d'ajout d'élément manuel a la liste (par exemple: "ajoutes des clémentines")
2. apres V1.
3. oui
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T10:58:53.677575+01:00: L'audio fait-il partie de la V1 ? Il s'agit de la dictée d'une recette, et de l'audio ou du chat enregistré dans l'app pour alimenter la liste. -> 1. je valide les 4 parcours plus un parcours d'ajout d'élément manuel a la liste (par exemple: "ajoutes des clémentines")
2. apres V1.
3. oui
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T10:58:53.677579+01:00: Avant l'envoi vers Rappels, pouvez-vous retoucher la liste générée (retirer ce que vous avez déjà, modifier une quantité, ajouter un article à la main) ? -> 1. je valide les 4 parcours plus un parcours d'ajout d'élément manuel a la liste (par exemple: "ajoutes des clémentines")
2. apres V1.
3. oui
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T11:02:31.702072+01:00: Pour le parcours E, comment ajoutez-vous un article à la main ? Et cet ajout est-il possible après un envoi vers Rappels ? -> Pour le parcours E, comment ajoutez-vous un article à la main ? Et cet ajout est-il possible après un envoi vers Rappels ?
Champ de saisie simple (nom et quantité facultative), sans IA, avant ou après l'envoi, renvoyé vers Rappels avec la règle de correspondance
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T11:13:48.249205+01:00: Which capabilities belong to the first version (MVP)? -> 1. ok
2. ok
3. ok
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T11:13:48.249212+01:00: What does the project depend on (other teams, systems, data, vendors)? -> 1. ok
2. ok
3. ok
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T11:13:48.249214+01:00: Which edge cases or exceptions must be handled? -> 1. ok
2. ok
3. ok
Owner-selected benchmark candidates (not validated stories):
Multi-source recipe import (website link, pasted or shared text, YouTube link)
Recipe import from a photo of a cookbook page, magazine or handwritten card
AI extraction of ingredients and steps into a standardized recipe format
Import of recipes received in messages or as copied text
AI-assisted recipe modification and scaling via chat
Single merged, checkable grocery list from several selected recipes
Grocery list sync with Apple Reminders
Automatic grouping of list items by category or aisle
Household sharing via iCloud without user accounts
Local-first processing and storage
On-device model tooling for Apple platforms
Import from an existing recipe manager (Paprika)
Separate lists per store or location
Meal planning with a recipe catalog
- 2026-11-22T11:29:12.290959+01:00: Confirmez-vous l'hypothèse s2_a4 pour les manques fonctionnels de la V1 : bibliothèque minimale (liste, recherche par titre, suppression, sélection multiple avec portions), catégories fixes avec possibilité de changer la catégorie d'un article, et écran de correction pré-rempli avec le texte source visible quand l'IA échoue ? -> repasse en francais.
1. ok pour ta reco
2. propose moi des trucs
- 2026-11-22T11:36:33.373031+01:00: Quelles capacités font partie de la première version (MVP) ? -> A
- 2026-11-22T11:38:37.854937+01:00: Quand l'IA locale échoue et qu'aucune clé n'est branchée, quel effort de correction manuelle jugez-vous acceptable ? -> Quand l'IA locale échoue et qu'aucune clé n'est branchée, quel effort de correction manuelle jugez-vous acceptable ?
Rester dans les objectifs de l'étape 1, même en cas d'échec (1 min texte ou web, 2 min photo, correction comprise)
- 2026-11-22T11:38:37.854942+01:00: Quelles capacités font partie de la première version (MVP) ? -> Quand l'IA locale échoue et qu'aucune clé n'est branchée, quel effort de correction manuelle jugez-vous acceptable ?
Rester dans les objectifs de l'étape 1, même en cas d'échec (1 min texte ou web, 2 min photo, correction comprise)
- 2026-11-22T11:45:57.568243+01:00: Quelles capacités font partie de la première version (MVP) ? -> youtube et paprika apres la v1
- 2026-11-22T11:49:48.754103+01:00: Quelles capacités font partie de la première version (MVP) ? -> A

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.
