# slice-5 (vague 3)

Clé d'IA optionnelle. Dernière des trois tranches restantes ; coupée en premier (s5_d1), sauf si s5_d3 s'applique.

## Dépendances

slice-2

## Domaine possédé

- Accès au fournisseur d'IA (adresse, clé, consentement)

## Éléments du backlog

### s6_us15

En tant qu'utilisateur principal, j'active, si je le souhaite, ma propre clé pour tout service d'IA compatible avec l'API OpenAI, avec une adresse d'API configurable, après un écran de consentement unique.

- Objectif : Offrir un repli d'extraction sans aucun coût pour le porteur.
- Terminé quand : L'option est désactivée par défaut. L'utilisateur saisit l'adresse d'API (https obligatoire), le nom du modèle et sa clé, conservée dans le trousseau iOS. Protocole pris en charge : POST {adresse}/chat/completions, seul protocole testé. Une photo n'est envoyée comme image que si l'utilisateur indique que le modèle accepte les images ; sinon seul le texte lu par Vision est envoyé. L'écran de consentement unique présente l'adresse saisie, les types de données envoyées et le coût à la charge de l'utilisateur ; il est redemandé si l'hôte change ou avant l'envoi d'un type de données non couvert (par exemple les images), pas à chaque envoi. Refus, délai de 30 s, erreur du service : retour au meilleur résultat local et à l'écran de correction. La clé n'apparaît dans aucun journal. Tranche reportable selon s5_d1, sauf exception s5_d3.
- `WHEN l'utilisateur active sa clé pour la première fois THE SYSTEM SHALL afficher l'écran de consentement unique présentant les données envoyées et le fournisseur choisi`
- `WHEN l'utilisateur configure sa clé THE SYSTEM SHALL accepter l'adresse d'API de tout service compatible avec l'API OpenAI`
- `WHEN l'extraction par l'IA embarquée échoue ou est partielle et que la clé de l'utilisateur est activée THE SYSTEM SHALL déléguer l'extraction au fournisseur choisi`
- `WHEN l'hôte de l'adresse d'API change THE SYSTEM SHALL redemander le consentement avant tout envoi`
- `WHEN le fournisseur est en erreur THE SYSTEM SHALL afficher l'écran de correction avec le meilleur résultat local`

## Contrats fournis

- **ct-fournisseur-ia** — ConfigurationFournisseur {adresse https, modele, accepte_images, cle (trousseau iOS), hote_consenti, types_consentis}. completer(texte ou image) → résultat au format de ct-extraction, ou fournisseur_en_erreur. hote_consenti comprend l'hôte et le port. Une redirection vers une autre origine est refusée avant tout envoi. Refusé si la clé est absente, l'option désactivée, l'hôte différent de hote_consenti ou le type de données absent de types_consentis.

## Contrats consommés

- **ct-extraction** — extraire(ContenuRecu, cible : recette | message) → {statut, cause (facultative), moteur (structure | embarque | cle_externe | manuel), texte_source, recette partielle ou articles}. Statut recette — complet : titre, au moins un ingrédient, tous les ingrédients nommés, au moins une étape ; partiel : au moins un titre, un ingrédient ou une étape, sans être complet ; echec : rien d'exploitable. Portions absentes : n'affecte pas le statut. Statut message — complet : au moins un article, tous nommés, extraits par l'IA ; partiel : au moins un article, sans être complet, y compris par découpage par ligne (ia_indisponible, ia_en_erreur ou contenu_trop_long) ; echec : aucun article. Causes : ia_indisponible, ia_en_erreur, hors_ligne, page_inaccessible, delai, contenu_trop_long, rien_trouve, fournisseur_en_erreur. Ordre : 1) données structurées (JSON-LD) et analyse déterministe des lignes d'ingrédients ; 2) IA embarquée sur ce qui manque ; 3) clé externe (slice-5 seulement), si activée, consentie, et si le statut est partiel ou echec avec un texte ou une image à envoyer ; 4) écran de correction, toujours. Contexte : taille lue à l'exécution ; un texte trop long est réduit au bloc recette, puis découpé en 3 morceaux au plus, extraits dans l'ordre et concaténés ; au-delà, partiel avec contenu_trop_long. Annulable par l'utilisateur à tout moment.

## Scénarios d'intégration

1. Étant donné : La clé est activée et consentie pour un hôte, et l'IA embarquée renvoie un résultat partiel
   Quand : L'extraction se poursuit
   Alors : Le texte est envoyé à cet hôte sans confirmation supplémentaire, puis l'écran de correction s'affiche avec le résultat
   `WHEN l'extraction par l'IA embarquée échoue ou est partielle et que la clé de l'utilisateur est activée THE SYSTEM SHALL déléguer l'extraction au fournisseur choisi`

2. Étant donné : La clé est activée et consentie pour un hôte
   Quand : L'utilisateur remplace l'adresse par un autre hôte
   Alors : Aucun envoi n'a lieu avant un nouveau consentement
   `WHEN l'hôte de l'adresse d'API change THE SYSTEM SHALL redemander le consentement avant tout envoi`

## Bouchons

- Serveur factice compatible avec l'API OpenAI (succès, erreur, délai)
