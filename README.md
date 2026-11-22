# Persillade

Persillade est une app iPhone pour organiser ses recettes, préparer les repas de la semaine et regrouper
les ingrédients dans une liste de courses à envoyer vers Apple Rappels. Les données sont stockées sur
l’iPhone. Le projet est en cours de développement et les captures des écrans définitifs seront ajoutées
avec les premiers parcours.

## Construction et tests

Il faut Xcode 27 ou plus récent, avec le runtime iOS 27. Ouvrir `Persillade.xcodeproj` et sélectionner
le schéma partagé **Persillade**. Le test de la photothèque utilise un simulateur neuf où le script
de préparation ajoute une photo de recette générée en tête du sélecteur.

```sh
swift test --package-path Paquets/PersilladeCore
(
  set -e
  simulateur=$(xcrun simctl create "Persillade Tests" com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro com.apple.CoreSimulator.SimRuntime.iOS-27-0)
  trap 'xcrun simctl delete "$simulateur"' EXIT
  xcodebuild -scheme Persillade -destination "platform=iOS Simulator,id=$simulateur" \
    -derivedDataPath .build/DerivedData build-for-testing
  xcrun simctl boot "$simulateur"
  bash .github/scripts/preparer-phototheque-test.sh "$simulateur"
  xcodebuild -scheme Persillade -destination "platform=iOS Simulator,id=$simulateur" \
    -derivedDataPath .build/DerivedData -parallel-testing-enabled NO test-without-building
)
xcodebuild -scheme Persillade -destination 'generic/platform=iOS' \
  -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build
git ls-files -z '*.swift' | xargs -0 swift format lint --strict
```

Dans la CI, le job `app` attend la fin du démarrage d’un iPhone 17 sous iOS 27.0
avant de lancer les tests. En cas d’échec, le rapport `.xcresult` est conservé
trois jours si Xcode a pu le produire.

Le [banc d’extraction](docs/mesures/extraction.md) se lance séparément et produit un rapport Markdown.

## Installation sur iPhone

1. Préparer un iPhone 15 Pro ou plus récent sous iOS 27. Dans Xcode, ajouter le compte de l’équipe
   Apple Developer Program qui a accès aux identifiants du projet.
2. Copier `Config/Local.xcconfig.example` vers `Config/Local.xcconfig` et renseigner `DEVELOPMENT_TEAM`
   dans la copie locale, ignorée par Git.
3. Dans le compte Apple Developer, associer les identifiants explicites `xyz.g1lom.persillade` et
   `xyz.g1lom.persillade.partage` à l’App Group `group.xyz.g1lom.persillade`. Les deux cibles
   utilisent ce groupe pour transmettre les recettes de la feuille de partage à l’app.
4. Connecter et déverrouiller l’iPhone, accepter « Faire confiance à cet ordinateur » si iOS le
   demande, puis l’appairer dans Xcode et l’inscrire dans l’équipe de développement. Si nécessaire,
   activer le mode développeur dans **Réglages → Confidentialité et sécurité → Mode développeur**,
   redémarrer et confirmer l’activation.
5. Lancer le schéma **Persillade** sur l’iPhone depuis Xcode, ou utiliser les commandes suivantes
   depuis la racine du dépôt. Renseigner l’identifiant de destination affiché par Xcode dans
   `PERSILLADE_IPHONE`. La commande de build autorise Xcode à créer ou à actualiser les profils,
   les identifiants et les certificats nécessaires à la signature automatique.

   ```sh
   xcodebuild -scheme Persillade -destination "platform=iOS,id=$PERSILLADE_IPHONE" \
     -derivedDataPath .build/DerivedData -allowProvisioningUpdates build
   xcrun devicectl device install app --device "$PERSILLADE_IPHONE" \
     .build/DerivedData/Build/Products/Debug-iphoneos/Persillade.app
   xcrun devicectl device process launch --device "$PERSILLADE_IPHONE" xyz.g1lom.persillade
   ```

6. Si iOS affiche « Développeur non approuvé », ouvrir **Réglages → Général → VPN et gestion de
   l’appareil**, sélectionner l’identité de développement si elle y figure et suivre l’invite de
   confiance avant de relancer l’app.

[Configuration des App Groups](https://developer.apple.com/help/account/identifiers/enable-app-capabilities/) ·
[Mode développeur](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)

## Structure

- `Persillade/` contient l’interface SwiftUI et `PersilladePartage/` l’extension de partage iOS.
- `Paquets/PersilladeCore/` contient le cœur métier Swift pur et la cible `PersilladePlateforme`, dédiée
  aux adaptateurs Apple.
- `PersilladeTests/` et `PersilladeUITests/` contiennent les tests Xcode.
- `Config/` contient les réglages de compilation et `docs/` le cadrage et les décisions d’architecture.

## Licence

Le code public est distribué sous [GPLv3](LICENSE). Une [licence commerciale](LICENCE-COMMERCIALE.md)
peut être accordée séparément. Les modalités de contribution sont décrites dans [CONTRIBUTING.md](CONTRIBUTING.md).
