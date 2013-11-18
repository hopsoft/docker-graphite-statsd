FROM hopsoft/nodejs
MAINTAINER Nathan Hopkins, natehop@gmail.com

ADD assets /opt/hopsoft/graphite
RUN /opt/hopsoft/graphite/install
