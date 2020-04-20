#!/bin/bash
set -e

. ./lib/url-helper.sh

remove_newline_and_comma() {
    result=`echo $1|sed -z 's/\r//g'|sed -z 's/\n//g'|sed -z 's/,//g'`
    echo $result
}

keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
    result=`redis-cli GET $key`
    bool=`echo $result| cut -d',' -f 4`
    if [ $bool = "true" ]; then
        url=`echo $result| cut -d',' -f 1`
        govname=`get_orgname_by_url $url`
        # urlからpathを得る
        path=${url//http:\/\//}
        path=${path//https:\/\//}
        # urlからdescriptionを得る
        desc=`grep $path ./result.txt |cut -d':' -f 2`
        desc=`remove_newline_and_comma $desc`
        # urlからタイトルを得る
        title=`get_title_by_url $url|remove_newline_and_comma $(cat)`
        echo $govname,$url,$title,$desc
  fi
done
