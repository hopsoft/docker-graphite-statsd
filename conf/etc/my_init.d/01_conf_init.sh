#!/bin/bash

conf_dir=/etc/graphite-statsd/conf

# auto setup graphite with default configs if /opt/graphite/conf is missing
# needed for the use case when a docker host volume is mounted at an of the following:
#  - /opt/graphite/conf
#  - /opt/graphite/storage
graphite_conf_dir_contents=$(find /opt/graphite/conf -mindepth 1 -print -quit)
graphite_webapp_dir_contents=$(find /opt/graphite/webapp/graphite -mindepth 1 -print -quit)
graphite_storage_dir_contents=$(find /opt/graphite/storage -mindepth 1 -not -path /opt/graphite/storage/lost+found -print -quit | grep -v lost+found)
graphite_log_dir_contents=$(find /var/log/graphite -mindepth 1 -print -quit)
graphite_custom_dir_contents=$(find /opt/graphite/webapp/graphite/functions/custom -mindepth 1 -print -quit)
if [[ -z $graphite_log_dir_contents ]]; then
  mkdir -p /var/log/graphite
  touch /var/log/syslog
fi
if [[ -z $graphite_conf_dir_contents ]]; then
  cp -R $conf_dir/opt/graphite/conf/*.conf /opt/graphite/conf/
fi
if [[ -z $graphite_webapp_dir_contents ]]; then
  cp $conf_dir/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
fi
if [[ -z $graphite_storage_dir_contents ]]; then
  mkdir -p /opt/graphite/storage/whisper
  /usr/local/bin/django_admin_init.exp
fi
if [[ -z $graphite_custom_dir_contents ]]; then
  touch /opt/graphite/webapp/graphite/functions/custom/__init__.py
fi
# auto setup statsd with default config if /opt/statsd is missing
# needed for the use case when a docker host volume is mounted at an of the following:
#  - /opt/statsd
statsd_dir_contents=$(find /opt/statsd -mindepth 1 -print -quit)
if [[ -z $statsd_dir_contents ]]; then
  git clone -b v0.8.0 https://github.com/etsy/statsd.git /opt/statsd && \
  cp $conf_dir/opt/statsd/config_*.js /opt/statsd/
fi

