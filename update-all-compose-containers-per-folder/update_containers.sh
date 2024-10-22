#!/usr/bin/env bash

function print_line_break() {
  printf '%20s\n' | tr ' ' -
}

readarray -d '' composeConfigs < <(find . -type f -name docker-compose.y* -print0)

for cfg in "${composeConfigs[@]}"; do
  echo ""
  echo "[Updating docker-compose containers for config: $cfg]"
  print_line_break
  docker-compose -f "$cfg" pull
  docker-compose -f "$cfg" up -d
done

docker image prune
