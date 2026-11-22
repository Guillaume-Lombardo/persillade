> **Révisé le 22/11/2026 :** agrégats affinés, règle de renvoi remplacée. En cas d'écart, [revision.md](../revision.md) et `delivery/` l'emportent.

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
