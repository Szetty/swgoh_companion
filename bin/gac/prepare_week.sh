#!/usr/bin/env sh

set -xe

WEEK_NR=$1

mix run -e "SWGOHCompanion.GAC.prepare_week($WEEK_NR)"