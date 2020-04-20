#!/bin/bash
set -e

. ./lib/test-helper.sh

. ./lib/url-helper.sh

echo test get_domain_by_url
actual=`get_domain_by_url http://www.kantei.go.jp`
expect="www.kantei.go.jp"
assert_equal "$expect" "$actual"


echo test get_orgname_by_url
actual=`get_orgname_by_url https://www.mhlw.go.jp`
expect="厚生労働省"
assert_equal "$expect" "$actual"


echo test get_title_by_res
res=`wget -q -O - https://kantei.go.jp`
title=`get_title_by_res "$res"`
assert_equal "首相官邸ホームページ" "$title"

echo test get_title_by_res
res=`wget -q -O - https://www.city.funabashi.lg.jp/jigyou/shoukou/002/corona-jigyosha.html`
title=`get_title_by_res "$res"`
assert_equal "新型コロナウィルス感染症に関する中小企業者（農林漁業者を含む）・労働者への支援｜船橋市公式ホームページ" "$title"

echo test get_title_by_res
res=`wget -q -O - https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html`
title=`get_title_by_res "$res"`
assert_equal "新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について - 大分県ホームページ" "$title"
