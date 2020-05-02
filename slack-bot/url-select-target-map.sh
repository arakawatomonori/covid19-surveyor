#!/bin/bash
set -e

source .env
ts=`date '+%s'`

. ./lib/slack-helper.sh
. ./lib/url-helper.sh
. ./lib/redis-helper.sh

namespace="vscovid-crawler-select-target"

send_message() {
    member_id=$1
    # オファー済みか確認
    already_offered=`redis_already_offered $namespace $member_id`
    if [ $already_offered = "1" ]; then
        return 0
    fi
    # キューから一件取り出す
    value=`redis_pop_value_from_queue $namespace`
    url=`echo $value| cut -d' ' -f 2 | cut -d',' -f 1`
    orgname=`echo $value| cut -d',' -f 2`
    title=`echo $value| cut -d',' -f 3`
    desc=`echo $value| cut -d',' -f 4`
    md5=`get_md5_by_url $url`
    # unixtime
    timestamp=`date '+%s'`

    redis_offer $namespace $member_id
    redis_push_job $namespace $md5 $url $member_id $timestamp

    # Slack DM送信
    echo $member_id
    im_id=`open_im $member_id`
    json=`cat <<EOF
{
    "channel":"${im_id}",
    "text":"",
    "blocks":[
        {
            "type":"section",
            "text":{
                "type":"mrkdwn",
                "text":"タイトル: ${title}"
            }
        },
        {
            "type":"section",
            "text":{
                "type":"mrkdwn",
                "text":"URL: ${url}"
            }
        },
        {
            "type":"section",
            "text":{
                "type":"mrkdwn",
                "text":"概要: ${desc}"
            }
        },
        {
            "type":"section",
            "text":{
                "type":"mrkdwn",
                "text":" *このURLの制度は、以下の誰を対象とした経済支援制度ですか？* "
            }
        },
        {
            "type":"section",
            "block_id":"section678",
            "text":{
                "type":"mrkdwn",
                "text":"制度対象"
            },
            "accessory":{
                "action_id":"vscovid-crawler-select-target",
                "type":"static_select",
                "placeholder":{
                    "type":"plain_text",
                    "text":"Select an item"
                },
                "options":[
                    {
                        "text":{
                            "type":"plain_text",
                            "text":"中小企業"
                        },
                        "value":"1"
                    },
                    {
                        "text":{
                            "type":"plain_text",
                            "text":"会社員"
                        },
                        "value":"2"
                    },
                    {
                        "text":{
                            "type":"plain_text",
                            "text":"個人事業主"
                        },
                        "value":"3"
                    },
                    {
                        "text":{
                            "type":"plain_text",
                            "text":"子育て世帯"
                        },
                        "value":"4"
                    },
                    {
                        "text":{
                            "type":"plain_text",
                            "text":"個人"
                        },
                        "value":"4"
                    },
                    {
                        "text":{
                            "type":"plain_text",
                            "text":"いずれでもない/わからない"
                        },
                        "value":"0"
                    }
                ]
            }
        }
    ]
}
EOF
`
    echo $json | jq .
    wget -q -O - --post-data "$json" \
    --header="Content-type: application/json" \
    --header="Authorization: Bearer ${slack_token}" \
    https://slack.com/api/chat.postMessage | jq .
    echo ""
}

main() {
    channels_id=`get_channels_id`
    members_list=`get_members_list $channels_id`

    echo members num ${#members_list[@]}

    # 一秒に一回でいい
    # 各メンバーにDMを送る
    # テスターのID
    #members_list="xUUL8QC8BUx"
    for member in $members_list; do
        member_id=${member:1:-1}
        send_message $member_id
    done
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
