> **Révisé le 22/11/2026 :** règles de renvoi vers Rappels et version d'iOS précisées. En cas d'écart, [revision.md](../revision.md) et `delivery/` l'emportent.

# Structured Summary

## Stage 1 - Problem Framing and 5W1H

Cadrage du problème (étape 1).

L'utilisateur confirme les sept hypothèses du projet :
- liste Rappels partagée suffisante ;
- synchronisation dans un seul sens suffisante ;
- partage iOS ou copier-coller pour les messages ;
- accès externe = clé de fournisseur de l'utilisateur, inutile au foyer en V1 ;
- IA embarquée de l'iPhone 15 Pro suffisante pour la majorité des recettes texte ;
- export Paprika exploitable si Paprika entre en V1 ;
- distribution App Store sous licence commerciale ou avec une exception App Store.

Ces hypothèses deviennent des bases de conception. Les actions de vérification déjà prévues restent en place :
- tests sur l'iPhone 15 Pro avant le point des 6 semaines (r2) ;
- avis juridique avant publication (r3).

Plus aucun point bloquant identifié pour l'étape 1. La décision de transition revient aux règles du serveur.

Restent ouverts, sans bloquer l'étape :
- conversion d'unités et variantes de nom ;
- arrondi lors de la mise à l'échelle ;
- effort de correction manuelle acceptable ;
- format Paprika et import YouTube ;
- choix GPLv3 ou AGPLv3 ;
- fournisseurs d'IA pris en charge ;
- catégories de la liste.

# Open Questions and Uncertainties

