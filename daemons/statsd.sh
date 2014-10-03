#!/bin/bash

node /opt/statsd/stats.js /opt/statsd/config.js 2>&1 >> /var/log/statsd.log

