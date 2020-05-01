#!/bin/bash
set -e

# ファイルを結合して一つにまとめる
# ソートする
# 重複を取り除く
cat ./tmp/grep_コロナ_*.txt.tmp | sort | uniq > ./tmp/grep_aggregate.txt
