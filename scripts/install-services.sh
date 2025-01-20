#!/usr/bin/env bash

# Recharger les fichiers d'unités systemd
systemctl --user daemon-reload

for service in ${services[@]}; do
  systemctl --user enable "${service}.service"
  systemctl --user start "${service}.service"
done
