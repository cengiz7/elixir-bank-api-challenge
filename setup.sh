#!/bin/bash

set -euo pipefail;
set -x;

# start postgres first to give it some time to initialize the new database
docker compose up -d

mix local.hex --force
mix local.rebar --force
mix deps.get

mix deps.compile

# wait for postgres to be up
docker compose up --wait

mix ecto.create
mix ecto.migrate

MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
