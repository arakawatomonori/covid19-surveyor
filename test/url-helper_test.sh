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
assert_equal "【事業者向け】新型コロナウイルス感染症に係る支援制度のご案内｜船橋市公式ホームページ" "$title"

echo test get_title_by_res
res=`wget -q -O - https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html`
title=`get_title_by_res "$res"`
assert_equal "新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について - 大分県ホームページ" "$title"



# FIXME: Skip Assert
echo skip get_desc_by_res https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html
res=`wget -q -O - https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html`
desc=`get_desc_by_res "$res"`
# assert_equal " 新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について 大分県では、新型コロナウイルスの流行に伴い、中小企業・小規模事業者か  の経営・金融相談に対応するため、下記のとおり特別相談窓口を開設します。" "$desc"

