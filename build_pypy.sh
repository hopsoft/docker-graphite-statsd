#!/usr/bin/env bash
VERSION=master
IMAGE=jamiehewland/alpine-pypy:3.6-7.3-alpine3.11
docker build . \
    --build-arg BASEIMAGE=${IMAGE} --build-arg python_binary=/usr/local/bin/pypy3 \
    --no-cache --tag graphite-statsd:$VERSION-pypy