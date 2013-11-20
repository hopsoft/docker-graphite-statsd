# Docker Image for Graphite

This image includes the following:

* [Graphite](http://graphite.readthedocs.org/en/latest/) - front-end dashboard
* [Carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html) - back-end
* [Statsd](https://github.com/etsy/statsd/wiki) - UDP based back-end proxy

The notable files for building the Docker image are:

* `Dockerfile`
* `assets` - files copied to the image
  * `install` - the install script

The majority of the install logic resides in the
[assets/install](https://github.com/hopsoft/docker-graphite-statsd/blob/master/assets/install) script.
The intent is to mitigate issues that arise from
[stacking too many AUFS layers](https://github.com/dotcloud/docker/issues/1171).

## Vagrant

This project ships with a `Vagrantfile` to simplify using and/or building the image,
but Vagrant isn't required.

### Clone the Project

```
git clone https://github.com/hopsoft/docker-graphite-statsd.git
cd docker-graphite-statsd
```

### Start the Virtual Machine & Login

*Ports 3000, 4000, & 5000 are mapped between the host & the virtual machine.*

```
vagrant up
vagrant ssh
```

### Build the Image

```
sudo docker build -t hopsoft/graphite-statsd /vagrant
```

### Start a Container

Be sure to map ports for the following services:

* `80` - nginx which is reverse proxying to the Django front-end dashboard
* `2003` - carbon daemon for backend storage
* `8125` - statsd daemon for the UDP based storage proxy

*Note: Be sure to specify the UDP protocol for the Statsd port.*

It's also a good idea to mount volumes for Graphite's SQLite database, configuration, & log files.

* `/opt/graphite/storage`
* `/opt/graphite/conf`
* `/var/log`

```
sudo su -
mkdir /var/log/graphite
docker run -i -t -p 3000:80 -p 2003:2003 -p 8125:8125/udp -v /var/log/graphite:/var/log -v /opt/graphite/storage -v /opt/graphite/conf hopsoft/graphite-statsd bash
# manually tweak the container if desired
/opt/hopsoft/graphite-statsd/start
```

Exit the container with: `CTL-P CTL-Q`

---

Using data volumes will allow you to start a new container while preserving the
configuration & data should something happen to the original container.

See Docker's [working with volumes](http://docs.docker.io/en/latest/use/working_with_volumes/#create-a-new-container-using-existing-volumes-from-an-existing-container).

## Start Using Graphite

### Send Some Stats

We'll fake some stats with a random counter to prove things are working.
*Note: This examples assume that you are running Graphite in the Vagrant virtual machine.*

```
while true
do
  value="$(((RANDOM % 10) + 1))"
  echo $value
  # echo "example.carbon.counter.changed $value `date -d -${value}min +%s`" | nc localhost 2003
  echo -n "example.statsd.counter.changed:$value|c" | nc -w 1 -u localhost 8125
  sleep 1
done
```

### Visualize the Data

From the host machine visit: [http://localhost:3000/dashboard](http://localhost:3000/dashboard)

## What Next?

1. Update the default Django admin user account. _The default is insecure._

  * username: root
  * password: root
  * email: root.graphite@mailinator.com

  First login at: [http://localhost:3000/account/login](http://localhost:3000/account/login)
  Then update the root user's profile at: [http://localhost:3000/admin/auth/user/1/](http://localhost:3000/admin/auth/user/1/)

2. Read up on Graphite's [post-install tasks](https://graphite.readthedocs.org/en/latest/install.html#post-install-tasks).
  Focus on the [storage-schemas.conf](https://graphite.readthedocs.org/en/latest/config-carbon.html#storage-schemas-conf)

  **Note:** If you change settings in `storage-schemas.conf`, be sure to run `whisper-resize.py` to resize the whisper files.
  For example, if you update the config to look something like this:

  ```
  [all]
  pattern = .*
  retentions = 10s:12h,1m:7d,10m:5y
  ```

  Resize the storage files by running this command.

  ```
  find /opt/graphite/storage -type f -name '*.wsp' -exec whisper-resize.py --nobackup {} 10s:12h 1m:7d 10m:5y \;
  ```

  **Important:** Ensure your Statsd flush interval is at least as long as the highest-resolution retention.
  For example, if `/opt/statsd/config.js` looks like this.

  ```
  flushInterval: 10
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

## Additional Reading

* [Practical Guide to StatsD/Graphite Monitoring](http://matt.aimonetti.net/posts/2013/06/26/practical-guide-to-graphite-monitoring/)

