#!/usr/bin/docker build .
#
# VERSION               1.0

FROM       alpine:3.20
MAINTAINER jiri.dutka@xorux.com

ENV HOSTNAME XoruX
ENV VI_IMAGE 1

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apk -U upgrade && apk add --no-cache \
    bash \
    wget \
    supervisor \
    busybox-suid \
    apache2 \
    bc \
    net-snmp \
    net-snmp-tools \
    rrdtool \
    perl-rrd \
    perl-xml-simple \
    perl-xml-libxml \
    perl-net-ssleay \
    perl-crypt-ssleay \
    perl-net-snmp \
    net-snmp-perl \
    perl-lwp-protocol-https \
    perl-date-format \
    perl-dbd-pg \
    perl-io-tty \
    perl-want \
    # perl-font-ttf \
    net-tools \
    bind-tools \
    libxml2-utils \
    # snmp-mibs-downloader \
    openssh-client \
    ttf-dejavu \
    graphviz \
    vim \
    rsyslog \
    tzdata \
    sudo \
    less \
    ed \
    sharutils \
    make \
    tar \
    perl-dev \
    # perl-app-cpanminus \ 
    sqlite \
    perl-dbd-pg \
    perl-dbd-sqlite \
    iproute2 \
    lsblk \
    procps \
    diffutils \
    dpkg \
    gpg \
    gpg-agent

# perl-font-ttf from testing repo (needed for PDF reports)
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community perl-font-ttf
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing sblim-wbemcli

# rrdtool v 1.8.0 fails on start, install older version  (fixed in rrdtool-1.8.0-r5)
# RUN wget -q -P /tmp https://dl-cdn.alpinelinux.org/alpine/v3.17/main/x86_64/rrdtool-1.7.2-r6.apk
# RUN apk add /tmp/rrdtool-1.7.2-r6.apk

# temporary return back to 8.x version of openssh due to scp incompatibilities
# RUN apk add --no-cache openssh-client-common=8.8_p1-r1 openssh-client-default=8.8_p1-r1 openssh-keygen=8.8_p1-r1 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.15/main 

# install perl PDF API from CPAN (no more needed, bundled since v7.80-1)
# RUN cpanm -l /usr -n PDF::API2

# setup default user
RUN addgroup -S stor2rrd 
RUN adduser -S stor2rrd -G stor2rrd -s /bin/bash

# configure Apache
COPY configs/apache2/stor2rrd.conf /etc/apache2/sites-available/
COPY configs/apache2/htpasswd /etc/apache2/conf/
COPY configs/apache2/hardening.conf /etc/apache2/conf.d

# change apache user to stor2rrd
RUN sed -i 's/^User apache/User stor2rrd/g' /etc/apache2/httpd.conf

# disable status module
RUN sed -i '/mod_status.so/ s/^#*/#/' /etc/apache2/httpd.conf

# add product installations
ENV STOR_VER_MAJ "8.00"
ENV STOR_VER_MIN ""

ENV STOR_VER "${STOR_VER_MAJ}${STOR_VER_MIN}"

# expose ports for SSH, HTTP, HTTPS
EXPOSE 80

COPY configs/crontab /var/spool/cron/crontabs/stor2rrd
RUN chmod 640 /var/spool/cron/crontabs/stor2rrd && chown stor2rrd:cron /var/spool/cron/crontabs/stor2rrd

# download tarballs from SF
# ADD http://downloads.sourceforge.net/project/lpar2rrd/lpar2rrd/$LPAR_SF_DIR/lpar2rrd-$LPAR_VER.tar /home/lpar2rrd/
# ADD http://downloads.sourceforge.net/project/stor2rrd/stor2rrd/$STOR_SF_DIR/stor2rrd-$STOR_VER.tar /home/stor2rrd/

# download tarballs from official website
ADD https://stor2rrd.com/download-static/stor2rrd/stor2rrd-$STOR_VER.tar /tmp/

# extract tarballs
WORKDIR /tmp
RUN tar xvf stor2rrd-$STOR_VER.tar

COPY supervisord.conf /etc/
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

#RUN mkdir -p /home/lpar2rrd/lpar2rrd/data
#RUN mkdir -p /home/lpar2rrd/lpar2rrd/etc

VOLUME [ "/home/stor2rrd" ]

ENTRYPOINT [ "/startup.sh" ]

