#!/bin/bash

CONTAINER_TAG=${1:-'hopsoft/graphite-statsd'}

sudo docker run \
	-t \
	-p 3000:80 \
	-p 2003:2003 \
	-p 8125:8125/udp \
	-v /srv/graphite/log:/var/log \
	-v /srv/graphite/storage:/opt/graphite/storage \
	-v /srv/graphite/conf:/opt/graphite/conf \
	${CONTAINER_TAG} /opt/hopsoft/graphite-statsd/start
