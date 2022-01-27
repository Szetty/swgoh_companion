#!/usr/bin/env sh

set -xe

ALLY_CODE=${1:-""}
OUT_PATH=${2:-""}

mix run -e "SWGOHCompanion.save_gac_enemy_roster(\"$ALLY_CODE\", \"$OUT_PATH\")"