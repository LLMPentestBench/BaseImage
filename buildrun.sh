#!/bin/bash
set -e

docker build -t tp-dind:latest .
./run.sh
