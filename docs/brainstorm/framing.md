> **Révisé le 22/11/2026 :** export d'origine, conservé pour l'historique. En cas d'écart, [revision.md](revision.md) et `delivery/` l'emportent.

# Brainstorm Session Export

- Session ID: `3777ae1a-e286-4185-9d94-3d8fa6bee5b4`
- Current stage: `stage_7_delivery_slicing`
- Pending human review: `False`

## Conversation Summary

- Message count: `133`
- Open questions: `5`

## Stage 0 - Initial Pitch

# Structured Summary

## Stage 0 - Initial Pitch

Application iPhone unique (Android dans un second temps) d'organisation de l'alimentation du foyer, pour l'utilisateur et son foyer, éventuellement le grand public via l'App Store. La première version porte en priorité sur deux volets : les recettes (import multi-sources, standardisation par IA, édition, suivi pas à pas) et les listes de courses (générées depuis audio, chat ou messages reçus, et depuis les recettes, synchronisées avec Apple Rappels). Le suivi des stocks n'est pas cité comme prioritaire. Le parcours optimisé signifie l'ordre de visite des magasins ou lieux, prévu pour plus tard, avec des listes séparées par lieu et par catégorie. Traitement local privilégié, gratuit a priori, double licence. Restent ouverts : le moment où les listes séparées par lieu et catégorie arrivent, le recours éventuel à une IA externe, le choix de la licence libre, le détail des stocks et le partage au sein du foyer.

# Open Questions and Uncertainties

- Moment d'arrivée des listes séparées par lieu et par catégorie : dès la première version ou plus tard ; définition des catégories ; mode de saisie des commerces fréquents.
- Place du suivi des stocks : il n'est pas cité dans la priorité de la V1, ce qui reste à confirmer.
- Standardisation IA des recettes : faisable en local sur l'iPhone, ou recours acceptable à un service externe (coût, confidentialité).
- Mode d'import depuis YouTube (lien, description, sous-titres) et conformité aux conditions d'utilisation.
- Granularité du suivi des stocks (présence, quantités, péremption) et mode de mise à jour (manuel, après les courses, par photo).
- Licence libre précise (GPL, AGPL, MPL…) et gestion des contributions externes (CLA) compatibles avec la double licence et l'App Store.
- Mode de récupération des messages WhatsApp, Messenger et SMS : extension de partage ou copier-coller, puisque iOS interdit la lecture directe.
- Partage des listes et des recettes entre membres du foyer : listes partagées d'Apple Rappels, synchronisation propre ou iCloud.
- Modèles d'iPhone et versions d'iOS minimaux, compte tenu du traitement local (transcription, extraction et standardisation IA).

## Open Questions

- Les listes séparées par lieu et par catégorie font-elles partie de la première version ?: Cela fixe le contenu exact de la V1. La séparation par lieu exige de saisir les commerces fréquents dès le départ ; la séparation par catégorie ne demande aucune configuration. | Options: ['Oui, par catégorie seulement ; les lieux plus tard', 'Oui, par lieu et par catégorie dès la V1', 'Non, une liste simple en V1 ; séparation plus tard'] | Recommended: Oui, par catégorie seulement ; les lieux plus tard
- Quelle licence libre copyleft envisagez-vous pour la double licence ?: Le choix conditionne la publication sur l'App Store (incompatibilités connues avec la GPL), la gestion des contributions (CLA nécessaire pour garder la double licence) et la commercialisation future. | Options: ['GPLv3 + licence commerciale', 'AGPLv3 + licence commerciale', 'MPL 2.0 + licence commerciale', 'Pas encore décidé : à étudier plus tard'] | Recommended: none
- Pour la standardisation des recettes par IA, un service externe est-il acceptable ?: L'IA embarquée est limitée aux iPhone récents et traite moins bien les contenus longs ou bruités. Un service externe implique des coûts et fait sortir les données de l'appareil (confidentialité). | Options: ['Local uniquement, avec correction manuelle', 'Local par défaut, service externe optionnel désactivé par défaut', 'Service externe accepté si nécessaire'] | Recommended: Local par défaut, service externe optionnel désactivé par défaut

# Questions to Continue

- Les listes séparées par lieu et par catégorie font-elles partie de la première version ?
- Quelle licence libre copyleft envisagez-vous pour la double licence ?
- Pour la standardisation des recettes par IA, un service externe est-il acceptable ?

# Stage Deliverable

## Stage 0 - Initial Pitch

### Facts

- Le produit est une application pour téléphone.
- L'application génère des listes, spécialement des listes de courses pour le marché, à partir d'une discussion ou d'un chat.
- Le résultat doit être synchronisé dans l'app de rappels par défaut du téléphone, au minimum sur iPhone.
- L'objectif est de gagner du temps et de rationaliser les courses au marché à partir de discussions.
- Les listes de courses doivent pouvoir être générées à partir de recettes, en récupérant leurs ingrédients.
- Le projet inclut un volet recettes, intégré dans la même application que les listes de courses.
- Les recettes doivent pouvoir être importées depuis des sites web, du texte collé ou partagé, des photos de livres ou de fiches, de l'audio (dictée), YouTube, etc.
- Les recettes doivent pouvoir être modifiées facilement.
- Les recettes doivent pouvoir être suivies étape par étape.
- L'application doit permettre de suivre les stocks alimentaires de la maison.
- L'ajustement des stocks à partir de photos du frigo et des placards est envisagé de façon éventuelle (optionnelle).
- Les utilisateurs cibles sont l'utilisateur lui-même et son foyer.
- Une publication pour le grand public sur l'App Store est envisagée de façon éventuelle.
- L'application doit être sous double licence : une licence libre et contaminante (copyleft), et une licence permettant une éventuelle commercialisation.
- L'application sera a priori gratuite.
- Les sources des listes sont un audio ou un chat enregistré dans l'app, et des messages reçus par SMS, WhatsApp, Messenger, etc.
- L'iPhone est la plateforme initiale. Android viendra dans un second temps, une fois l'app disponible et stable sur iPhone.
- L'utilisateur ne dispose pas d'appareil Android pour tester.
- L'app doit utiliser au maximum les capacités locales de l'iPhone pour limiter les appels externes payants.
- Idéalement, l'application prend en compte les commerces fréquentés pour proposer un parcours de courses optimisé.
- L'IA sera utilisée pour mettre en forme et standardiser les recettes importées.
- Toutes les fonctionnalités (listes, recettes, stocks, parcours) doivent être réunies dans une seule application.
- La première version porte en priorité sur les recettes et les listes de courses.
- Le « parcours optimisé » désigne l'ordre de visite des magasins ou lieux de courses. Il est prévu pour plus tard.
- Les listes de courses doivent pouvoir être séparées par lieu et par catégorie.

### Assumptions

- None explicitly recorded.

### Decisions

