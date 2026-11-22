# slice-4 (vague 3)

Suivi pas à pas. Deuxième des trois tranches restantes ; coupée après la clé (s5_d1), ou en premier si s5_d3 s'applique.

## Dépendances

slice-2

## Domaine possédé

- Session de cuisine (étape courante d'une recette)

## Éléments du backlog

### s6_us9

En tant qu'utilisateur principal, je cuisine une recette en suivi pas à pas.

- Objectif : Cuisiner plus confortablement (hypothèse de confort, sans objectif chiffré).
- Terminé quand : Une recette enregistrée s'affiche étape par étape, avec un passage à l'étape suivante et à l'étape précédente. L'écran reste allumé pendant le suivi. Tranche reportable selon le plan de coupe (s5_d1), ou en premier selon l'exception s5_d3.
- `WHEN l'utilisateur passe à l'étape suivante ou précédente THE SYSTEM SHALL afficher cette étape et sa position dans la recette`

## Contrats fournis

- **ct-session-cuisine** — ouvrir(recette_id) → étapes ordonnées ; suivante ; precedente ; position. Aucune écriture dans la recette.

## Contrats consommés

- **ct-bibliotheque** — enregistrer(Recette) → id ; lire(id) ; modifier(Recette) ; lister() ; rechercherParTitre(texte) ; supprimer(id). Stockage local persistant dans l'app (SwiftData), conservé entre lancements et mises à jour, sans copie réseau. Sauvegarde : celle de l'iPhone ; pas d'export propre en V1. Échec d'écriture : signalé, saisie conservée à l'écran.

## Scénarios d'intégration

1. Étant donné : Une recette de 5 étapes est enregistrée
   Quand : L'utilisateur ouvre le suivi, avance de deux étapes puis recule d'une
   Alors : L'étape 2 sur 5 est affichée et l'écran reste allumé
   `WHEN l'utilisateur passe à l'étape suivante ou précédente THE SYSTEM SHALL afficher cette étape et sa position dans la recette`

## Bouchons

Aucun
