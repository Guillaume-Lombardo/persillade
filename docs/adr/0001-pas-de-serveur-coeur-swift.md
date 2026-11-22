# 0001 — Stockage local et cœur métier en Swift

**Décision adoptée le 22/11/2026.**

Persillade garde les données de l’app sur l’iPhone, sans copie sur un serveur du projet ni appel
externe payé par le porteur. L’app s’intègre aux listes Apple Rappels choisies par l’utilisateur.
Le cœur métier est un paquet Swift pur, sans UI, testé sur macOS et partagé par l’app et son
extension. Les intégrations aux frameworks Apple vivent dans la cible `PersilladePlateforme`.

Le porteur envisageait un service Go ou Rust. Un service Go impliquerait exploitation, comptes,
traitement de données privées et obligations RGPD, sans fonction exigeant un serveur. Un cœur Rust
embarqué via UniFFI ajouterait une chaîne de compilation, un xcframework, un pont de types et une
dépendance tierce. Avec un seul client iPhone, ce pont ne servirait aucun autre client.

Rouvrir la décision dans deux cas.

- Un client Android ou web doit réutiliser le cœur métier. Réévaluer un cœur Rust partagé.
- Une synchronisation multi-appareils hors iCloud ou une extraction serveur devient nécessaire.
  Réévaluer un petit service Go après avoir cadré la confidentialité et l’exploitation.