- Ajouter au projet un volet application de recettes : import, édition, suivi pas à pas, génération de listes de courses et suivi des stocks. (Décision exprimée par l'utilisateur après réflexion.)
- Première version sur iPhone uniquement ; Android dans un second temps. (Pas de matériel Android pour tester ; priorité à la stabilité sur iPhone.)
- Double licence : une licence libre copyleft et une licence autorisant une commercialisation future. Gratuit a priori. (Choix exprimé par l'utilisateur pour garder l'ouverture et une option de commercialisation.)
- Privilégier le traitement local sur l'iPhone et limiter les appels à des services externes. (Éviter les coûts des appels externes payants.)
- Une seule application regroupe listes de courses, recettes, stocks et parcours de courses. (Choix exprimé explicitement par l'utilisateur.)
- Les recettes importées sont mises en forme et standardisées par IA. (Choix exprimé par l'utilisateur pour unifier des sources hétérogènes.)
- La première version est centrée sur les recettes et les listes de courses. L'ordre de visite des magasins est reporté à plus tard. (Choix exprimé explicitement par l'utilisateur.)

### Risks

- [technical] Sur iOS, une application tierce ne peut pas lire directement les conversations de WhatsApp, Messenger ou iMessage/SMS, alors que ces messages font partie des sources souhaitées. | impact: high | probability: high | mitigation: Prévoir une extension de partage iOS et le copier-coller pour les messages reçus. L'audio et le chat sont, eux, enregistrés directement dans l'app. | action: Valider avec l'utilisateur que le passage par le menu « Partager » est acceptable.
- [scope] Même réduite aux recettes et aux listes, la première version reste large : import multi-sources avec IA, génération de listes depuis audio, chat, messages et recettes, synchronisation avec Rappels. Le projet risque de tarder à livrer une première version utile. | impact: high | probability: medium | mitigation: Ordonner les sources d'import et de génération au sein de la V1, et livrer d'abord un parcours de bout en bout minimal (recette → liste → Rappels). | action: Définir le premier parcours de bout en bout lors du cadrage du problème.
- [technical] L'import de recettes depuis des sites, du texte, des photos, l'audio et YouTube, ainsi que l'ajustement des stocks par photo, reposent sur des extractions et des reconnaissances peu fiables. | impact: medium | probability: high | mitigation: Étaler les sources d'import sur plusieurs versions, en commençant par les plus fiables (pages web structurées, texte collé). Prévoir une validation et une correction manuelles après la standardisation IA. | action: Ordonner les sources d'import une fois le volet prioritaire choisi.
- [technical] La transcription audio, l'extraction d'articles et la standardisation des recettes par IA embarquée exigent des iPhone et des versions d'iOS récents, avec une qualité parfois inférieure aux services externes. | impact: medium | probability: medium | mitigation: Définir un iPhone et une version d'iOS minimaux. Prévoir une correction manuelle, et éventuellement un service externe optionnel désactivé par défaut. | action: Clarifier les appareils cibles et accepter ou non un recours externe optionnel.
- [legal] La double licence exige de détenir les droits sur tout le code. Les licences GPL sont réputées incompatibles avec les conditions de distribution de l'App Store. | impact: medium | probability: medium | mitigation: Mettre en place un accord de contributeur (CLA) dès le départ. Publier sur l'App Store sous la licence non copyleft détenue par l'auteur. Choisir la licence libre en connaissance de cause. | action: Faire choisir la licence via la question e913bc4f-0a11-4b08-9f64-9dcac5c427ee.
- [legal] L'import depuis YouTube dépend de l'accès à la description ou aux sous-titres, souvent incomplets, et des conditions d'utilisation de YouTube. | impact: medium | probability: medium | mitigation: Se limiter au partage du lien et à l'exploitation des métadonnées accessibles. Prévoir une saisie ou dictée complémentaire. | action: Vérifier les conditions d'utilisation de YouTube avant de fixer ce mode d'import.
- [scope] Aucune donnée publique ne décrit les commerces ou les lieux de l'utilisateur. Les listes par lieu et l'ordre de visite exigent donc une configuration manuelle des commerces fréquents. | impact: medium | probability: high | mitigation: Commencer par une séparation par catégorie, puis ajouter des lieux saisis manuellement. Garder l'ordre de visite pour une version ultérieure, comme prévu. | action: Clarifier le moment d'arrivée des listes par lieu via la question q_v1_split_lists.

### Open Questions

- Les listes séparées par lieu et par catégorie font-elles partie de la première version ?
- Quelle licence libre copyleft envisagez-vous pour la double licence ?
- Pour la standardisation des recettes par IA, un service externe est-il acceptable ?

### Stage Fields

- pitch_summary: Application iPhone unique (Android dans un second temps) d'organisation de l'alimentation du foyer, pour l'utilisateur et son foyer, avec une éventuelle publication grand public sur l'App Store. Objectif : gagner du temps et rationaliser les courses. La première version porte en priorité sur deux volets. 1) Recettes : import depuis des sites web, du texte collé ou partagé, des photos de livres ou de fiches, la dictée audio, YouTube, etc. ; mise en forme et standardisation par IA ; modification ; suivi étape par étape. 2) Listes de courses, notamment pour le marché : générées à partir des recettes, d'audio ou de chat enregistrés dans l'app, ou de messages reçus (SMS, WhatsApp, Messenger) ; séparées par lieu et par catégorie ; synchronisées avec Apple Rappels. Ensuite viendront le suivi des stocks de la maison (éventuellement ajusté par photo) et le parcours optimisé, c'est-à-dire l'ordre de visite des magasins ou lieux. Le traitement se fait au maximum en local sur l'iPhone, pour limiter les appels externes payants. L'app est gratuite a priori, sous double licence (libre copyleft et commerciale).
- clear_points: ['Une seule application regroupe listes, recettes, stocks et parcours de courses.', 'Priorité de la première version : recettes et listes de courses.', "Plateforme : iPhone d'abord ; Android dans un second temps, une fois l'app stable.", "Utilisateurs cibles : l'utilisateur et son foyer ; éventuellement le grand public via l'App Store.", "Sources des listes : audio ou chat enregistré dans l'app, messages reçus (SMS, WhatsApp, Messenger, etc.) et recettes.", "Génération de listes de courses, avec le marché comme cas d'usage prioritaire.", 'Listes séparées par lieu et par catégorie.', 'Synchronisation des listes avec Apple Rappels.', "Sources d'import des recettes : sites web, texte collé ou partagé, photo de livre ou de fiche, dictée audio, YouTube, etc.", 'Mise en forme et standardisation des recettes par IA.', 'Volet recettes : modification et suivi étape par étape.', 'Suivi des stocks alimentaires de la maison, avec ajustement par photo envisagé et optionnel : hors priorité de la V1.', 'Parcours optimisé : ordre de visite des magasins ou lieux, prévu pour plus tard.', "Traitement local sur l'iPhone privilégié, pour limiter les appels externes payants.", 'Modèle : gratuit a priori, double licence (libre copyleft et licence permettant une commercialisation).', 'Objectif : gagner du temps et rationaliser les courses.']
- ambiguities: ["Listes séparées par lieu et par catégorie : dès la première version, ou plus tard comme l'ordre de visite ?", 'Catégories de produits : liste fixe ou personnalisable ?', 'Standardisation IA des recettes : entièrement locale, ou recours possible à un service externe ?', 'Import depuis YouTube : à partir du lien, de la description ou des sous-titres ?', "Récupération des messages WhatsApp, Messenger et SMS : passage par l'extension de partage ou le copier-coller (lecture directe impossible sur iOS).", 'Suivi des stocks : niveau de détail (présence, quantités, péremption) et mode de mise à jour (manuel, après les courses, par photo).', 'Lien entre stocks et listes : faut-il retirer automatiquement de la liste ce qui est déjà en stock ?', '« Rationaliser » : simple extraction des articles, ou aussi regroupement, quantités et dédoublonnage ?', "Partage au sein du foyer : listes partagées d'Apple Rappels ou synchronisation propre à l'app ?", "Double licence : licence libre précise et compatibilité avec la distribution sur l'App Store."]
- missing_information: ["Ordre des sources d'import et de génération au sein de la première version.", 'Description des commerces fréquents (marché, étals, magasins) et manière de les saisir.', 'Indicateurs de succès (temps gagné, oublis évités, gaspillage réduit, etc.).', 'Contraintes de confidentialité des conversations et des photos du domicile, en cas de recours à un service externe.', "Modèles d'iPhone et versions d'iOS minimaux pour le traitement local et l'IA embarquée.", 'Contraintes de calendrier ou de budget.']

### Readiness

- 7/7 passed/total
- [x] field:pitch_summary: Required field pitch_summary: clear
- [x] field:clear_points: Required field clear_points: clear
- [x] field:ambiguities: Required field ambiguities: clear
- [x] field:missing_information: Required field missing_information: clear
- [x] specific_pitch: Pitch must describe the idea in at least five words.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- pitch_summary: clear
- clear_points: clear
- ambiguities: clear
- missing_information: clear

### Clarifications

- 2026-11-21T13:58:23.882608+01:00: Qui sont les utilisateurs cibles de l'application ? -> la cible, c'est moi et mon foyer; eventuellement le grand public (publié sur l'app store); je souhaite que l'app soit avec double license un license libre et contaminante et une license qui me permet eventuellement de commercialiser un jour (a priori, on part sur du gratuit quand meme)
un audio ou un chat que l'on enregistre dans l'app, des messages que l'on recoit par message, par whatsapp, messenger, etc
pourquoi pas sur android une fois l'app dispo et stable sur iphone (mais j'ai rien pour tester donc dans 1 second temps). on voudrait utiliser les capacité locales de l'iphone au max pour limiter les appels externe (et du coup, payant)
- 2026-11-21T13:58:23.882618+01:00: D'où provient concrètement la « discussion ou chat » à partir de laquelle la liste est générée ? -> la cible, c'est moi et mon foyer; eventuellement le grand public (publié sur l'app store); je souhaite que l'app soit avec double license un license libre et contaminante et une license qui me permet eventuellement de commercialiser un jour (a priori, on part sur du gratuit quand meme)
un audio ou un chat que l'on enregistre dans l'app, des messages que l'on recoit par message, par whatsapp, messenger, etc
pourquoi pas sur android une fois l'app dispo et stable sur iphone (mais j'ai rien pour tester donc dans 1 second temps). on voudrait utiliser les capacité locales de l'iphone au max pour limiter les appels externe (et du coup, payant)
- 2026-11-21T13:58:23.882620+01:00: Android fait-il partie du périmètre initial, ou la première version vise-t-elle uniquement l'iPhone ? -> la cible, c'est moi et mon foyer; eventuellement le grand public (publié sur l'app store); je souhaite que l'app soit avec double license un license libre et contaminante et une license qui me permet eventuellement de commercialiser un jour (a priori, on part sur du gratuit quand meme)
un audio ou un chat que l'on enregistre dans l'app, des messages que l'on recoit par message, par whatsapp, messenger, etc
pourquoi pas sur android une fois l'app dispo et stable sur iphone (mais j'ai rien pour tester donc dans 1 second temps). on voudrait utiliser les capacité locales de l'iphone au max pour limiter les appels externe (et du coup, payant)
- 2026-11-21T14:04:44.773893+01:00: Quelles sources d'import de recettes sont indispensables pour la première version ? -> idealement, on ajoute aussi les commerce fréquent pour avoir un parcour optimisé pour les courses.

pour les recettes, doivent venir de site, de texte collé partagé, de photo de livre/fiche, d'audio (on doit pouvoir dicter), youtube, etc. on utilisera de l'IA pour mettre en forme et standardisé.

on devrait avoir tout ca dans 1 seule app.
- 2026-11-21T14:12:41.765594+01:00: L'application unique étant confirmée, quel volet est prioritaire pour la première version ? -> 1. recettes et liste de courses.
2. parcours optimisé => ordre de visite des magasins/lieux (pour plus tard) avec des listes séparé par lieux, par catégorie
- 2026-11-21T14:12:41.765609+01:00: Que signifie « parcours optimisé » avec les commerces fréquents ? -> 1. recettes et liste de courses.
2. parcours optimisé => ordre de visite des magasins/lieux (pour plus tard) avec des listes séparé par lieux, par catégorie
- 2026-11-21T14:12:41.765615+01:00: Quels points de l'idée sont déjà clairs et arrêtés ? -> 1. recettes et liste de courses.
2. parcours optimisé => ordre de visite des magasins/lieux (pour plus tard) avec des listes séparé par lieux, par catégorie

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.

## Stage 1 - Problem Framing and 5W1H

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

## Stage 2 - User Story Mapping

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

## Stage 3 - Event Storming

# Structured Summary

## Stage 3 - Event Storming

**Confirmé : vous validez la modélisation telle quelle (s3_f3).** Cette validation porte sur trois éléments, comme annoncé.
- **Les événements**, regroupés par domaine :
  - préparation : sélection des recettes et des portions, ajout d'un message ;
  - extraction : extraction réussie, en échec ou partielle, délégation au fournisseur externe, correction manuelle ;
  - liste : génération de la liste fusionnée, puis retouches (retrait, quantité, catégorie, ajout manuel) ;
  - Rappels : envoi, puis renvoi vers une liste existante ;
  - autres : activation de la clé avec consentement, coche par le foyer dans Rappels, non remontée dans l'app.
- **Les commandes** correspondantes.
- **Les quatre sous-ensembles** : liste de courses, recette standardisée, envoi vers Rappels, extraction.

**Déjà enregistré :**
- **Décision s3_d1 :** l'event storming se fait en version allégée. Il couvre la préparation de la liste, l'envoi et le renvoi vers Rappels, et la chaîne de repli de l'IA.
- **Acteurs et règles métier :** confirmés aux étapes précédentes.
- **Points de complexité (s3_f2) :** fusion de la liste, renvoi vers une liste Rappels existante, chaîne de repli de l'IA.

**Ce qui reste incertain :** aucun point identifié pour cette étape. La question sur la modélisation et celle sur les événements métier sont résolues par votre réponse.

Le passage à l'étape suivante sera décidé par les règles du serveur.

# Open Questions and Uncertainties

- None currently identified.

## Open Questions

