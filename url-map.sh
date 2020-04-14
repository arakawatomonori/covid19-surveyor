# vscovid-crawler:queue-* を一件GET
# vscovid-crawler:offered-members をGET
# vscovid-crawler:offered-members にいない人にDMを送る
# vscovid-crawler:offered-members をSET
# vscovid-crawler:queue-{URLのMD5ハッシュ} をDEL
# vscovid-crawler:job-{URLのMD5ハッシュ} をSET

echo $slack_token
channels_name=vscovid19-arkw

# 全チャンネルの一覧を取得
#channels_list=`wget -q -O - --post-data "token=${slack_token}&exclude_archived=true" https://slack.com/api/channels.list`
# channels_nameで絞り込んでchannels_idを得る
#channels_id=`echo $channels_list | jq '.channels[] | select(.name == "'${channels_name}'")' | jq .id`
#channels_id=${channels_id:1:-1}
#echo $channels_id

# channels_nameのチャンネルの詳細情報を取得
#channels_info=`wget -q -O - --post-data "token=${slack_token}&channel=${channels_id}" https://slack.com/api/channels.info`
# channels_infoからメンバー一覧を取り出す
#channels_members=`echo $channels_info | jq .channel.members[]`
# 各メンバーにDMを送る
channels_members="xUUL8QC8BUx xU011H85CM0Wx xUUQ99JY5Rx"
for member in $channels_members; do
	echo $member
	member_id=${member:1:-1}
	im_open=`wget -q -O - --post-data "token=${slack_token}&user=${member_id}" https://slack.com/api/im.open`
	im_id=`echo $im_open | jq .channel.id`
	im_id=${im_id:1:-1}
	json=`cat <<EOF
{
  "channel": "${im_id}",
  "text": "<https://www.code4japan.org/>",
  "blocks": [
	{
		"type": "section",
		"text": {
			"type": "mrkdwn",
			"text": "https://www.code4japan.org/"
		}
	},
	{
		"type": "section",
		"text": {
			"type": "mrkdwn",
			"text": "*この制度は北海道独自の経済支援制度ですか？*"
		}
	},
	{
		"type": "actions",
		"elements": [
			{
				"type": "button",
				"action_id": "hogehoge",
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
				"action_id": "hugahuga",
				"value": "false",
				"style": "danger",
				"text": {
					"type": "plain_text",
					"text": "いいえ",
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
	https://slack.com/api/chat.postMessage
	echo ""
done
