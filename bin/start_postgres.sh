#!/usr/bin/env sh

set -ex

docker run -d \
    --name swgoh-companion \
    -e POSTGRES_PASSWORD=postgres \
    -e PGDATA=/var/lib/postgresql/data \
    -v $PWD/pgdata:/var/lib/postgresql/data \
    -p 5431:5431 \
    postgres:14 \
    -c 'port=5431'