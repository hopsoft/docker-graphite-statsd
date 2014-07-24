FROM hopsoft/nodejs
MAINTAINER Nathan Hopkins, natehop@gmail.com

ADD assets /opt/hopsoft/graphite-statsd
RUN /opt/hopsoft/graphite-statsd/build

EXPOSE 80 2003 8125
