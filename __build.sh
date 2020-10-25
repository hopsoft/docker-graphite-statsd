#!/usr/bin/env bash
VERSION=1.1.7-7

docker buildx build . \
        --cache-from=type=local,src=.build \
        --cache-to=type=local,dest=.build \
        --build-arg python_binary=python3 \
        --platform linux/arm,linux/arm64,linux/amd64 \
        --tag graphiteapp/graphite-statsd:$VERSION --push

docker buildx build . \
        --cache-from=type=local,src=.build \
        --build-arg python_binary=python3 \
        --platform linux/arm,linux/arm64,linux/amd64 \
        --tag graphiteapp/graphite-statsd:latest --push
