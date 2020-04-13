#!/bin/bash
set -e

cat grep*.txt.tmp > cat.txt.tmp
sort cat.txt.tmp > sort.txt.tmp
uniq -d sort.txt.tmp > uniq.txt.tmp

urls=""
for line in `cat uniq.txt.tmp`; do
	echo $line
	url=`echo ${line} | cut -d':' -f 1`
	url="${url:2:-1}l"
	urls=("${urls}\n${url}")
done

echo -e $urls
echo -e $urls > urls.txt.tmp

uniq urls.txt.tmp > urls.txt
