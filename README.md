<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

- [Docker Image for Graphite & Statsd](#docker-image-for-graphite--statsd)
  - [Get Graphite & Statsd running instantly](#get-graphite--statsd-running-instantly)
  - [Quick Start](#quick-start)
    - [Includes the following components](#includes-the-following-components)
    - [Mapped Ports](#mapped-ports)
    - [Mounted Volumes](#mounted-volumes)
    - [Base Image](#base-image)
  - [Start Using Graphite & Statsd](#start-using-graphite--statsd)
    - [Send Some Stats](#send-some-stats)
    - [Visualize the Data](#visualize-the-data)
  - [Secure the Django Admin](#secure-the-django-admin)
  - [Change the Configuration](#change-the-configuration)
  - [Statsd Admin Management Interface](#statsd-admin-management-interface)
  - [Secure Grafana](#secure-grafana)
  - [Connect Grafana to Graphite](#connect-grafana-to-graphite)
  - [A Note on Volumes](#a-note-on-volumes)
  - [Memcached config](#memcached-config)
  - [Additional Reading](#additional-reading)
  - [Contributors](#contributors)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

[![Docker Pulls](https://img.shields.io/docker/pulls/hopsoft/graphite-statsd.svg?style=flat)](https://hub.docker.com/r/hopsoft/graphite-statsd/)

> __NOTICE:__ Check out the official Graphite & Statsd Docker image at https://github.com/graphite-project/docker-graphite-statsd

# Docker Image for Graphite & Statsd

## Get Graphite & Statsd running instantly

Graphite & Statsd can be complex to setup.
This image will have you running & collecting stats in just a few minutes.

## Quick Start

```sh
docker run -d\
 --name graphite\
 --restart=always\
 -p 80:80\
 -p 81:81\
 -p 2003-2004:2003-2004\
 -p 2023-2024:2023-2024\
 -p 8125:8125/udp\
 -p 8126:8126\
 hopsoft/graphite-statsd
```

This starts a Docker container named: **graphite**

That's it, you're done ... almost.

### Includes the following components

* [Nginx](http://nginx.org/) - reverse proxies the graphite dashboard
* [Graphite](http://graphite.readthedocs.org/en/latest/) - front-end dashboard
* [Carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html) - back-end
* [Statsd](https://github.com/statsd/statsd/wiki) - UDP based back-end proxy
* [Grafana](https://grafana.com) - front-end dashboard (more refined than Graphite)

### Mapped Ports

Host | Container | Service
---- | --------- | -------------------------------------------------------------------------------------------------------------------
  80 |        80 | [nginx - grafana](https://www.nginx.com/resources/admin-guide/)
  81 |        81 | [nginx - graphite](https://www.nginx.com/resources/admin-guide/)
2003 |      2003 | [carbon receiver - plaintext](http://graphite.readthedocs.io/en/latest/feeding-carbon.html#the-plaintext-protocol)
2004 |      2004 | [carbon receiver - pickle](http://graphite.readthedocs.io/en/latest/feeding-carbon.html#the-pickle-protocol)
2023 |      2023 | [carbon aggregator - plaintext](http://graphite.readthedocs.io/en/latest/carbon-daemons.html#carbon-aggregator-py)
2024 |      2024 | [carbon aggregator - pickle](http://graphite.readthedocs.io/en/latest/carbon-daemons.html#carbon-aggregator-py)
8125 |      8125 | [statsd](https://github.com/statsd/statsd/blob/master/docs/server.md)
8126 |      8126 | [statsd admin](https://github.com/statsd/statsd/blob/master/docs/admin_interface.md)

By default, statsd listens on the UDP port 8125. If you want it to listen on the TCP port 8125 instead, you can set the environment variable `STATSD_INTERFACE` to `tcp` when running the container.

### Mounted Volumes

Host              | Container                  | Notes
----------------- | -------------------------- | -------------------------------
DOCKER ASSIGNED   | /opt/graphite/conf         | graphite config
DOCKER ASSIGNED   | /opt/graphite/storage      | graphite stats storage
DOCKER ASSIGNED   | /etc/grafana               | grafana config
DOCKER ASSIGNED   | /etc/nginx                 | nginx config
DOCKER ASSIGNED   | /opt/statsd                | statsd config
DOCKER ASSIGNED   | /etc/logrotate.d           | logrotate config
DOCKER ASSIGNED   | /var/log                   | log files

### Base Image

Built using [Phusion's base image](https://github.com/phusion/baseimage-docker).

* All Graphite related processes are run as daemons & monitored with [runit](http://smarden.org/runit/).
* Includes additional services such as logrotate.

## Start Using Graphite & Statsd

### Send Some Stats

Let's fake some stats with a random counter to prove things are working.

```sh
while true; do echo -n "example:$((RANDOM % 100))|c" | nc -w 1 -u 127.0.0.1 8125; done
```

### Visualize the Data

Open Graphite in a browser.

* http://localhost:81/dashboard
* http://localhost:81/render?from=-10mins&until=now&target=stats.example

## Secure the Django Admin

Update the default Django admin user account. _The default is insecure._

  * username: root
  * password: root
  * email: root.graphite@mailinator.com

First login at: http://localhost:81/account/login
Then update the root user's profile at: http://localhost:81/admin/auth/user/1/

## Change the Configuration

Read up on Graphite's [post-install tasks](https://graphite.readthedocs.org/en/latest/install.html#post-install-tasks).
Focus on the [storage-schemas.conf](https://graphite.readthedocs.org/en/latest/config-carbon.html#storage-schemas-conf).

1. Stop the container `docker stop graphite`.
1. Find the configuration files on the host by inspecting the container `docker inspect graphite`.
1. Update the desired config files.
1. Restart the container `docker start graphite`.

**Note**: If you change settings in `/opt/graphite/conf/storage-schemas.conf`
be sure to delete the old whisper files under `/opt/graphite/storage/whisper/`.

---

**Important:** Ensure your Statsd flush interval is at least as long as the highest-resolution retention.
For example, if `/opt/statsd/config.js` looks like this.

```
flushInterval: 10000
```

Ensure that `storage-schemas.conf` retentions are no finer grained than 10 seconds.

```
[all]
pattern = .*
retentions = 5s:12h # WRONG
retentions = 10s:12h # OK
retentions = 60s:12h # OK
```

## Statsd Admin Management Interface

A management interface (default on port 8126) allows you to manage statsd & retrieve stats.

```sh
# show all current counters
echo counters | nc localhost 8126
```

[More info & additional commands.](https://github.com/statsd/statsd/blob/master/docs/admin_interface.md)

## Secure Grafana

Update the default Grafana admin account. _The default is insecure._

  * username: admin
  * password: admin
  * email: admin@localhost

First login at: http://localhost
Then update the admin user's profile at: http://localhost/admin/users/edit/1

## Connect Grafana to Graphite

Visit http://localhost/datasources/new
Then configure the Graphite data source with the URL http://localhost:81

## A Note on Volumes

You may find it useful to mount explicit volumes so configs & data can be managed from a known location on the host.

Simply specify the desired volumes when starting the container.

```
docker run -d\
 --name graphite\
 --restart=always\
 -v /path/to/graphite/configs:/opt/graphite/conf\
 -v /path/to/graphite/data:/opt/graphite/storage\
 -v /path/to/statsd:/opt/statsd\
 hopsoft/graphite-statsd
```

**Note**: The container will initialize properly if you mount empty volumes at
          `/opt/graphite`, `/opt/graphite/conf`, `/opt/graphite/storage`, or `/opt/statsd`

## Memcached config

If you want Graphite to use an existing Memcached server, set the following environment variables:

```
docker run -d\
 --name graphite\
 --restart=always\
 -p 80:80\
 -p 2003-2004:2003-2004\
 -p 2023-2024:2023-2024\
 -p 8125:8125/udp\
 -p 8126:8126\
 -e "MEMCACHE_HOST=127.0.0.1:11211"\  # Memcached host(s) comma delimited
 -e "CACHE_DURATION=60"\              # in seconds
 hopsoft/graphite-statsd
```

## Additional Reading

* [Introduction to Docker](http://docs.docker.io/#introduction)
* [Official Statsd Documentation](https://github.com/statsd/statsd/)
* [Practical Guide to StatsD/Graphite Monitoring](http://matt.aimonetti.net/posts/2013/06/26/practical-guide-to-graphite-monitoring/)
* [Configuring Graphite for StatsD](https://github.com/statsd/statsd/blob/master/docs/graphite.md)

## Contributors

Build the image yourself.

1. `git clone https://github.com/hopsoft/docker-graphite-statsd.git`
1. `docker build -t hopsoft/graphite-statsd .`
