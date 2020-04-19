

. ./lib/slack-helper.sh
. ./lib/url-helper.sh


pop_url_from_queue() {
	# vscovid-crawler:queue-* を一件GET
	key=`redis-cli KEYS vscovid-crawler:queue-* | tail -n 1`
	# URLを得る
	url=`redis-cli GET ${key}`
	# vscovid-crawler:queue-{URLのMD5ハッシュ} をDEL
	redis-cli DEL "vscovid-crawler:queue-$md5"
	echo $url
}

push_job() {

}



send_message() {
	member_id=$1
	# vscovid-crawler:offered-members にいない人にだけDMを送る
	already_offered=`redis-cli SISMEMBER vscovid-crawler:offered-members ${member_id}`
	if [ $already_offered = "1" ]; then
		return 0
	fi
	# vscovid-crawler:offered-members をSADD
	redis-cli SADD "vscovid-crawler:offered-members" $member_id
	echo offer to $member_id
	url=`pop_url_from_queue`
	echo $url
	md5=`get_md5_by_url $url`
	url_not_found=`check_url_exists $url`
	# 404だった場合
	if [ $url_not_found = "1" ]; then
		return 0
	fi
	title=`get_title_by_url ${url}`
	orgname=`get_orgname_by_url ${url}`
	echo $orgname
	# unixtime
	timestamp=`date '+%s'`
	# vscovid-crawler:job-{URLのMD5ハッシュ} をSET
	redis-cli SET "vscovid-crawler:job-$md5" "${url},${member_id},${timestamp}"
	# Slack DM送信
	im_open=`wget -q -O - --post-data "token=${slack_token}&user=${member_id}" https://slack.com/api/im.open`
	im_id=`echo $im_open | jq .channel.id`
	im_id=${im_id:1:-1}
	json=`cat <<EOF
{
  "channel": "${im_id}",
  "text": "<${url}>",
  "blocks": [
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
"
                        }
                },
                {
                        "type": "actions",
												"action_id": "${md5}-bool"
                        "elements": [
                                {
                                        "type": "button",
                                        "action_id": "${md5}-true",
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
                                        "action_id": "${md5}-false",
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
                                        "action_id": "${md5}-undefined",
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
		send_message $member_id
	done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main $@
fi
