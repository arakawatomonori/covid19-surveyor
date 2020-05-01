#!/bin/bash
set -e

. ./lib/url-helper.sh
. ./lib/redis-helper.sh

source .env
ts=`date '+%s'`

namespace="vscovid-crawler-vote"

while read line; do
    url=`echo $line| cut -d',' -f 2`
    md5=`get_md5_by_url $url`
    # not_covid19_helpの可能性が60%以上ならスキップ
    predict_json=`grep $md5 ./data/eval-results-md5.csv | head -n 1 | cut -d' ' -f 2-`
    echo $predict_json
    if [[ $predict_json != "" ]];then
        not_covid19_help=`echo $predict_json | jq .not_covid19_help`
        not_covid19_help=$(echo "$not_covid19_help*100" | bc | cut -d'.' -f 1)
        threshold=60
        echo $not_covid19_help
        if [ $not_covid19_help -gt $threshold ];then
            continue
        fi
    fi
    redis-cli SET "$namespace:queue-$md5" $url
done < ./data/urls-md5.csv

exit 1

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
