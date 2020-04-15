# urls.txtの内容をredisのqueueとして投入する
# すでに投入済みの場合はスキップする

for url in `cat urls.txt`; do
	# URLの整形
	url=${url:9:-1}l
	echo path $url
	domain=$(cut -d'/' -f 1 <<< $url)
	echo domain $domain
	host=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 3`
	echo host $host
	url=${url/$domain/$host}
	echo url $url
	# md5を計算
	md5=`echo $url | md5sum | cut -d' ' -f 1`
	echo $md5
	# redisに存在しないことを確認する
	queue_num=`redis-cli GET vscovid-crawler:queue-${md5}`
	job_num=`redis-cli GET vscovid-crawler:job-${md5}`
	result_num=`redis-cli GET vscovid-crawler:result-${md5}`
	if [ ${#queue_num} = "0" ] && [ ${#job_num} = "0" ] && [ ${#result_num} = "0" ]; then
		redis-cli SET vscovid-crawler:queue-$md5 $url
	fi
done
