#!/usr/bin/env bash

docker buildx build \
  --tag rbvtopudding/devops:latest \
  --push \
  --platform linux/arm64/v8,linux/amd64 \
  .
