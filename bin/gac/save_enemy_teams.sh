#!/usr/bin/env sh

set -xe

WEEK=$1
ROUND=$2
TEAMS=${3:-"[]"}

mix run -e "SWGOHCompanion.GAC.save_enemy_teams(\"$WEEK\", \"$ROUND\", $TEAMS)"
