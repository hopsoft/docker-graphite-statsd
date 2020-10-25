#!/usr/bin/env bash
VERSION=1.1.7-7
IMAGE=jamiehewland/alpine-pypy:3.6-7.3-alpine3.11
docker build . \
    --build-arg BASEIMAGE=${IMAGE} --build-arg python_binary=/usr/local/bin/pypy3 \
    --no-cache --tag graphiteapp/graphite-statsd:$VERSION-pypy