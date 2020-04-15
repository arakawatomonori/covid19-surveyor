#!/bin/bash
set -e

###
### About
### grep.shで./tmpに収集した情報を結合し、ソートし、重複を取り除くスクリプト
###
### Usage
### ./aggregate.sh
###


cat ./tmp/grep_コロナ_*.txt.tmp > ./tmp/cat.txt.tmp
sort ./tmp/cat.txt.tmp > ./tmp/sort.txt.tmp
uniq -d ./tmp/sort.txt.tmp > result.txt

urls=""
for line in `cat result.txt`; do
	url=`echo ${line} | cut -d':' -f 1`
	url="${url:2:-1}l"
	urls=("${urls}\n${url}")
done

echo -e $urls > ./tmp/urls.txt.tmp

uniq ./tmp/urls.txt.tmp > urls.txt
