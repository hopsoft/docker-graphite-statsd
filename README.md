# Docker Image for Graphite

## Deploy Graphite & Statsd with a single click... almost

Graphite & Statsd can be a pain in the ass to setup.
This Docker image will help you get up & running quickly.

## Quick Start

```
git clone https://github.com/hopsoft/docker-graphite-statsd.git
./docker-graphite-statsd/bin/start
```

This starts a Docker container named: **graphite**

### Includes the following components

* [Nginx](http://nginx.org/) - reverse proxies the graphite dashboard
* [Graphite](http://graphite.readthedocs.org/en/latest/) - front-end dashboard
* [Carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html) - back-end
* [Statsd](https://github.com/etsy/statsd/wiki) - UDP based back-end proxy

### Mapped Ports

| Service | Host | Container |
| ------- | ---- | --------- |
| nginx   |   80 |        80 |
| carbon  | 2003 |      2003 |
| statsd  | 8125 |      8125 |

### Mounted Volumes

| Host              | Container             |
| ----------------- | --------------------- |
| /var/log/graphite | /var/log              |
| DOCKER ASSIGNED   | /opt/graphite/storage |
| DOCKER ASSIGNED   | /opt/graphite/conf    |

## Start Using Graphite & Statsd

### Send Some Stats

Let's fake some stats with a random counter to prove things are working.

```
./docker-graphite-statsd/bin/send_stats
```

### Visualize the Data

From the host machine visit: [http://localhost/dashboard](http://localhost/dashboard)

## Update the Configuration

1. Update the default Django admin user account. _The default is insecure._

  * username: root
  * password: root
  * email: root.graphite@mailinator.com

  First login at: [http://localhost/account/login](http://localhost/account/login)
  Then update the root user's profile at: [http://localhost/admin/auth/user/1/](http://localhost/admin/auth/user/1/)

2. Read up on Graphite's [post-install tasks](https://graphite.readthedocs.org/en/latest/install.html#post-install-tasks).
  Focus on the [storage-schemas.conf](https://graphite.readthedocs.org/en/latest/config-carbon.html#storage-schemas-conf)

  **Note:** If you change settings in `storage-schemas.conf`, be sure to run `whisper-resize.py` to resize the whisper files.
  For example, if you update the config to look something like this:

  ```
  [all]
  pattern = .*
  retentions = 10s:12h,1m:7d,10m:5y
  ```

  Resize the storage files by running the following.

  ```
  docker attach graphite
  find /opt/graphite/storage -type f -name '*.wsp' \
  -exec whisper-resize.py --nobackup {} 10s:12h 1m:7d 10m:5y \;
  <CTL-P><CTL-Q> # detaches from the container
  ```

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

  [Read more about synching Statsd with Graphite configs.](https://github.com/etsy/statsd/blob/master/docs/graphite.md)

3. Learn about [Statsd](https://github.com/etsy/statsd/).

4. Start sending stats from your apps.

## Useful Docker Commands

```
docker attach graphite # attaches to the running container
<CTL-P><CTL-Q>         # detaches from the container

docker stop graphite   # stops the container

docker start graphite  # starts the container (after it's been stopped)

docker rm graphite     # removes the container
```

## Additional Reading

* [Introduction to Docker](http://docs.docker.io/#introduction)
* [Practical Guide to StatsD/Graphite Monitoring](http://matt.aimonetti.net/posts/2013/06/26/practical-guide-to-graphite-monitoring/)
* [Configuring Graphite for StatsD](https://github.com/etsy/statsd/blob/master/docs/graphite.md)
