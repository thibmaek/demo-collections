#!/usr/bin/env bash

readarray -d '' composeConfigs < <(find . -type f -name docker-compose.y* -print0)

for cfg in "${composeConfigs[@]}"; do
  docker-compose -f "$cfg" pull
  docker-compose -f "$cfg" up -d
done

docker image prune
