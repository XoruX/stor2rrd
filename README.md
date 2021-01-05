# XoruX STOR2RRD Docker
This is dockerized version of single [XoruX](https://www.xorux.com) application - [STOR2RRD](https://www.stor2rrd.com).

It's based on the latest official [Alpine Linux](https://hub.docker.com/_/alpine) with all necessary dependencies installed.

Quick start:

    docker run -d --name STOR2RRD --restart always -p 8080:80 xorux/stor2rrd

or better 

    XORUX_DIR=/srv/xorux   # select any directory with rwx owner permissions
    mkdir -p $XORUX_DIR/stor2rrd
    chown 1005 $XORUX_DIR/stor2rrd # 1005 is uid of user stor2rrd inside the container
    docker run -d --name STOR2RRD --restart always -v $XORUX_DIR/stor2rrd/data:/home/stor2rrd/stor2rrd/data -v $XORUX_DIR/stor2rrd/etc:/home/stor2rrd/stor2rrd/etc -p 8080:80 xorux/stor2rrd

If you run container with volume params, it will use XORUX_DIR to store all data and configurations for easy backups, log access and further upgrades.

You can set container timezone via env variable TIMEZONE in docker run command:

    docker run -d --name STOR2RRD --restart always -v $XORUX_DIR/stor2rrd/data:/home/stor2rrd/stor2rrd/data -v $XORUX_DIR/stor2rrd/etc:/home/stor2rrd/stor2rrd/etc -p 8080:80 -e TIMEZONE="Europe/Prague" xorux/stor2rrd

Application UI can be found on http://<CONTAINER_IP>, use admin/admin for login.

You can connect via SSH on port 22 (exposed), username **stor2rrd**, password **xorux4you** - please change it ASAP.
