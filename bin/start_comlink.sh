#!/usr/bin/env sh

set -ex

docker run --name swgoh-comlink \
  -d \
  --env APP_NAME=szetty-swgoh-comlink \
  --network swgoh-comlink \
  -p 3000:3000 \
  ghcr.io/swgoh-utils/swgoh-comlink:latest