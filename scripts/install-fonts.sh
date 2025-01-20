#!/usr/bin/env bash

declare -a nerd_fonts=(
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
nerd_fonts_repo_url="https://github.com/ryanoasis/nerd-fonts"
nerd_fonts_version="$(git ls-remote --refs --tags "$nerd_font_repo_url" | tail -n 1 | awk -F '/' '{ print $NF }')"

others_fonts=(
  "https://github.com/google/material-design-icons;material-design-icons/font;material-design-icons-font"
  "https://github.com/Templarian/MaterialDesign-Webfont;MaterialDesign-Webfont/fonts;materialdesign-webfont"
  "https://github.com/FortAwesome/Font-Awesome;Font-Awesome/otfs;font-awesome"
  "https://github.com/stephenhutchings/typicons.font;typicons.font/src/font;typicons-font"
)
fonts_others_dir="${HOME}/.lcoal/Github"

fonts_dir="${HOME}/.local/share/fonts"

mkdir -p "$fonts_dir"

# Download NerdFonts
for font in "${nerd_fonts[@]}"; do
  download_url="${nerd_fonts_repo_url}/releases/download/${nerd_fonts_version}/${font}.tar.xz"

  echo "Downloading $download_url"
  curl -sfL "$download_url" | tar -xJC "$fonts_dir"
done

# Download Others Fonts
mkdir -p "$fonts_others_dir"

for font in "${others_fonts[@]}"; do
  font_url="$(echo "$font" | awk -F';' '{ print $1 }')"
  font_dir_src="$(echo "$font" | awk -F';' '{ print $2 }')"
  font_dir_dst="$(echo "$font" | awk -F';' '{ print $3 }')"

  git clone --depth 1 "$font_url" "${fonts_others_dir}/${font_dir_src}"
  ln -s "${fonts_others_dir}/${font_dir_src}" "${fonts_dir}/${font_dir_dst}"
done

# Delete unnecessary files
find "$fonts_dir" -name '*Windows Compatible*' -delete
find "$fonts_dir" -name '*.txt' -delete
find "$fonts_dir" -name '*.md' -delete

# Build cache fonts
fc-cache -fv
