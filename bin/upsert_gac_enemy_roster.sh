#!/usr/bin/env sh

set -xe

ALLY_CODE=${1:-"nil"}
TEAMS=${2:-"[]"}

mix run -e "SWGOHCompanion.upsert_gac_enemy_roster(\"$ALLY_CODE\", $TEAMS)"
