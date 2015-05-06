#!/bin/bash

/usr/bin/nodejs /opt/statsd/stats.js /opt/statsd/config.js 2>&1 >> /var/log/statsd/statsd.log

