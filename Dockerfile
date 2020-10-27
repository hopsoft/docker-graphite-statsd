ARG BASEIMAGE=alpine:3.12.0
FROM $BASEIMAGE as base
LABEL maintainer="Denys Zhdanov <denis.zhdanov@gmail.com>"

RUN true \
 && apk add --update --no-cache \
      cairo \
      cairo-dev \
      collectd \
      collectd-disk \
      collectd-nginx \
      findutils \
      librrd \
      logrotate \
      memcached \
      nginx \
      nodejs \
      npm \
      redis \
      runit \
      sqlite \
      expect \
      dcron \
      python3-dev \
      mysql-client \
      mysql-dev \
      postgresql-client \
      postgresql-dev \
      librdkafka \
      jansson \
 && rm -rf \
      /etc/nginx/conf.d/default.conf \
 && mkdir -p \
      /var/log/carbon \
      /var/log/graphite

FROM base as build
LABEL maintainer="Denys Zhdanov <denis.zhdanov@gmail.com>"

ARG python_binary=python3

RUN true \
 && apk add --update \
      alpine-sdk \
      git \
      pkgconfig \
      wget \
      go \
      cairo-dev \
      libffi-dev \
      openldap-dev \
      python3-dev \
      rrdtool-dev \
      jansson-dev \
      librdkafka-dev \
      mysql-dev \
      postgresql-dev \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && $python_binary /tmp/get-pip.py pip==20.1.1 setuptools==50.3.2 wheel==0.35.1 && rm /tmp/get-pip.py \
 && pip install virtualenv==16.7.10 \
 && virtualenv -p $python_binary /opt/graphite \
 && . /opt/graphite/bin/activate \
 && pip install \
      cairocffi==1.1.0 \
      django==2.2.16 \
      django-statsd-mozilla \
      fadvise \
      gunicorn==20.0.4 \
      eventlet>=0.24.1 \
      gevent>=1.4 \
      msgpack==0.6.2 \
      redis \
      rrdtool \
      python-ldap \
      mysqlclient \
      psycopg2 \
      django-cockroachdb==2.2.*

ARG version=1.1.7

# install whisper
ARG whisper_version=${version}
ARG whisper_repo=https://github.com/graphite-project/whisper.git
RUN git clone -b ${whisper_version} --depth 1 ${whisper_repo} /usr/local/src/whisper \
 && cd /usr/local/src/whisper \
 && . /opt/graphite/bin/activate \
 && $python_binary ./setup.py install

# install carbon
ARG carbon_version=${version}
ARG carbon_repo=https://github.com/graphite-project/carbon.git
RUN . /opt/graphite/bin/activate \
 && git clone -b ${carbon_version} --depth 1 ${carbon_repo} /usr/local/src/carbon \
 && cd /usr/local/src/carbon \
 && pip3 install -r requirements.txt \
 && $python_binary ./setup.py install

# install graphite
ARG graphite_version=${version}
ARG graphite_repo=https://github.com/graphite-project/graphite-web.git
RUN . /opt/graphite/bin/activate \
 && git clone -b ${graphite_version} --depth 1 ${graphite_repo} /usr/local/src/graphite-web \
 && cd /usr/local/src/graphite-web \
 && pip3 install -r requirements.txt \
 && $python_binary ./setup.py install

# install statsd
ARG statsd_version=0.9.0
ARG statsd_repo=https://github.com/statsd/statsd.git
WORKDIR /opt
RUN git clone "${statsd_repo}" \
 && cd /opt/statsd \
 && git checkout tags/v"${statsd_version}" \
 && npm install

# build go-carbon (experimental)
# https://github.com/go-graphite/go-carbon/pull/340
ARG gocarbon_version=0.15.5
ARG gocarbon_repo=https://github.com/go-graphite/go-carbon.git
RUN git clone "${gocarbon_repo}" /usr/local/src/go-carbon \
 && cd /usr/local/src/go-carbon \
 && git checkout tags/v"${gocarbon_version}" \
 && make \
 && chmod +x go-carbon && mkdir -p /opt/graphite/bin/ \
 && cp -fv go-carbon /opt/graphite/bin/go-carbon

# install brubeck (experimental)
ARG brubeck_version=e95d95945a9319be38e593e95691344a99fe851d
ARG brubeck_repo=https://github.com/lukepalmer/brubeck.git
ENV BRUBECK_NO_HTTP=1
RUN git clone "${brubeck_repo}" /usr/local/src/brubeck \
 && cd /usr/local/src/brubeck && git checkout "${brubeck_version}" \
 && ./script/bootstrap \
 && chmod +x brubeck && mkdir -p /opt/graphite/bin/ \
 && cp -fv brubeck /opt/graphite/bin/brubeck

COPY conf/opt/graphite/conf/                             /opt/defaultconf/graphite/
COPY conf/opt/graphite/webapp/graphite/local_settings.py /opt/defaultconf/graphite/local_settings.py

# config graphite
COPY conf/opt/graphite/conf/* /opt/graphite/conf/
COPY conf/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
WORKDIR /opt/graphite/webapp
RUN mkdir -p /var/log/graphite/ \
  && PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py collectstatic --noinput --settings=graphite.settings

# config statsd
COPY conf/opt/statsd/config/ /opt/defaultconf/statsd/config/

FROM base as production
LABEL maintainer="Denys Zhdanov <denis.zhdanov@gmail.com>"

ENV STATSD_INTERFACE udp

COPY conf /

# copy from build image
COPY --from=build /opt /opt

# defaults
EXPOSE 80 2003-2004 2013-2014 2023-2024 8080 8125 8125/udp 8126
VOLUME ["/opt/graphite/conf", "/opt/graphite/storage", "/opt/graphite/webapp/graphite/functions/custom", "/etc/nginx", "/opt/statsd/config", "/etc/logrotate.d", "/var/log", "/var/lib/redis"]

STOPSIGNAL SIGHUP

ENTRYPOINT ["/entrypoint"]
