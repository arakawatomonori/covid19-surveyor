#!/bin/bash
set -e

. ./lib/url-helper.sh

source .env
ts=`date '+%s'`


keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
    value=`redis-cli GET $key`
    url=`echo $value| cut -d',' -f 1`
    md5=`get_md5_by_url $url`
    redis-cli SET vscovid-crawler-vote:queue-${md5} $value
done