#!/bin/bash
set -e


# 依存lib
. ./lib/url-helper.sh
. ./lib/string-helper.sh

get_text_by_url() {
    set +e
    url=$1
    res=$(wget -q -O - --tries=1 --timeout=5 --dns-timeout=5 --connect-timeout=5 --read-timeout=5 $url)
    if [ $? -ne 0 ]; then
        return 1
    fi
    title=$(get_title_by_res "$res"|sed "s/\"/ /g")
    desc=$(get_desc_by_res "$res" | remove_newline_and_comma | sed "s/\"/ /g")
    set -e
    echo "$title $desc"
}


echo "" > ./data/eval.csv
while read line;do
    echo $line
    md5=$(echo $line|cut -d',' -f 1)
    url=$(echo $line|cut -d',' -f 2)
    if [[ $url == "" ]]; then
        continue
    fi
    text=$(get_text_by_url $url)
    if [[ $text == "" ]]; then
        continue
    fi
    echo "$md5,$text" >> ./data/eval.csv
done < ./data/urls-md5.csv