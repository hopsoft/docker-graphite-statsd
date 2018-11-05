#!/bin/bash

conf_dir=/etc/graphite-statsd/conf

# auto setup graphite with default configs if /opt/graphite/conf is missing
# needed for the use case when a docker host volume is mounted at an of the following:
#  - /opt/graphite/conf
#  - /opt/graphite/storage

function folder_empty() {
	[ -z "$(find "${1}" -mindepth 1 -not -name "lost+found" -print -quit)" ]
}

if folder_empty /var/log/graphite; then
  mkdir -p /var/log/graphite
  touch /var/log/syslog
fi

if folder_empty /opt/graphite/conf; then
  cp -R $conf_dir/opt/graphite/conf/*.conf /opt/graphite/conf/
fi

if folder_empty /opt/graphite/webapp/graphite; then
  cp $conf_dir/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
fi

if folder_empty /opt/graphite/storage; then
  mkdir -p /opt/graphite/storage/whisper
  /usr/local/bin/django_admin_init.exp
fi

if folder_empty /opt/graphite/webapp/graphite/functions/custom; then
  touch /opt/graphite/webapp/graphite/functions/custom/__init__.py
fi

# auto setup statsd with default config if /opt/statsd is missing
# needed for the use case when a docker host volume is mounted at an of the following:
#  - /opt/statsd
if folder_empty /opt/statsd; then
  git clone -b v0.8.0 https://github.com/etsy/statsd.git /opt/statsd && \
  cp $conf_dir/opt/statsd/config_*.js /opt/statsd/
fi
