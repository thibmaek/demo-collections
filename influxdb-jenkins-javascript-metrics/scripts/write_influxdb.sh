#!/usr/bin/env bash
set -e

function display_help() {
  echo ""
  echo "Usage:"
  echo "  Pass fields as arguments in the format of field=value to this script"
  echo "    e.g: ./write_influxdb.sh my_measurement myfield=somevalue otherfield=3"
  echo ""
}

# Convenience wrapper around curl to insert tags + fields in InfluxDB.
# This script gracefully exits with 0 even if writing to database is unsuccessful.
function write_to_influxdb() {
  local database="orbit_metrics" # This is your InfluxDB database
  local jobBranch author tags fields

  if [ -z "$1" ]; then
    echo ""
    echo "No measurement provided to write_to_influxdb.sh!"
    display_help
    exit 1
  fi

  # Non PR builds do not have the CHANGE_BRANCH env
  if [ -z "$CHANGE_BRANCH" ]; then
    jobBranch="$BRANCH_NAME"
  else
    jobBranch="$CHANGE_BRANCH"
  fi

  # Branch builds do not have CHANGE_AUTHOR env
  if [ -z "$CHANGE_AUTHOR" ]; then
    author="jenkins"
  else
    author="$CHANGE_AUTHOR"
  fi

  tags="project=my_project,branch=$jobBranch,author=$author,job=$BUILD_ID"

  for field in "${@:2}"; do
    key=$(echo "$field" | sed 's/=.*//g')
    value=$(echo "$field" | awk -F= '{print $2}')
    echo "Field: { $key: $value }"
    # Basically: Join key + value into array, trim leading whitespace, join by comma
    fields=$(echo "$fields $key=$value" | sed 's/^ //g' | sed 's/ /,/g')
  done

  echo "Writing measurement to $database.$1"
  echo "  Tags: $tags"
  echo "  Fields: $fields"
  echo ""
  echo "HTTP Payload: $1,$tags $fields"

  curl -i -X POST \
    "$INF_HOST/write?db=$database&u=$INF_USER&p=$INF_PASS" \
    --data-binary "$1,$tags $fields" || echo "Could not insert measurement into database..."
}

write_to_influxdb "$@"