- None.

# Questions to Continue

- No further question required to complete this stage.

# Stage Deliverable

## Stage 3 - Event Storming

### Facts

- L'utilisateur juge l'event storming utile en version allégée : seulement la préparation de la liste, l'envoi vers Rappels et le repli de l'IA.
- L'utilisateur confirme les trois points de complexité : la fusion de la liste, le renvoi vers une liste Rappels existante et la chaîne de repli de l'IA.
- L'utilisateur valide telle quelle la modélisation proposée : les événements, les commandes et les quatre sous-ensembles (liste de courses, recette standardisée, envoi vers Rappels, extraction).

### Assumptions

- None explicitly recorded.

### Decisions

- Event storming en version allégée, limité à la préparation de la liste (parcours B et E), à l'envoi et au renvoi vers Rappels, et à la chaîne de repli de l'IA. Le suivi pas à pas et le détail des sources d'import sont hors modélisation. (Choix explicite de l'utilisateur. L'app est personnelle et locale, mais ces zones portent les règles métier délicates.)

### Risks

- No explicit risks recorded yet.

### Open Questions

- None.

### Stage Fields

- event_storming_relevant: True
- domain_events: ['Recettes et portions sélectionnées pour la semaine', 'Message ajouté comme source de la liste', "Recette ou message extrait par l'IA embarquée", 'Extraction en échec ou partielle', 'Extraction déléguée au fournisseur externe (clé activée)', 'Correction manuelle enregistrée', 'Liste fusionnée générée', 'Article retiré de la liste', "Quantité d'un article modifiée", "Catégorie d'un article changée", 'Article ajouté manuellement', 'Liste envoyée vers la liste Rappels partagée', 'Liste renvoyée vers une liste Rappels existante (articles absents, articles seulement cochés et compléments de quantité ajoutés)', 'Clé de fournisseur activée avec consentement', "Article coché dans Rappels par le foyer (externe, non remonté dans l'app)"]
- commands: ['Sélectionner des recettes et leurs portions', 'Ajouter un message partagé ou copié', "Lancer l'extraction d'une recette ou d'un message", "Corriger manuellement le résultat de l'extraction", 'Générer la liste fusionnée', 'Retirer un article', "Modifier la quantité d'un article", "Changer la catégorie d'un article", 'Ajouter manuellement un article (nom, quantité facultative)', 'Envoyer la liste vers Rappels', "Activer la clé de fournisseur d'IA"]
- actors: ['Utilisateur principal (iPhone 15 Pro ou ultérieur) : sélectionne, retouche, ajoute et envoie la liste, corrige les extractions', "Foyer (autre membre, iPhone 11) : coche la liste dans Apple Rappels, sans l'app", 'Système : IA embarquée Apple', "Système : fournisseur d'IA externe via la clé de l'utilisateur (désactivé par défaut)", 'Système : Apple Rappels']
- business_rules: ['Fusion : les unités comparables (g et kg, cl et l) sont converties puis additionnées', 'Fusion : les variantes de nom (« tomates » et « tomates cerises ») restent sur des lignes distinctes', "Mise à l'échelle : les articles à l'unité donnant une fraction sont arrondis au supérieur", "Ajout manuel avec quantité d'un article déjà présent : fusion si les unités se comparent, sinon ligne distincte", "Ajout manuel sans quantité d'un article déjà présent : aucune nouvelle ligne, la ligne existante est conservée", "Envoi vers Rappels dans un seul sens : les coches et ajouts du foyer ne remontent pas dans l'app", 'Renvoi vers une liste Rappels existante : correspondance par nom normalisé ; ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification', "Ajout manuel après l'envoi : renvoi selon la règle de correspondance par nom normalisé", "Chaîne de repli : IA embarquée, puis clé de l'utilisateur si elle est activée, sinon correction manuelle sur un écran pré-rempli avec le texte source visible", 'Clé de fournisseur : désactivée par défaut, consentement explicite unique, sans confirmation à chaque envoi', "Les catégories proviennent d'une liste fixe prédéfinie ; l'utilisateur peut changer la catégorie d'un article"]
- complexity_hotspots: ["Fusion de la liste depuis plusieurs recettes et messages : conversion des unités comparables, lignes distinctes pour les variantes de nom, arrondi au supérieur lors de la mise à l'échelle", 'Renvoi vers une liste Rappels existante : correspondance par nom normalisé, ajout des articles absents ou seulement cochés et du complément de quantité, sans suppression ni modification', "Chaîne de repli de l'extraction : IA embarquée, puis clé de l'utilisateur si elle est activée, sinon correction manuelle, dans les délais cibles (moins de 1 minute pour une recette texte ou web, moins de 2 minutes pour une recette photo)"]
- aggregates: ['Liste de courses (lignes : nom normalisé, quantité, unité, catégorie, origine)', 'Recette standardisée (ingrédients, quantités, unités, étapes, portions)', 'Envoi vers Rappels (correspondance avec la liste partagée existante)', 'Extraction (chaîne de repli IA embarquée, clé externe, correction manuelle)']

### Readiness

- 6/6 passed/total
- [x] field:event_storming_relevant: Required field event_storming_relevant: clear
- [x] field:domain_events: Required field domain_events: clear
- [x] irrelevance_justified: Event storming irrelevance must be justified explicitly.
- [x] relevant_events: Relevant event storming requires domain events.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- event_storming_relevant: clear
- domain_events: clear
- commands: clear
- actors: clear
- business_rules: clear
- complexity_hotspots: clear
- aggregates: clear
- not_relevant_reason: missing

### Clarifications

- 2026-11-22T12:07:40.938873+01:00: L'event storming est-il utile pour votre projet ? -> L'event storming est-il utile pour votre projet ?
Oui, en version allégée : seulement la préparation de la liste, l'envoi vers Rappels et le repli de l'IA
- 2026-11-22T12:08:11.056749+01:00: Les trois points de complexité proposés vous conviennent-ils ? Il s'agit de la fusion de la liste, du renvoi vers une liste Rappels existante et de la chaîne de repli de l'IA. -> Les trois points de complexité proposés vous conviennent-ils ? Il s'agit de la fusion de la liste, du renvoi vers une liste Rappels existante et de la chaîne de repli de l'IA.
Oui, les trois
- 2026-11-22T12:09:31.317986+01:00: La modélisation proposée vous convient-elle ? Elle comprend les événements (sélection, fusion, retouche, envoi, renvoi, extraction réussie ou en échec, correction), les commandes et quatre sous-ensembles : liste de courses, recette standardisée, envoi vers Rappels, extraction. -> La modélisation proposée vous convient-elle ? Elle comprend les événements (sélection, fusion, retouche, envoi, renvoi, extraction réussie ou en échec, correction), les commandes et quatre sous-ensembles : liste de courses, recette standardisée, envoi vers Rappels, extraction.
Oui, telle quelle
- 2026-11-22T12:09:31.317995+01:00: Quels événements métier se produisent dans le processus (par exemple « Commande passée ») ? -> La modélisation proposée vous convient-elle ? Elle comprend les événements (sélection, fusion, retouche, envoi, renvoi, extraction réussie ou en échec, correction), les commandes et quatre sous-ensembles : liste de courses, recette standardisée, envoi vers Rappels, extraction.
Oui, telle quelle

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.

## Stage 4 - Impact Mapping

# Structured Summary

## Stage 4 - Impact Mapping

Votre réponse est enregistrée : les acteurs d'impact sont **remplacés** par les utilisateurs et acteurs de l'étape 1. Ce choix remplace votre réponse précédente (« les ajouter »), qui est retirée.

**Ce qui change**
- **Libellés repris mot pour mot de l'étape 1.** La liste des acteurs d'impact reprend désormais exactement les libellés de l'étape 1, sans formulation propre à cette étape. La correspondance entre les deux étapes est ainsi directe :
  - l'utilisateur principal, porteur du projet ;
  - l'autre membre du foyer ;
  - le fournisseur d'IA externe, via la clé de l'utilisateur, désactivé par défaut ;
  - Apple Rappels.
- **Acteurs non retenus.** Le grand public et iCloud figurent à l'étape 1, mais seulement après la V1. Ils ne sont pas retenus comme acteurs d'impact de l'objectif V1.
- **Influence de chaque acteur.** Elle reste portée par les comportements B1 à B5 et les hypothèses H1 à H5 :
  - l'utilisateur principal est l'acteur décisif ;
  - l'autre membre du foyer coche la liste partagée ;
  - le fournisseur d'IA externe sert de repli d'extraction ;
  - Apple Rappels sert de canal de partage.
- **IA embarquée Apple.** Elle n'est toujours pas un acteur d'impact. Elle reste une dépendance technique et le mécanisme d'extraction de H2 (décision s4_d1, inchangée).
- **Étape 1.** Elle n'est pas modifiée. La décision s4_d2 est mise à jour en conséquence.

**Ce qui est confirmé**
- **Objectif métier :** préparer la liste d'une semaine type en moins de 2 minutes, au lieu de 10 à 30 minutes.
- **Comportements attendus :** B1 à B5.
- **Livrables :** chacun est rattaché à un comportement et à une hypothèse.
- **Hypothèses de valeur :** H1 à H5.

**Ce qui reste incertain :** aucun point identifié pour cette étape.

Le passage à l'étape suivante est décidé par les règles du serveur.

# Open Questions and Uncertainties

- None currently identified.

## Open Questions

- None.

# Questions to Continue

- No further question required to complete this stage.

# Stage Deliverable

## Stage 4 - Impact Mapping

### Facts

- L'utilisateur valide telle quelle la proposition de cartographie d'impact : objectif de moins de 2 minutes, acteurs, comportements B1 à B5, livrables rattachés et hypothèses H1 à H4.
- Le suivi pas à pas reste en V1. Il est rattaché à une hypothèse de confort en cuisine, sans objectif chiffré, et assumé comme hors de l'objectif principal de temps de préparation de la liste.
- Changement de comportement attendu de l'autre membre du foyer : il coche la liste Apple Rappels partagée pendant les courses, au lieu d'une liste papier ou de messages.
- L'utilisateur choisit de remplacer les acteurs d'impact absents de l'étape 1 par des utilisateurs de l'étape 1. L'IA embarquée Apple est donc retirée des acteurs d'impact.
- L'utilisateur choisit finalement de remplacer les acteurs d'impact par les utilisateurs et acteurs de l'étape 1, plutôt que de les ajouter à l'étape 1. Ce choix annule sa réponse précédente.

### Assumptions

- None explicitly recorded.

### Decisions

- L'IA embarquée Apple n'est plus un acteur d'impact. Elle reste une dépendance technique et le mécanisme d'extraction des livrables et de l'hypothèse H2. (Les acteurs d'impact doivent correspondre aux acteurs identifiés à l'étape 1. L'utilisateur a choisi l'option de remplacement.)
- Les acteurs d'impact reprennent mot pour mot les libellés de l'étape 1 retenus pour la V1 : utilisateur principal, l'autre membre du foyer, fournisseur d'IA externe, Apple Rappels. Le grand public et iCloud, prévus après la V1, ne sont pas des acteurs d'impact de l'objectif V1. L'influence de chaque acteur est portée par les comportements B1 à B5 et les hypothèses H1 à H5. L'IA embarquée Apple reste une dépendance technique (s4_d1 inchangée). (Choix explicite de l'utilisateur : remplacer les acteurs d'impact par les utilisateurs de l'étape 1, sans modifier l'étape 1.)

### Risks

- No explicit risks recorded yet.

### Open Questions

- None.

### Stage Fields

- business_goal: Réduire le temps de préparation hebdomadaire de la liste de courses du foyer de 10 à 30 minutes aujourd'hui à moins de 2 minutes, pour une semaine type (environ 5 recettes et 2 messages), de la sélection des recettes et des messages jusqu'à la liste disponible dans Apple Rappels. Le gain visé est d'environ 8 à 28 minutes par semaine, dès la V1 (environ 3 mois).
- influential_actors: ["Utilisateur principal (porteur du projet), qui importe les recettes et prépare les courses dans l'app ; cible de la V1", "L'autre membre du foyer : en V1, coche seulement une liste Apple Rappels partagée, sans utiliser l'app ; cible de la V1 ; partage iCloud plus tard", "Fournisseur d'IA externe choisi par l'utilisateur via sa propre clé (option désactivée par défaut)", 'Apple Rappels (réception des listes et partage avec le foyer)']
- expected_behaviors: ["B1 – L'utilisateur principal prépare la liste d'une semaine type (environ 5 recettes et 2 messages) en moins de 2 minutes, mesurées de la sélection jusqu'à la liste disponible dans Rappels.", "B2 – L'utilisateur principal importe et standardise une recette texte ou web en moins de 1 minute, correction comprise.", "B3 – L'utilisateur principal importe et standardise une recette photo (livre, magazine, fiche manuscrite) en moins de 2 minutes, correction comprise.", "B4 – Le foyer coche la liste Apple Rappels partagée pendant les courses, au lieu d'une liste papier ou de messages, sans installer l'app.", "B5 – L'utilisateur principal ajoute un article oublié (nom, quantité facultative) avant ou après l'envoi, sans reconstruire la liste."]
- deliverables: ['Import de recette par lien web → B2 (H2)', 'Import de recette par texte collé ou partagé (extension de partage iOS) → B2 (H2)', 'Import de recette par photo (page de livre, magazine, fiche manuscrite) → B3 (H2)', "Import d'articles ou de recettes depuis des messages partagés ou copiés (SMS, WhatsApp, Messenger) → B1 (H1)", "Extraction et standardisation par l'IA embarquée Apple (repli par clé utilisateur, sinon correction manuelle) → B2, B3 (H2)", 'Correction manuelle avec écran pré-rempli, texte source visible et édition champ par champ → B2, B3 (H2)', 'Bibliothèque de recettes minimale (liste, recherche par titre, suppression, sélection multiple avec portions) → B1 (H1)', "Mise à l'échelle simple selon le nombre de portions → B1 (H1)", 'Liste de courses unique, fusionnée depuis plusieurs recettes et messages, cochable → B1 (H1)', 'Regroupement par catégorie (liste fixe prédéfinie) avec changement de catégorie → B1, B4 (H1, H3)', "Retouche de la liste avant l'envoi (retrait, modification de quantité) → B1 (H1)", "Ajout manuel d'un article sans IA, avant ou après l'envoi → B5 (H4)", 'Envoi dans un seul sens vers une liste Apple Rappels partagée, avec correspondance par nom normalisé → B1, B4, B5 (H1, H3, H4)', "Activation optionnelle d'une clé de fournisseur d'IA avec écran de consentement unique → B2, B3 (H2)", 'Suivi pas à pas de la recette → H5 (hypothèse de confort en cuisine, hors objectif principal, sans comportement chiffré)']
- value_hypotheses: ["H1 – Si la liste est générée automatiquement par fusion des recettes sélectionnées (portions mises à l'échelle) et des messages, regroupée par catégorie, retouchable puis envoyée vers Rappels, alors l'utilisateur principal prépare sa semaine type en moins de 2 minutes au lieu de 10 à 30 minutes.", "H2 – Si l'IA embarquée Apple standardise les recettes, avec repli par clé utilisateur et un écran de correction pré-rempli montrant le texte source, alors une recette texte ou web est prête en moins de 1 minute et une recette photo en moins de 2 minutes, correction comprise.", "H3 – Si la liste est poussée vers une liste Apple Rappels partagée et regroupée par catégorie, alors l'autre membre du foyer coche la liste pendant les courses, au lieu d'une liste papier ou de messages, sans installer l'app.", 'H4 – Si un article oublié peut être ajouté par un champ simple et renvoyé selon la correspondance par nom normalisé, alors la liste partagée reste à jour sans être reconstruite ni dupliquée.', "H5 – Si la recette est disponible en suivi pas à pas, alors l'utilisateur principal cuisine plus confortablement. Hypothèse de confort, sans objectif chiffré, assumée comme hors de l'objectif principal de temps de préparation de la liste."]

### Readiness

- 8/8 passed/total
- [x] field:business_goal: Required field business_goal: clear
- [x] field:influential_actors: Required field influential_actors: clear
- [x] field:expected_behaviors: Required field expected_behaviors: clear
- [x] field:deliverables: Required field deliverables: clear
- [x] field:value_hypotheses: Required field value_hypotheses: clear
- [x] consistent_actors: Impact actors must exist in stage 1 users/actors.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- business_goal: clear
- influential_actors: clear
- expected_behaviors: clear
- deliverables: clear
- value_hypotheses: clear

### Clarifications

- 2026-11-22T12:13:40.975230+01:00: La proposition de cartographie d'impact vous convient-elle (objectif de moins de 2 minutes, acteurs, comportements B1 à B5, livrables rattachés, hypothèses H1 à H4) ? -> La proposition de cartographie d'impact vous convient-elle (objectif de moins de 2 minutes, acteurs, comportements B1 à B5, livrables rattachés, hypothèses H1 à H4) ?
Oui, telle quelle
- 2026-11-22T12:13:40.975238+01:00: Quel objectif métier le projet doit-il faire progresser ? -> La proposition de cartographie d'impact vous convient-elle (objectif de moins de 2 minutes, acteurs, comportements B1 à B5, livrables rattachés, hypothèses H1 à H4) ?
Oui, telle quelle
- 2026-11-22T12:13:40.975242+01:00: Qui peut aider ou freiner l'atteinte de cet objectif ? -> La proposition de cartographie d'impact vous convient-elle (objectif de moins de 2 minutes, acteurs, comportements B1 à B5, livrables rattachés, hypothèses H1 à H4) ?
Oui, telle quelle
- 2026-11-22T12:14:22.852438+01:00: Le suivi pas à pas est en V1 mais ne sert pas l'objectif de temps de préparation de la liste. Comment voulez-vous le rattacher ? -> Le suivi pas à pas est en V1 mais ne sert pas l'objectif de temps de préparation de la liste. Comment voulez-vous le rattacher ?
Ajouter une hypothèse de confort en cuisine, sans objectif chiffré, en assumant qu'il est hors objectif principal

Quel changement de comportement attendez-vous concrètement de l'autre membre du foyer avec la liste Rappels partagée, par rapport à aujourd'hui ?
Il coche la liste pendant les courses, au lieu d'une liste papier ou de messages
- 2026-11-22T12:14:22.852443+01:00: Quel changement de comportement attendez-vous concrètement de l'autre membre du foyer avec la liste Rappels partagée, par rapport à aujourd'hui ? -> Le suivi pas à pas est en V1 mais ne sert pas l'objectif de temps de préparation de la liste. Comment voulez-vous le rattacher ?
Ajouter une hypothèse de confort en cuisine, sans objectif chiffré, en assumant qu'il est hors objectif principal

Quel changement de comportement attendez-vous concrètement de l'autre membre du foyer avec la liste Rappels partagée, par rapport à aujourd'hui ?
Il coche la liste pendant les courses, au lieu d'une liste papier ou de messages
- 2026-11-22T12:15:37.440747+01:00: Certains acteurs d'impact ne figurent pas parmi les utilisateurs de l'étape 1 : faut-il les y ajouter ou les remplacer ? -> Certains acteurs d'impact ne figurent pas parmi les utilisateurs de l'étape 1 : faut-il les y ajouter ou les remplacer ?
Les remplacer par des utilisateurs de l'étape 1
- 2026-11-22T12:17:44.202032+01:00: Certains acteurs d'impact ne figurent pas parmi les utilisateurs de l'étape 1 : faut-il les y ajouter ou les remplacer ? -> Certains acteurs d'impact ne figurent pas parmi les utilisateurs de l'étape 1 : faut-il les y ajouter ou les remplacer ?
Les ajouter aux utilisateurs de l'étape 1
- 2026-11-22T12:19:36.227603+01:00: Certains acteurs d'impact ne figurent pas parmi les utilisateurs de l'étape 1 : faut-il les y ajouter ou les remplacer ? -> Certains acteurs d'impact ne figurent pas parmi les utilisateurs de l'étape 1 : faut-il les y ajouter ou les remplacer ?
Les remplacer par des utilisateurs de l'étape 1

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.

## Stage 5 - Risk Storming and Pre-mortem

# Structured Summary

## Stage 5 - Risk Storming and Pre-mortem

Vos deux réponses sont enregistrées, et les deux questions ouvertes sont résolues.

**1. La clé d'IA est protégée si l'IA embarquée est insuffisante (décision s5_d3).** Au point des 6 semaines, le plan de coupe peut s'appliquer alors que les tests de s5_r1 montrent que l'IA embarquée ne tient pas les cibles de 1 et 2 minutes. Dans ce cas, vous gardez la clé d'IA optionnelle et reportez d'abord le suivi pas à pas. Hors de ce cas, le plan de coupe s5_d1 reste inchangé : la clé d'IA d'abord, puis le suivi pas à pas. J'ai reporté cette exception dans les risques s5_r1, s5_r7, s5_r8 et s5_r9.

