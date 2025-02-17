#!/usr/bin/env bash

services=(
  "local-net"
)

# Reload SystemD units files
systemctl --user daemon-reload

for service in ${services[@]}; do
  systemctl --user enable "${service}.service"
  systemctl --user start "${service}.service"
done
