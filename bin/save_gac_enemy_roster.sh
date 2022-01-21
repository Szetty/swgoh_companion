#!/usr/bin/env sh

set -xe

ALLY_CODE=${1:-"nil"}
OUT_PATH=${2:-"nil"}
TEAMS=${3:-"[]"}

mix run -e "SWGOHCompanion.save_gac_enemy_roster(\"$ALLY_CODE\", $TEAMS, \"$OUT_PATH\")"