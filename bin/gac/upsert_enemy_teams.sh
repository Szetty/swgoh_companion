#!/usr/bin/env sh

set -xe

WEEK=$1
ROUND=$2

mix run -e "SWGOHCompanion.GAC.upsert_enemy_teams(\"$WEEK\", \"$ROUND\")"