- Conversion entre unités comparables (g et kg, cl et l) lors du calcul de la quantité supplémentaire, et traitement des variantes de nom (« tomates » et « tomates cerises »).
- Règles d'arrondi des quantités lors de la mise à l'échelle par nombre de portions (articles à l'unité, comme les œufs).
- Import depuis Paprika : format précis à vérifier s'il entre en V1.
- Choix final entre GPLv3 et AGPLv3, à valider juridiquement avant publication.
- Faisabilité et mode d'import depuis YouTube (lien, description, sous-titres), s'il entre en V1.
- Fournisseurs d'IA externes pris en charge et détail des données envoyées lorsque la clé est activée.
- Effort de correction manuelle acceptable quand l'IA locale échoue et qu'aucune clé n'est branchée, compté dans les 2 minutes de la liste, la minute par recette texte ou web et les 2 minutes par recette photo.
- Liste de catégories ou de rayons fixe ou personnalisable.
- Prise en charge éventuelle d'appareils sans IA Apple (accès externe) en cas de publication grand public, après la V1.
- Temps actuel nécessaire pour saisir ou mettre en forme une recette non chiffré : le gain visé par les objectifs d'import de recettes n'est pas mesuré.

## Open Questions

- None.

# Questions to Continue

- No further question required to complete this stage.

# Stage Deliverable

## Stage 1 - Problem Framing and 5W1H

### Facts

- Application iPhone unique regroupant recettes, listes de courses, plus tard stocks et parcours ; Android dans un second temps.
- La V1 porte sur les recettes et les listes de courses.
- Listes de courses séparées par catégorie en V1, par lieu plus tard.
- Parcours optimisé = ordre de visite des magasins ou lieux, prévu pour plus tard.
- Cible : l'utilisateur et son foyer, éventuellement le grand public via l'App Store.
- Traitement local privilégié. Recours à un fournisseur d'IA externe si le local ne suffit pas, avec coût à chiffrer. Possibilité envisagée que l'utilisateur branche son propre fournisseur.
- Sources des recettes : sites web, texte collé ou partagé, photo de livre ou de fiche, dictée audio, YouTube, etc., avec standardisation par IA.
- Sources des listes : audio ou chat enregistré dans l'app, messages reçus (SMS, WhatsApp, Messenger), recettes. Synchronisation avec Apple Rappels.
- App gratuite a priori, sous double licence envisagée : GPL ou AGPL, plus licence commerciale et CLA.
- Fonctionnalités retenues : import multi-sources (lien, texte, YouTube) ; import par photo d'une page de livre, d'un magazine ou d'une fiche manuscrite ; extraction IA dans un format standard ; import depuis des messages ou du texte copié ; modification et mise à l'échelle par chat IA ; liste fusionnée et cochable depuis plusieurs recettes ; synchronisation avec Apple Rappels ; regroupement par catégorie ou par rayon ; partage du foyer via iCloud sans compte ; traitement local d'abord ; outils d'IA embarquée Apple ; import depuis Paprika ; listes par magasin ou par lieu ; planification des repas.
- Objectif de succès de la V1 retenu : liste de courses prête en moins de 2 minutes à partir des recettes et des messages.
- Échéance de la V1 dans environ 3 mois ; budget d'IA externe proche de zéro.
- En V1, les membres du foyer cochent seulement une liste Apple Rappels partagée ; le partage iCloud dans l'app vient plus tard.
- Les listes par magasin ou par lieu et la planification des repas sont reportées après la V1 ; la V1 reste sur les recettes et les listes par catégorie.
- Repli d'IA en V1 : l'utilisateur peut brancher sa propre clé de fournisseur (option désactivée par défaut) ; sinon, correction manuelle. Aucun appel externe n'est payé par le porteur.
- Mesure de l'objectif des 2 minutes : de la sélection des recettes et des messages jusqu'à la liste disponible dans Apple Rappels, pour une semaine type d'environ 5 recettes et 2 messages.
- Synchronisation avec Apple Rappels dans un seul sens : l'app pousse la liste vers Rappels, les coches du foyer restent dans Rappels.
- Objectif de succès du volet recettes : une recette texte ou web importée et standardisée en moins de 1 minute, correction comprise.
- Frictions actuelles citées par l'utilisateur : temps, organisation, variété des repas.
- Utilisateurs visés : l'utilisateur et son foyer ; objectif de fluidifier les courses pour son foyer.
- Appareils cibles : iPhone 15 et iPhone 11, sous l'iOS actuel, avec un accès externe pour les appareils plus anciens.
- La variété des repas n'est pas traitée en V1. Elle viendra avec la planification des repas, après la V1.
- L'iPhone 15 du porteur est un modèle Pro. L'IA embarquée Apple vise l'iPhone 15 Pro et les modèles ultérieurs.
- Temps actuel de préparation de la liste de courses : entre 10 et 30 minutes par semaine.
- En V1, l'iPhone 11 sert seulement à cocher la liste Apple Rappels partagée ; l'app n'y est pas nécessaire.
- Lors d'un nouvel envoi vers une liste Apple Rappels existante, l'app ajoute seulement les articles absents, sans rien supprimer.
- Lors d'un nouvel envoi vers une liste Apple Rappels existante, un article déjà présent mais coché est rajouté comme nouvel article non coché ; l'article coché existant n'est pas modifié.
- Lors d'un nouvel envoi vers une liste Apple Rappels existante, si un article est déjà présent, non coché, avec une autre quantité, l'app ajoute un nouvel article avec la quantité supplémentaire ; l'article existant n'est pas modifié.
- Lors d'un nouvel envoi vers une liste Apple Rappels existante, l'app reconnaît un article déjà présent par son nom normalisé (singulier ou pluriel, accents, majuscules). Si les unités ne se comparent pas, elle ajoute un nouvel article avec la quantité complète.
- Quand un utilisateur active sa propre clé de fournisseur, l'app affiche un écran unique indiquant les données envoyées et le fournisseur choisi, avec un consentement explicite.
- Priorité des sources d'import de recettes en V1 : lien web et texte collé ou partagé d'abord ; photo ensuite ; YouTube et Paprika après la V1 si le temps manque.
- Objectif de l'import par photo : une recette importée par photo (page de livre, magazine ou fiche manuscrite) et standardisée en moins de 2 minutes, correction comprise.
- La mise à l'échelle simple des recettes (selon le nombre de portions) fait partie de la V1 ; le chat de modification par IA vient après la V1.
- Point de décision à mi-parcours, vers 6 semaines : si les imports web, texte et photo n'atteignent pas leurs objectifs, YouTube et Paprika sont reportés après la V1.
- L'utilisateur confirme les sept hypothèses du projet : liste Rappels partagée suffisante ; synchronisation dans un seul sens suffisante ; partage iOS ou copier-coller pour les messages ; accès externe correspondant à la clé de fournisseur de l'utilisateur ; IA embarquée de l'iPhone 15 Pro suffisante pour la majorité des recettes texte ; export Paprika exploitable ; distribution App Store sous licence commerciale ou avec exception App Store.

### Assumptions

- L'IA embarquée Apple, disponible sur l'iPhone 15 Pro du porteur et les modèles ultérieurs, suffit pour standardiser la majorité des recettes texte. Hypothèse confirmée par l'utilisateur ; elle reste testée sur l'iPhone 15 Pro avant le point des 6 semaines (r2). Les contenus bruités (photo, vidéo) pourront nécessiter la clé de fournisseur de l'utilisateur ou une correction manuelle.
- Les messages SMS, WhatsApp et Messenger seront récupérés via l'extension de partage iOS ou le copier-coller, iOS interdisant la lecture directe. Hypothèse confirmée par l'utilisateur.
- Le binaire de l'App Store sera distribué sous la licence commerciale ou avec une exception App Store ajoutée à la GPLv3. Hypothèse confirmée par l'utilisateur ; elle reste soumise à un avis juridique avant publication (r3).
- Une liste Apple Rappels partagée suffit pour que les membres du foyer consultent et cochent les courses en V1, sans installer l'app. Hypothèse confirmée par l'utilisateur.
- Une synchronisation dans un seul sens suffit en V1 : l'utilisateur principal n'a pas besoin de voir dans l'app les coches ou les ajouts faits par le foyer dans Rappels. Hypothèse confirmée par l'utilisateur.
- « L'accès externe pour les plus anciens » correspond à la clé de fournisseur branchée par l'utilisateur (décision d2), et non à un service payé par le porteur. Il n'est pas nécessaire au foyer en V1. Hypothèse confirmée par l'utilisateur.
- L'export Paprika est exploitable pour importer des recettes existantes, si l'import Paprika entre en V1. Hypothèse confirmée par l'utilisateur ; le format reste à vérifier si Paprika entre en V1.

### Decisions

- V1 : listes séparées par catégorie uniquement ; séparation par magasin ou par lieu reportée après la V1. (Réponse explicite de l'utilisateur, confirmée lors de l'arbitrage du périmètre V1.)
- IA locale par défaut. Repli externe uniquement via une clé de fournisseur branchée par l'utilisateur (option désactivée par défaut) ; sinon, correction manuelle. Aucun coût d'IA externe pour le porteur. (Réponse explicite de l'utilisateur ; cohérent avec un budget d'IA externe proche de zéro.)
- V1 visée dans environ 3 mois, avec un budget d'IA externe proche de zéro. (Réponse explicite de l'utilisateur à la question sur l'échéance et le budget.)
- V1 : le foyer coche uniquement une liste Apple Rappels partagée ; le partage iCloud sans compte dans l'app est reporté après la V1. (Réponse explicite de l'utilisateur ; allège le périmètre au vu de l'échéance d'environ 3 mois.)
- Périmètre V1 : recettes et listes de courses par catégorie ; listes par lieu et planification des repas après la V1. (Réponse explicite de l'utilisateur ; réduit le périmètre au vu de l'échéance d'environ 3 mois.)
- L'objectif des 2 minutes est chronométré de la sélection des recettes et des messages jusqu'à la liste disponible dans Apple Rappels, sur une semaine type d'environ 5 recettes et 2 messages. (Réponse explicite de l'utilisateur à la question sur la mesure de l'objectif.)
- V1 : synchronisation avec Apple Rappels dans un seul sens. L'app pousse la liste vers Rappels ; les coches du foyer restent dans Rappels et ne remontent pas dans l'app. (Réponse explicite de l'utilisateur ; évite les conflits de synchronisation bidirectionnelle et allège la V1 prévue en environ 3 mois.)
- Objectif chiffré du volet recettes en V1 : une recette texte ou web importée et standardisée en moins de 1 minute, correction comprise. (Réponse explicite de l'utilisateur à la question sur l'objectif du volet recettes.)
- Cible de la V1 : l'utilisateur principal et son foyer. Le grand public reste une cible éventuelle, ultérieure à la V1. (Réponse explicite de l'utilisateur : « moi et mon foyer, fluidifier les courses ».)
- Appareils V1 : l'app tourne sur l'iPhone 15 Pro (appareil du porteur) et les modèles ultérieurs, sous l'iOS actuel, avec l'IA embarquée Apple. L'iPhone 11 sert seulement à cocher la liste Apple Rappels partagée ; l'app n'y est pas nécessaire en V1. (Réponses explicites de l'utilisateur : « iPhone 15 Pro et ultérieur », puis « l'iPhone 11 sert seulement à cocher la liste Rappels partagée : l'app n'y est pas nécessaire en V1 ».)
- La variété des repas est hors V1. Elle sera traitée avec la planification des repas, après la V1. La V1 répond aux frictions de temps et d'organisation. (Réponse explicite de l'utilisateur ; aligne le problème sur le périmètre V1 (d5).)
- V1 : lors d'un nouvel envoi vers une liste Apple Rappels existante, l'app ajoute les articles absents ou seulement présents à l'état coché, et ne supprime ni ne modifie aucun article existant. (Réponses explicites de l'utilisateur ; préserve les coches et les ajouts du foyer malgré la synchronisation dans un seul sens (d7).)
- V1 : un article à envoyer déjà présent dans la liste Rappels mais coché est rajouté comme nouvel article non coché ; l'ancien article coché reste inchangé. (Réponse explicite de l'utilisateur ; évite d'oublier en magasin un article resté coché depuis les courses précédentes.)
- V1 : un article à envoyer déjà présent dans la liste Rappels, non coché, avec une quantité différente, donne lieu à l'ajout d'un nouvel article portant uniquement la quantité supplémentaire ; l'article existant reste inchangé. (Réponse explicite de l'utilisateur ; garantit une quantité suffisante en magasin sans modifier les articles du foyer, conformément à la synchronisation dans un seul sens (d7) et aux règles d12 et d13.)
- V1 : correspondance des articles par nom normalisé (singulier ou pluriel, accents, majuscules). Si les unités ne se comparent pas, ajout d'un nouvel article avec la quantité complète, sans modifier l'article existant. (Réponse explicite de l'utilisateur. Évite les doublons dus aux variations d'écriture sans fusionner des articles différents. Complète les règles d12, d13 et d14.)
- V1 : à l'activation de la clé de fournisseur de l'utilisateur, un écran unique présente les données envoyées et le fournisseur choisi, et recueille un consentement explicite ; pas de confirmation à chaque envoi externe. (Réponse explicite de l'utilisateur ; limite le risque de confidentialité (r5) sans alourdir chaque import, et prépare une éventuelle publication.)
- V1 : import de recettes priorisé dans cet ordre : lien web et texte collé ou partagé, puis photo. YouTube et Paprika sont reportés après la V1 si le temps manque. (Réponse explicite de l'utilisateur ; protège l'objectif d'une minute par recette et réduit le risque de périmètre (r1) pour une échéance d'environ 3 mois.)
- Objectif chiffré de l'import par photo en V1 : une recette importée par photo (page de livre, magazine ou fiche manuscrite) et standardisée en moins de 2 minutes, correction comprise. (Réponse explicite de l'utilisateur. La reconnaissance de texte sur photo demande plus de correction que le texte ou le web ; l'objectif est donc plus large que celui d'une minute (d8).)
- V1 : mise à l'échelle simple des recettes selon le nombre de portions. Le chat de modification des recettes par IA est reporté après la V1. (Réponse explicite de l'utilisateur ; allège la V1 prévue en environ 3 mois, réduit la dépendance à l'IA embarquée et sert directement l'objectif de la liste en moins de 2 minutes.)
- V1 : point de décision à mi-parcours, vers 6 semaines. Si les imports web, texte et photo n'atteignent pas leurs objectifs (moins de 1 minute pour le texte ou le web, moins de 2 minutes pour la photo, correction comprise), YouTube et Paprika sont reportés après la V1. (Réponse explicite de l'utilisateur ; remplace le critère vague « si le temps manque » et protège les objectifs chiffrés de la V1 prévue en environ 3 mois (d8, d17, d18).)
- Les sept hypothèses du projet sont confirmées et servent de bases de conception. Les hypothèses techniques et juridiques (IA embarquée, export Paprika, licence App Store) gardent leurs actions de vérification prévues : tests sur l'iPhone 15 Pro avant le point des 6 semaines, vérification du format Paprika s'il entre en V1, avis juridique avant publication. (Réponse explicite de l'utilisateur : « je confirme les hypothèses 1 à 7 ». Les vérifications sont maintenues car elles relèvent de tests ou d'un avis extérieur, conformément aux risques r2 et r3.)
- Multi\-source recipe import \(website link, pasted or shared text, YouTube link\) (Owner-selected benchmark candidate)
- Recipe import from a photo of a cookbook page, magazine or handwritten card (Owner-selected benchmark candidate)
- AI extraction of ingredients and steps into a standardized recipe format (Owner-selected benchmark candidate)
- Import of recipes received in messages or as copied text (Owner-selected benchmark candidate)
- AI\-assisted recipe modification and scaling via chat (Owner-selected benchmark candidate)
- Single merged, checkable grocery list from several selected recipes (Owner-selected benchmark candidate)
- Grocery list sync with Apple Reminders (Owner-selected benchmark candidate)
- Automatic grouping of list items by category or aisle (Owner-selected benchmark candidate)
- Household sharing via iCloud without user accounts (Owner-selected benchmark candidate)
- Local\-first processing and storage (Owner-selected benchmark candidate)
- On\-device model tooling for Apple platforms (Owner-selected benchmark candidate)
- Import from an existing recipe manager \(Paprika\) (Owner-selected benchmark candidate)
- Separate lists per store or location (Owner-selected benchmark candidate)
- Meal planning with a recipe catalog (Owner-selected benchmark candidate)

