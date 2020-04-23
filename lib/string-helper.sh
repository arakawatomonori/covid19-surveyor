#!/bin/bash
set -e

source .env


# 改行とコンマの除去
# - \n は read line の時点で削られる.
# - \r は sed で明示的に削る.
# - コンマも sed で削るが、コンマ前後の文字列が繋がるのは良くないのでスペースに置換.
remove_newline_and_comma() {
    while read line
    do
        echo -n $(echo $line | sed -z 's/\r//g' | sed -z 's/,/ /g')
    done
    echo ""
}


# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
