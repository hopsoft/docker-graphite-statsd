#!/bin/bash

/usr/bin/python /opt/graphite/webapp/graphite/manage.py runfcgi daemonize=false host=127.0.0.1 port=8080