### Risks

- [Périmètre] Le périmètre V1 reste large pour un développeur seul et une échéance d'environ 3 mois : import multi-sources, import par photo, mise à l'échelle. Il est allégé par le report du partage iCloud, des listes par lieu, de la planification des repas et du chat de modification (d19), par la priorisation des sources d'import (web et texte, puis photo) et par un point de décision à mi-parcours sur YouTube et Paprika (d20). | impact: élevé | probability: moyenne | mitigation: Livrer d'abord l'import par lien web et texte, puis la photo ; limiter la modification à la mise à l'échelle simple par nombre de portions ; vers 6 semaines, reporter YouTube et Paprika après la V1 si les imports web, texte et photo n'atteignent pas leurs objectifs (d20). | action: Tenir le point de décision à mi-parcours (environ 6 semaines) en mesurant les temps d'import web, texte et photo sur l'iPhone 15 Pro.
- [Technique] La qualité de l'IA embarquée Apple de l'iPhone 15 Pro reste incertaine sur les contenus longs ou bruités, notamment les photos de fiches manuscrites. L'iPhone 11 n'exécute pas l'app en V1 ; son absence d'IA Apple n'est donc plus un risque pour la V1. | impact: élevé | probability: moyenne | mitigation: Privilégier aussi les traitements locaux sans IA générative (pages web structurées, reconnaissance de texte), une correction manuelle rapide et une clé facultative. | action: Tester sur l'iPhone 15 Pro un échantillon de recettes texte, web et photo au regard des objectifs de 1 minute (texte et web) et de 2 minutes (photo).
- [Juridique] Incompatibilité GPL/AGPL avec l'App Store, et contributions externes sans CLA bloquant la double licence. | impact: élevé | probability: moyenne | mitigation: CLA dès la première contribution externe ; distribution App Store sous licence commerciale ou exception GPLv3 article 7. | action: Valider le schéma de licence avec un juriste avant publication.
- [Coût] Le repli externe passe par la clé de l'utilisateur, donc payée par le porteur pour l'usage du foyer. Ce coût n'apparaît que si l'IA embarquée de l'iPhone 15 Pro se révèle insuffisante ; l'iPhone 11 n'exécute pas l'app en V1. Sans clé, la correction manuelle peut compromettre les objectifs de 1 et 2 minutes. | impact: moyen | probability: faible | mitigation: Utiliser au maximum l'IA embarquée et les traitements locaux non génératifs. Garder la clé facultative et prévoir un écran de correction manuelle simple et rapide. | action: Estimer le volume d'appels externes résiduels pour une semaine type après les tests sur l'iPhone 15 Pro.
- [Confidentialité] Quand l'utilisateur active sa propre clé, des messages, de l'audio ou des photos sont envoyés au fournisseur qu'il a choisi. | impact: moyen | probability: faible | mitigation: Option désactivée par défaut ; écran unique à l'activation présentant les données envoyées et le fournisseur choisi, avec consentement explicite (d16) ; politique de confidentialité conforme au RGPD. | action: Lister les fournisseurs pris en charge et les données envoyées, puis rédiger le texte de l'écran d'activation.
- [Technique] Import YouTube limité par les conditions d'utilisation et l'accès aux sous-titres et descriptions. Source reportable après la V1 si le temps manque (d17). | impact: faible | probability: élevée | mitigation: Source de dernière priorité ; partage du lien et extraction de la description en priorité si elle est intégrée. | action: Vérifier la faisabilité à l'étape technique, seulement si YouTube entre en V1.
- [Technique] Avec une synchronisation dans un seul sens, l'app ne voit pas les coches ni les ajouts du foyer dans Rappels. Les règles retenues évitent l'écrasement, l'oubli et les quantités insuffisantes : ajout des articles absents, des articles seulement cochés et du complément de quantité, correspondance par nom normalisé, quantité complète si les unités ne se comparent pas, sans suppression ni modification. Un risque résiduel demeure. Des variantes de nom (« tomates » et « tomates cerises ») ou des unités non comparables peuvent produire des articles en double ou des quantités surestimées. | impact: faible | probability: moyenne | mitigation: Règles d'envoi d12, d13, d14 et d15 ; conversion entre unités comparables (g et kg, cl et l) ; libellés clairs pour repérer les doublons en magasin. | action: Préciser la conversion entre unités comparables et le traitement des variantes de nom à l'étape 2.

