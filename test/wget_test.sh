#!/bin/bash
set -e

. ./lib/test-helper.sh

. ./crawler/wget.sh

echo test get_target_urls
actual=`get_target_urls data/test.csv`
expect="http://www.kantei.go.jp https://www.cao.go.jp"
assert_equal "$expect" "$actual"

echo test get_target_domains
urls="https://www.cao.go.jp http://www.bousai.go.jp"
domains=`get_target_domains $urls`
expect="www.cao.go.jp www.bousai.go.jp"
assert_equal "$expect" "$domains"
