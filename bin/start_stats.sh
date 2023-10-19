#!/usr/bin/env sh

set -ex

docker run --name=swgoh-stats \
  -d \
  --network swgoh-comlink \
  -e NODE_ENV=production \
  -e PORT=3001 \
  -e CLIENT_URL=http://swgoh-comlink:3000 \
  -p 3001:3001 \
  -u $(id -u):$(id -g) \
  -v $(pwd)/statCalcData:/app/statCalcData \
  ghcr.io/swgoh-utils/swgoh-stats:latest