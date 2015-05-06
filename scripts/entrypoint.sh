#!/bin/bash
set -e

if [ ! -f /opt/graphite/storage/graphite.db ]; then
  if [ -d /opt/graphite/storage ]; then
    ## running for the first time with storage volume mounted
    ## copy everything
    cp -r /opt/graphite/storage_orig/* /opt/graphite/storage/
  else
    ## running for the fist time without storage volume mounted
    ## simply rename
    mv /opt/graphite/storage_orig /opt/graphite/storage
  fi
fi

# ensure log directories
mkdir -p /var/log/carbon /var/log/graphite /var/log/nginx /var/log/statsd

if [ "$1" == "my_init" ]; then
  /sbin/my_init
fi

exec "$@"

