


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
    govname=`grep "$domain" ./data/*.csv | head -1 | cut -d',' -f 1 | cut -d':' -f 2`
    echo $govname
    return 0
}

# tested
get_title_by_res() {
	res=$1
	title=`echo $res | grep -o '<title>.*</title>' | sed 's#<title>\(.*\)</title>#\1#'`
	echo $title
}

get_title_by_url() {
	url=$1
	res=`wget -q -O - $url`
	title=`get_title_by_res "$res"`
	echo $title
}

get_md5_by_url() {
	url=$1
	# URLからmd5を得る
	md5=`echo $url | md5sum | cut -d' ' -f 1`
	echo $md5
}

check_url_exists() {
	# URLが404でないことを確認
	url_not_found=`wget --spider $url 2>&1 |grep -c '404 Not Found'`
	echo $url_not_found
}




# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
