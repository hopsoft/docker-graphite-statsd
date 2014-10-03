FROM phusion/baseimage:0.9.14
MAINTAINER Nathan Hopkins <natehop@gmail.com>

#RUN echo deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main universe > /etc/apt/sources.list.d/universe.list
RUN apt-get -y update

# dependencies
RUN apt-get -y --force-yes install vim \
  nginx \
  python-dev \
  python-flup \
  python-pip \
  expect \
  git \
  memcached \
  sqlite3 \
  libcairo2 \
  libcairo2-dev \
  python-cairo \
  pkg-config \
  nodejs

# python dependencies
RUN pip install django==1.3 \
  python-memcached==1.53 \
  django-tagging==0.3.1 \
  whisper==0.9.12 \
  twisted==11.1.0 \
  txAMQP==0.6.2

# install graphite
RUN git clone -b 0.9.12 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
WORKDIR /usr/local/src/graphite-web
RUN python ./setup.py install
COPY scripts/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
COPY conf/graphite/ /opt/graphite/conf/

# install whisper
RUN git clone -b 0.9.12 https://github.com/graphite-project/whisper.git /usr/local/src/whisper
WORKDIR /usr/local/src/whisper
RUN python ./setup.py install

# install carbon
RUN git clone -b 0.9.12 https://github.com/graphite-project/carbon.git /usr/local/src/carbon
WORKDIR /usr/local/src/carbon
RUN python ./setup.py install

# install statsd
RUN git clone -b v0.7.2 https://github.com/etsy/statsd.git /opt/statsd
COPY conf/statsd/config.js /opt/statsd/config.js

# config nginx
RUN mkdir -p /var/log/nginx
RUN rm /etc/nginx/sites-enabled/default
COPY conf/nginx/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx/graphite.conf /etc/nginx/sites-available/graphite.conf
RUN ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled/graphite.conf

# init django admin
COPY scripts/django_admin_init.exp /usr/local/bin/django_admin_init.exp
RUN /usr/local/bin/django_admin_init.exp

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
