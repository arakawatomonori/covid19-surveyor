#!/bin/bash
set -e


# 依存lib
. ./lib/url-helper.sh
. ./lib/string-helper.sh

get_url_by_md5() {
    md5=$1
    url=$(grep "$md5" ./urls-md5.csv | head -1 | cut -d',' -f 2)
    echo $url
}

get_row_by_url_with_label() {
    url=$1
    label=$2
    res=$(wget -q -O - --timeout=5 $url)
    if [ $? -ne 0 ]; then
        return 1
    fi
    title=$(get_title_by_res "$res"|sed "s/\"/ /g")
    desc=$(get_desc_by_res "$res" | remove_newline_and_comma | sed "s/\"/ /g")
    echo "$title $desc, $label"
}

main() {
    keys=$(redis-cli KEYS "vscovid-crawler-vote:result-*")
    for key in $keys; do
        md5=$(echo $key| cut -d'-' -f 4)
        score=$(redis-cli GET $key)
        label="covid19_help"
        if [[ $score == "0" ]]; then
            label="unknown"
        elif [[ $score == -* ]]; then
            label="not_covid19_help"
        fi
        url=`get_url_by_md5 $md5`
        if [[ $url == "" ]]; then
            continue
        fi
        echo `get_row_by_url $url $label`
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
