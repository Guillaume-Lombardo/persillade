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
