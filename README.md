# Docker Image for Graphite

This image includes the following.

* [Graphite](http://graphite.readthedocs.org/en/latest/) - front-end dashboard
* [Carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html) - back-end storage
* [Statsd](https://github.com/etsy/statsd/wiki) - UDP based storage proxy

The notable files for building the Docker image are:

* `Dockerfile`
* `assets` - files copied to the image
  * `install` - the install script

The majority of the install logic resides in the
[assets/install](https://github.com/hopsoft/docker-graphite/blob/master/assets/install) script.
The intent is to mitigate issues that arise from
[stacking too many AUFS layers](https://github.com/dotcloud/docker/issues/1171).

## Vagrant

This project ships with a `Vagrantfile` to simplify the process of using and/or building the image.

### Clone the Project

```
git clone https://github.com/hopsoft/docker-graphite.git
cd docker-graphite
```

### Start the Virtual Machine & Login

*Note: Ports 3000, 4000, & 5000 are mapped between the host & the virtual machine.*

```
vagrant up
vagrant ssh
```

## Build the Image

```
sudo docker build -t hopsoft/graphite /vagrant
```

## Use the Image

The image includes a start-up script that simplifies the process of starting
the various services that Graphite uses.

Be sure to map ports for the following services:

* __80__ - Nginx which is reverse proxying to the Django front-end dashboard
* __2003__ - Carbon daemon for backend storage
* __8125__ - Statsd daemon for the UDP based storage proxy

*Note: Be sure to specify the UDP protocol for the Statsd port.*

It's also a good idea to mount volumes for Graphite's Sqlite database, configuration, & any log files.

* `/opt/graphite/storage`
* `/opt/graphite/conf`
* `/var/log`

```
sudo docker run -i -t -p 3000:80 -p 2003:2003 -p 8125:8125/udp -v /opt/graphite/storage -v /opt/graphite/conf hopsoft/graphite bash
# manually tweak the container if desired
/opt/hopsoft/graphite/start
```

Exit the container with: `CTL-P CTL-Q`

Using data volumes will allow you to start a new container while preserving the
configuration & data should something happen to the original container.

See Docker's [working with volumes](http://docs.docker.io/en/latest/use/working_with_volumes/#create-a-new-container-using-existing-volumes-from-an-existing-container).

## Use Graphite

*Note: These examples assume that you are running Graphite in the Vagrant virtual machine.*

### Send Some Stats

We'll fake some stats with a random counter to prove things are working.

*Note: We are sending stats to both the carbon back-end & the statsd proxy.*

```
while true
do
  value=$(((RANDOM % 10) + 1))
  echo $value
  # echo "example.carbon.counter.changed $value `date -d -${value}min +%s`" | nc localhost 2003
  echo "example.statsd.counter.changed:$value|c" | nc -w 1 -u localhost 8125
  sleep 1
done
```

### View the Dashbaord

```
http://localhost:3000/dashboard
```

## What Next?

1. Update the default Django admin user account. _The default is insecure._

* username: root
* password: root
* email: root.graphite@mailinator.com

```
http://localhost:3000/account/login
http://localhost:3000/admin/auth/user/1/
```

2. Read up on Graphite's [post-install tasks](https://graphite.readthedocs.org/en/latest/install.html#post-install-tasks).

3. Learn about [Statsd](https://github.com/etsy/statsd/).

4. Start sending stats from your apps.

## Additional Reading

* [Practical Guide to StatsD/Graphite Monitoring](http://matt.aimonetti.net/posts/2013/06/26/practical-guide-to-graphite-monitoring/)

