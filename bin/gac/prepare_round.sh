#!/usr/bin/env sh

set -xe

WEEK=$1
ROUND_NR=$2
ALLY_CODE=$3

mix run -e "SWGOHCompanion.GAC.prepare_round(\"$WEEK\", $ROUND_NR, \"$ALLY_CODE\")"
