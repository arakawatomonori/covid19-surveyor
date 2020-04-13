#!/bin/bash
set -e

/etc/init.d/nginx start


mkdir -p /var/spool/squid
chown -R proxy:proxy /var/spool/squid
$(which squid) -N -f /etc/squid/squid.conf -z

exec $(which squid) -f /etc/squid/squid.conf -NYCd 1