### Open Questions

- None.

### Stage Fields

- problem_statement: Organiser l'alimentation du foyer prend du temps. Les frictions citées sont le temps, l'organisation et la variété des repas. Aujourd'hui, la préparation de la liste de courses prend entre 10 et 30 minutes par semaine. Les recettes proviennent de sources hétérogènes (sites, livres, vidéos, dictée). Les listes de courses, notamment pour le marché, sont construites à partir de recettes et de messages reçus. La V1 cible les frictions de temps et d'organisation. Elle fournit une app iPhone qui importe et standardise les recettes, puis génère des listes de courses par catégorie, poussées vers Apple Rappels, en visant moins de 2 minutes par semaine type pour la liste (gain d'environ 8 à 28 minutes par semaine). La variété des repas sera traitée après la V1, avec la planification des repas.
- users_actors: ["Utilisateur principal (porteur du projet), qui importe les recettes et prépare les courses dans l'app ; cible de la V1", "L'autre membre du foyer : en V1, coche seulement une liste Apple Rappels partagée, sans utiliser l'app ; cible de la V1 ; partage iCloud plus tard", "Grand public via l'App Store : cible éventuelle, ultérieure à la V1", "Fournisseur d'IA externe choisi par l'utilisateur via sa propre clé (option désactivée par défaut)", 'Apple Rappels (réception des listes et partage avec le foyer)', 'iCloud (partage au sein du foyer, après la V1)']
- measurable_objectives: ["Liste de courses prête en moins de 2 minutes, mesurées de la sélection des recettes et des messages jusqu'à la liste disponible dans Apple Rappels, pour une semaine type (environ 5 recettes et 2 messages)", 'Une recette texte ou web importée et standardisée en moins de 1 minute, correction comprise', 'Une recette importée par photo (page de livre, magazine ou fiche manuscrite) et standardisée en moins de 2 minutes, correction comprise']
- constraints: ["iPhone uniquement en V1 ; Android plus tard, faute d'appareil de test", "Appareils V1 : l'app tourne sur l'iPhone 15 Pro (appareil du porteur) et les modèles ultérieurs, sous l'iOS actuel, avec l'IA embarquée Apple ; l'iPhone 11 sert seulement à cocher la liste Apple Rappels partagée, l'app n'y est pas nécessaire en V1", 'Accès externe pour les appareils plus anciens : non nécessaire au foyer en V1 ; prise en charge éventuelle à arbitrer en cas de publication grand public, après la V1', 'Échéance de la V1 : environ 3 mois', "Budget d'IA externe proche de zéro : aucun appel externe payé par le porteur", "Traitement et stockage local d'abord, avec l'IA embarquée Apple sur iPhone 15 Pro et ultérieur", "Repli d'IA : l'utilisateur peut brancher sa propre clé de fournisseur (option désactivée par défaut) ; sinon, correction manuelle", 'Activation de la clé de fournisseur : écran unique présentant les données envoyées et le fournisseur choisi, avec consentement explicite ; pas de confirmation à chaque envoi', 'Pas de compte utilisateur ; en V1, le foyer partage les courses via une liste Apple Rappels partagée ; partage iCloud après la V1', "Synchronisation avec Apple Rappels dans un seul sens en V1 : l'app pousse la liste vers Rappels ; les coches du foyer restent dans Rappels et ne remontent pas dans l'app", 'iOS ne permet pas de lire directement SMS, WhatsApp et Messenger : récupération par partage ou copier-coller', 'App gratuite a priori', 'Double licence (GPL ou AGPL + licence commerciale) avec CLA, compatible avec la distribution App Store']
- non_goals: ['Séparation des listes par magasin ou par lieu en V1 (fonctionnalité retenue, reportée après la V1)', 'Planification des repas avec catalogue de recettes en V1 (fonctionnalité retenue, reportée après la V1)', 'Réponse à la variété des repas en V1 (traitée avec la planification des repas, après la V1)', "Chat de modification des recettes par IA en V1 (reporté après la V1 ; la V1 garde la mise à l'échelle simple par nombre de portions)", 'Ordre de visite optimisé des magasins ou lieux en V1', 'Suivi des stocks de la maison (et ajustement par photo) en V1', 'Version Android en V1', "Partage de recettes et de listes via iCloud dans l'app en V1"]
- hypotheses: ["L'IA embarquée Apple, disponible sur l'iPhone 15 Pro du porteur et les modèles ultérieurs, suffit pour standardiser la majorité des recettes texte (confirmée par l'utilisateur ; tests prévus sur l'iPhone 15 Pro avant le point des 6 semaines)", "Les messages externes seront partagés vers l'app via l'extension de partage iOS ou le copier-coller (confirmée par l'utilisateur)", "Le binaire de l'App Store peut être distribué sous licence commerciale ou avec une exception App Store (confirmée par l'utilisateur ; avis juridique prévu avant publication)", "Une liste Apple Rappels partagée suffit pour que l'autre membre du foyer consulte et coche les courses en V1, sans installer l'app (confirmée par l'utilisateur)", "Une synchronisation dans un seul sens suffit : l'utilisateur principal n'a pas besoin de voir dans l'app les coches ou ajouts du foyer (confirmée par l'utilisateur)", "L'export Paprika est exploitable pour importer des recettes existantes, si l'import Paprika entre en V1 (confirmée par l'utilisateur ; format à vérifier si Paprika entre en V1)", "« L'accès externe pour les plus anciens » correspond à la clé de fournisseur branchée par l'utilisateur ; il n'est pas nécessaire au foyer en V1 (confirmée par l'utilisateur)"]
- initial_risks: ["Périmètre V1 encore large pour une échéance d'environ 3 mois (allégé par le report du partage iCloud, des listes par lieu, de la planification des repas et du chat de modification, et par la priorisation des imports : web et texte, puis photo ; YouTube et Paprika reportables)", "Qualité de l'IA locale de l'iPhone 15 Pro incertaine sur les contenus bruités ; sans clé utilisateur, correction manuelle nécessaire", "Coût de la clé externe pour le porteur si l'IA embarquée de l'iPhone 15 Pro se révèle insuffisante, à arbitrer avec un budget proche de zéro", "Incompatibilité GPL/AGPL avec l'App Store et contributions sans CLA", "Effort de correction manuelle incompatible avec les objectifs de 1 et 2 minutes quand l'IA locale échoue", "Confidentialité des données envoyées au fournisseur choisi par l'utilisateur lorsqu'il active sa clé", 'Import YouTube limité techniquement et juridiquement (source reportable après la V1)', "Doublons ou quantités surestimées lors d'un nouvel envoi vers une liste Rappels existante, en cas de variantes de nom ou d'unités non comparables. Règle retenue : correspondance par nom normalisé, ajout des articles absents, des articles seulement cochés et du complément de quantité, quantité complète si les unités ne se comparent pas, sans suppression ni modification."]
- five_w_one_h: Qui : l'utilisateur principal dans l'app et l'autre membre du foyer, qui coche une liste Apple Rappels partagée en V1 (partage iCloud plus tard) ; le grand public est une cible éventuelle, ultérieure. Quoi : une app de recettes (import priorisé : lien web et texte collé ou partagé, puis photo ; YouTube et Paprika reportés après la V1 si le temps manque ; import depuis les messages ; extraction IA dans un format standard ; mise à l'échelle simple selon le nombre de portions ; suivi pas à pas ; chat de modification après la V1) et de listes de courses fusionnées depuis plusieurs recettes, cochables, regroupées par catégorie ou par rayon. Listes par magasin ou par lieu et planification des repas reportées après la V1. Quand : V1 dans environ 3 mois. Où : app sur iPhone 15 Pro et modèles ultérieurs sous l'iOS actuel ; l'iPhone 11 sert seulement à cocher la liste Rappels partagée, sans l'app en V1 ; pour les courses au marché et en magasin. Pourquoi : en V1, réduire le temps passé et mieux s'organiser ; la préparation de la liste prend aujourd'hui 10 à 30 minutes par semaine ; la variété des repas viendra après la V1 avec la planification. Cibles : une liste de courses prête en moins de 2 minutes, une recette texte ou web standardisée en moins de 1 minute et une recette photo standardisée en moins de 2 minutes, correction comprise. Comment : traitement local d'abord avec l'IA embarquée Apple ; aucun coût d'IA externe pour le porteur, avec un repli via la clé de fournisseur de l'utilisateur (désactivé par défaut, écran de consentement unique), sinon correction manuelle ; listes poussées dans un seul sens vers Apple Rappels et partagées au foyer via Rappels ; import par partage iOS.

