#!/bin/bash
# Rend les écrans de maquettes.html en PNG @2x (393 × 852 pt), la planche contact et la preuve du motif.
set -eu
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PROFIL="$(mktemp -d)"; trap 'rm -rf "$PROFIL"' EXIT
rendre() { "$CHROME" --headless --hide-scrollbars --user-data-dir="$PROFIL" --force-device-scale-factor="$1" --window-size="$2" --screenshot="$3" "file://$PWD/$4" >/dev/null 2>&1; }
SOMBRES=" recettes fiche correction semaine courses coursesenv rapport pas "
for e in recettes:01-recettes fiche:02-fiche-recette correction:03-import-correction saisie:04-correction-saisie \
         etapes:05-correction-etapes vide:06-recettes-vide semaine:07-semaine semaineavis:08-semaine-avis \
         courses:09-courses coursesenv:10-courses-apres-envoi detail:11-detail-ligne ajout:12-ajout-manuel \
         destination:13-destination message:14-articles-message listes:15-choix-liste acces:16-acces-refuse \
         rapport:17-rapport-envoi pas:18-pas-a-pas coursesax:19-courses-ax3 \
         correctionax:20-correction-ax3 pasax:21-pas-a-pas-ax3; do
  k="${e%%:*}"; rendre 2 393,852 "${e#*:}.png" "maquettes.html?e=$k"
  case "$SOMBRES" in *" $k "*) rendre 2 393,852 "${e#*:}-sombre.png" "maquettes.html?e=$k&m=sombre";; esac
done
rendre 1 3720,4080 ../planche.png maquettes.html
rendre 1.5 1920,1760 ../preuve-motif.png preuve-motif.html
