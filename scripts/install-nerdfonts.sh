#!/usr/bin/env bash

declare -a fonts=(
  "Agave"
  "AnonymousPro"
  "Arimo"
  "AurulentSansMono"
  "BigBlueTerminal"
  "BitstreamVeraSansMono"
#  "CascaidaCode"
  "CodeNewRoman"
  "Cousine"
  "DaddyTimeMono"
  "DejaVuSansMono"
  "DroidSansMono"
  "FantasqueSansMono"
  "FiraCode"
  "FiraMono"
  "Go-Mono"
  "Gohu"
  "Hack"
  "Hasklig"
  "HeavyData"
  "Hermit"
  "iA-Writer"
  "IBMPlexMono"
#  "Inconsolate"
  "InconsolataGo"
  "InconsolataLGC"
  "Iosevka"
  "JetBrainsMono"
  "Lekton"
  "LiberationMono"
  "Lilex"
  "Meslo"
  "Monofur"
  "Mononoki"
  "Monoid"
  "MPlus"
  "NerdFontsSymbolsOnly"
  "Noto"
  "OpenDyslexic"
  "Overpass"
  "ProFont"
  "ProggyClean"
  "RobotoMono"
  "ShareTechMono"
  "Terminus"
  "Tinos"
  "Ubuntu"
  "UbuntuMono"
  "VictorMono"
)

version="$(git ls-remote --refs --tags https://github.com/ryanoasis/nerd-fonts | tail -n 1 | awk -F '/' '{ print $NF }')"
fonts_dir="${HOME}/.local/share/fonts"

if [ ! -d "$fonts_dir" ]; then
  mkdir -p "$fonts_dir"
fi

for font in "${fonts[@]}"; do
  download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font}.tar.xz"

  echo "Downloading $download_url"
  curl -sfL "$download_url" | tar -xJC "$fonts_dir"
done

find "$fonts_dir" -name '*Windows Compatible*' -delete
find "$fonts_dir" -name '*.txt' -delete
find "$fonts_dir" -name '*.md' -delete

fc-cache -fv
