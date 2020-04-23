#!/bin/bash
set -e

. ./lib/url-helper.sh

source .env
ts=`date '+%s'`

namespace="redis-crawler-vote"

keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
    value=`redis-cli GET $key`
    url=`echo $value| cut -d',' -f 1`
    md5=`get_md5_by_url $url`
    redis-cli SET "$namespace:queue-$md5" $value
done

for url in `cat ./tmp/urls-uniq.txt`; do
    echo path $url
    domain=`get_domain_by_url $url`
    echo domain $domain
    host_with_url_scheme=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 3`
    echo host_with_url_scheme $host_with_url_scheme
    url=${url/$domain/$host_with_url_scheme}
    echo url $url
    md5=`get_md5_by_url $url`
    echo $md5
    # redisに存在しないことを確認する
    is_exists=`redis_exists_md5 $namespace $md5`
    if [ $is_exists = "0" ]; then
        redis-cli SET "$namespace:queue-$md5" $url
    fi
done