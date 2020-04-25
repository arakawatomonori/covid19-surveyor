#!/bin/bash
set -e

source .env
ts=`date '+%s'`

. ./lib/slack-helper.sh
. ./lib/url-helper.sh
. ./lib/redis-helper.sh
. ./lib/auto-ml-helper.sh

namespace="vscovid-crawler-vote"

send_message() {
    member_id=$1
    # オファー済みか確認
    already_offered=`redis_already_offered $namespace $member_id`
    if [ $already_offered = "1" ]; then
        return 0
    fi
    # キューから一件取り出す
    value=`redis_pop_value_from_queue $namespace`
    value=`echo $value| cut -d' ' -f 2`
    url=`echo $value| cut -d',' -f 1`
    echo $url
    title=`get_title_by_url ${url}`

    if [[ $title == "" ]];then
        return 1
    fi

    predict=`get_predict_by_url $url`
    predict_label=`echo $predict | cut -d',' -f 1`
    echo $predict_label
    predict_score=`echo $predict | cut -d',' -f 2`
    set +e
    predict_score=$(echo "$predict_score*100" | bc | cut -d'.' -f 1)
    set -e
    echo $predict_score
    if [[ $predict_label == "\"not_covid19_help\"" ]];then
        if [ $predict_score -gt 60 ];then
            return 1
        fi
    fi

    user_id=`echo $value| cut -d',' -f 2`
    timestamp=`echo $value| cut -d',' -f 3`
    result=`echo $value| cut -d',' -f 4`

    orgname=`get_orgname_by_url ${url}`

    md5=`get_md5_by_url $url`
    # unixtime
    timestamp=`date '+%s'`

    redis_offer $namespace $member_id
    redis_push_job $namespace $md5 $url $member_id $timestamp

    # Slack DM送信
    im_id=`open_im $member_id`
    json=`cat <<EOF
{
    "channel":"${im_id}",
    "text":"",
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "私はこのURLは$predict_score%自治体独自の新型コロナ関連経済支援制度だと思いますが、あなたは自治体独自の新型コロナ関連経済支援制度だと思いますか？"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "タイトル: ${title}"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "URL: ${url}"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "
*このURLは、以下の2つの条件を満たしていますか？*

• 新型コロナウイルスについての経済支援制度である
• ${orgname}が独自に実施しているものである

※経済支援制度とは、お金が貰える|お金が借りられる|お金が節約できる制度です
※上記以外でも、住宅の支援、食料の支援、子育ての支援などの場合は「はい」と答えてください
※このURLが他の組織の制度を${orgname}が紹介しているだけの場合は「いいえ」と答えてください
※このURLがトップページやリンク集の場合は「いいえ」と答えてください

※回答に困ったとき
• <https://github.com/arakawatomonori/covid19-surveyor/wiki|Wiki> 内に回答時の FAQ をまとめてあります。
• FAQ 等を見ても分からない場合は Slack の #covid19-survey-qa にご質問ください。
"
            }
        },
        {
            "type": "actions",
            "elements": [
                {
                    "type": "button",
                    "action_id": "vscovid-crawler-vote-${md5}-true",
                    "value": "true",
                    "style": "primary",
                    "text": {
                        "type": "plain_text",
                        "text": "はい",
                        "emoji": false
                    }
                },
                {
                    "type": "button",
                    "action_id": "vscovid-crawler-vote-${md5}-false",
                    "value": "false",
                    "style": "danger",
                    "text": {
                        "type": "plain_text",
                        "text": "いいえ",
                        "emoji": false
                    }
                },
                {
                    "type": "button",
                    "action_id": "vscovid-crawler-vote-${md5}-undefined",
                    "value": "undefined",
                    "text": {
                        "type": "plain_text",
                        "text": "迷う",
                        "emoji": false
                    }
                }
            ]
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
    #members_list="xUUL8QC8BUx xU011H85CM0Wx xUUQ99JY5Rx xU011C3YGDABx"
    for member in $members_list; do
        member_id=${member:1:-1}
        echo `send_message $member_id`
    done
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
