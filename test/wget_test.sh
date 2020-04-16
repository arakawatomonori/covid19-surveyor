#!/bin/bash

. ./crawler/wget.sh

# test get_target_urls
urls=`get_target_urls data/test.csv`
echo $urls
urls_expect_result="http://www.kantei.go.jp https://www.cao.go.jp http://www.bousai.go.jp https://www.mhlw.go.jp https://www.meti.go.jp"
echo $urls_expect_result
if [ "$urls" = "$urls_expect_result" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi

# test get_target_domains
domains=`get_target_domains $urls`
echo $domains
domains_expect_result="www.kantei.go.jp www.cao.go.jp www.bousai.go.jp www.mhlw.go.jp www.meti.go.jp"
echo $domains_expect_result
if [ "$domains" = "$domains_expect_result" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi
