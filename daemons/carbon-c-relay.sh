#!/bin/bash

/usr/local/src/carbon-c-relay/relay -f /opt/graphite/conf/carbon-c-relay.conf 2>&1 >> /var/log/carbon-c-relay.log
