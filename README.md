# Persillade

Persillade est une app iPhone pour organiser ses recettes, préparer les repas de la semaine et regrouper
les ingrédients dans une liste de courses à envoyer vers Apple Rappels. Les données sont stockées sur
l’iPhone. Le projet est en cours de développement et les captures des écrans définitifs seront ajoutées
avec les premiers parcours.

## Construction et tests

Il faut Xcode 27 ou plus récent, avec le runtime iOS 27. Ouvrir `Persillade.xcodeproj` et sélectionner
le schéma partagé **Persillade**. Le test de la photothèque utilise un simulateur neuf où le script
d’installation ajoute une seule photo de recette générée.

```sh
swift test --package-path Paquets/PersilladeCore
(
  set -e
  simulateur=$(xcrun simctl create "Persillade Tests" com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro com.apple.CoreSimulator.SimRuntime.iOS-27-0)
  trap 'xcrun simctl delete "$simulateur"' EXIT
  bash .github/scripts/preparer-phototheque-test.sh "$simulateur"
  xcodebuild -scheme Persillade -destination "platform=iOS Simulator,id=$simulateur" \
    -derivedDataPath .build/DerivedData -parallel-testing-enabled NO build test
)
xcodebuild -scheme Persillade -destination 'generic/platform=iOS' \
  -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build
git ls-files -z '*.swift' | xargs -0 swift format lint --strict
```

## Installation sur iPhone

1. Préparer un iPhone 15 Pro ou plus récent sous iOS 27. Dans Xcode, ajouter le compte de l’équipe
   Apple Developer Program qui a accès aux identifiants du projet.
2. Copier `Config/Local.xcconfig.example` vers `Config/Local.xcconfig` et renseigner `DEVELOPMENT_TEAM`
   dans la copie locale, ignorée par Git.
3. Vérifier que les identifiants `xyz.g1lom.persillade` et `xyz.g1lom.persillade.partage` sont associés
   à l’App Group `group.xyz.g1lom.persillade` dans cette équipe.
4. Connecter l’iPhone, activer le mode développeur si iOS le demande, puis choisir l’iPhone comme
   destination dans Xcode et lancer le schéma **Persillade**.

[Configuration des App Groups](https://developer.apple.com/help/account/identifiers/enable-app-capabilities/)

## Structure

- `Persillade/` contient l’interface SwiftUI et `PersilladePartage/` l’extension de partage iOS.
- `Paquets/PersilladeCore/` contient le cœur métier Swift pur et la cible `PersilladePlateforme`, dédiée
  aux adaptateurs Apple.
- `PersilladeTests/` et `PersilladeUITests/` contiennent les tests Xcode.
- `Config/` contient les réglages de compilation et `docs/` le cadrage et les décisions d’architecture.

## Licence

Le code public est distribué sous [GPLv3](LICENSE). Une [licence commerciale](LICENCE-COMMERCIALE.md)
peut être accordée séparément. Les modalités de contribution sont décrites dans [CONTRIBUTING.md](CONTRIBUTING.md).