### Readiness

- 11/11 passed/total
- [x] field:problem_statement: Required field problem_statement: clear
- [x] field:users_actors: Required field users_actors: clear
- [x] field:measurable_objectives: Required field measurable_objectives: clear
- [x] field:constraints: Required field constraints: clear
- [x] field:non_goals: Required field non_goals: clear
- [x] field:hypotheses: Required field hypotheses: clear
- [x] field:initial_risks: Required field initial_risks: clear
- [x] field:five_w_one_h: Required field five_w_one_h: clear
- [x] measurable_objectives: Every objective needs an explicit numeric target or metric value.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- problem_statement: clear
- users_actors: clear
- measurable_objectives: clear
- constraints: clear
- non_goals: clear
- hypotheses: clear
- initial_risks: clear
- five_w_one_h: clear

### Clarifications

- 2026-11-21T18:49:36.219319+01:00: Quels critères chiffrés indiqueront que la V1 est réussie ? -> Quels critères chiffrés indiqueront que la V1 est réussie ?
Liste de courses prête en moins de 2 minutes à partir des recettes et messages
- 2026-11-22T00:11:03.795334+01:00: Quelle échéance et quel budget pour la V1, y compris le plafond mensuel de l'IA externe ? -> Quelle échéance et quel budget pour la V1, y compris le plafond mensuel de l'IA externe ?
Échéance dans environ 3 mois, budget IA externe proche de zéro
- 2026-11-22T00:11:03.795344+01:00: Pouvez-vous résumer le projet en qui, quoi, où, quand, pourquoi et comment ? -> Quelle échéance et quel budget pour la V1, y compris le plafond mensuel de l'IA externe ?
Échéance dans environ 3 mois, budget IA externe proche de zéro
- 2026-11-22T00:13:40.040107+01:00: Quel rôle joue le foyer en V1, maintenant que le partage iCloud sans compte est retenu ? -> Quel rôle joue le foyer en V1, maintenant que le partage iCloud sans compte est retenu ?
Ils cochent seulement une liste Rappels partagée ; le partage iCloud vient plus tard
- 2026-11-22T00:20:53.529787+01:00: Listes par magasin ou par lieu et planification des repas : V1 ou plus tard ? -> Listes par magasin ou par lieu et planification des repas : V1 ou plus tard ?
Les deux plus tard, la V1 reste sur recettes et listes par catégorie
- 2026-11-22T00:20:53.529797+01:00: Ces informations se contredisent : La fonctionnalité retenue « Listes séparées par magasin ou par lieu » contredit la décision d1 et le non-objectif « Séparation des listes par lieu en V1 ». Il faut préciser si elle entre en V1 ou reste pour plus tard.. Laquelle est la bonne ? -> Listes par magasin ou par lieu et planification des repas : V1 ou plus tard ?
Les deux plus tard, la V1 reste sur recettes et listes par catégorie
- 2026-11-22T00:28:36.415651+01:00: Avec un budget d'IA externe proche de zéro, comment fonctionne le repli quand l'IA locale ne suffit pas ? -> Avec un budget d'IA externe proche de zéro, comment fonctionne le repli quand l'IA locale ne suffit pas ?
L'utilisateur peut brancher sa propre clé de fournisseur (désactivé par défaut), sinon correction manuelle
- 2026-11-22T00:30:47.932371+01:00: Comment mesurer l'objectif des 2 minutes : point de départ, point d'arrivée et volume de référence ? -> Comment mesurer l'objectif des 2 minutes : point de départ, point d'arrivée et volume de référence ?
De la sélection des recettes et messages jusqu'à la liste disponible dans Rappels, pour une semaine type (environ 5 recettes et 2 messages)
- 2026-11-22T00:35:39.848662+01:00: Synchronisation avec Apple Rappels : dans un seul sens (app vers Rappels) ou dans les deux sens ? -> Synchronisation avec Apple Rappels : dans un seul sens (app vers Rappels) ou dans les deux sens ?
Un seul sens : l'app pousse la liste vers Rappels, les coches du foyer restent dans Rappels
- 2026-11-22T00:42:07.644070+01:00: Quel objectif chiffré pour le volet recettes ? -> Quel objectif chiffré pour le volet recettes ?
Une recette texte ou web importée et standardisée en moins de 1 minute, correction comprise
- 2026-11-22T00:50:29.776383+01:00: Quel problème le projet résout-il, et pour qui ? -> 1. temps, organisation, variété des repas
2. moi et mon foyer. fludifier les course
3. iphone 15 et 11; ios actuel, avec un acces externe pour les plus anciens.
- 2026-11-22T00:50:29.776389+01:00: Qui sont les utilisateurs, et quelles autres personnes ou quels systèmes sont concernés ? -> 1. temps, organisation, variété des repas
2. moi et mon foyer. fludifier les course
3. iphone 15 et 11; ios actuel, avec un acces externe pour les plus anciens.
- 2026-11-22T00:50:29.776391+01:00: Quelles contraintes s'appliquent (budget, délai, réglementation, technique) ? -> 1. temps, organisation, variété des repas
2. moi et mon foyer. fludifier les course
3. iphone 15 et 11; ios actuel, avec un acces externe pour les plus anciens.
- 2026-11-22T00:53:02.314620+01:00: La V1 doit-elle déjà répondre à la variété des repas ? -> La V1 doit-elle déjà répondre à la variété des repas ?
Hors V1 : la variété viendra avec la planification des repas
- 2026-11-22T01:06:18.507092+01:00: Votre iPhone 15 est-il un modèle Pro, et que faire sur les appareils sans IA embarquée Apple ? -> iphone 15 pro et ulterieur
- 2026-11-22T01:06:18.507101+01:00: Ces informations se contredisent : L'approche « traitement local d'abord avec l'IA embarquée Apple » (d2, contraintes) ne fonctionne pas sur l'iPhone 11. Si l'iPhone 15 n'est pas un modèle Pro, elle ne fonctionne sur aucun des deux appareils cibles, car Apple Intelligence et le framework Foundation Models exigent un iPhone 15 Pro ou plus récent. La voie externe deviendrait alors la voie principale. Or elle passe par une clé payée par l'utilisateur, c'est-à-dire par vous, ce qui contredit un budget d'IA externe proche de zéro.. Laquelle est la bonne ? -> iphone 15 pro et ulterieur
- 2026-11-22T01:09:33.405562+01:00: Combien de temps passez-vous aujourd'hui, par semaine, à préparer la liste de courses ? -> Combien de temps passez-vous aujourd'hui, par semaine, à préparer la liste de courses ?
Entre 10 et 30 minutes
- 2026-11-22T06:23:01.005086+01:00: Que doit faire l'iPhone 11 en V1 ? -> Que doit faire l'iPhone 11 en V1 ?
Il sert seulement à cocher la liste Rappels partagée : l'app n'y est pas nécessaire en V1
- 2026-11-22T07:11:57.661062+01:00: Quand vous renvoyez une liste vers une liste Rappels existante, que doit faire l'app ? -> Quand vous renvoyez une liste vers une liste Rappels existante, que doit faire l'app ?
Ajouter seulement les articles absents, sans rien supprimer
- 2026-11-22T09:24:43.335074+01:00: Si un article à envoyer est déjà dans la liste Rappels mais coché, que doit faire l'app ? -> Si un article à envoyer est déjà dans la liste Rappels mais coché, que doit faire l'app ?
Le rajouter comme nouvel article non coché
- 2026-11-22T09:54:16.174089+01:00: Si un article à envoyer est déjà dans la liste Rappels, non coché, mais avec une autre quantité, que doit faire l'app ? -> Si un article à envoyer est déjà dans la liste Rappels, non coché, mais avec une autre quantité, que doit faire l'app ?
Ajouter un nouvel article avec la quantité supplémentaire
- 2026-11-22T10:00:30.056799+01:00: Comment l'app doit-elle reconnaître qu'un article est déjà dans la liste Rappels ? -> Comment l'app doit-elle reconnaître qu'un article est déjà dans la liste Rappels ?
Même nom normalisé (singulier/pluriel, accents, majuscules) ; si les unités ne se comparent pas, ajouter un nouvel article avec la quantité complète
- 2026-11-22T10:08:51.415543+01:00: Quand un utilisateur active sa propre clé de fournisseur, que doit afficher l'app ? -> Quand un utilisateur active sa propre clé de fournisseur, que doit afficher l'app ?
Un écran unique à l'activation : données envoyées, fournisseur choisi, consentement explicite
- 2026-11-22T10:11:46.156854+01:00: Quelles sources d'import de recettes doivent impérativement être dans la V1 ? -> Quelles sources d'import de recettes doivent impérativement être dans la V1 ?
Lien web et texte collé ou partagé d'abord ; photo ensuite ; YouTube et Paprika après la V1 si le temps manque
- 2026-11-22T10:14:17.008247+01:00: Quel objectif chiffré pour l'import d'une recette par photo ? -> Quel objectif chiffré pour l'import d'une recette par photo ?
Moins de 2 minutes par recette, correction comprise
- 2026-11-22T10:17:36.155072+01:00: Le chat de modification et la mise à l'échelle des recettes font-ils partie de la V1 ? -> Le chat de modification et la mise à l'échelle des recettes font-ils partie de la V1 ?
Mise à l'échelle simple (nombre de portions) en V1, chat de modification après la V1
- 2026-11-22T10:19:31.504967+01:00: Quand et sur quel critère décider du report de YouTube et Paprika après la V1 ? -> Quand et sur quel critère décider du report de YouTube et Paprika après la V1 ?
Point à mi-parcours (environ 6 semaines) : si les imports web, texte et photo n'atteignent pas leurs objectifs, YouTube et Paprika sont reportés
- 2026-11-22T10:31:23.707618+01:00: Sur quelles hypothèses, encore à vérifier, le projet repose-t-il ? -> je confirme les hypothese 1 à 7.

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.


