#!/bin/bash
set -e

docker run \
  --runtime sysbox-runc \
  -it --rm \
  --hostname cont-dind-test \
  --network mt_proxynet \
  tp-dind:latest

# docker run --runtime sysbox-runc -it --hostname abc --name abc --network mt_proxynet tp-dind:latest
