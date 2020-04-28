#!/bin/bash
set -e



. ./lib/url-helper.sh
. ./lib/string-helper.sh

get_row_by_url() {
    url=$1
    orgname=$(get_orgname_by_url $url)
    prefname=$(get_prefname_by_url $url)
    res=$(wget -q -O - --timeout=5 $url)
    if [ $? -ne 0 ]; then
        return 1
    fi
    title=$(get_title_by_res "$res")
    desc=$(get_desc_by_res "$res" | remove_newline_and_comma)
    echo $orgname,$prefname,$url,$title,$desc
}


get_url_by_md5() {
    md5=$1
    url=$(grep "$md5" ./data/urls-md5.csv | head -1 | cut -d',' -f 2)
    echo $url
}

main() {
    keys=$(redis-cli KEYS "vscovid-crawler-vote:result-*")
    for key in $keys; do
        md5=$(echo $key| cut -d'-' -f 4)
        score=$(redis-cli GET $key)
        if [[ $score == "0" ]]; then
            continue
        elif [[ $score == -* ]]; then
            continue
        fi
        url=`get_url_by_md5 $md5`
        if [[ $url == "" ]]; then
            continue
        fi
        echo `get_row_by_url $url $label`
        bool=$(echo ${result}| cut -d',' -f 4)
        if [ "${bool}" = "true" ]; then
            url=$(echo ${result}| cut -d',' -f 1)
            set +e
            get_row_by_url $url
            set -e
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi