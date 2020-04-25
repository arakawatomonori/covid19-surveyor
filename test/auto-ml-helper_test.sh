#!/bin/bash
set -e

source .env

. ./lib/test-helper.sh
. ./lib/auto-ml-helper.sh


# environment=developmentの時だけ以下のテストを実行するようにしたい
if [ $environment = "development" ]; then
    echo test get_predict_by_url covid19_help
    actual=$(get_predict_by_url "https://www.pref.ehime.jp/h10500/kojinjigyo/kojin_kigenencho.html")
    expect="\"covid19_help\",0.88701725"
    assert_equal "$expect" "$actual"

    echo test get_predict_by_url not_covid19_help
    actual=$(get_predict_by_url "https://www.pref.ehime.jp/")
    expect="\"not_covid19_help\",0.96028984"
    assert_equal "$expect" "$actual"
fi