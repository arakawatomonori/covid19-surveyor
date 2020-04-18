#!/bin/bash
set -e

. ./slack-bot/url-map.sh

echo test get_channels_id
## setup
rm -f "tmp/channels_list.json"
channels_id=`get_channels_id`
if [ -n "${#channels_id}" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect not null
	echo -e "\t" actual $channels_id
	exit 1
fi

echo test get_members_list
## setup
rm -f "tmp/members_list.json"
members_list=`get_members_list $channels_id`
if [ -n "${#members_list}" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect not null
	echo -e "\t" actual $members_list
	exit 1
fi



echo test get_title_by_res
res=`wget -q -O - https://kantei.go.jp`
title=`get_title_by_res "$res"`
title_expect_result="首相官邸ホームページ"
if [ "$title" = "$title_expect_result" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" actual $title
	echo -e "\t" expect $title_expect_result
	exit 1
fi

echo test get_title_by_res
res=`wget -q -O - https://www.city.funabashi.lg.jp/jigyou/shoukou/002/corona-jigyosha.html`
title=`get_title_by_res "$res"`
title_expect_result="新型コロナウィルス感染症に関する中小企業者（農林漁業者を含む）・労働者への支援｜船橋市公式ホームページ"
if [ "$title" = "$title_expect_result" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" actual $title
	echo -e "\t" expect $title_expect_result
	exit 1
fi

echo test get_title_by_res
res=`wget -q -O - https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html`
title=`get_title_by_res "$res"`
title_expect_result="新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について - 大分県ホームページ"
if [ "$title" = "$title_expect_result" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" actual $title
	echo -e "\t" expect $title_expect_result
	exit 1
fi
