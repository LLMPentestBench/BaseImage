#!/bin/bash
set -e

docker run \
  --runtime sysbox-runc \
  -it --rm \
  --network llmptb_proxynet \
  llmptb-baseimage:latest

# docker run --runtime sysbox-runc -it --name abc --network llmptb_proxynet llmptb-baseimage:latest
