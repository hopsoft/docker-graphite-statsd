#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get -q update
apt-get -y --force-yes install docker.io
ln -sf /usr/bin/docker.io /usr/local/bin/docker
