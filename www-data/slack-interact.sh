#!/bin/bash
set -e

. ./ubuntu/home/ubuntu/vscode-crawler/lib/url-helper.sh

eval "$(cat /home/ubuntu/vscovid-crawler/.env <(echo) <(declare -x))"

formdata=`cat`
echo $formdata > /home/ubuntu/vscovid-crawler/tmp/slack-interact.formdata.log
# urlencodeされているのでdecodeする
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
decoded_data=$(urldecode $formdata)
# payload=JSONなので消してJSONとして読めるようにする
json=${decoded_data:8:-1}}
echo $json > /home/ubuntu/vscovid-crawler/tmp/slack-interact.json.log

token=`echo $json | jq .token`
token=${token:1:-1}
event_type=`echo $json | jq .type`
event_type=${event_type:1:-1}
echo $event_type > /home/ubuntu/vscovid-crawler/tmp/slack-interact.event-type.log

if [ "$event_type" == "block_actions" ]; then
        channel_id=`echo $json | jq .channel.id`
	channel_id=${channel_id:1:-1}
	ts=`echo $json | jq .container.message_ts`
	ts=${ts:1:-1}
        user_id=`echo $json | jq .user.id`
        user_id=${user_id:1:-1}
        url=`echo $json | jq .message.text`
        url=${url:2:-2}
        md5=`get_md5_by_url $url`
        timestamp=`date '+%s'`
        result=`echo $json | jq .actions[0].value`
        result=${result:1:-1}
        action_id=`echo $json | jq .actions[0].action_id`
        namespace="vscovid-crawler"
        echo $action_id|grep '-select-type'
        if [$? -eq 0];then
                namespace="vscovid-crawler-select-type"
        else
                namespace="vscovid-crawler"
        fi
        # vscovid-crawler:offered-membersからIDをDEL
        redis-cli SREM "$namespace:offered-members" $user_id > /dev/null
        # vscovid-crawler:job-{URLのMD5ハッシュ} をDEL
        redis-cli DEL "$namespace:job-$md5" > /dev/null
        # vscovid-crawler:result-{URLのMD5ハッシュ} をSET
        redis-cli SET "$namespace:result-$md5" "${url},${user_id},${timestamp},${result}" > /dev/null
        res=`cat <<EOF
        fi
{
	"token": "${slack_token}",
	"channel": "${channel_id}",
	"ts": "${ts}",
        "text": "回答ありがとうございます！",
	"blocks": null,
	"attachments": null
}
EOF
`
        echo 'Content-type: application/json'
        echo ''
        echo $res
	wget -q -O /home/ubuntu/vscovid-crawler/tmp/slack-interact.res.log --post-data "$res" \
        --header="Content-type: application/json" \
        --header="Authorization: Bearer ${slack_token}" \
        https://slack.com/api/chat.update
        exit
fi

echo 'Content-type: text/plain'
echo ''
echo 'hello'
echo $event_type
