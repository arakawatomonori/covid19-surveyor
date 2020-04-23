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
cat ./tmp/grep_コロナ_*.txt.tmp | sort | uniq > ./tmp/results.txt

# result.txtからurlのみを抜き出す
urls=$(cat ./tmp/results.txt | cut -d':' -f 1 | sed -z 's/\.\/www-data\///g')

echo "" > ./tmp/urls.txt

for url in $urls; do
    echo "$url" >> ./tmp/urls.txt
done

uniq ./tmp/urls.txt > ./tmp/urls-uniq.txt
