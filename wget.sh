#!/bin/bash
set -e

#files=("data/gov.csv data/pref.csv data/city.csv")

urls=()
domains=()
while (( $# > 0 ))
do
	for line in `cat $1`; do
		url=`echo ${line} | cut -d',' -f 3`
		urls=("${urls} $url")
		domain=${url//http:\/\//}
		domain=${domain//https:\/\//}
		domains=("${domains} $domain")
	done
	shift
done



cd www-data
echo $urls | xargs -n 1 echo | xargs -P 16 -I{} wget -l 2 -r --no-check-certificate {}
echo $domains | xargs -n 1 echo | xargs -I{} cp -f robots.txt {}
cd -

