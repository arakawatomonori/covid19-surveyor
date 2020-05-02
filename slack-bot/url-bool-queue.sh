#!/bin/bash
set -e

# tmp/urls-uniq.txt の内容をredisのqueueとして投入する
# すでに投入済みの場合はスキップする

. ./lib/redis-helper.sh
. ./lib/url-helper.sh

namespace="vscovid-crawler"

for url in `cat ./tmp/urls-uniq.txt`; do
    echo path $path
    domain=`echo $path | cut -d'/' -f 1 `
    echo domain $domain
    top_url=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 3`
    echo top_url $top_url
    schema=`echo $top_url | cut -d'/' -f 1`
    url="$schema//$path"
    echo url $url
    md5=`get_md5_by_url $url`
    echo $md5
    # redisに存在しないことを確認する
    is_exists=`redis_exists_md5 $namespace $md5`
    if [ $is_exists = "0" ]; then
        redis-cli SET "$namespace:queue-$md5" $url
    fi
done
