# build docker image to run the unifi controller
#
# the unifi contoller is used to admin ubunquty wifi access points
#
FROM ubuntu:latest
MAINTAINER stuart nixon dotcomstu@gmail.com
ENV DEBIAN_FRONTEND noninteractive

RUN \
 	mkdir -p /var/log/supervisor /usr/lib/unifi/data && \
  	touch /usr/lib/unifi/data/.unifidatadir

# add unifi repo
RUN echo > /etc/apt/sources.list.d/100-ubnt.list '\n\
## Debian/Ubuntu\n\
# stable => unifi4\n\
# deb http://www.ubnt.com/downloads/unifi/debian unifi4 ubiquiti\n\
deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti\n\
\n'

# optional mongo upstream repo
RUN echo > /etc/apt/sources.list.d/200-mongo.list '\n\ 
## Ubuntu\n\
deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen\n\
\n'


#RUN apt-get update -q -y
#RUN apt-get install -q -y supervisor apt-utils lsb-release curl wget rsync util-linux

# add ubiquity + 10gen(mongo) repo + key
# update then install
RUN \
	apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 && \
   	apt-get update -q -y && \
    apt-get install -q -y supervisor apt-utils lsb-release curl wget rsync util-linux && \
   	apt-get install -q -y unifi

ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /usr/lib/unifi/data
EXPOSE  8443 8880 8080 27117
WORKDIR /usr/lib/unifi
CMD ["/usr/bin/supervisord"]
