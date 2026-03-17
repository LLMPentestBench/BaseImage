#!/bin/bash
set -e

docker run \
  --runtime sysbox-runc \
  -it --rm \
  --network mt_proxynet \
  mt-baseimage:latest

# docker run --runtime sysbox-runc -it --name abc --network mt_proxynet mt-baseimage:latest
