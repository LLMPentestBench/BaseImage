#!/bin/bash

docker compose rm --stop --force litellm
docker compose up -d litellm
