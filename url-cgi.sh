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
	md5=`echo $url | md5sum | cut -d' ' -f 1`
	timestamp=`date '+%s'`
	result=`echo $json | jq .actions.value`
	result=${result:1:-1}
	response_url=`echo $json | jq .response_url`
	redis-cli SREM vscovid-crawler:offered-members $user_id
	redis-cli DEL vscovid-crawler:job-$md5
	redis-cli SET vscovid-crawler:result-$md5 "${url},${user_id},${timestamp},${result}"
	json='{"replace_original": "true", "text": "解答ありがとうございます！"}'
	echo 'Content-type: application/json'
	echo ''
	echo $json
	wget -q -O - --post-data "$json" \
        --header="Content-type: application/json" \
        --header="Authorization: Bearer ${slack_token}" \
        $response_url

fi

