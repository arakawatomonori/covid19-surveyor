#!/bin/bash -e

# import all
make -C /app test

$(which nginx) -t
/etc/init.d/nginx start

/etc/init.d/fcgiwrap start

mkdir -p /var/spool/squid
chown -R proxy:proxy /var/spool/squid
$(which squid) -N -f /etc/squid/squid.conf -z

exec $(which squid) -f /etc/squid/squid.conf -NYCd 1