**2. Les niveaux d'impact et de probabilité des neuf risques (s5_r1 à s5_r9) sont confirmés.** Ils ne sont plus marqués « proposé ». Les niveaux de s5_r7 (probabilité moyenne à élevée) et de s5_r9 (probabilité moyenne) restent tels quels.

**Ce qui est couvert**
Les six catégories de risques sont couvertes : technique, données et qualité, sécurité et conformité, adoption, planning et dépendances, organisation. Chaque risque a désormais :
- un impact et une probabilité confirmés ;
- une parade concrète ;
- une action de suivi datée.

**Ce qui reste ouvert, sans question bloquante identifiée**
- **Fournisseurs et consentement :** les fournisseurs d'IA pris en charge et le contenu exact de l'écran de consentement. L'action de s5_r4 est prévue avant la livraison de la clé.
- **Licence :** le choix entre GPLv3 et AGPLv3. L'action de s5_r5 est prévue avant publication.

Le passage à l'étape suivante est décidé par les règles du serveur.

# Open Questions and Uncertainties

- Fournisseurs d'IA pris en charge et données exactes affichées sur l'écran de consentement : encore ouverts (action prévue avant la livraison de la clé, s5_r4).
- Choix entre GPLv3 et AGPLv3 : encore ouvert (action prévue avant publication, s5_r5).

## Open Questions

- None.

# Questions to Continue

- No further question required to complete this stage.

# Stage Deliverable

## Stage 5 - Risk Storming and Pre-mortem

### Facts

- La V1 est réalisée par le porteur du projet seul, sur son temps libre.
- Le porteur prévoit de consacrer plus de 10 heures par semaine à la V1, sur son temps libre.

### Assumptions

- None explicitly recorded.

### Decisions

