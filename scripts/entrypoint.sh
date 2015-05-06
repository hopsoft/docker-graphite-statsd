#!/bin/bash
set -e

for i in $EASY_MOUNTS; do
  if [ ! -d $i ]; then
    # directory not exist, simply rename the _orig directory back
    mv ${i}_orig $i
  elif [ "$(find $i -maxdepth 0 -empty -exec echo empty \;)" ]; then
    # empty directory, mounted from host? copy contents
    cp -r ${i}_orig/* $i/
  fi
done

# ensure log directories
mkdir -p /var/log/carbon /var/log/graphite /var/log/nginx /var/log/statsd

if [ "$1" == "my_init" ]; then
  /sbin/my_init
fi

exec "$@"

