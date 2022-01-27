#!/usr/bin/env sh

set -xe

ROUND=${1:-""}
TEAMS=${2:-"[]"}

mix run -e "SWGOHCompanion.save_gac_enemy_teams(\"$ROUND\", $TEAMS)"
