#!/bin/bash
set -e

. /home/ubuntu/vscovid-crawler/lib/url-helper.sh

eval "$(cat /home/ubuntu/vscovid-crawler/.env <(echo) <(declare -x))"

formdata=`cat`
echo $formdata > /home/ubuntu/vscovid-crawler/tmp/slack-interact.formdata.log
# urlencodeされているのでdecodeする
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
decoded_data=$(urldecode $formdata)
# payload=JSONなので消してJSONとして読めるようにする
json=${decoded_data:8:-1}}
echo $json > /home/ubuntu/vscovid-crawler/tmp/slack-interact.json.log

token=`echo $json | jq -r .token`
event_type=`echo $json | jq -r .type`
echo $event_type > /home/ubuntu/vscovid-crawler/tmp/slack-interact.event-type.log

if [ "$event_type" == "block_actions" ]; then
    channel_id=`echo $json | jq -r .channel.id`
    ts=`echo $json | jq -r .container.message_ts`
    user_id=`echo $json | jq -r .user.id`
    url=`echo $json | jq -r .message.blocks[2].text.text`
    url=`echo ${url:6}`
    md5=`get_md5_by_url $url`
    timestamp=`date '+%s'`
    result=`echo $json | jq -r .actions[0].value`
    action_id=`echo $json | jq -r .actions[0].action_id`
    echo $action_id > /home/ubuntu/vscovid-crawler/tmp/slack-interact.action-id.log
    namespace="vscovid-crawler"
    remain=""
    if [[ $action_id == vscovid-crawler-vote-* ]]; then
        namespace="vscovid-crawler-vote"
        # offered-membersからIDをDEL
        redis-cli SREM "$namespace:offered-members" $user_id > /dev/null
        # 回答回数をカウント
        redis-cli INCR "$namespace:count-$user_id" > /dev/null
        if [ "$result" = "true" ]; then
            value=`redis-cli INCR "$namespace:result-$md5"`
        else
            value=`redis-cli DECR "$namespace:result-$md5"`
        fi
        remain=`redis-cli KEYS $namespace:queue-*  | wc -l`
    elif [[ $action_id == vscovid-crawler-select-target ]]; then
        result=`echo $json | jq -r '.actions[0].selected_options|map(.value)|join(" ")'`
        namespace="vscovid-crawler-select-target"
        # offered-membersからIDをDEL
        redis-cli SREM "$namespace:offered-members" $user_id > /dev/null
        # 回答回数をカウント
        redis-cli INCR "$namespace:count-$user_id" > /dev/null
        # result-{URLのMD5ハッシュ} をSET
        redis-cli SET "$namespace:result-$md5" "${url},${user_id},${timestamp},${result}" > /dev/null
        remain=`redis-cli KEYS $namespace:queue-*  | wc -l`
    elif [ "$action_id" = "vscovid-crawler-select-type" ]; then
        namespace="vscovid-crawler-select-type"
        # vscovid-crawler:offered-membersからIDをDEL
        redis-cli SREM "$namespace:offered-members" $user_id > /dev/null
        # 回答回数をカウント
        redis-cli INCR "$namespace:count-$user_id" > /dev/null
        # vscovid-crawler:job-{URLのMD5ハッシュ} をDEL
        redis-cli DEL "$namespace:job-$md5" > /dev/null
        # vscovid-crawler:result-{URLのMD5ハッシュ} をSET
        redis-cli SET "$namespace:result-$md5" "${url},${user_id},${timestamp},${result}" > /dev/null
        remain=`redis-cli KEYS $namespace:queue-*  | wc -l`
    else
        namespace="vscovid-crawler"
        # vscovid-crawler:offered-membersからIDをDEL
        redis-cli SREM "$namespace:offered-members" $user_id > /dev/null
        # vscovid-crawler:job-{URLのMD5ハッシュ} をDEL
        redis-cli DEL "$namespace:job-$md5" > /dev/null
        # vscovid-crawler:result-{URLのMD5ハッシュ} をSET
        redis-cli SET "$namespace:result-$md5" "${url},${user_id},${timestamp},${result}" > /dev/null
        remain=`redis-cli KEYS $namespace:queue-*  | wc -l`
    fi
    res=`cat <<EOF
{
    "token": "${slack_token}",
    "channel": "${channel_id}",
    "ts": "${ts}",
    "text": "回答ありがとうございます！残り件数：${remain}",
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
