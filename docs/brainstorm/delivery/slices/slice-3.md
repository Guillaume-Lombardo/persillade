# slice-3 (vague 3)

Import de recette par photo. Première des trois tranches restantes (ordre s2_d7) ; maintien décidé au jalon J1 selon s6_sp1.

## Dépendances

slice-2

## Domaine possédé

- Capture photo (image et texte lu)

## Éléments du backlog

### s6_us3

En tant qu'utilisateur principal, j'importe une recette par photo (page de livre, magazine, fiche manuscrite).

- Objectif : Importer une recette photo en moins de 2 minutes, correction comprise.
- Terminé quand : Une photo prise dans l'app ou choisie dans la photothèque est lue par reconnaissance de texte sur l'iPhone (Vision), puis suit ct-extraction. L'entrée image directe du modèle embarqué n'est utilisée que si s6_sp1 montre qu'elle fonctionne sur l'iPhone 15 Pro et fait mieux. Accès photo refusé ou aucun texte lu : message clair et correction manuelle. Le temps est inférieur à 2 minutes, correction comprise, sur des pages de livre, de magazine et des fiches manuscrites réelles ; les échecs complets sont rapportés à part.
- `WHEN l'utilisateur prend ou choisit une photo de recette THE SYSTEM SHALL en extraire le texte sur l'iPhone et afficher l'écran de correction pré-rempli`
- `WHEN aucun texte n'est lu sur la photo THE SYSTEM SHALL l'indiquer et ouvrir l'écran de correction vide avec la photo visible`

## Contrats fournis

- **ct-photo** — lireTexte(image) → texte (Vision, sur l'iPhone) ou rien_trouve ; le ContenuRecu reste de type image et extraire appelle lireTexte, pour que l'image reste disponible à la clé externe ; image conservée pour l'écran de correction jusqu'à l'enregistrement, puis supprimée.

## Contrats consommés

- **ct-entree-partage** — ContenuRecu {id, type (url | texte | image), contenu, origine (feuille_partage | presse_papiers | appareil_photo | phototheque), recu_le}. L'extension accepte url et texte, écrit dans l'App Group puis se ferme, sans réseau ni IA. L'app traite la file à l'ouverture, demande la destination (recette | message), et retire l'élément une fois enregistré ou abandonné explicitement. Les origines appareil_photo et phototheque sont branchées en slice-3.
- **ct-extraction** — extraire(ContenuRecu, cible : recette | message) → {statut, cause (facultative), moteur (structure | embarque | cle_externe | manuel), texte_source, recette partielle ou articles}. Statut recette — complet : titre, au moins un ingrédient, tous les ingrédients nommés, au moins une étape ; partiel : au moins un titre, un ingrédient ou une étape, sans être complet ; echec : rien d'exploitable. Portions absentes : n'affecte pas le statut. Statut message — complet : au moins un article, tous nommés, extraits par l'IA ; partiel : au moins un article, sans être complet, y compris par découpage par ligne (ia_indisponible, ia_en_erreur ou contenu_trop_long) ; echec : aucun article. Causes : ia_indisponible, ia_en_erreur, hors_ligne, page_inaccessible, delai, contenu_trop_long, rien_trouve, fournisseur_en_erreur. Ordre : 1) données structurées (JSON-LD) et analyse déterministe des lignes d'ingrédients ; 2) IA embarquée sur ce qui manque ; 3) clé externe (slice-5 seulement), si activée, consentie, et si le statut est partiel ou echec avec un texte ou une image à envoyer ; 4) écran de correction, toujours. Contexte : taille lue à l'exécution ; un texte trop long est réduit au bloc recette, puis découpé en 3 morceaux au plus, extraits dans l'ordre et concaténés ; au-delà, partiel avec contenu_trop_long. Annulable par l'utilisateur à tout moment.
- **ct-bibliotheque** — enregistrer(Recette) → id ; lire(id) ; modifier(Recette) ; lister() ; rechercherParTitre(texte) ; supprimer(id). Stockage local persistant dans l'app (SwiftData), conservé entre lancements et mises à jour, sans copie réseau. Sauvegarde : celle de l'iPhone ; pas d'export propre en V1. Échec d'écriture : signalé, saisie conservée à l'écran.

## Scénarios d'intégration

1. Étant donné : Une page de livre de recettes est photographiée dans l'app
   Quand : La lecture et l'extraction se terminent
   Alors : L'écran de correction affiche la photo et les champs pré-remplis ; après correction, la recette est dans la bibliothèque
   `WHEN l'utilisateur prend ou choisit une photo de recette THE SYSTEM SHALL en extraire le texte sur l'iPhone et afficher l'écran de correction pré-rempli`

## Bouchons

- Photos réelles de test (livre, magazine, manuscrit) issues de s6_sp1
