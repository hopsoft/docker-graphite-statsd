#!/bin/bash

/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=c start --debug 2>&1 >> /var/log/carbon-cache-c.log
