# Ingrédients alternatifs

Une recette peut proposer plusieurs choix pour un même ingrédient, par exemple « 6 abricots
ou 12 oreillons d’abricots au sirop ». Le choix principal garde les champs de l’ingrédient.
La recette JSON v2 ajoute `alternatives`, une liste ordonnée de choix avec leur propre nom,
quantité exacte et unité éventuelles. Une recette v1 garde ses données et prend une liste vide.

L’analyse reconnaît les choix séparés par « ou » lorsqu’une mesure introduit chaque choix.
Elle interprète aussi « chocolat noir ou au lait » avec une seule mesure comme deux choix pour
cette même mesure. Les précisions sans mesure propre, dont « bintje ou charlotte », restent
associées au nom. La correction permet d’ajouter, de modifier, de supprimer ou de promouvoir
une alternative en conservant la citation d’origine.

La mise à l’échelle applique à chaque choix le rapport exact des portions. La liste de courses
additionne les principaux et conserve les alternatives comme mentions indépendantes, dans
l’ordre de rencontre. Les mentions strictement identiques ne sont affichées qu’une fois.
Les listes enregistrées avant cette évolution ont des mentions vides. Le contrat d’envoi vers
Rappels écrit le titre du principal et ne prévoit pas de champ de note.
