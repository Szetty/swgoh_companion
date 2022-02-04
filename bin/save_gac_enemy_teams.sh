#!/usr/bin/env sh

set -xe

WEEK=$1
ROUND=$2
TEAMS=${3:-"[]"}

mix run -e "SWGOHCompanion.save_gac_enemy_teams(\"$WEEK\", \"$ROUND\", $TEAMS)"
