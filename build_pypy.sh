#!/usr/bin/env bash
VERSION=1.1.8-6
IMAGE=jamiehewland/alpine-pypy:3.6-7.3-alpine3.11
docker build . \
    --build-arg BASEIMAGE=${IMAGE} --build-arg python_binary=/usr/local/bin/pypy3 --build-arg python_extra_flags="" \
    --no-cache --tag graphiteapp/graphite-statsd:$VERSION-pypy