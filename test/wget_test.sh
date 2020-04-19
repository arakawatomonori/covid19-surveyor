#!/bin/bash
set -e

. ./lib/helper.sh

. ./crawler/wget.sh

echo test get_target_urls
actual=`get_target_urls data/test.csv`
assert_equal "http://www.kantei.go.jp https://www.cao.go.jp http://www.bousai.go.jp https://www.mhlw.go.jp https://www.meti.go.jp" "$actual"

echo test get_target_domains
actual=`get_target_domains $actual`
assert_equal "www.kantei.go.jp www.cao.go.jp www.bousai.go.jp www.mhlw.go.jp www.meti.go.jp" "$actual"
