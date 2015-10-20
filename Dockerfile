FROM phusion/baseimage:0.9.15
MAINTAINER Matthew Tse <mtse@google.com>

#RUN echo deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main universe > /etc/apt/sources.list.d/universe.list
RUN apt-get -y update\
 && apt-get -y upgrade

# dependencies
RUN apt-get -y --force-yes install vim\
 nginx\
 python-dev\
 python-flup\
 python-pip\
 expect\
 git\
 memcached\
 sqlite3\
 libcairo2\
 libcairo2-dev\
 python-cairo\
 pkg-config\
 nodejs

# python dependencies
RUN pip install django==1.5\
 python-memcached==1.53\
 django-tagging==0.3.1\
 twisted==11.1.0\
 txAMQP==0.6.2

# install graphite
RUN git clone -b 0.9.13-pre1 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
WORKDIR /usr/local/src/graphite-web
RUN python ./setup.py install

# install whisper
RUN git clone -b 0.9.12 https://github.com/graphite-project/whisper.git /usr/local/src/whisper
WORKDIR /usr/local/src/whisper
RUN python ./setup.py install

# install carbon
RUN git clone -b 0.9.12 https://github.com/graphite-project/carbon.git /usr/local/src/carbon
WORKDIR /usr/local/src/carbon
RUN python ./setup.py install

# install carbon-c-relay
RUN git clone -b v0.44 https://github.com/grobian/carbon-c-relay.git /usr/local/src/carbon-c-relay
WORKDIR /usr/local/src/carbon-c-relay
RUN make

# install grafana
WORKDIR /usr/local/src/grafana
RUN curl https://grafanarel.s3.amazonaws.com/builds/grafana-2.1.3.linux-x64.tar.gz -o grafana-2.1.3.linux-x64.tar.gz
RUN tar -xzvf grafana-2.1.3.linux-x64.tar.gz

# config nginx
RUN rm /etc/nginx/sites-enabled/default

# init django admin
ADD scripts/django_admin_init.exp /usr/local/bin/django_admin_init.exp
RUN /usr/local/bin/django_admin_init.exp

# logging support
RUN mkdir -p /var/log/carbon /var/log/graphite /var/log/nginx
# ADD conf/logrotate /etc/logrotate.d/graphite
# RUN chmod 644 /etc/logrotate.d/graphite

# daemons
ADD daemons/carbon-cache-a.sh /etc/service/carbon-cache-a/run
ADD daemons/carbon-cache-b.sh /etc/service/carbon-cache-b/run
ADD daemons/carbon-cache-c.sh /etc/service/carbon-cache-c/run
ADD daemons/carbon-cache-d.sh /etc/service/carbon-cache-d/run
ADD daemons/carbon-cache-e.sh /etc/service/carbon-cache-e/run
ADD daemons/carbon-cache-f.sh /etc/service/carbon-cache-f/run
ADD daemons/carbon-cache-g.sh /etc/service/carbon-cache-g/run
ADD daemons/carbon-cache-h.sh /etc/service/carbon-cache-h/run

# ADD daemons/carbon-aggregator.sh /etc/service/carbon-aggregator/run
ADD daemons/graphite.sh /etc/service/graphite/run
# ADD daemons/statsd.sh /etc/service/statsd/run
ADD daemons/carbon-c-relay.sh /etc/service/carbon-c-relay/run
ADD daemons/nginx.sh /etc/service/nginx/run
ADD daemons/grafana.sh /etc/service/grafana/run

# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configs
ADD scripts/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD conf/graphite/ /opt/graphite/conf/
ADD conf/grafana/defaults.ini /etc/grafana/conf/defaults.ini
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx/graphite.conf /etc/nginx/sites-available/graphite.conf
RUN ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled/graphite.conf

# defaults
ENV HOME /root
CMD ["/sbin/my_init"]
