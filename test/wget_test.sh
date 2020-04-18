#!/bin/bash
set -e

. ./crawler/wget.sh

echo test get_target_urls
actual=`get_target_urls data/test.csv`
expect="http://www.kantei.go.jp https://www.cao.go.jp http://www.bousai.go.jp https://www.mhlw.go.jp https://www.meti.go.jp"
if [ "$actual" = "$expect" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect $expect
	echo -e "\t" actual $actual
	exit 1
fi

echo test get_target_domains
actual=`get_target_domains $actual`
expect="www.kantei.go.jp www.cao.go.jp www.bousai.go.jp www.mhlw.go.jp www.meti.go.jp"
if [ "$actual" = "$expect" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect $expect
	echo -e "\t" actual $actual
	exit 1
fi
