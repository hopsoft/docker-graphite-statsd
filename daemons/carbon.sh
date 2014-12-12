#!/bin/bash

/usr/bin/python /opt/graphite/bin/carbon-cache.py start --debug --logdir=/var/log/carbon 2>&1 >> /var/log/carbon.log
/usr/bin/python /opt/graphite/bin/carbon-aggregator.py start --debug --logdir=/var/log/carbon 2>&1 >> /var/log/carbon-aggregator.log
