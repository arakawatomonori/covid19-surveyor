#!/bin/bash
set -e

keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
    result=`redis-cli GET $key`
    bool=`echo $result| cut -d',' -f 4`
    if [ $bool = "true" ]; then
        url=`echo $result| cut -d',' -f 1`
        echo $url
  fi
done