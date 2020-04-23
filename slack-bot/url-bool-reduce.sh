#!/bin/bash
set -e

#
# Summary
#   投票結果を元に CSV 形式の文字列を標準出力に出力
#
# Detail
#   ・Redis の "vscovid-crawler:result-*" を元に URL を抽出
#   ・抽出した URL を全 wget し、結果を CSV 形式で標準出力に出力
#
# Caution
#   wget が URL 件数分走るので負荷に注意
#

# 依存lib
. ./lib/url-helper.sh
. ./lib/string-helper.sh

get_row_by_url() {
    url=$1
    orgname=$(get_orgname_by_url $url)
    prefname=$(get_prefname_by_url $url)
    res=$(wget -q -O - $url)
    if [ $? -ne 0 ]; then
        return 1
    fi
    title=$(get_title_by_res "$res")
    desc=$(get_desc_by_res "$res" | remove_newline_and_comma)
    echo $orgname,$prefname,$url,$title,$desc
}

main() {
    keys=$(redis-cli KEYS "vscovid-crawler:result-*")
    for key in $keys; do
        result=$(redis-cli GET $key)
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
