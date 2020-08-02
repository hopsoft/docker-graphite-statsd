#!/usr/bin/env bash
VERSION=master
docker build . --build-arg python_binary=python3 --no-cache --tag graphite-statsd:$VERSION