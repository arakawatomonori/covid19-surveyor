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



echo test get_desc_by_res
res=`wget -q -O - https://www.pref.oita.jp/soshiki/14040/sodanmadoguti1.html`
desc=`get_desc_by_res "$res"`
assert_equal "印刷用ページを表示する掲載日：2020年1月31日更新新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について大分県では、新型コロナウイルスの流行に伴い、中小企業・小規模事業者からの経営・金融相談に対応するため、下記のとおり特別相談窓口を開設します。記１名称大分県中小企業・小規模事業者経営・金融相談窓口２期間令和２年１月３１日（金）～７月３１日（金）９：００～１７：００（土曜、日曜及び祝日を除く）３担当課、電話番号商工観光労働部経営創造・金融課（経営に関すること）電話：097-506-3223（金融に関すること）電話：097-506-3226４相談内容中小企業・小規模事業者の経営、金融全般に関すること５その他次の機関でも相談を受け付けています。・大分県信用保証協会&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;保証一課（電話：097-532-8246)保証二課（電話：097-532-8247)経営支援課（電話：097-532-8296）・大分県商工会連合会経営支援課（電話：097-534-9507)・大分県中小企業団体中央会組織支援一課（電話：097-536-6331)&nbsp;・各商工会議所・商工会よりよいウェブサイトを提供するためにみなさまのご意見をお聞かせください。このページの情報は役に立ちましたか？とてもまあまあふつうあまりまったくこのページは見つけやすかったですか？とてもまあまあふつうあまりまったくこのページに対するご意見・ご要望を記入してください（個人に関する情報は記入しないでください）。なお、お答えが必要なご意見等はこちらではお受けできません。直接担当部署、またはパブリックコメント（意見募集）へお願いします。※1いただいたご意見は、より分かりやすく役に立つホームページとするために参考にさせていただきますので、ご協力をお願いします。※2ブラウザでCookie（クッキー）が使用できる設定になっていない、または、ブラウザがCookie（クッキー）に対応していない場合はご利用頂けません。この情報に関するお問い合わせ先はこちらです経営創造・金融課〒870-8501大分市大手町３丁目１番１号（大分県庁舎本館７階）金融・再生支援班Tel：097-506-3226Fax：097-506-1882前のページに戻るこのページの先頭へ個人情報の取り扱い免責事項・リンクについてこのホームページについてRSS配信について大分県〒870-8501大分市大手町3丁目1番1号097-536-1111（代表）県庁への行き方フロアマップ組織別電話番号一覧Copyright&#169;2015OitaPrefecture,Allrightsreserved." "$desc"



echo test get_desc_by_res
res=`wget -q -O - https://www.city.hamamatsu.shizuoka.jp/nousei/koronataioumtg.html`
desc=`get_desc_by_res "$res"`
assert_equal "新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について-大分県ホームページ トップページ&gt;組織からさがす&gt;経営創造・金融課&gt;新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について 新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について 新型コロナウイルスの流行に伴う経営・金融相談窓口の開設について大分県では、新型コロナウイルスの流行に伴い、中小企業・小規模事業者からの経営・金融相談に対応するため、下記のとおり特別相談窓口を開設します。記１名称大分県中小企業・小規模事業者経営・金融相談窓口２期間令和２年１月３１日（金）～７月３１日（金）９：００～１７：００（土曜、日曜及び祝日を除く）３担当課、電話番号商工観光労働部経営創造・金融課（経営に関すること）電話：097-506-3223（金融に関すること）電話：097-506-3226４相談内容中小企業・小規模事業者の経営、金融全般に関すること５その他次の機関でも相談を受け付けています。・大分県信用保証協会&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;保証一課（電話：097-532-8246)保証二課（電話：097-532-8247)経営支援課（電話：097-532-8296）・大分県商工会連合会経営支援課（電話：097-534-9507)・大分県中小企業団体中央会組織支援一課（電話：097-536-6331)&nbsp;・各商工会議所・商工会" "$desc"