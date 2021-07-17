#!/bin/bash
set -e

. ./lib/env.sh


#
# About: 改行とコンマの除去
# Details:
#   - \n は read line の時点で削られる.
#   - \r は sed で明示的に削る.
#   - コンマも sed で削るが、コンマ前後の文字列が繋がるのは良くないのでスペースに置換.
# Input: StdIn
# Output: StdOut
#

remove_newline_and_comma() {
    while read line
    do
        echo -n $(echo $line | sed -z 's/\r//g' | sed -z 's/,/ /g')
    done
    echo ""
    return 0
}


#
# About:
#   コメント行の除去
# Detailed:
#   複数行文字列を受け取り、「#」で始まる行はコメントとして除外した結果を出力する.
# Input: StdIn
# Output: StdOut
#
remove_comment_lines() {
    grep -v '^#'
    return 0
}


# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
