#!/bin/bash
set -e

# import all
cd /home/ubuntu/vscovid-crawler
make test

$(which nginx) -t
/etc/init.d/nginx start

/etc/init.d/fcgiwrap start

mkdir -p /var/spool/squid
chown -R proxy:proxy /var/spool/squid
$(which squid) -N -f /etc/squid/squid.conf -z

exec $(which squid) -f /etc/squid/squid.conf -NYCd 1


