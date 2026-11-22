# Persillade

- Ordre d’autorité : brief du lot, `docs/brainstorm/revision.md`, contrats et tranches dans
  `docs/brainstorm/delivery/`, puis `docs/adr/`. `framing.md` et `stages/` sont historiques.
- App SwiftUI iPhone (iOS 27), sans serveur ni dépendance tierce. Le cœur métier en
  `PersilladeCore` importe Foundation uniquement. SwiftData, EventKit, FoundationModels,
  Vision et le trousseau relèvent de `PersilladePlateforme`. L’extension de partage ne lie
  que le cœur. Les groupes Xcode synchronisés prennent en compte les nouveaux fichiers.
- Swift 6 et concurrence stricte. Domaine en français, identifiants sans accents. UI en français.
  Conserver les invariants de recette, les fractions exactes et les contrats JSON versionnés.
  Propager les erreurs. Réserver `try!` et `fatalError` aux tests.
- Valider avec `swift test --package-path Paquets/PersilladeCore`,
  `git ls-files -z '*.swift' | xargs -0 swift format lint --strict` et le schéma Xcode
  `Persillade` (build iOS générique et build/test sur iPhone iOS 27). Utiliser
  `-derivedDataPath .build/DerivedData` dans chaque worktree. Les commandes figurent dans le README.
- Garder l’équipe de signature dans `Config/Local.xcconfig` ignoré. Les commits suivent
  Conventional Commits en anglais. Voir le CLA avant toute contribution externe.
