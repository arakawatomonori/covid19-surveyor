#!/bin/bash
set -e

cat ./grep-data/grep_コロナ_*.txt.tmp > ./tmp/cat.txt.tmp
sort ./tmp/cat.txt.tmp > ./tmp/sort.txt.tmp
uniq -d ./tmp/sort.txt.tmp > result.txt

urls=""
for line in `cat uniq.txt`; do
	echo $line
	url=`echo ${line} | cut -d':' -f 1`
	url="${url:2:-1}l"
	urls=("${urls}\n${url}")
done

echo -e $urls
echo -e $urls > ./tmp/urls.txt.tmp

uniq ./tmp/urls.txt.tmp > urls.txt
