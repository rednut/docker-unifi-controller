# build docker image to run the unifi controller
#
# the unifi contoller is used to admin ubunquty wifi access points
#
FROM ubuntu
MAINTAINER stuart nixon dotcomstu@gmail.com
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /var/log/supervisor /usr/lib/unifi/data && \
    touch /usr/lib/unifi/data/.unifidatadir

# add unifi and mongo repo
ADD ./100-ubnt.list /etc/apt/sources.list.d/100-ubnt.list

# add ubiquity + 10gen(mongo) repo + key
# update then install
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 && \
    apt-get update -q -y && \
    apt-get install -q -y mongodb-server unifi

VOLUME /usr/lib/unifi/data
EXPOSE  8443 8880 8080 27117
WORKDIR /usr/lib/unifi
CMD ["java", "-Xmx256M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]
