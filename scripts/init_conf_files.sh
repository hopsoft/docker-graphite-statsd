#!/bin/bash

# This script will copy any configuration files from /conf-default and then
# copy any configuration files from /conf-custom.
#
# /conf-default contains the default configuration as defined in the Docker image
# /conf-custom can be used to customize any configuration file by mounting an apropriate volume
#
# This script will be run at startup (see https://github.com/phusion/baseimage-docker#running_startup_scripts)

set -e

DIR_CONF_DEFAULT=/conf-default
DIR_CONF_CUSTOM=/conf-custom
DIR_GRAPHITE=/opt/graphite/conf
DIR_GRAPHITE_WEB=/opt/graphite/webapp
DIR_STATSD=/opt/statsd
DIR_NGINX=/etc/nginx
DIR_LOGROTATE=/etc/logrotate.d

# Copy default configs
cp $DIR_CONF_DEFAULT/graphite-webapp/* $DIR_GRAPHITE_WEB
cp $DIR_CONF_DEFAULT/graphite/* $DIR_GRAPHITE
cp $DIR_CONF_DEFAULT/statsd/* $DIR_STATSD
cp $DIR_CONF_DEFAULT/nginx/nginx.conf $DIR_NGINX
cp $DIR_CONF_DEFAULT/nginx/graphite.conf $DIR_NGINX/sites-available
cp $DIR_CONF_DEFAULT/logrotate $DIR_LOGROTATE/graphite

# Copy custom configs (if they exist)
if [[ -d $DIR_CONF_CUSTOM/graphite-webapp ]]; then
  cp $DIR_CONF_CUSTOM/graphite-webapp/* $DIR_GRAPHITE_WEB
fi
if [[ -d $DIR_CONF_CUSTOM/graphite ]]; then
  cp $DIR_CONF_CUSTOM/graphite/* $DIR_GRAPHITE
fi
if [[ -d $DIR_CONF_CUSTOM/statsd ]]; then
  cp $DIR_CONF_CUSTOM/statsd/* $DIR_STATSD
fi
if [[ -e $DIR_CONF_CUSTOM/nginx/nginx.conf ]]; then
  cp $DIR_CONF_CUSTOM/nginx/nginx.conf $DIR_NGINX
fi
if [[ -e $DIR_CONF_CUSTOM/nginx/graphite.conf ]]; then
  cp $DIR_CONF_CUSTOM/nginx/graphite.conf $DIR_NGINX/sites-available
fi
if [[ -d $DIR_CONF_CUSTOM/logrotate ]]; then
  cp $DIR_CONF_CUSTOM/logrotate $DIR_LOGROTATE/graphite
fi