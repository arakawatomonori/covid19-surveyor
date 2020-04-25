#!/bin/bash
set -e

. ./lib/test-helper.sh
. ./lib/auto-ml-helper.sh

echo test get_predict_by_url
actual=$(get_predict_by_url "https://www.pref.ehime.jp/h10500/kojinjigyo/kojin_kigenencho.html")
expect=""
assert_equal $expect $actual