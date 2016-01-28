#!/bin/bash

# Set timezone for Graphite-Web
sed -i "s~#\?TIME_ZONE = '.*'~TIME_ZONE = '${TZ}'~" /opt/graphite/webapp/graphite/local_settings.py

/usr/bin/python /opt/graphite/webapp/graphite/manage.py runfcgi daemonize=false host=127.0.0.1 port=8080