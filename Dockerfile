FROM phusion/baseimage:0.11 as build
MAINTAINER Denys Zhdanov <denis.zhdanov@gmail.com>

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install wget \
  nginx \
  python3-dev \
  python3-pip \
  python3-ldap \
  git \
  sqlite3 \
  libffi-dev \
  librrd-dev \
  libcairo2-dev \
  python3-cairo \
  python3-rrdtool \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

# fix python dependencies (LTS Django)
RUN python3 -m pip install --upgrade virtualenv virtualenv-tools && \
  virtualenv /opt/graphite && \
  . /opt/graphite/bin/activate && \
  python3 -m pip install --upgrade pip && \
  pip3 install django==1.11.15 && \
  pip3 install msgpack-python && \
  pip3 install gunicorn && \
  pip3 install fadvise && \
  pip3 install redis && \
  pip3 install rrdtool && \
  pip3 install msgpack-python && \
  pip3 install django-statsd-mozilla

ARG version=1.1.4
ARG whisper_version=${version}
ARG carbon_version=${version}
ARG graphite_version=${version}

ARG whisper_repo=https://github.com/graphite-project/whisper.git
ARG carbon_repo=https://github.com/graphite-project/carbon.git
ARG graphite_repo=https://github.com/graphite-project/graphite-web.git

ARG statsd_version=v0.8.0

ARG statsd_repo=https://github.com/etsy/statsd.git

# install whisper
RUN git clone -b ${whisper_version} --depth 1 ${whisper_repo} /usr/local/src/whisper
WORKDIR /usr/local/src/whisper
RUN . /opt/graphite/bin/activate && python3 ./setup.py install

# install carbon
RUN git clone -b ${carbon_version} --depth 1 ${carbon_repo} /usr/local/src/carbon
WORKDIR /usr/local/src/carbon
RUN . /opt/graphite/bin/activate && pip3 install -r requirements.txt \
  && python3 ./setup.py install

# install graphite
RUN git clone -b ${graphite_version} --depth 1 ${graphite_repo} /usr/local/src/graphite-web
WORKDIR /usr/local/src/graphite-web
RUN . /opt/graphite/bin/activate && pip3 install -r requirements.txt \
  && python3 ./setup.py install

# fixing RRD support (see https://github.com/graphite-project/docker-graphite-statsd/issues/63)
RUN sed -i \
's/return os.path.realpath(fs_path)/return os.path.realpath(fs_path).decode("utf-8")/' \
/opt/graphite/webapp/graphite/readers/rrd.py

# installing nodejs 6
WORKDIR /opt
RUN wget https://nodejs.org/download/release/v6.14.4/node-v6.14.4-linux-x64.tar.gz && \
  tar -xvpzf node-v6.14.4-linux-x64.tar.gz && rm node-v6.14.4-linux-x64.tar.gz && mv node-v6.14.4-linux-x64 nodejs

# install statsd
RUN git clone -b ${statsd_version} ${statsd_repo} /opt/statsd

# config graphite
ADD conf/opt/graphite/conf/*.conf /opt/graphite/conf/
ADD conf/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
WORKDIR /opt/graphite/webapp
RUN mkdir -p /var/log/graphite/ \
  && PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py collectstatic --noinput --settings=graphite.settings

# config statsd
ADD conf/opt/statsd/config_*.js /opt/statsd/

FROM phusion/baseimage:0.11 as production
MAINTAINER Denys Zhdanov <denis.zhdanov@gmail.com>

# choose a timezone at build-time
# use `--build-arg CONTAINER_TIMEZONE=Europe/Brussels` in `docker build`
ARG CONTAINER_TIMEZONE
ENV DEBIAN_FRONTEND noninteractive

RUN if [ ! -z "${CONTAINER_TIMEZONE}" ]; \
    then ln -sf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata; \
    fi

RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get install --yes --no-install-recommends \
    git \
    redis \
    collectd \
    nginx \
    python3-pip \
    python3-ldap \
    expect \
    memcached \
    sqlite3 \
    libcairo2 \
    librrd-dev && \
    apt-get clean && \
    apt-get autoremove --yes  && \
    rm -rf /var/lib/apt/lists/*

# copy /opt from build image
COPY --from=build /opt /opt

# config nginx
RUN rm /etc/nginx/sites-enabled/default
ADD conf/etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/etc/nginx/sites-enabled/graphite-statsd.conf /etc/nginx/sites-enabled/graphite-statsd.conf

# config redis
ADD conf/etc/redis/redis.conf /etc/redis/redis.conf

# config collectd
ADD conf/etc/collectd/collectd.conf /etc/collectd/collectd.conf

# logging support
RUN mkdir -p /var/log/carbon /var/log/graphite /var/log/nginx /var/log/graphite/
ADD conf/etc/logrotate.d/graphite-statsd /etc/logrotate.d/graphite-statsd

# daemons
ADD conf/etc/service/ /etc/service/

# default conf setup
ADD conf /etc/graphite-statsd/conf
ADD conf/etc/my_init.d/01_conf_init.sh /etc/my_init.d/01_conf_init.sh

# init django admin
ADD conf/usr/local/bin/django_admin_init.exp /usr/local/bin/django_admin_init.exp
ADD conf/usr/local/bin/manage.sh /usr/local/bin/manage.sh
RUN chmod +x /usr/local/bin/manage.sh && /usr/local/bin/django_admin_init.exp

# defaults
EXPOSE 80 2003-2004 2023-2024 8080 8125 8125/udp 8126
VOLUME ["/opt/graphite/conf", "/opt/graphite/storage", "/opt/graphite/webapp/graphite/functions/custom", "/etc/nginx", "/opt/statsd", "/etc/logrotate.d", "/var/log", "/var/lib/redis"]
WORKDIR /
ENV HOME /root
ENV STATSD_INTERFACE udp

CMD ["/sbin/my_init"]
