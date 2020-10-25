#!/usr/bin/env bash
VERSION=master
docker buildx build . \
        --build-arg python_binary=python3 \
        --platform linux/arm,linux/arm64,linux/amd64 \
        --no-cache \
        --tag graphiteapp/graphite-statsd:$VERSION --push