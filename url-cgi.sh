#!/bin/bash
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
# HTTP POSTされてきたリクエストボディが標準入力に入っている
json=`cat`
# urlencodeされているのでdecodeする
json=$(urldecode $json)
# payload=を消してJSONとして読めるようにする
json=${json:8:-1}}
echo $json > /home/ubuntu/wget/tmp/url-cgi.json.log

token=`echo $json | jq .token`
token=${token:1:-1}
event_type=`echo $json | jq .type`
event_type=${event_type:1:-1}
echo $event_type > /home/ubuntu/wget/tmp/url-cgi.type.log

if [ "$event_type" == "url_verification" ]; then
	challenge=`echo $json | jq .challenge`
	challenge=${challenge:1:-1}
	echo 'Content-type: text/plain'
	echo ''
	echo $challenge
	exit
fi

if [ "$event_type" == "block_actions" ]; then
	user_id=`echo $json | jq .user.id`
	user_id=${user_id:1:-1}
	url=`echo $json | jq .message.text`
	url=${url:2:-2}
	md5=`echo $url | md5sum | cut -d' ' -f 1`
	timestamp=`date '+%s'`
	result=`echo $json | jq .actions.value`
	result=${result:1:-1}
	response_url=`echo $json | jq .response_url`
	# vscovid-crawler:offered-membersからIDをDEL
	redis-cli SREM vscovid-crawler:offered-members $user_id > /dev/null
	# vscovid-crawler:job-{URLのMD5ハッシュ} をDEL
	redis-cli DEL vscovid-crawler:job-$md5 > /dev/null
	# vscovid-crawler:result-{URLのMD5ハッシュ} をSET
	redis-cli SET vscovid-crawler:result-$md5 "${url},${user_id},${timestamp},${result}" > /dev/null
	json='{"text": "解答ありがとうございます！"}'
	echo 'Content-type: application/json'
	echo ''
	echo $json
	exit
fi

echo 'Content-type: text/plain'
echo ''
echo 'hello'
