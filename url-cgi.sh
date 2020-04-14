#!/bin/bash
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
json=`cat`
json=$(urldecode $json)
json=${json:8:-1}}
echo $json > /home/ubuntu/wget/tmp/url-cgi.json.log
token=`echo $json | jq .token`
token=${token:1:-1}
type=`echo $json | jq .type`
type=${type:1:-1}
echo $type > /home/ubuntu/wget/tmp/url-cgi.type.log

if [ $type == "url_verification" ]; then
	challenge=`echo $json | jq .challenge`
	challenge=${challenge:1:-1}
	echo 'Content-type: text/plain'
	echo ''
	echo $challenge
fi

# vscovid-crawler:offered-membersからIDをDEL
# vscovid-crawler:job-{URLのMD5ハッシュ} をDEL
# vscovid-crawler:result-{URLのMD5ハッシュ} をSET
if [ $type == "block_actions" ]; then
	user_id=`echo $json | jq .user.id`
	user_id=${user_id:1:-1}
	url=`echo $json | jq .message.text`
	url=${url:2:-2}
	action_id=`echo $json | jq .actions.action_id`
	action_id=${action_id:1:-1}
	result=`echo $json | jq .actions.value`
	result=${result:1:-1}
	redis-cli SREM vscovid-crawler:offered-members $user_id
	redis-cli DEL vscovid-crawler:job-$action_id
	redis-cli SET vscovid-crawler:result-$action_id "${url},${user_id},${timestamp},${result}"
	echo 'Content-type: application/json'
	echo ''
	echo '{"replace_original": "true", "text": "解答ありがとうございます！"}'
fi

