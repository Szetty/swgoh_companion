#!/usr/bin/env sh

set -xe

mix run -e "SWGOHCompanion.upsert_missing_gear_count"
