#!/bin/bash
set -e

docker build -t llmptb-baseimage:latest .
./run.sh
