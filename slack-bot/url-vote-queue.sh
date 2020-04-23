#!/bin/bash
set -e

. ./lib/url-helper.sh
. ./lib/redis-helper.sh

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

# http://example.com/foo/bar.html のとき
# domain_and_path=example.com/foo/bar.html
for domain_and_path in `cat ./tmp/urls-uniq.txt`; do
    # path=foo/bar.html
    path=`echo $domain_and_path | cut -d'/' -f 2-`
    echo path $path
    domain=`echo $path| cut -d'/' -f1 `
    # domain=example.com
    echo domain $domain
    top_url=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 3`
    # top_url=https://example.com/index.html
    echo top_url $top_url
    # schema=https:
    schema=`echo $top_url | cut -d'/' -f 1`
    # url=https://example.com/foo/bar.html
    url="$schema//$domain/$path"
    md5=`get_md5_by_url $url`
    echo $md5
    # redisに存在しないことを確認する
    is_exists=`redis_exists_md5 $namespace $md5`
    if [ $is_exists = "0" ]; then
        redis-cli SET "$namespace:queue-$md5" $url
    fi
done