#!/bin/bash
set -e

docker build -t mt-baseimage:latest .
./run.sh
