#!/bin/bash
set -e

# reduce.csvの内容をredisのqueueとして投入する
# すでに投入済みの場合はスキップする

. ./lib/url-helper.sh

namespace="vscovid-crawler-select-type"

while read line; do
    orgname=`echo $line| cut -d',' -f 1`
    url=`echo $line| cut -d',' -f 2`
    title=`echo $line| cut -d',' -f 3`
    desc=`echo $line| cut -d',' -f 4`
    md5=`get_md5_by_url $url`
    
    is_exists=`redis_exists_md5 $namespace $md5`
    if [ $is_exists = "0" ]; then
      redis-cli SET "$namespace:queue-$md5" "$url,$orgname,$title,$desc"
    fi
done < reduce.csv