#!/bin/bash
set -e

. ./lib/test-helper.sh

. ./lib/url-helper.sh

echo test get_domain_by_url
actual=`get_domain_by_url http://www.kantei.go.jp`
expect="www.kantei.go.jp"
assert_equal $expect $actual


echo test get_govname_by_url
actual=`get_govname_by_url https://www.mhlw.go.jp`
expect="厚生労働省"
assert_equal $expect $actual