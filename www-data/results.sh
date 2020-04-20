#!/bin/bash
echo 'Content-type: text/plain'
echo ''
keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
    result=`redis-cli GET $key`
    url=`echo $result| cut -d',' -f 1`
    bool=`echo $result| cut -d',' -f 4`
    if [ $bool = "true" ]; then
        echo $url
    fi
done



