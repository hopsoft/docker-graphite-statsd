FROM hopsoft/nodejs
MAINTAINER Nathan Hopkins, natehop@gmail.com

ADD assets /opt/hopsoft/graphite-statsd
RUN /opt/hopsoft/graphite-statsd/install

###
# Ensure that nginx has it's log directory to write to or it'll shit a brick
###
RUN mkdir -p /var/log/nginx