## Benchmark

Version: 1

### Facts (sourced snippets)
- [RecipeAI](<https://recipeai.ai/>): According to its search snippet, a recipe app for iPhone and Android that saves recipes from social video platforms, websites, messages and copied text into a single library. It also converts photographed recipes into digital recipes with AI.
  - Evidence: https://recipeai.ai/
  - Import from Instagram, TikTok, YouTube, Facebook and Pinterest
  - Import from websites, messages and copied text
  - Photo import of cookbooks, magazines and handwritten notes
  - AI conversion of photographed recipes into digital recipes
  - Single recipe library
- [Pluck](<https://pluckrecipes.com/>): According to its search snippet, an iOS and Android app that accepts recipe links from social platforms and food blogs. It uses AI to extract ingredients and steps into a searchable recipe box.
  - Evidence: https://pluckrecipes.com/
  - Paste a recipe link from Instagram, TikTok, YouTube or food blogs
  - AI extraction of ingredients and steps
  - Searchable recipe box
- [Cooklist](<https://www.youtube.com/watch?v=Vh2CoQstETg>): According to a 2023 promotional video snippet, the Cooklist app imports recipes from a snapped photo or an uploaded image.
  - Evidence: https://www.youtube.com/watch?v=Vh2CoQstETg
  - Recipe import from a camera photo
  - Recipe import from an uploaded image
- [BiteCaddy](<https://bitecaddy.co/features/recipe-import>): According to its feature page snippet, BiteCaddy saves recipes from TikTok or YouTube links, cookbook photos or website URLs. It automatically extracts ingredients, steps and USDA nutrition data.
  - Evidence: https://bitecaddy.co/features/recipe-import
  - Import from TikTok and YouTube links
  - Photo import of cookbook pages
  - Import from cooking\-site URLs
  - Automatic extraction of ingredients and steps
  - USDA nutrition information
- [mise](<https://trymise.app/>): According to its search snippet, an iPhone app that imports recipes from websites, YouTube, photos and Paprika. Users can chat with AI to scale or modify recipes and use a distraction\-free cooking view.
  - Evidence: https://trymise.app/
  - Import from websites, YouTube and photos
  - Import from Paprika
  - AI chat to scale or modify recipes
  - Distraction\-free cooking
- [Yummi \- Recipe Manager](<https://apps.apple.com/us/app/yummi-recipe-manager/id6741091088>): According to its App Store listing snippet, a recipe manager that organizes recipes by category, syncs with Reminders and syncs recipes across devices via iCloud.
  - Evidence: https://apps.apple.com/us/app/yummi-recipe-manager/id6741091088
  - Organization by category
  - Sync with Reminders
  - iCloud sync across devices
- [recipe.sync](<https://apps.apple.com/us/app/recipe-sync/id6756237806>): According to its App Store listing snippet, recipe.sync turns recipes into timed, step\-by\-step plans. It adds a grocery list built from recipe ingredients after a quick review, organized by aisle and sendable to another list app.
  - Evidence: https://apps.apple.com/us/app/recipe-sync/id6756237806
  - Timed step\-by\-step cooking plan
  - Grocery list from recipe ingredients after a quick review
  - Shopping by aisle
  - Sending the list to another app the user already uses
  - Support for cooking with several people or alone
- [Apple Reminders \(grocery list\)](<https://support.apple.com/guide/iphone/make-a-grocery-list-iph80ba26e1f/ios>): According to Apple's support guide snippet, the Reminders app on iPhone can make a grocery list that automatically sorts items into categories, with adjustable grouping.
  - Evidence: https://support.apple.com/guide/iphone/make-a-grocery-list-iph80ba26e1f/ios
  - Grocery list in Reminders
  - Automatic sorting of items into categories
  - Changeable grouping of items
- [Recipe Notes](<https://recipenotes.app/help/enable-reminders-permission>): According to a help page snippet, Recipe Notes can sync with iOS Reminders for shopping lists and meal planning once permission is granted.
  - Evidence: https://recipenotes.app/help/enable-reminders-permission
  - Sync with iOS Reminders for shopping lists
  - Meal planning
- [Aisle](<https://www.aisle-grocery.com/>): According to its search snippet, a shared grocery\-list app for iPhone with one household list edited in real time and organized by aisle. It states it has no accounts and no ads, with data kept in the user's iCloud.
  - Evidence: https://www.aisle-grocery.com/
  - Shared household list with real\-time editing
  - Organization by aisle
  - No accounts
  - No ads
  - Data stored in the user's iCloud
- [Shared Grocery List: Shopping](<https://apps.apple.com/us/app/shared-grocery-list-shopping/id6747925662>): According to its App Store listing snippet, an app to create, manage and share shopping lists, including unlimited lists for different events, stores or households.
  - Evidence: https://apps.apple.com/us/app/shared-grocery-list-shopping/id6747925662
  - Unlimited shopping lists
  - Separate lists per event, store or household
  - List sharing
- [Shared Grocery List Organizer](<https://apps.apple.com/us/app/shared-grocery-list-organizer/id771220733>): According to its App Store listing snippet, a shopping list app aimed at US shoppers. It arranges products by supermarket aisle and lets users share lists with family and friends.
  - Evidence: https://apps.apple.com/us/app/shared-grocery-list-organizer/id771220733
  - Arrangement of products by aisle
  - Product knowledge for US supermarkets
  - Sharing with family and friends
- [HopDrop](<https://hop-drop.app/>): According to its search snippet, a shared grocery list app for iPhone and Android with drag\-and\-drop lists, a self\-restocking pantry, recipes based on what users have and shared to\-dos.
  - Evidence: https://hop-drop.app/
  - Shared grocery lists
  - Drag\-and\-drop lists
  - Self\-restocking pantry
  - Recipe suggestions from available items
  - Shared to\-dos
- [recipe\-to\-grocery\-list](<https://github.com/lukefwalton/recipe-to-grocery-list>): According to its GitHub repository snippet, a local\-first iOS app that turns recipes into one merged, checkable grocery list. Recipes can come from a shared link, pasted text or a photographed page, and users confirm ingredients and pick what they are cooking.
  - Evidence: https://github.com/lukefwalton/recipe-to-grocery-list
  - Local\-first iOS app
  - Recipe input via shared link, pasted text or photo of a page
  - Ingredient confirmation step
  - Selection of the recipes to cook
  - Single merged, checkable grocery list
  - Pricing (as reported): Described as free in the repository title \(not verified\)
- [apple/coreai\-models](<https://github.com/apple/coreai-models>): According to its GitHub snippet and a third\-party article snippet, an Apple repository of model export recipes, Python primitives and guidance for running models on\-device on Apple platforms. It is a developer toolkit, not a consumer app.
  - Evidence: https://github.com/apple/coreai-models
  - Evidence: https://aibit.im/en/article/apple-core-ai-models-export-recipes-python-primitives-swift-runtime
  - Guidance for authoring PyTorch models for on\-device execution
  - Model export recipes
  - Swift runtime utilities \(per third\-party article\)
- [Ladle & Crumb](<https://ladleandcrumb.com/>): According to its search snippet, a family meal planner with 1,800\+ recipes and a pantry\-aware shopping list. Groceries can be sent to a store for pickup or delivery.
  - Evidence: https://ladleandcrumb.com/
  - Family meal planning
  - Catalog of 1,800\+ recipes
  - Single shopping list that accounts for the pantry
  - Sending groceries to a store for pickup or delivery
- [MealNite](<https://www.mealnite.com/>): According to its search snippet, a family app combining meal planning, nutrition tracking, grocery lists, social cooking and health goals.
  - Evidence: https://www.mealnite.com/
  - Meal planning
  - Nutrition tracking
  - Grocery lists
  - Social cooking
  - Health goals
- [Family Pantry](<https://familypantry.us/>): According to its search snippet, a family dinner planner with a combined grocery list, a free weekly planner and grocery budgeting based on the user's own prices.
  - Evidence: https://familypantry.us/
  - Family dinner planning
  - Combined grocery list
  - Free weekly planner
  - Grocery budget using user\-entered prices
  - Pricing (as reported): A free weekly planner is mentioned; other pricing unknown

### Assumptions (to confirm)
- All product descriptions come from search snippets only and were not independently verified; actual capabilities may differ.
- Pricing is unknown for almost all products because the snippets do not state it.
- The snippets do not indicate whether the observed AI features run on\-device or in the cloud.
- Recommendations \(adopt, adapt, skip\) are hypotheses for the owner to review, not selections made on the owner's behalf.
- Skip recommendations for stock tracking and per\-location lists are inferred from the V1 non\-goals in the framing.
- Aisle\- and category\-based products appear oriented toward supermarkets, mainly in the US; their fit for open\-air markets is assumed to be limited.
- The Reddit post is a developer's self\-description of an unnamed app and is used only as weak supporting evidence.
- Multi\-source recipe import \(website link, pasted or shared text, YouTube link\): adopt — Hypothesis: several products' snippets describe this import pattern, and it matches the owner's stated V1 recipe sources. Snippets do not show how YouTube content is actually extracted \(link, description or subtitles\).
- Recipe import from a photo of a cookbook page, magazine or handwritten card: adopt — Hypothesis: photo import appears frequently in the snippets and matches a stated owner need. Whether this can be done fully on\-device with acceptable quality is not established by the evidence.
- AI extraction of ingredients and steps into a standardized recipe format: adopt — Hypothesis: these snippets describe AI\-based structuring, which corresponds to the owner's AI standardization goal. The snippets do not say whether processing is local or cloud\-based.
- Import of recipes received in messages or as copied text: adopt — Hypothesis: RecipeAI's snippet mentions messages and copied text as sources. This aligns with the owner's plan to use the iOS share extension or copy\-paste, since iOS does not allow direct reading of messaging apps.
- Step\-by\-step cooking mode \(timed or distraction\-free\): adopt — Hypothesis: both snippets describe a guided or distraction\-free cooking view, matching the owner's step\-by\-step follow\-up requirement. Timers are observed only for recipe.sync.
- AI\-assisted recipe modification and scaling via chat: adapt — Hypothesis: the owner wants recipe editing. Chat\-based modification is one observed approach, but its feasibility with local AI is uncertain.
- Ingredient review and confirmation before adding to the grocery list: adopt — Hypothesis: a review step could reduce errors from AI extraction before items reach the list, which may matter if local AI quality is variable.
- Single merged, checkable grocery list from several selected recipes: adopt — Hypothesis: merging recipes into one list may support the owner's 'rationalize shopping' goal. Whether merging includes quantity aggregation and deduplication is not detailed in the snippets.
- Grocery list sync with Apple Reminders: adopt — Hypothesis: Reminders sync is observed in several apps and is an explicit owner requirement. recipe.sync's snippet only says it sends the list to another app, without naming Reminders.
- Automatic grouping of list items by category or aisle: adapt — Hypothesis: category grouping is part of the owner's V1. Observed products target supermarket aisles, mostly in a US context, so categories may need adapting for market stalls. Apple Reminders' own categorization might be reused if Reminders sync is used.
- Household sharing via iCloud without user accounts: adapt — Hypothesis: an account\-free, iCloud\-based approach could suit the local\-first and free model. Whether to rely on shared Apple Reminders lists or the app's own sync remains an open owner decision.
- Local\-first processing and storage: adopt — Hypothesis: these snippets describe local\-first or iCloud\-only data handling, consistent with the owner's preference for on\-device processing. The scope of local AI in these products is not stated.
- On\-device model tooling for Apple platforms: adapt — Hypothesis: this toolkit may help run recipe\-standardization models locally. Its suitability, device requirements and maturity are not established by the snippets.
- Import from an existing recipe manager \(Paprika\): adapt — Hypothesis: migration import could help public adoption, but it is not among the owner's stated V1 sources.
- Separate lists per store or location: skip — Hypothesis: separation by location is listed as a V1 non\-goal in the framing, so it may be deferred. It remains relevant for later versions.
- Pantry\-aware lists and self\-restocking pantry: skip — Hypothesis: home stock tracking is a V1 non\-goal in the framing. These products could inform a later stock\-tracking phase.
- Nutrition information \(USDA data\): skip — Hypothesis: nutrition is not among the owner's stated goals. USDA data is also US\-oriented.
- Meal planning with a recipe catalog: skip — Hypothesis: meal planning is not explicitly part of the owner's V1 scope.
- Sending groceries to a store for pickup or delivery: skip — Hypothesis: this does not match the market\-focused, local\-first use case. It would also likely require external service integrations.

### Decisions (owner selected)
- Multi\-source recipe import \(website link, pasted or shared text, YouTube link\)
- Recipe import from a photo of a cookbook page, magazine or handwritten card
- AI extraction of ingredients and steps into a standardized recipe format
- Import of recipes received in messages or as copied text
- AI\-assisted recipe modification and scaling via chat
- Single merged, checkable grocery list from several selected recipes
- Grocery list sync with Apple Reminders
- Automatic grouping of list items by category or aisle
- Household sharing via iCloud without user accounts
- Local\-first processing and storage
- On\-device model tooling for Apple platforms
- Import from an existing recipe manager \(Paprika\)
- Separate lists per store or location
- Meal planning with a recipe catalog

### Open questions
- Which candidate features does the owner want to select for V1?
- Should list categories rely on Apple Reminders' automatic grocery categorization or on the app's own category model?
- Should household sharing rely on shared Apple Reminders lists or on the app's own iCloud sync?
- How should YouTube recipes be extracted \(link metadata, description or subtitles\), given the observed products do not detail this?
- Is local on\-device AI sufficient for photo and noisy\-text recipe extraction, or is an external fallback needed?
- Should merged lists aggregate quantities and deduplicate ingredients across recipes?
- Is a review and confirmation step required before ingredients are added to the list?
- Does recipe\-to\-grocery\-list's open\-source license allow reuse or inspiration under the planned dual\-licensing model?
