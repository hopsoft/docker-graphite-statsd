FROM phusion/baseimage:0.11 as build
MAINTAINER Denys Zhdanov <denis.zhdanov@gmail.com>

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y update \
 && apt-get -y upgrade \
 && apt-get -y install \
      git \
      libcairo2-dev \
      libffi-dev \
      librrd-dev \
      nginx \
      pkg-config \
      python3-cairo \
      python3-dev \
      python3-ldap \
      python3-pip \
      python3-rrdtool \
      sqlite3 \
      wget \
 && rm -rf /var/lib/apt/lists/*

# fix python dependencies (LTS Django)
RUN python3 -m pip install --upgrade virtualenv virtualenv-tools \
 && virtualenv /opt/graphite \
 && . /opt/graphite/bin/activate \
 && python3 -m pip install --upgrade pip \
 && pip3 install \
      django==1.11.15 \
      django-statsd-mozilla \
      fadvise \
      gunicorn \
      msgpack-python \
      redis \
      rrdtool

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
COPY conf/opt/graphite/conf/*.conf /opt/graphite/conf/
COPY conf/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
WORKDIR /opt/graphite/webapp
RUN mkdir -p /var/log/graphite/ \
  && PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py collectstatic --noinput --settings=graphite.settings

# config statsd
COPY conf/opt/statsd/config_*.js /opt/statsd/

FROM phusion/baseimage:0.11 as production
MAINTAINER Denys Zhdanov <denis.zhdanov@gmail.com>

ENV STATSD_INTERFACE udp

# choose a timezone at build-time
# use `--build-arg CONTAINER_TIMEZONE=Europe/Brussels` in `docker build`
ARG CONTAINER_TIMEZONE

RUN if [ ! -z "${CONTAINER_TIMEZONE}" ]; \
    then ln -sf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata; \
    fi

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update --fix-missing \
 && apt-get -y upgrade \
 && apt-get install --yes --no-install-recommends \
      collectd \
      expect \
      git \
      libcairo2 \
      librrd-dev \
      memcached \
      nginx \
      python3-ldap \
      python3-pip \
      redis \
      sqlite3 \
 && apt-get clean \
 && apt-get autoremove --yes \
 && rm -rf \
      /var/lib/apt/lists/* \
      /etc/nginx/sites-enabled/default \
 && mkdir -p \
      /var/log/carbon \
      /var/log/graphite

COPY conf /
COPY conf /etc/graphite-statsd/conf/

# copy /opt from build image
COPY --from=build /opt /opt

RUN /usr/local/bin/django_admin_init.exp

# defaults
EXPOSE 80 2003-2004 2023-2024 8080 8125 8125/udp 8126
VOLUME ["/opt/graphite/conf", "/opt/graphite/storage", "/opt/graphite/webapp/graphite/functions/custom", "/etc/nginx", "/opt/statsd", "/etc/logrotate.d", "/var/log", "/var/lib/redis"]

CMD ["/sbin/my_init"]
