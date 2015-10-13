#!/bin/bash

/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=e start --debug 2>&1 >> /var/log/carbon-cache-e.log
