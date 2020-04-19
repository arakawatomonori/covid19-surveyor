
. ./slack-bot/url-map.sh

keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
	result=`redis-cli GET $key`
	bool=`echo $result| cut -d',' -f 4`
	if [ $bool = "true" ]; then
		url=`echo $result| cut -d',' -f 1`
		# ドメイン名から自治体名を得る
		domain=$(cut -d'/' -f 3 <<< $url)
		govname=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 1|cut -d':' -f 2`
		# urlからpathを得る
		path=${url//http:\/\//}
		path=${path//https:\/\//}
		# urlからdescriptionを得る
		description=`grep $path ./result.txt |cut -d':' -f 2`
		# urlからタイトルを得る
		title=`get_title_by_url $url`
		echo $govname,$url,$title,$description
  fi
done