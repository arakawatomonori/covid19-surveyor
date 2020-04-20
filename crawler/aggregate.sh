#!/bin/bash
set -e

###
### About
### grep.shで./tmpに収集した情報を結合し、ソートし、重複を取り除くスクリプト
###
### Dependency
### - make wget
### - make grep
###
### Usage
### - make aggregate
###


# ファイルを結合して一つにまとめる
# ソートする
# 重複を取り除く
cat ./tmp/grep_コロナ_*.txt.tmp | sort | uniq -d > results.txt

# result.txtからurlのみを抜き出す
url=$(cat results.txt | cut -d':' -f 1 | sed -z 's/\.\/www-data\///g')

echo -e ${urls} | uniq > urls.txt
