#!/bin/bash

/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=a start --debug 2>&1 >> /var/log/carbon-cache-a.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=b start --debug 2>&1 >> /var/log/carbon-cache-b.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=c start --debug 2>&1 >> /var/log/carbon-cache-c.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=d start --debug 2>&1 >> /var/log/carbon-cache-d.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=e start --debug 2>&1 >> /var/log/carbon-cache-e.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=f start --debug 2>&1 >> /var/log/carbon-cache-f.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=g start --debug 2>&1 >> /var/log/carbon-cache-g.log
/usr/bin/python /opt/graphite/bin/carbon-cache.py --instance=h start --debug 2>&1 >> /var/log/carbon-cache-h.log
