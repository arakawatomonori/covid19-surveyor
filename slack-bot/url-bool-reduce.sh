#!/bin/bash
set -e

. ./lib/url-helper.sh

remove_newline_and_comma() {
    result=`echo $1|sed -z 's/\r//g'|sed -z 's/\n//g'|sed -z 's/,//g'`
    echo $result
}

get_row_by_url() {
    url=$1
    orgname=`get_orgname_by_url $url`
    prefname=`get_prefname_by_url $url`
    res=`wget -q -O - $url`
    title=`get_title_by_res "$res"`
    desc=`get_desc_by_res "$res"`
    echo $orgname,$prefname,$url,$title,$desc
}

main() {
    keys=`redis-cli KEYS "vscovid-crawler:result-*"`
    for key in $keys; do
        result=`redis-cli GET $key`
        bool=`echo $result| cut -d',' -f 4`
        if [ $bool = "true" ]; then
            url=`echo $result| cut -d',' -f 1`
            row=`get_row_by_url $url`
            echo $row
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
