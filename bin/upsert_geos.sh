#!/usr/bin/env sh

set -xe

ALLY_CODE=$1
STARTING_ROW=$2

mix run -e "SWGOHCompanion.upsert_geos(\"$ALLY_CODE\", $STARTING_ROW)"
