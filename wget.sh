#!/bin/bash
set -e
files=("data/gov.csv data/pref.csv")
echo $files
urls=()
domains=()

for file in $files; do
	for line in `cat ${file}`; do
		url=`echo ${line} | cut -d',' -f 3`
		urls=("${urls} $url")
		domain=${url//http:\/\//}
		domain=${domain//https:\/\//}
		domains=("${domains} $domain")
	done
done

cd www-data
echo $urls | xargs -n 1 echo | xargs -P 0 -I% echo Download: % && wget -q -l 2 -r --no-check-certificate %
echo $domains | xargs -n 1 echo | xargs -I{} cp -f robots.txt {}
cd -

./grep.sh
./index.sh > index.html

