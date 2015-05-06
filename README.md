# Based on: https://github.com/hopsoft/docker-graphite-statsd many thanks!

# Docker Image for Graphite & Statsd

## Get Graphite & Statsd running instantly

Graphite & Statsd can be complex to setup.
This image will have you running & collecting stats in just a few minutes.

## Quick Start

```sh
sudo docker run -d --name graphite --net host docker-graphite-statsd
```

This starts a Docker container named: **graphite**

That's it, you're done ... almost.

### Includes the following components

* [Nginx](http://nginx.org/) - reverse proxies the grafana/graphite dashboard
* [Grafana](http://grafana.org/) - nicer graphing graphite dashboard
* [Graphite](http://graphite.readthedocs.org/en/latest/) - front-end dashboard
* [Carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html) - back-end
* [Statsd](https://github.com/etsy/statsd/wiki) - UDP based back-end proxy

### Mapped Ports (when start with --net host)

| Host | Container |     Service    |
| ---- | --------- | -------------- |
|   80 |        80 | nginx/grafana  |
|   81 |        81 | nginx/graphite |
| 2003 |      2003 | carbon         |
| 8125 |      8125 | statsd         |

### Recommended volumes:

grafana/dashboards:/opt/grafana/app/dashboards
graphite/config:/opt/graphite/conf
graphite/storage:/opt/graphite/storage
logs:/var/log

### Base Image

Built using [Phusion's base image](https://github.com/phusion/baseimage-docker).

* All Graphite related processes are run as daemons & monitored with [runit](http://smarden.org/runit/).
* Includes additional services such as logrotate.

## Start Using Graphite & Statsd

### Send Some Stats

Let's fake some stats with a random counter to prove things are working.

```sh
while true
do
  echo -n "example.statsd.counter.changed:$(((RANDOM % 10) + 1))|c" | nc -w 1 -u localhost 8125
done
<CTL-C>
```

### Visualize the Data

Open Grafana in a browser at [http://localhost](http://localhost).
Open Graphite in a browser at [http://localhost:81](http://localhost:81).

### How to edit or create grafana dashboards

Elastic search is not installed in this image, 
hence the dashboards are to be created or updated, 
then exported as JSON files.  Base on the default dashboard 
http://localhost/#/dashboard/file/default.json for example, 
add/update the graphs, then export to mydashboard.json for instance, 
save it in the directory which is mounted to /opt/grafana/app/dashboards in the container. 
Open http://localhost/#/dashboard/file/mydashboard.json in a browser to view the new dashboard.

## Secure the Django Admin

Update the default Django admin user account. _The default is insecure._

  * username: root
  * password: root
  * email: admin@admin.com

First login at: [http://localhost/account/login](http://localhost/account/login)
Then update the root user's profile at: [http://localhost/admin/auth/user/1/](http://localhost/admin/auth/user/1/)

## Change the Configuration

Read up on Graphite's [post-install tasks](https://graphite.readthedocs.org/en/latest/install.html#post-install-tasks).
Focus on the [storage-schemas.conf](https://graphite.readthedocs.org/en/latest/config-carbon.html#storage-schemas-conf)

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

## A Note on Disk Space

If running this image on cloud infrastructure such as AWS,
you should consider mounting `/opt/graphite/storage` & `/var/log` on a larger volume.

1. Configure the host to mount a large EBS volume.
1. Specify the volume mounts when starting the container.

    ```
    sudo docker run -d \
      --name graphite \
      --net host
      -v /path/to/ebs/graphite:/opt/graphite/storage \
      -v /path/to/ebs/log:/var/log \
      docker-graphite-statsd
    ```

## Additional Reading

* [Introduction to Docker](http://docs.docker.io/#introduction)
* [Official Statsd Documentation](https://github.com/etsy/statsd/)
* [Practical Guide to StatsD/Graphite Monitoring](http://matt.aimonetti.net/posts/2013/06/26/practical-guide-to-graphite-monitoring/)
* [Configuring Graphite for StatsD](https://github.com/etsy/statsd/blob/master/docs/graphite.md)

