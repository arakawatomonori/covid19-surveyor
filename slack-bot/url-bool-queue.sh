#!/bin/bash
set -e

# urls.txtの内容をredisのqueueとして投入する
# すでに投入済みの場合はスキップする

. ./lib/redis-helper.sh
. ./lib/url-helper.sh

namespace="vscovid-crawler"

for url in `cat urls.txt`; do
    # URLの整形
    url=${url:9:-1}l
    echo path $url
    domain=`get_domain_by_url $url`
    echo domain $domain
    host=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 3`
    echo host $host
    url=${url/$domain/$host}
    echo url $url
    md5=`get_md5_by_url $url`
    echo $md5
    # redisに存在しないことを確認する
    is_exists=`redis_exists_md5 $namespace $md5`
    if [ $is_exists = "0" ]; then
        redis-cli SET "$namespace:queue-$md5" $url
    fi
done
