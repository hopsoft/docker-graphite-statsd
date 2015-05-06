FROM phusion/baseimage:0.9.16
# Info of base image, see: https://github.com/phusion/baseimage-docker

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
 nodejs \
 wget

# python dependencies
RUN pip install django==1.3\
 python-memcached==1.53\
 django-tagging==0.3.1\
 twisted==11.1.0\
 txAMQP==0.6.2

# install graphite
RUN git clone -b 0.9.12 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
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

# install statsd
RUN git clone -b v0.7.2 https://github.com/etsy/statsd.git /opt/statsd

# Install Grafana
RUN mkdir /opt/grafana
RUN wget http://grafanarel.s3.amazonaws.com/grafana-1.9.1.tar.gz -O /opt/grafana.tar.gz &&\
    tar -xzf /opt/grafana.tar.gz -C /opt/grafana --strip-components=1 &&\
    rm /opt/grafana.tar.gz

# configure graphite
ADD scripts/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD conf/graphite/ /opt/graphite/conf/

# configure statsd
ADD conf/statsd/config.js /opt/statsd/config.js

# configure nginx
RUN rm /etc/nginx/sites-enabled/default
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx/graphite.conf /etc/nginx/sites-available/graphite.conf
ADD conf/nginx/grafana.conf  /etc/nginx/sites-available/grafana.conf
RUN ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled/graphite.conf
RUN ln -s /etc/nginx/sites-available/grafana.conf /etc/nginx/sites-enabled/grafana.conf

# configure grafana
ADD conf/grafana/config.js /opt/grafana/config.js

# init django admin
ADD scripts/django_admin_init.exp /usr/local/bin/django_admin_init.exp
RUN /usr/local/bin/django_admin_init.exp

# logging support
ADD conf/logrotate /etc/logrotate.d/graphite

# daemons
ADD daemons/carbon.sh /etc/service/carbon/run
ADD daemons/carbon-aggregator.sh /etc/service/carbon-aggregator/run
ADD daemons/graphite.sh /etc/service/graphite/run
ADD daemons/statsd.sh /etc/service/statsd/run
ADD daemons/nginx.sh /etc/service/nginx/run

# rename the storage directory to storage_orig in the image
# it will be renamed back in entrypoint.sh when a container starts for the first time
WORKDIR /opt/graphite
RUN mv storage storage_orig

# entrypoint
ENV HOME /root
ADD scripts/entrypoint.sh /root/

# cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# defaults
ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["my_init"]

