#!/usr/bin/env sh

set -xe

WEEK=$1
ROUND=$2
TEAMS=${3:-"[]"}

mix run -e "SWGOHCompanion.GAC.upsert_enemy_teams(\"$WEEK\", \"$ROUND\", $TEAMS)"
