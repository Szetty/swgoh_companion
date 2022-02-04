#!/usr/bin/env sh

set -xe

WEEK=$1
GAC_NR=$2
WEEK_NR=$3
ALLY_CODES=$4

# $('div.ag-pinned-left-cols-container > div[comp-id] a').map((_, a) => a.getAttribute('href').replace('/p/', ''))

mix run -e "SWGOHCompanion.GAC.prepare_week(\"$WEEK\", $GAC_NR, $WEEK_NR, $ALLY_CODES)"