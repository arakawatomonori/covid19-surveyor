#!/bin/bash

. ./slack-bot/url-map.sh

# test get_title_by_url
res=`wget -q -O - https://kantei.go.jp`
title=`get_title_by_res "$res"`
echo actual $title
title_expect_result="首相官邸ホームページ"
echo expect $title_expect_result
if [ "$title" = "$title_expect_result" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi

# test get_title_by_url
res=`wget -q -O - https://www.city.funabashi.lg.jp/jigyou/shoukou/002/corona-jigyosha.html`
title=`get_title_by_res "$res"`
echo actual $title
title_expect_result="新型コロナウィルス感染症に関する中小企業者（農林漁業者を含む）・労働者への支援｜船橋市公式ホームページ"
echo expect $title_expect_result
if [ "$title" = "$title_expect_result" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi

# test get_title_by_url
res=`wget -q -O - https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html`
title=`get_h1_by_res "$res"`
echo actual $title
title_expect_result="新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について"
echo expect $title_expect_result
if [ "$title" = "$title_expect_result" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi
