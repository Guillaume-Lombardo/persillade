#!/bin/bash
set -euo pipefail

# Le test sélectionne l’unique image d’un simulateur neuf.
simulateur_photo_test=${1:?Indiquer l’UDID d’un simulateur neuf.}
mkdir -p .build
swift .github/scripts/generer-photo-import.swift .build/recette-test.jpg
xcrun simctl bootstatus "$simulateur_photo_test" -b
xcrun simctl addmedia "$simulateur_photo_test" .build/recette-test.jpg
