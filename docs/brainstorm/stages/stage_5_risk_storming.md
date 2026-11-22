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
