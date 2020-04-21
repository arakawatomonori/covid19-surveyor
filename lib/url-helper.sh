#!/bin/bash
set -e


# URLからドメイン名を取得
get_domain_by_url() {
    url=$1
    domain=$(cut -d'/' -f 3 <<< $url)
    echo $domain
    return 0
}


# URL から団体名を取得
#   /data/*.csv からドメインに紐づく名前定義を引っ張ってくる
get_orgname_by_url() {
    url=$1
    domain=`get_domain_by_url $url`
    orgname=`grep "$domain" ./data/*.csv | head -1 | cut -d',' -f 1 | cut -d':' -f 2`
    echo $orgname
    return 0
}

# tested
get_title_by_res() {
    res=$1
    title=`echo "$res" | grep -o '<title>.*</title>' | sed 's#<title>\(.*\)</title>#\1#'`
    echo $title
}

get_title_by_url() {
    url=$1
    res=`wget -q -O - $url`
    title=`get_title_by_res "$res"`
    echo $title
}

get_desc_by_res() {
    res=$1
    res=`echo "$res" | sed 's/<script>.*<\/script>//g;/<script>/,/<\/script>/{/<script>/!{/<\/script>/!d}};s/<script>.*//g;s/.*<\/script>//g'`
    desc=`echo "$res" | grep コロナ | sed -e 's/ //g' -e 's/　//g' -e 's/[ \t]*//g' -e 's/<[^>]*>//g'`
    echo $desc
}

get_md5_by_url() {
    url=$1
    # URLからmd5を得る
    md5=`echo $url | md5sum | cut -d' ' -f 1`
    echo $md5
}

# URL が 404 ではないかどうかを確認する
# 存在すれば 1、存在しなければ 0 を出力する
check_url_exists() {
    url_not_found=`wget --spider $url 2>&1 |grep -c '404 Not Found'`
    echo $url_not_found
}

get_prefname_by_url() {
    url=$1
    domain=`get_domain_by_url $url`
    prefname=`grep "$domain" ./data/*.csv | head -1 | cut -d',' -f 4 | cut -d':' -f 2`
    echo $prefname
    return 0
}

# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
