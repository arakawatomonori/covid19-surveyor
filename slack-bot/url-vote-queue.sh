#!/bin/bash
set -e

. ./lib/env.sh

. ./lib/url-helper.sh
. ./lib/redis-helper.sh

ts=`date '+%s'`

namespace="vscovid-crawler-vote"

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
    # domain=example.com
    domain=`echo $domain_and_path| cut -d'/' -f1 `
    echo domain $domain
    # path=foo/bar.html
    path=`echo $domain_and_path | cut -d'/' -f 2-`
    echo path $path
    # top_url=https://example.com/index.html
    top_url=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 3`
    if [ $top_url = "" ]; then
	    continue
    fi
    echo top_url $top_url
    # schema=https:
    schema=`echo $top_url | cut -d'/' -f 1`
    # url=https://example.com/foo/bar.html
    url="$schema//$domain/$path"
    echo url $url
    md5=`get_md5_by_url $url`
    echo $md5
    # redisに存在しないことを確認する
    is_exists=`redis_exists_md5 $namespace $md5`
    if [ $is_exists = "0" ]; then
        redis-cli SET "$namespace:queue-$md5" $url
    fi
done
