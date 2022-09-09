# Docker Image for Graphite

## Get Graphite running instantly to use with sitespeed.io

This is originally a fork from [Hopsoft](https://github.com/hopsoft/docker-graphite-statsd) (massive love to Hopsoft for setting up the original image) and now we just [wrap the official docker image](https://hub.docker.com/r/graphiteapp/graphite-statsd/) for Graphite. We wrap it and add some configuration to make sitespeed.io metrics to work better.

In this image, Graphite is always setup with Basic Auth (feed your .htpasswd file when starting) and the Graphite data dir is set to */opt/graphite/storage/whisper*.

## Quick Start

```sh
sudo docker run -d \
  --name graphite \
  -p 8080:80 \
  -p 2003:2003 \
  sitespeedio/graphite
```

This starts a Docker container named: **graphite** with Basic Auth **guest/guest**. Please change the login that by feeding your own .htpasswd file when starting the container ([more info about how to create your .htpasswd file](http://httpd.apache.org/docs/2.2/programs/htpasswd.html)):

```sh
sudo docker run -d \
  --name graphite \
  -p 8080:80 \
  -p 2003:2003 \
  -v /local/path/to/.htpasswd:/etc/nginx/.htpasswd \
  sitespeedio/graphite
```

And the final config that you should do is map the Graphite data dir outside of your container:

```sh
sudo docker run -d \
  --name graphite \
  -p 8080:80 \
  -p 2003:2003 \
  -v /local/path/to/.htpasswd:/etc/nginx/.htpasswd \
  -v /path/to/data/graphite/storage/whisper:/opt/graphite/storage/whisper \
  sitespeedio/graphite
```

## Data retention
You can change how often data will be stored in the  [storage-schemas.conf](https://github.com/sitespeedio/docker-graphite-statsd/blob/master/conf/graphite/storage-schemas.conf) and how metrics will be aggregated over time in [storage-aggregation.conf](https://github.com/sitespeedio/docker-graphite-statsd/blob/master/conf/graphite/storage-aggregation.conf).

The default one looks like this:

```
[sitespeed_crux]
pattern = ^sitespeed_io\.crux\.
retentions = 60m:40d

[sitespeed_run]
pattern = ^sitespeed_io\.(.*)\.(.*)\.run\.
retentions = 10s:3d

[sitespeed]
pattern = ^sitespeed_io\.
retentions = 10m:40d
```

It will store data for 40 days, change that if you need to store data longer. Etsy has good [documentation](https://github.com/etsy/statsd/blob/master/docs/graphite.md) on how to setup your Graphite metrics.

To change it, you can feed the image with a new *storage-schemas.conf*. The one you want to replace is located  
*/opt/graphite/conf/storage-schemas.conf*

Start your image like this:

```sh
sudo docker run -d \
  --name graphite \
  -p 8080:80 \
  -p 2003:2003 \
  -v /local/path/to/.htpasswd:/etc/nginx/.htpasswd \
  -v /path/to/data/graphite/storage/whisper:/opt/graphite/storage/whisper \
  -v /path/to/storage-schemas.conf:/opt/graphite/conf/storage-schemas.conf \
  sitespeedio/graphite
```


### Base Image

Built using [Official Graphite Docker container](https://hub.docker.com/r/graphiteapp/graphite-statsd/).
