#!/usr/bin/env sh

set -xe

ROUND=${1:-0}
TEAMS=${2:-"[]"}

mix run -e "SWGOHCompanion.upsert_gac_enemy_roster(\"$ROUND\", $TEAMS)"
