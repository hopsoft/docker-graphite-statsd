#!/bin/bash

cd /usr/local/src/grafana/grafana-2.1.3/bin/

./grafana-server --config /usr/local/src/grafana/defaults.ini 2>&1 >> /var/log/grafana.log