- Plan de coupe au point des 6 semaines : si le socle recette et le parcours B ne sont pas livrés, reporter d'abord la clé d'IA optionnelle, puis le suivi pas à pas. (Choix explicite de l'utilisateur ; parade concrète aux risques s5_r7 et s5_r9.)
- Vérifier que l'autre membre du foyer coche la liste Rappels partagée lors de vraies courses, dès que le parcours B fonctionne de bout en bout. (Choix explicite de l'utilisateur ; tester tôt l'hypothèse H3 pour pouvoir corriger avant la fin de la V1 (risque s5_r6).)
- Exception au plan de coupe s5_d1 : si, au point des 6 semaines, les tests de s5_r1 montrent que l'IA embarquée ne tient pas les cibles (1 minute texte ou web, 2 minutes photo, correction comprise), la clé d'IA optionnelle est conservée et le suivi pas à pas est reporté en premier. (Choix explicite de l'utilisateur. La clé d'IA est la seule parade, hors correction manuelle, aux risques s5_r1 et s5_r8.)

### Risks

- No explicit risks recorded yet.

### Open Questions

- None.

### Stage Fields

- risks_by_category: [{'id': 's5_r1', 'category': 'Technique', 'description': "L'IA embarquée Apple de l'iPhone 15 Pro extrait mal les contenus bruités (photo floue, fiche manuscrite, page web chargée). La correction manuelle dépasse alors 1 minute pour une recette texte ou web, ou 2 minutes pour une recette photo.", 'impact': 'Élevé (confirmé) : les objectifs B2 et B3 (hypothèse H2) sont manqués.', 'probability': "Moyenne (confirmée) : la qualité sur les contenus bruités est jugée incertaine dès l'étape 1.", 'mitigation': "Chaîne de repli : IA embarquée, puis clé de l'utilisateur si elle est activée, sinon écran de correction pré-rempli avec le texte source visible et une édition champ par champ. Imports priorisés : web et texte d'abord, photo ensuite. Si l'IA embarquée ne tient pas les cibles, la clé d'IA est conservée même si le plan de coupe s'applique (décision s5_d3).", 'action': "Avant le point des 6 semaines, tester sur l'iPhone 15 Pro des recettes réelles du foyer (texte, web, photo et manuscrit), en chronométrant le temps correction comprise par rapport aux cibles de 1 et 2 minutes."}, {'id': 's5_r2', 'category': 'Technique', 'description': "Lors d'un renvoi vers une liste Rappels existante, des doublons apparaissent ou les quantités sont surestimées, en raison de variantes de nom ou d'unités non comparables.", 'impact': 'Moyen (confirmé) : la liste partagée devient confuse pour le foyer (hypothèses H3 et H4).', 'probability': 'Moyenne (confirmée).', 'mitigation': 'Règle confirmée : correspondance par nom normalisé ; ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification.', 'action': 'Pendant la livraison du parcours B, écrire des tests de renvoi couvrant chaque branche de la règle : article absent, article coché, complément de quantité, unités non comparables, variante de nom.'}, {'id': 's5_r3', 'category': 'Données et qualité', 'description': "La liste fusionnée est imprécise (unités non comparables, variantes de nom sur des lignes distinctes, arrondis), ce qui allonge la retouche avant l'envoi.", 'impact': "Moyen (confirmé) : l'objectif de moins de 2 minutes (B1, hypothèse H1) est menacé.", 'probability': 'Moyenne (confirmée).', 'mitigation': "Règles de fusion confirmées : conversion des unités comparables, lignes distinctes pour les variantes, arrondi au supérieur. Retouche et changement de catégorie possibles avant l'envoi.", 'action': "À la fin du parcours B, chronométrer une semaine type réelle (environ 5 recettes et 2 messages), de la sélection jusqu'à Rappels, et noter les retouches nécessaires."}, {'id': 's5_r4', 'category': 'Sécurité et conformité', 'description': "Les données envoyées au fournisseur d'IA choisi par l'utilisateur, une fois sa clé activée, posent un problème de confidentialité (texte de messages, photos).", 'impact': 'Élevé (confirmé) en cas de publication grand public ; faible pour le foyer en V1.', 'probability': "Faible (confirmée) en V1 : l'option est désactivée par défaut.", 'mitigation': 'Option désactivée par défaut et écran de consentement unique présentant les données envoyées et le fournisseur choisi.', 'action': "Avant de livrer la clé d'IA optionnelle, arrêter la liste des fournisseurs pris en charge et le contenu exact affiché sur l'écran de consentement."}, {'id': 's5_r5', 'category': 'Sécurité et conformité', 'description': "La licence GPL ou AGPL est incompatible avec la distribution sur l'App Store, ou des contributions sont acceptées sans CLA, ce qui bloque la double licence.", 'impact': "Élevé (confirmé) : la publication sur l'App Store est bloquée.", 'probability': 'Moyenne (confirmée).', 'mitigation': "Double licence avec CLA ; binaire de l'App Store sous licence commerciale ou avec une exception App Store.", 'action': "Choisir entre GPLv3 et AGPLv3, mettre en place le CLA avant toute contribution externe, et obtenir l'avis juridique prévu avant publication."}, {'id': 's5_r6', 'category': 'Adoption', 'description': "L'autre membre du foyer n'utilise pas la liste Rappels partagée pendant les courses et revient au papier ou aux messages.", 'impact': "Élevé (confirmé) : l'hypothèse H3 et le comportement B4 échouent, et le partage au foyer est perdu.", 'probability': "Faible à moyenne (confirmée) : l'hypothèse est confirmée mais pas encore testée.", 'mitigation': "Aucune installation nécessaire : liste regroupée par catégorie dans une application déjà présente sur l'iPhone 11. Vérification précoce, dès que le parcours B fonctionne, pour pouvoir corriger avant la fin de la V1 (décision s5_d2).", 'action': "Dès que le parcours B fonctionne de bout en bout, envoyer la liste vers la liste Rappels partagée pour de vraies courses. Vérifier que l'autre membre du foyer la coche pendant les courses et noter si elle revient au papier ou aux messages."}, {'id': 's5_r7', 'category': 'Planning et dépendances', 'description': "Le périmètre de la V1 (15 capacités) est trop large pour l'échéance d'environ 3 mois, réalisée par une seule personne sur son temps libre.", 'impact': 'Élevé (confirmé) : la V1 est livrée en retard ou incomplète.', 'probability': "Moyenne à élevée (confirmée) : le risque est suivi depuis l'étape 1 (s2_r1). Le porteur annonce plus de 10 heures par semaine (s5_f2), soit plus de 130 heures sur environ 3 mois, face à 15 capacités.", 'mitigation': "Ordre de livraison confirmé : socle recette, parcours B, import photo, suivi pas à pas, clé d'IA. YouTube et Paprika sont reportés en itération 1. Plan de coupe arbitré (s5_d1) : reporter d'abord la clé d'IA optionnelle, puis le suivi pas à pas. Exception (s5_d3) : si l'IA embarquée ne tient pas les cibles, garder la clé et reporter d'abord le suivi pas à pas.", 'action': "Au point des 6 semaines, vérifier que le socle recette et le parcours B sont livrés. Sinon, appliquer le plan de coupe : reporter après la V1 la clé d'IA optionnelle, puis le suivi pas à pas (s5_d1). Si les tests de s5_r1 montrent que l'IA embarquée ne tient pas les cibles, reporter d'abord le suivi pas à pas et garder la clé (s5_d3)."}, {'id': 's5_r8', 'category': 'Planning et dépendances', 'description': "Si l'IA embarquée se révèle insuffisante, seule la clé externe permet de tenir les objectifs, avec un coût incompatible avec un budget proche de zéro pour le porteur.", 'impact': 'Moyen (confirmé) : il faut choisir entre payer des appels externes et corriger manuellement plus longtemps.', 'probability': 'Moyenne (confirmée) : elle dépend du résultat des tests de s5_r1.', 'mitigation': "Aucun appel externe payé par le porteur ; la clé reste celle de l'utilisateur, avec correction manuelle en dernier recours. Si l'IA embarquée est insuffisante, la clé d'IA optionnelle est conservée dans la V1 même si le plan de coupe s'applique (décision s5_d3).", 'action': "Au point des 6 semaines, à partir des résultats de s5_r1, décider si la correction manuelle tient les cibles. Si ce n'est pas le cas, conserver la clé d'IA optionnelle dans la V1 (s5_d3) et réarbitrer son usage."}, {'id': 's5_r9', 'category': 'Organisation', 'description': "La V1 repose sur une seule personne, le porteur, qui y travaille uniquement sur son temps libre. Une période chargée (travail, famille, santé) ou une baisse de motivation arrête totalement l'avancement, sans personne pour prendre le relais.", 'impact': 'Élevé (confirmé) : la V1 est livrée en retard, incomplète ou abandonnée en cours de route.', 'probability': 'Moyenne (confirmée) : le porteur annonce plus de 10 heures par semaine (s5_f2). Le risque tient surtout à la régularité de ce temps libre sur environ 3 mois.', 'mitigation': "Ordre de livraison confirmé, qui rend l'app utile dès le parcours B (socle recette puis parcours B). YouTube et Paprika sont déjà reportés en itération 1. Point de contrôle aux 6 semaines, avec un plan de coupe arbitré (s5_d1) : clé d'IA optionnelle d'abord, puis suivi pas à pas. Exception (s5_d3) : si l'IA embarquée est insuffisante, le suivi pas à pas est reporté en premier.", 'action': "Avant de démarrer, réserver plus de 10 heures par semaine sur le temps libre, en créneaux réguliers. Au point des 6 semaines, comparer l'avancement réel à l'ordre de livraison. Si le socle recette et le parcours B ne sont pas livrés, appliquer le plan de coupe (s5_d1), ou son exception si l'IA embarquée ne tient pas les cibles (s5_d3)."}]

### Readiness

- 4/4 passed/total
- [x] field:risks_by_category: Required field risks_by_category: clear
- [x] concrete_risks: Risk storming needs at least three concrete risk items across two categories with concrete mitigations and actions.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- risks_by_category: clear

### Clarifications

- 2026-11-22T12:22:38.072610+01:00: Qui réalise la V1, et avec quel temps disponible sur les 3 mois ? -> Qui réalise la V1, et avec quel temps disponible sur les 3 mois ?
Le porteur seul, sur son temps libre
- 2026-11-22T12:23:44.849226+01:00: Au point des 6 semaines, si le socle recette et le parcours B ne sont pas livrés, que reportez-vous en premier ? -> Au point des 6 semaines, si le socle recette et le parcours B ne sont pas livrés, que reportez-vous en premier ?
Reporter d'abord la clé d'IA optionnelle, puis le suivi pas à pas

Quand voulez-vous vérifier que l'autre membre du foyer utilise la liste Rappels partagée pendant les courses ?
Dès que le parcours B fonctionne de bout en bout, lors de vraies courses
- 2026-11-22T12:23:44.849233+01:00: Quand voulez-vous vérifier que l'autre membre du foyer utilise la liste Rappels partagée pendant les courses ? -> Au point des 6 semaines, si le socle recette et le parcours B ne sont pas livrés, que reportez-vous en premier ?
Reporter d'abord la clé d'IA optionnelle, puis le suivi pas à pas

Quand voulez-vous vérifier que l'autre membre du foyer utilise la liste Rappels partagée pendant les courses ?
Dès que le parcours B fonctionne de bout en bout, lors de vraies courses
- 2026-11-22T13:57:54.845869+01:00: Combien de temps libre pensez-vous consacrer à la V1 chaque semaine, en moyenne ? -> Combien de temps libre pensez-vous consacrer à la V1 chaque semaine, en moyenne ?
Plus de 10 heures par semaine
- 2026-11-22T13:58:45.146437+01:00: Si les tests de s5_r1 montrent que l'IA embarquée ne tient pas les cibles et que le plan de coupe s'applique au point des 6 semaines, gardez-vous la clé d'IA optionnelle ? -> Si les tests de s5_r1 montrent que l'IA embarquée ne tient pas les cibles et que le plan de coupe s'applique au point des 6 semaines, gardez-vous la clé d'IA optionnelle ?
Oui : dans ce cas, garder la clé d'IA et reporter d'abord le suivi pas à pas

Confirmez-vous les niveaux d'impact et de probabilité proposés pour les risques s5_r1 à s5_r9, ou souhaitez-vous en corriger certains ?
Je confirme tous les niveaux proposés
- 2026-11-22T13:58:45.146443+01:00: Confirmez-vous les niveaux d'impact et de probabilité proposés pour les risques s5_r1 à s5_r9, ou souhaitez-vous en corriger certains (par exemple baisser s5_r7 ou s5_r9 au vu des plus de 10 heures par semaine) ? -> Si les tests de s5_r1 montrent que l'IA embarquée ne tient pas les cibles et que le plan de coupe s'applique au point des 6 semaines, gardez-vous la clé d'IA optionnelle ?
Oui : dans ce cas, garder la clé d'IA et reporter d'abord le suivi pas à pas

Confirmez-vous les niveaux d'impact et de probabilité proposés pour les risques s5_r1 à s5_r9, ou souhaitez-vous en corriger certains ?
Je confirme tous les niveaux proposés

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.

## Stage 6 - Backlog Synthesis

# Structured Summary

## Stage 6 - Backlog Synthesis

Vos trois réponses sont enregistrées.

**1. Backlog validé tel quel.** Votre « ok » valide l'ensemble de la proposition. Les trois parties du backlog ne sont donc plus de simples propositions :
- les 15 récits MVP ;
- les 5 spikes ;
- les 6 chantiers transverses.

**2. Ma proposition pour les spikes.** Je propose de garder les 5 spikes déjà présentés, que vous venez de valider. Chacun découle d'une action de suivi de l'étape 5 :
- **s6_sp1** : tester l'IA embarquée sur l'iPhone 15 Pro avec vos recettes réelles, avant le point des 6 semaines (s5_r1). Ce test décide aussi de l'exception s5_d3.
- **s6_sp2** : prototyper l'écriture et la relecture d'une liste Rappels partagée, en testant chaque branche de la règle de renvoi (s5_r2).
- **s6_sp3** : chronométrer une semaine type réelle à la fin du parcours B (s5_r3).
- **s6_sp4** : faire de vraies courses avec l'autre membre du foyer sur la liste Rappels partagée, dès que le parcours B fonctionne (s5_r6).
- **s6_sp5** : obtenir l'avis juridique sur la distribution App Store avant la publication (s5_r5).

Je n'ajoute pas d'autre spike : aucun autre risque de l'étape 5 ne le justifie. Le risque de coût (s5_r8) est déjà traité par s6_sp1 et par le point des 6 semaines (s6_cc6). Si vous souhaitez retirer ou fusionner un spike, dites-le-moi.

**3. Fournisseurs d'IA (s6_d1 mis à jour).** La clé optionnelle accepte tout service compatible avec l'API OpenAI, avec une adresse d'API configurable par l'utilisateur. J'ai reporté ce choix à deux endroits :
- dans le récit s6_us15, avec un nouveau critère sur l'adresse configurable ;
- dans le risque s5_r4.

**Ce qui reste ouvert, sans bloquer le backlog :**
- le contenu exact de l'écran de consentement, à arrêter avant de livrer la clé d'IA ;
- le contenu de la liste fixe de catégories ;
- le résultat de l'avis juridique.

Le passage à l'étape suivante est décidé par les règles du serveur.

# Open Questions and Uncertainties

- Contenu exact de l'écran de consentement de la clé d'IA (action de s5_r4), à arrêter avant la livraison de s6_us15.
- Contenu de la liste fixe prédéfinie de catégories (décision s2_d8, liste non encore arrêtée).
- Résultat de l'avis juridique sur la distribution App Store sous double licence GPLv3 et licence commerciale.

## Open Questions

- Que doit présenter l'écran de consentement unique de la clé d'IA ?: Comme l'adresse d'API est configurable, les données (textes de messages, photos) peuvent partir vers n'importe quel service. L'écran doit permettre un consentement éclairé (s5_r4), et la définition de terminé de s6_us15 en dépend. | Options: ["Adresse d'API saisie et types de données envoyées (texte de recette, texte de messages, photos)", "Adresse d'API, types de données et rappel que le coût est à la charge de l'utilisateur", "Je fournirai le texte avant la livraison de la clé d'IA"] | Recommended: Adresse d'API, types de données et rappel que le coût est à la charge de l'utilisateur
- Quelles catégories doivent figurer dans la liste fixe prédéfinie de la V1 ?: Le regroupement par catégorie (s6_us11) et le chantier s6_cc3 dépendent de cette liste. Elle détermine aussi la lisibilité de la liste Rappels pour le foyer (H3). | Options: ['Je fournis ma liste de catégories', 'Je la définirai pendant le socle recette'] | Recommended: Je fournis ma liste de catégories

# Questions to Continue

- Que doit présenter l'écran de consentement unique de la clé d'IA ?
- Quelles catégories doivent figurer dans la liste fixe prédéfinie de la V1 ?

# Stage Deliverable

## Stage 6 - Backlog Synthesis

### Facts

- None explicitly confirmed yet.

### Assumptions

- None explicitly recorded.

### Decisions

- La clé de fournisseur d'IA optionnelle accepte tout service compatible avec l'API OpenAI, avec une adresse d'API configurable par l'utilisateur. (Réponses explicites de l'utilisateur : « format openai pour les provider », puis « tout service compatible avec l'API OpenAI ».)
- Double licence : GPLv3 et licence commerciale, avec CLA. L'AGPLv3 n'est pas retenue. (Réponse explicite de l'utilisateur. Elle tranche le choix entre GPLv3 et AGPLv3 laissé ouvert dans s5_r5.)

### Risks

- [Sécurité et conformité] Les données envoyées au fournisseur d'IA choisi par l'utilisateur, une fois sa clé activée, posent un problème de confidentialité (texte de messages, photos). | impact: Élevé (confirmé) en cas de publication grand public ; faible pour le foyer en V1. | probability: Faible (confirmée) en V1 : l'option est désactivée par défaut. | mitigation: Option désactivée par défaut et écran de consentement unique présentant les données envoyées et le fournisseur choisi. Tout service compatible avec l'API OpenAI, avec une adresse d'API configurable par l'utilisateur (s6_d1) : l'écran doit donc montrer l'adresse saisie. | action: Avant de livrer la clé d'IA optionnelle, arrêter le contenu exact affiché sur l'écran de consentement.
- [Sécurité et conformité] La licence GPL ou AGPL est incompatible avec la distribution sur l'App Store, ou des contributions sont acceptées sans CLA, ce qui bloque la double licence. | impact: Élevé (confirmé) : la publication sur l'App Store est bloquée. | probability: Moyenne (confirmée). | mitigation: Double licence GPLv3 et licence commerciale, avec CLA (s6_d2). Binaire de l'App Store sous licence commerciale ou avec une exception App Store. | action: Mettre en place le CLA avant toute contribution externe et obtenir l'avis juridique prévu avant publication.

### Open Questions

- Que doit présenter l'écran de consentement unique de la clé d'IA ?
- Quelles catégories doivent figurer dans la liste fixe prédéfinie de la V1 ?

### Stage Fields

- mvp_user_stories: [{'id': 's6_us1', 'statement': "En tant qu'utilisateur principal, j'importe une recette depuis un lien web pour l'enregistrer au format standard.", 'objective': "Importer une recette web, de la saisie du lien jusqu'à l'enregistrement, en moins de 1 minute, correction comprise.", 'definition_of_done': "Un lien web, partagé ou collé, déclenche l'extraction puis l'affichage de l'écran de correction pré-rempli, avant l'enregistrement dans la bibliothèque. Le temps est inférieur à 1 minute, correction comprise, sur des recettes web réelles du foyer.", 'link': 'stage_4_impact_mapping:value_hypotheses:1', 'capability': 'Import de recette par lien web', 'ears_criteria': ["WHEN l'utilisateur partage ou colle un lien web de recette THE SYSTEM SHALL lancer l'extraction et afficher l'écran de correction pré-rempli avec le texte source visible"]}, {'id': 's6_us2', 'statement': "En tant qu'utilisateur principal, j'importe une recette depuis un texte collé ou partagé via l'extension de partage iOS.", 'objective': 'Importer une recette texte en moins de 1 minute, correction comprise.', 'definition_of_done': "Un texte collé, ou partagé via l'extension de partage iOS, est extrait, corrigeable et enregistré. Le temps est inférieur à 1 minute, correction comprise, sur des recettes texte réelles.", 'link': 'stage_4_impact_mapping:value_hypotheses:1', 'capability': 'Import de recette par texte collé ou partagé (extension de partage iOS)', 'ears_criteria': ["WHEN l'utilisateur partage un texte vers l'app via l'extension de partage iOS THE SYSTEM SHALL lancer l'extraction de la recette"]}, {'id': 's6_us3', 'statement': "En tant qu'utilisateur principal, j'importe une recette par photo (page de livre, magazine, fiche manuscrite).", 'objective': 'Importer une recette photo en moins de 2 minutes, correction comprise.', 'definition_of_done': "Une photo prise ou choisie est extraite, présentée dans l'écran de correction, puis enregistrée. Le temps est inférieur à 2 minutes, correction comprise, sur des pages de livre, de magazine et des fiches manuscrites réelles. Livraison en 3e position de l'ordre de livraison.", 'link': 'stage_1_problem_framing:measurable_objectives:2', 'capability': 'Import de recette par photo (page de livre, magazine, fiche manuscrite)', 'ears_criteria': []}, {'id': 's6_us4', 'statement': "En tant qu'utilisateur principal, j'ajoute des articles ou des recettes depuis des messages partagés ou copiés (SMS, WhatsApp, Messenger).", 'objective': 'Intégrer les messages reçus comme sources de la liste de la semaine.', 'definition_of_done': "Un message partagé via l'extension de partage iOS ou collé depuis le presse-papiers est extrait en articles. Ces articles sont intégrés à la liste fusionnée de la semaine. Le parcours fonctionne avec les messages issus des SMS, de WhatsApp et de Messenger.", 'link': 'stage_4_impact_mapping:value_hypotheses:0', 'capability': "Import d'articles ou de recettes depuis des messages partagés ou copiés (SMS, WhatsApp, Messenger)", 'ears_criteria': ["WHEN l'utilisateur partage ou colle un message THE SYSTEM SHALL en extraire les articles et les proposer comme source de la liste fusionnée"]}, {'id': 's6_us5', 'statement': "En tant qu'utilisateur principal, je fais extraire et standardiser les ingrédients et les étapes par l'IA embarquée Apple, avec repli par clé utilisateur, sinon correction manuelle.", 'objective': 'Produire automatiquement une recette standardisée (ingrédients, quantités, unités, étapes, portions) sans appel externe payé par le porteur.', 'definition_of_done': "L'extraction locale produit le format standard. Un échec ou un résultat partiel déclenche la chaîne de repli : clé de l'utilisateur si elle est activée, sinon écran de correction pré-rempli. Aucun appel externe n'est fait sans clé activée.", 'link': 'stage_4_impact_mapping:value_hypotheses:1', 'capability': "Extraction et standardisation des ingrédients et des étapes par l'IA embarquée Apple (repli par clé utilisateur, sinon correction manuelle)", 'ears_criteria': ["WHEN l'extraction par l'IA embarquée échoue ou est partielle et qu'aucune clé n'est activée THE SYSTEM SHALL afficher l'écran de correction pré-rempli avec le texte source visible", "WHEN l'extraction par l'IA embarquée échoue ou est partielle et que la clé de l'utilisateur est activée THE SYSTEM SHALL déléguer l'extraction au fournisseur choisi"]}, {'id': 's6_us6', 'statement': "En tant qu'utilisateur principal, je corrige la recette standardisée sur un écran pré-rempli, avec le texte source visible et une édition champ par champ.", 'objective': 'Rendre la correction assez rapide pour tenir les cibles de 1 minute (texte ou web) et de 2 minutes (photo).', 'definition_of_done': "L'écran affiche le texte source à côté des champs pré-remplis : titre, portions, ingrédients avec quantité et unité, étapes. Chaque champ est modifiable. L'enregistrement produit une recette au format standard.", 'link': 'stage_4_impact_mapping:value_hypotheses:1', 'capability': 'Correction manuelle de la recette standardisée, avec écran pré-rempli, texte source visible et édition champ par champ', 'ears_criteria': []}, {'id': 's6_us7', 'statement': "En tant qu'utilisateur principal, je consulte, recherche par titre, supprime et sélectionne plusieurs recettes avec leurs portions pour la liste.", 'objective': 'Choisir rapidement les recettes de la semaine (environ 5) et leurs portions.', 'definition_of_done': 'La bibliothèque liste les recettes enregistrées. Elle permet la recherche par titre, la suppression et la sélection multiple avec un nombre de portions par recette. La sélection alimente la génération de la liste.', 'link': 'stage_4_impact_mapping:value_hypotheses:0', 'capability': 'Bibliothèque de recettes minimale : liste, recherche par titre, suppression, sélection multiple avec portions pour la liste', 'ears_criteria': []}, {'id': 's6_us8', 'statement': "En tant qu'utilisateur principal, j'adapte les quantités d'une recette au nombre de portions choisi.", 'objective': 'Obtenir des quantités justes dans la liste sans calcul manuel.', 'definition_of_done': "Les quantités sont recalculées au prorata des portions. Les articles à l'unité qui donnent une fraction sont arrondis au supérieur. Des tests couvrent le cas de 1,5 œuf qui devient 2.", 'link': 'stage_4_impact_mapping:value_hypotheses:0', 'capability': "Mise à l'échelle simple selon le nombre de portions", 'ears_criteria': ["WHEN la mise à l'échelle produit une fraction pour un article à l'unité THE SYSTEM SHALL arrondir la quantité au supérieur"]}, {'id': 's6_us9', 'statement': "En tant qu'utilisateur principal, je cuisine une recette en suivi pas à pas.", 'objective': 'Cuisiner plus confortablement (hypothèse de confort, sans objectif chiffré).', 'definition_of_done': "Une recette enregistrée s'affiche étape par étape, avec un passage à l'étape suivante et à l'étape précédente. L'élément peut être reporté selon le plan de coupe (s5_d1), ou en premier selon l'exception s5_d3.", 'link': 'stage_4_impact_mapping:value_hypotheses:4', 'capability': 'Suivi pas à pas de la recette', 'ears_criteria': []}, {'id': 's6_us10', 'statement': "En tant qu'utilisateur principal, j'obtiens une liste de courses unique et cochable, fusionnée depuis les recettes sélectionnées et les messages.", 'objective': "Générer automatiquement la liste d'une semaine type et la rendre prête en moins de 2 minutes.", 'definition_of_done': "La liste fusionne les recettes, après mise à l'échelle, et les messages. Les unités comparables (g et kg, cl et l) sont converties puis additionnées. Les variantes de nom restent sur des lignes distinctes. Chaque ligne est cochable. Des tests couvrent chaque règle de fusion.", 'link': 'stage_4_impact_mapping:value_hypotheses:0', 'capability': 'Liste de courses unique, fusionnée depuis plusieurs recettes et messages, cochable', 'ears_criteria': ['WHEN deux lignes portent le même nom normalisé avec des unités comparables THE SYSTEM SHALL convertir puis additionner les quantités sur une seule ligne', 'WHEN deux articles sont des variantes de nom THE SYSTEM SHALL les conserver sur des lignes distinctes']}, {'id': 's6_us11', 'statement': "En tant qu'utilisateur principal, je vois les articles regroupés par catégorie selon une liste fixe, et je peux changer la catégorie d'un article.", 'objective': "Rendre la liste lisible pendant les courses, pour l'utilisateur comme pour le foyer.", 'definition_of_done': "Chaque article reçoit une catégorie de la liste fixe (s6_cc3). L'utilisateur peut la changer. Le regroupement est conservé dans la liste envoyée vers Rappels.", 'link': 'stage_4_impact_mapping:value_hypotheses:2', 'capability': "Regroupement des articles par catégorie (liste fixe prédéfinie), avec changement de catégorie d'un article", 'ears_criteria': []}, {'id': 's6_us12', 'statement': "En tant qu'utilisateur principal, je retouche la liste avant l'envoi en retirant des articles ou en modifiant des quantités.", 'objective': 'Ajuster la liste en quelques secondes sans la reconstruire.', 'definition_of_done': "Avant l'envoi, chaque ligne peut être retirée ou voir sa quantité modifiée. Les modifications sont reflétées dans la liste envoyée.", 'link': 'stage_4_impact_mapping:value_hypotheses:0', 'capability': "Retouche de la liste avant l'envoi vers Rappels : retrait d'articles et modification de quantité", 'ears_criteria': []}, {'id': 's6_us13', 'statement': "En tant qu'utilisateur principal, j'ajoute un article oublié (nom, quantité facultative) par un champ simple, sans IA, avant ou après l'envoi.", 'objective': 'Garder la liste partagée à jour sans la reconstruire ni la dupliquer.', 'definition_of_done': "Un ajout avec quantité d'un article déjà présent fusionne la quantité si les unités se comparent, sinon crée une ligne distincte. Un ajout sans quantité d'un article déjà présent conserve la ligne existante. Après l'envoi, l'ajout est renvoyé selon la correspondance par nom normalisé. Chaque cas est testé.", 'link': 'stage_4_impact_mapping:value_hypotheses:3', 'capability': "Ajout manuel d'un article par champ de saisie simple (nom et quantité facultative), sans IA, avant ou après l'envoi vers Rappels", 'ears_criteria': ["WHEN l'utilisateur ajoute sans quantité un article déjà présent THE SYSTEM SHALL conserver la ligne existante sans créer de nouvelle ligne", "WHEN l'utilisateur ajoute un article après l'envoi THE SYSTEM SHALL le renvoyer vers la liste Rappels selon la correspondance par nom normalisé"]}, {'id': 's6_us14', 'statement': "En tant qu'utilisateur principal, j'envoie la liste dans un seul sens vers une liste Apple Rappels partagée avec le foyer.", 'objective': "Permettre au foyer de cocher la liste dans Rappels, sans installer l'app.", 'definition_of_done': "La liste est poussée vers la liste Rappels partagée choisie. Lors d'un renvoi, la règle s'applique : ajout des articles absents, des articles seulement cochés et du complément de quantité ; quantité complète si les unités ne se comparent pas ; aucune suppression ni modification. Les coches du foyer ne remontent pas dans l'app. Les tests de s5_r2 passent.", 'link': 'stage_4_impact_mapping:value_hypotheses:2', 'capability': 'Envoi de la liste dans un seul sens vers une liste Apple Rappels partagée, avec la règle de correspondance par nom normalisé', 'ears_criteria': ["WHEN l'utilisateur renvoie une liste vers une liste Rappels existante THE SYSTEM SHALL ajouter uniquement les articles absents, les articles seulement cochés et les compléments de quantité, sans supprimer ni modifier d'élément existant"]}, {'id': 's6_us15', 'statement': "En tant qu'utilisateur principal, j'active, si je le souhaite, ma propre clé pour tout service d'IA compatible avec l'API OpenAI, avec une adresse d'API configurable, après un écran de consentement unique.", 'objective': "Offrir un repli d'extraction sans aucun coût pour le porteur.", 'definition_of_done': "L'option est désactivée par défaut. L'utilisateur saisit sa clé et l'adresse d'API de tout service compatible avec l'API OpenAI (s6_d1). L'écran de consentement unique présente les données envoyées et le fournisseur choisi, identifié par l'adresse saisie. Aucune confirmation n'est demandée à chaque envoi. Le texte du consentement doit être arrêté avant la livraison. L'élément est reportable selon le plan de coupe (s5_d1), sauf exception s5_d3.", 'link': 'stage_4_impact_mapping:value_hypotheses:1', 'capability': "Activation optionnelle d'une clé de fournisseur d'IA, avec écran de consentement unique", 'ears_criteria': ["WHEN l'utilisateur active sa clé pour la première fois THE SYSTEM SHALL afficher l'écran de consentement unique présentant les données envoyées et le fournisseur choisi", "WHEN l'utilisateur configure sa clé THE SYSTEM SHALL accepter l'adresse d'API de tout service compatible avec l'API OpenAI"]}]
- risk_spikes: [{'id': 's6_sp1', 'statement': "Tester l'IA embarquée Apple sur l'iPhone 15 Pro avec des recettes réelles du foyer (texte, web, photo, manuscrit).", 'objective': "Savoir avant le point des 6 semaines si l'IA embarquée et la correction manuelle tiennent les cibles de 1 et 2 minutes.", 'definition_of_done': "Un échantillon de recettes réelles de chaque type est chronométré, correction comprise. Les résultats sont comparés aux cibles. La conclusion est consignée pour décider de l'application de l'exception s5_d3.", 'link': 's5_r1', 'ears_criteria': []}, {'id': 's6_sp2', 'statement': "Vérifier la faisabilité de l'écriture et de la lecture d'une liste Apple Rappels partagée (articles existants, état coché) pour appliquer la règle de renvoi.", 'objective': "Lever tôt l'incertitude technique sur le renvoi sans doublons ni quantités surestimées.", 'definition_of_done': 'Un prototype écrit des articles dans une liste Rappels partagée et relit les articles existants et leur état coché. Les tests couvrent chaque branche de la règle : article absent, article coché, complément de quantité, unités non comparables, variante de nom.', 'link': 's5_r2', 'ears_criteria': []}, {'id': 's6_sp3', 'statement': "Chronométrer une semaine type réelle (environ 5 recettes et 2 messages), de la sélection jusqu'à Rappels.", 'objective': "Vérifier que la liste fusionnée tient l'objectif de moins de 2 minutes, retouche comprise.", 'definition_of_done': 'À la fin du parcours B, au moins une semaine réelle est chronométrée. Les retouches nécessaires sont notées et le résultat est comparé à la cible de 2 minutes.', 'link': 's5_r3', 'ears_criteria': []}, {'id': 's6_sp4', 'statement': 'Faire faire de vraies courses au foyer avec la liste Rappels partagée dès que le parcours B fonctionne.', 'objective': "Valider tôt l'hypothèse H3 et pouvoir corriger avant la fin de la V1.", 'definition_of_done': "Une liste réelle est envoyée vers la liste partagée. Il est vérifié que l'autre membre du foyer la coche pendant les courses, et un éventuel retour au papier ou aux messages est noté.", 'link': 's5_r6', 'ears_criteria': []}, {'id': 's6_sp5', 'statement': "Obtenir l'avis juridique sur la distribution App Store sous double licence GPLv3 et licence commerciale.", 'objective': "Sécuriser la publication sur l'App Store avant la mise en ligne.", 'definition_of_done': "L'avis juridique est obtenu avant la publication. Il confirme la distribution du binaire sous licence commerciale ou avec une exception App Store, et les conclusions sont consignées.", 'link': 's5_r5', 'ears_criteria': []}]
- cross_cutting_work: [{'id': 's6_cc1', 'statement': 'Définir le format de recette standardisé : titre, portions, ingrédients avec quantité et unité, étapes.', 'objective': "Fournir le socle commun à l'extraction, à la correction, à la mise à l'échelle et à la fusion.", 'definition_of_done': "Le modèle de données est implémenté et utilisé par tous les imports, par l'écran de correction et par la génération de la liste. Il est livré en premier, dans le socle recette.", 'link': 'stage_4_impact_mapping:value_hypotheses:1', 'ears_criteria': []}, {'id': 's6_cc2', 'statement': 'Construire un module partagé de normalisation des noms et de conversion des unités comparables.', 'objective': "Appliquer les mêmes règles à la fusion, à l'ajout manuel et au renvoi vers Rappels.", 'definition_of_done': 'Le module normalise les noms et convertit les unités comparables (g et kg, cl et l). Il est utilisé par s6_us10, s6_us13 et s6_us14 et couvert par des tests unitaires.', 'link': 's5_r3', 'ears_criteria': []}, {'id': 's6_cc3', 'statement': 'Arrêter la liste fixe prédéfinie des catégories de la V1.', 'objective': 'Permettre le regroupement par catégorie décidé en s2_d8.', 'definition_of_done': "La liste des catégories est validée par le porteur et intégrée au socle. Chaque article reçoit une catégorie par défaut, modifiable par l'utilisateur.", 'link': 'stage_4_impact_mapping:value_hypotheses:2', 'ears_criteria': []}, {'id': 's6_cc4', 'statement': "Mettre en place l'extension de partage iOS et la lecture du presse-papiers comme points d'entrée communs.", 'objective': 'Servir les imports de liens web, de textes et de messages par un même mécanisme.', 'definition_of_done': "L'app apparaît dans la feuille de partage iOS pour les liens et les textes, et accepte le collage. Le contenu reçu est routé vers l'import de recette ou vers l'import de message.", 'link': 'stage_1_problem_framing:hypotheses:1', 'ears_criteria': []}, {'id': 's6_cc5', 'statement': 'Mettre en place la double licence GPLv3 et licence commerciale, avec CLA.', 'objective': "Préserver la double licence et la possibilité d'une distribution sur l'App Store.", 'definition_of_done': 'Les fichiers de licence GPLv3 et la mention de la licence commerciale sont présents dans le dépôt. Le CLA est en place avant toute contribution externe.', 'link': 's5_r5', 'ears_criteria': []}, {'id': 's6_cc6', 'statement': 'Tenir le point de contrôle des 6 semaines et appliquer, si nécessaire, le plan de coupe s5_d1 ou son exception s5_d3. Réserver des créneaux réguliers de plus de 10 heures par semaine (s5_r9).', 'objective': 'Livrer une V1 utile dans environ 3 mois malgré un porteur seul sur son temps libre.', 'definition_of_done': "À 6 semaines, l'avancement est comparé à l'ordre de livraison : socle recette et parcours B livrés. Si ce n'est pas le cas, le plan de coupe est appliqué : clé d'IA reportée d'abord, puis suivi pas à pas. Selon le résultat de s6_sp1, l'exception s5_d3 s'applique. La décision est consignée.", 'link': 's5_r7', 'ears_criteria': []}]

### Readiness

- 7/7 passed/total
- [x] field:mvp_user_stories: Required field mvp_user_stories: clear
- [x] field:risk_spikes: Required field risk_spikes: clear
- [x] field:cross_cutting_work: Required field cross_cutting_work: clear
- [x] backlog_traceability: Every backlog item needs objective, definition of done, an existing goal/risk/hypothesis link and valid optional EARS criteria.
- [x] backlog_scope: Every MVP backlog capability must exist in stage 2 MVP scope.
- [x] blocking_questions: Blocking questions remain open.
- [x] contradictions: Unresolved contradictions: 
- mvp_user_stories: clear
- risk_spikes: clear
- cross_cutting_work: clear

### Clarifications

- 2026-11-22T14:07:22.689442+01:00: Validez-vous le backlog proposé (15 récits MVP, 5 spikes, 6 chantiers transverses), ou souhaitez-vous en modifier certains éléments ? -> 1. ok
2. que proposes tu?
3. tout service compatible avec l'API OpenAI
- 2026-11-22T14:07:22.689448+01:00: « Format OpenAI » signifie-t-il le service OpenAI uniquement, ou tout service compatible avec l'API OpenAI, avec une adresse d'API configurable par l'utilisateur ? -> 1. ok
2. que proposes tu?
3. tout service compatible avec l'API OpenAI
- 2026-11-22T14:07:22.689450+01:00: Quels spikes (explorations) faut-il pour réduire les principaux risques ? -> 1. ok
2. que proposes tu?
3. tout service compatible avec l'API OpenAI

### Transition Decision

- Stage clear enough: yes
- Reason: All coded stage requirements are satisfied and no blocking questions remain.

## Stage 7 - Delivery Slicing

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
