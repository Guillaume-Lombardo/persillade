# Révision du 22/11/2026

Ce fichier et `delivery/` l'emportent sur les étapes 1 à 7 et sur `framing.md`, conservés pour l'historique.

## Décisions du porteur

- **r_d1 – Articles cochés.** Un ajout après l'envoi n'envoie que la ligne ajoutée. Lors d'un renvoi complet, un article coché avant le **premier envoi de la liste en cours** est ignoré, donc remis si la liste le demande. Un article coché depuis ce premier envoi compte comme acheté. Remplace d13 (étape 1) ; d12, d14 et d15 restent vrais et sont précisés par `ct-renvoi`. La formulation acceptée disait « avant le dernier envoi » : elle aurait fait oublier la semaine suivante les articles achetés la semaine précédente. L'intention est conservée.
- **r_d2 – Catégories.** Elles sont affichées dans l'app. Aucun regroupement n'est exigé dans Rappels. Le tri automatique d'une liste Rappels de type Courses est un bonus, constaté par s6_sp2.
- **r_d3 – Découpage.** Six tranches verticales ; la modification d'une recette enregistrée revient en V1 (s6_us6).
- **r_d4 – Nom.** Le projet s'appelle Persillade. Les marques restent à vérifier (classes 9 et 42) avant toute réservation ou publication.

## Précisions ajoutées, à relire par le porteur

| Sujet | Choix retenu | Où |
|---|---|---|
| Version d'iOS | iOS 27, iPhone 15 Pro et ultérieurs | slice-0 |
| Technique | SwiftUI, SwiftData, sans dépendance tierce | slice-0 |
| Arrondi | Après la fusion, pas par recette | ct-liste-courses |
| Cocher une ligne dans l'app | « À ne pas envoyer » | ct-liste-courses |
| Même article, une seule source avec quantité | La ligne avec quantité est gardée | ct-liste-courses |
| Ajout avec quantité sur une ligne sans quantité | La ligne prend la quantité | s6_us13 |
| Ajout sur une ligne cochée | Avec quantité : décochée. Sans quantité : telle quelle, l'app propose de décocher | ct-liste-courses |
| Nouvelle liste, seconde génération | Confirmation, qui annonce la perte des lignes actuelles | ct-liste-courses |
| Destination Rappels | Figée après la première écriture réussie de la liste en cours | ct-envoi-rappels |
| Portions absentes à l'import | 4, signalé à corriger | ct-recette-standard |
| Sauvegarde | Celle de l'iPhone, pas d'export propre en V1 | ct-bibliotheque |
| Consentement de la clé d'IA | Adresse, données envoyées, coût ; redemandé si l'hôte change | s6_us15 |
| Catégories | Liste proposée, à valider | ct-categories |

## Ordre et plan de coupe

1. slice-0 preuves et socle
2. slice-1 première vraie course
3. slice-2 parcours courses complet
4. slice-3 photo, puis slice-4 pas à pas, puis slice-5 clé d'IA. Ces trois tranches sont indépendantes entre elles : l'une peut être coupée sans bloquer les autres. L'ordre reste celui de s2_d7, car le porteur travaille seul.

## Jalons, hors tranche

- **J1 – Point des 6 semaines.**
  - slice-1 et slice-2 livrées : poursuivre dans l'ordre.
  - Sinon : reporter slice-5, puis slice-4 (s5_d1). Si s6_sp1 et les mesures de slice-1 montrent que l'extraction locale ne tient pas les cibles : reporter slice-4 d'abord et garder slice-5 (s5_d3).
  - Décider du maintien de slice-3 selon s6_sp1.
  - Comparer les durées mesurées, correction comprise, aux cibles inchangées, y compris en cas d'échec complet (s2_d10). Si elles ne tiennent pas, le porteur décide de la cible ou de la coupe.
- **J2 – Avis juridique (s6_sp5).** Avant toute publication sur l'App Store.

## Agrégats de l'étape 3, affinés

Le découpage vertical reste conforme aux règles du serveur, qui demandent un agrégat propre à chaque tranche :

- Recette standardisée (ingrédients, quantités, unités, étapes, portions)
- Liste de courses (lignes : nom normalisé, quantité, unité, catégorie, origine)
- Extraction (IA embarquée puis correction manuelle ; repli par clé externe ajouté en slice-5)
- Envoi vers Rappels (premier envoi et journal d'envoi)
- Renvoi vers Rappels (correspondance avec la liste partagée existante)
- Capture photo (image et texte lu)
- Session de cuisine (étape courante d'une recette)
- Accès au fournisseur d'IA (adresse, clé, consentement)

## Points ouverts, non bloquants pour démarrer

- Contenu des catégories : à valider pendant slice-0 (s6_cc3).
- Mode d'installation de la V1 sur l'iPhone (compte développeur Apple gratuit ou payant, TestFlight) : à choisir en slice-0, avec vérification que l'App Group fonctionne dans ce mode.
- Estimation en heures de chaque tranche : à faire en slice-0 (s6_cc6).

## Traçabilité

27 éléments : 16 récits, 5 spikes, 6 chantiers. s6_us14 est scindé (premier envoi) avec le nouveau s6_us16 (renvoi), même capacité de l'étape 2. s6_sp5 n'est rattaché à aucune tranche (J2).
