This is official Graphite docker image repo.

This repo produces two different repos on Docker Hub - https://hub.docker.com/r/graphiteapp/graphite-statsd (stable repo, with manual releases) and https://hub.docker.com/r/graphiteapp/docker-graphite-statsd (development repo, with automatic builds, unstable, use with caution!)

This repo was based on [@hopsoft's](https://github.com/hopsoft/) [docker-graphite-statsd](https://github.com/hopsoft/docker-graphite-statsd) docker image and was used as base for "official" Graphite docker image with his permission. Also, it contains parts of famous [@obfuscurity's](https://github.com/obfuscurity/) [synthesize](https://github.com/obfuscurity/synthesize) Graphite installer. Thanks a lot, Nathan and Jason!

Any suggestions / patches etc. are welcome!

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
 -p 2003-2004:2003-2004\
 -p 2023-2024:2023-2024\
 -p 8125:8125/udp\
 -p 8126:8126\
 graphiteapp/graphite-statsd
```

This starts a Docker container named: **graphite**

Please also note that you can freely remap container port to any host port in case of corresponding port is already occupied on host. It's also not mandatory to map all ports, map only required ports - please see table below.

That's it, you're done ... almost.



### Includes the following components

* [Nginx](http://nginx.org/) - reverse proxies the graphite dashboard
* [Graphite](http://graphite.readthedocs.org/en/latest/) - front-end dashboard
* [Carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html) - back-end
* [Statsd](https://github.com/etsy/statsd/wiki) - UDP based back-end proxy

### Mapped Ports

Host | Container | Service
---- | --------- | -------------------------------------------------------------------------------------------------------------------
  80 |        80 | [nginx](https://www.nginx.com/resources/admin-guide/)
2003 |      2003 | [carbon receiver - plaintext](http://graphite.readthedocs.io/en/latest/feeding-carbon.html#the-plaintext-protocol)
2004 |      2004 | [carbon receiver - pickle](http://graphite.readthedocs.io/en/latest/feeding-carbon.html#the-pickle-protocol)
2023 |      2023 | [carbon aggregator - plaintext](http://graphite.readthedocs.io/en/latest/carbon-daemons.html#carbon-aggregator-py)
2024 |      2024 | [carbon aggregator - pickle](http://graphite.readthedocs.io/en/latest/carbon-daemons.html#carbon-aggregator-py)
8080 |      8080 | Graphite internal gunicorn port (without Nginx proxying).
8125 |      8125 | [statsd](https://github.com/etsy/statsd/blob/master/docs/server.md)
8126 |      8126 | [statsd admin](https://github.com/etsy/statsd/blob/master/docs/admin_interface.md)

By default, statsd listens on the UDP port 8125. If you want it to listen on the TCP port 8125 instead, you can set the environment variable `STATSD_INTERFACE` to `tcp` when running the container.

Please also note that you can freely remap container port to any host port in case of corresponding port is already occupied on host.

### Mounted Volumes

Host              | Container                  | Notes
----------------- | -------------------------- | -------------------------------
DOCKER ASSIGNED   | /opt/graphite/conf         | graphite config
DOCKER ASSIGNED   | /opt/graphite/storage      | graphite stats storage
DOCKER ASSIGNED   | /opt/graphite/webapp/graphite/functions/custom      | graphite custom functions dir
DOCKER ASSIGNED   | /etc/nginx                 | nginx config
DOCKER ASSIGNED   | /opt/statsd/config         | statsd config
DOCKER ASSIGNED   | /etc/logrotate.d           | logrotate config
DOCKER ASSIGNED   | /var/log                   | log files
DOCKER ASSIGNED   | /var/lib/redis             | Redis TagDB data (optional)

### Base Image

Version before (and including) 1.1.4-9 were built using [Phusion's base image](https://github.com/phusion/baseimage-docker). Current version is based on [Alpine Linux](https://alpinelinux.org/) because of image size (please see [PR#66](https://github.com/graphite-project/docker-graphite-statsd/pull/66) for details).

* All Graphite related processes are run as daemons & monitored with [runit](http://smarden.org/runit/).
* Includes additional services such as logrotate, nginx, optional Redis for TagDB and optional collectd instance.

## Start Using Graphite & Statsd

### Send Some Stats

Let's fake some stats with a random counter to prove things are working.

```sh
while true; do echo -n "example:$((RANDOM % 100))|c" | nc -w 1 -u 127.0.0.1 8125; done
```

### Visualize the Data

Open Graphite in a browser.

* http://localhost/dashboard
* http://localhost/render?from=-10mins&until=now&target=stats.example

## Secure the Django Admin

Update the default Django admin user account. _The default is insecure._

  * username: root
  * password: root
  * email: root.graphite@mailinator.com

First login at: [http://localhost/account/login](http://localhost/account/login)
Then update the root user's profile at: [http://localhost/admin/auth/user/1/](http://localhost/admin/auth/user/1/)

## Tunables
Additional environment variables can be set to adjust performance.

* GRAPHITE_WSGI_PROCESSES: (4) the number of WSGI daemon processes that should be started
* GRAPHITE_WSGI_THREADS: (2) the number of threads to be created to handle requests in each daemon process
* GRAPHITE_WSGI_REQUEST_TIMEOUT: (65) maximum number of seconds that a request is allowed to run before the daemon process is restarted
* GRAPHITE_WSGI_MAX_REQUESTS: (1000) limit on the number of requests a daemon process should process before it is shutdown and restarted.
* GRAPHITE_WSGI_REQUEST_LINE: (0) The maximum size of HTTP request line in bytes.

### Graphite-web
* GRAPHITE_ALLOWED_HOSTS: (*) In Django 1.5+ set this to the list of hosts your graphite instances is accessible as. See: [https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS](https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS)
* GRAPHITE_TIME_ZONE: (Etc/UTC) Set your local timezone
* GRAPHITE_DATE_FORMAT: (%m/%d) Set your local date format
* GRAPHITE_LOG_ROTATION: (true) rotate logs
* GRAPHITE_LOG_ROTATION_COUNT: (1) number of logs to keep
* GRAPHITE_LOG_RENDERING_PERFORMANCE: (true) log performance information
* GRAPHITE_LOG_CACHE_PERFORMANCE: (true) log cache performance information
* GRAPHITE_LOG_FILE_INFO: (info.log), set to "-" for stdout/stderr
* GRAPHITE_LOG_FILE_EXCEPTION: (exception.log), set to "-" for stdout/stderr
* GRAPHITE_LOG_FILE_CACHE: (cache.log), set to "-" for stdout/stderr
* GRAPHITE_LOG_FILE_RENDERING: (rendering.log), set to "-" for stdout/stderr
* GRAPHITE_DEBUG: (false) Enable full debug page display on exceptions (Internal Server Error pages)
* GRAPHITE_DEFAULT_CACHE_DURATION: (60) Duration to cache metric data and graphs
* GRAPHITE_CARBONLINK_HOSTS: ('127.0.0.1:7002') List of carbonlink hosts
* GRAPHITE_CARBONLINK_TIMEOUT: (1.0) Carbonlink request timeout
* GRAPHITE_CARBONLINK_HASHING_TYPE: ('carbon_ch') Type of metric hashing function.
* GRAPHITE_REPLICATION_FACTOR: (1) # The replication factor to use with consistent hashing. This should usually match the value configured in Carbon.
* GRAPHITE_CLUSTER_SERVERS: ('') This should list of remote servers in the cluster. These servers must each have local access to metric data. Note that the first server to return a match for a query will be used. See [docs](https://graphite.readthedocs.io/en/latest/config-local-settings.html#cluster-configuration) for details.
* GRAPHITE_USE_WORKER_POOL: (true) Creates a pool of worker threads to which tasks can be dispatched. This makes sense if there are multiple CLUSTER_SERVERS and/or STORAGE_FINDERS because then the communication with them can be parallelized.
* GRAPHITE_POOL_WORKERS_PER_BACKEND: (8) The number of worker threads that should be created per backend server
* GRAPHITE_POOL_WORKERS: (1) A baseline number of workers that should always be created
* GRAPHITE_REMOTE_FIND_TIMEOUT: (30) Timeout for metric find requests
* GRAPHITE_REMOTE_FETCH_TIMEOUT: (60) Timeout to fetch series data
* GRAPHITE_REMOTE_RETRY_DELAY: (0) Time before retrying a failed remote webapp.
* GRAPHITE_REMOTE_PREFETCH_DATA: (false) # set to True to fetch all metrics using a single http request per remote server instead of one http request per target, per remote server. # Especially useful when generating graphs with more than 4-5 targets or if there's significant latency between this server and the backends.
* GRAPHITE_MAX_FETCH_RETRIES: (2) Number of retries for a specific remote data fetch
* GRAPHITE_FIND_CACHE_DURATION: (0) Time to cache remote metric find results
* GRAPHITE_STATSD_HOST: ("127.0.0.1") If set, django_statsd.middleware.GraphiteRequestTimingMiddleware and django_statsd.middleware.GraphiteMiddleware will be enabled.
* GRAPHITE_URL_ROOT: ('') Sets a url prefix if deploying graphite-web to a non-root location.

## TagDB
Graphite stores tag information in a separate tag database (TagDB). Please check [tags documentation](https://graphite.readthedocs.io/en/latest/tags.html) for details.

* GRAPHITE_TAGDB: ('graphite.tags.localdatabase.LocalDatabaseTagDB') TagDB is a pluggable store, by default it uses the local SQLite database.
* REDIS_TAGDB: (false) if set to true will use local Redis instance to store tags.
* GRAPHITE_TAGDB_CACHE_DURATION: (60) Time to cache seriesByTag results.
* GRAPHITE_TAGDB_AUTOCOMPLETE_LIMIT: (100) Autocomplete default result limit.
* GRAPHITE_TAGDB_REDIS_HOST: ('localhost') Redis TagDB host
* GRAPHITE_TAGDB_REDIS_PORT: (6379) Redis TagDB port
* GRAPHITE_TAGDB_REDIS_DB: (0) Redis TagDB database number
* GRAPHITE_TAGDB_HTTP_URL: ('') URL for HTTP TagDB
* GRAPHITE_TAGDB_HTTP_USER: ('') Username for HTTP TagDB
* GRAPHITE_TAGDB_HTTP_PASSWORD: ('') Password for HTTP TagDB
* GRAPHITE_TAGDB_HTTP_AUTOCOMPLETE: (false) Does the remote TagDB support autocomplete?

## Collectd
Use `COLLECTD=1` environment variable to enable local collectd instance

## Carbon-cache
If custom environment `GRAPHITE_CARBONLINK_HOSTS` variable is setup `carbon-cache` instances as daemons/services are [managed](./conf/etc/run_once/carbon-cache) based on the that, otherwise default instance (`127.0.0.1:7002`) is used.

**Note**: if default port `7002` is used among the hosts, need to setup `CARBON_DISABLED=1` in the environment.

## Carbon-relay
Use `RELAY=1` environment variable to enable carbon relay instance. Use `[relay]` section of carbon.conf to configure it.

**Note**: in order to use `carbon-relay` daemon correctly, it must accept & distribute incoming traffic within DESTINATIONS
          endpoints which by default isn't (`carbon-cache` is). As one of solutions is to adjust `graphitePort` value to
          carbon-relay LINE_RECEIVER_PORT in [`statsd`](https://github.com/statsd/statsd/blob/master/exampleConfig.js) config.

## Logrotate
By default logs are rotated daily, using built-in `/etc/periodic/daily/logrotate` script. Please note, that according to Docker [logging best practices](https://success.docker.com/article/logging-best-practices) "Ideally, applications log to stdout/stderr, and Docker sends those logs to the configured logging destination.". You can use `-` as log file name for such behaviour.

## Runit
Each service started and controlled by runit will be gracefully shutdown when stopping the container : wait up to 7 seconds for the service to become down, then it will be killed. The runit environment variable `$SVWAIT` overrides this default timeout. Additionnally, a global timeout can be also specified with the docker-run option `--stop-timeout`.
Each service started by default can be disabled by setting an environment variable named as : `$<service name>_DISABLED`. For instance : `CARBON_AGGREGATOR_DISABLED=1`, `STATSD_DISABLED=1`...

## Startup custom scripts
At startup, entrypoint will run all scripts found in the directory /etc/run_once. It can be mounted with a docker-run option like this : `--mount type=bind,source=/path/to/run_once,destination=/etc/run_once`.

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
For example, if `/opt/statsd/config/udp.js` looks like this.

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

[More info & additional commands.](https://github.com/etsy/statsd/blob/master/docs/admin_interface.md)

## A Note on Volumes

You may find it useful to mount explicit volumes so configs & data can be managed from a known location on the host.

Simply specify the desired volumes when starting the container.

```
docker run -d\
 --name graphite\
 --restart=always\
 -v /path/to/graphite/configs:/opt/graphite/conf\
 -v /path/to/graphite/data:/opt/graphite/storage\
 -v /path/to/statsd_config:/opt/statsd/config\
 graphiteapp/graphite-statsd
```

**Note**: The container will initialize properly if you mount empty volumes at
          `/opt/graphite/conf`, `/opt/graphite/storage`, or `/opt/statsd/config`.

## Memcached config

If you have a Memcached server running, and want to Graphite use it, you can do it using environment variables, like this:

```
docker run -d\
 --name graphite\
 --restart=always\
 -p 80:80\
 -p 2003-2004:2003-2004\
 -p 2023-2024:2023-2024\
 -p 8125:8125/udp\
 -p 8126:8126\
 -e "MEMCACHE_HOST=127.0.0.1:11211"\  # Memcached host. Separate by comma more than one servers.
 -e "CACHE_DURATION=60"\              # in seconds
 graphiteapp/graphite-statsd
```

Also, you can specify more than one memcached server, using commas:

```
-e "MEMCACHE_HOST=127.0.0.1:11211,10.0.0.1:11211"
```
## Running through docker-compose
The following command will start the graphite statsd container through docker-compose
```
docker-compose up
```

## Running through Kubernetes
You can use this 3-rd party repo with Graphite Helm chart - https://github.com/kiwigrid/helm-charts/tree/master/charts/graphite

## About `root` process 

This image uses `runit` as init system, to run multiple processes in single container. It's not against Docker guidelines but bit against Docker philosophy. Also, `runit` require root privileges to run, so, it's not possible to stop using root privileges, without completely rewrite this image. This is possible, of course, but it's better to use separate images per component then, and having separate repository for this new project. 

## Experimental Features
### go-carbon 

Use `GOCARBON=1` environment variable to enable [go-carbon](https://github.com/lomik/go-carbon) instance instead of normal Carbon. Please note that it will disable carbon-aggregator too. Use `GRAPHITE_CLUSTER_SERVERS="127.0.0.1:8000"` if you want also use [carbonserver](https://github.com/grobian/carbonserver) feature.

### brubeck

Use `BRUBECK=1` environment variable to enable [brubeck]() instance of normal Statsd. Please note that brubeck has different config format and not fully compatible with original statsd.


## Additional Reading

* [Introduction to Docker](http://docs.docker.io/#introduction)
* [Official Statsd Documentation](https://github.com/etsy/statsd/)
* [Practical Guide to StatsD/Graphite Monitoring](http://matt.aimonetti.net/posts/2013/06/26/practical-guide-to-graphite-monitoring/)
* [Configuring Graphite for StatsD](https://github.com/etsy/statsd/blob/master/docs/graphite.md)

## Contributors

Build the image yourself.

1. `git clone https://github.com/graphite-project/docker-graphite-statsd.git`
1. `docker build -t graphiteapp/graphite-statsd .`

Alternate versions can be specified via `--build-arg`:

* `version` will set the version/branch used for graphite-web, carbon & whisper
* `graphite_version`, `carbon_version` & `whisper_version` set the version/branch used for individual components
* `statsd_version` sets the version/branch used for statsd (note statsd version is prefixed with v)

Alternate repositories can also be specified with the build args `graphite_repo`, `carbon_repo`, `whisper_repo` & `statsd_repo`.

To build an image from latest graphite, whisper & carbon master, run:

`docker build -t graphiteapp/graphite-statsd . --build-arg version=master`

To build an image using a fork of graphite-web, run:

`docker build -t forked/graphite-statsd . --build-arg version=master --build-arg graphite_repo=https://github.com/forked/graphite-web.git`
