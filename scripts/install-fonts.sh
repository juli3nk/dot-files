#!/usr/bin/env bash

fontdir="${HOME}/.local/share/fonts"
ghdir="${HOME}/.local/Github"

mkdir -p "$fontdir" "$ghdir"
cd "$ghdir"

# Material Design Icons
git clone --depth 1 https://github.com/google/material-design-icons
ln -s "${PWD}/material-design-icons/font/MaterialIcons-Regular.ttf" "${fontdir}/"

# Community Fork
git clone --depth 1 https://github.com/Templarian/MaterialDesign-Webfont
ln -s "${PWD}/MaterialDesign-Webfont/fonts/materialdesignicons-webfont.ttf" "$fontdir/"

# FontAwesome
git clone --depth 1 https://github.com/FortAwesome/Font-Awesome
ln -s "${PWD}/Font-Awesome/otfs/Font Awesome 6 Brands-Regular-400.otf" "$fontdir/"
ln -s "${PWD}/Font-Awesome/otfs/Font Awesome 6 Free-Regular-400.otf" "$fontdir/"
ln -s "${PWD}/Font-Awesome/otfs/Font Awesome 6 Free-Solid-900.otf" "$fontdir/"

# Typicons
git clone --depth 1 https://github.com/stephenhutchings/typicons.font
ln -s "${PWD}/typicons.font/src/font/typicons.ttf" "$fontdir/"

fc-cache -fv
