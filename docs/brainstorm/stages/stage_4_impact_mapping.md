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
