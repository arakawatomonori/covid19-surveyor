
echo $slack_token
channels_name=vscovid19-arkw

# 全チャンネルの一覧を取得
#channels_list=`wget -q -O - --post-data "token=${slack_token}&exclude_archived=true" https://slack.com/api/channels.list`
# channels_nameで絞り込んでchannels_idを得る
#channels_id=`echo $channels_list | jq '.channels[] | select(.name == "'${channels_name}'")' | jq .id`
#channels_id=${channels_id:1:-1}

# channels_nameのチャンネルの詳細情報を取得
#channels_info=`wget -q -O - --post-data "token=${slack_token}&channel=${channels_id}" https://slack.com/api/channels.info`
# channels_infoからメンバー一覧を取り出す
#channels_members=`echo $channels_info | jq .channel.members[]`
# 各メンバーにDMを送る
channels_members="xUUL8QC8BUx xU011H85CM0Wx xUUQ99JY5Rx"
for member in $channels_members; do
	# vscovid-crawler:queue-* を一件GET
	scan=`redis-cli SCAN 0 COUNT 1 MATCH vscovid-crawler:queue-*`
	key=`echo $scan | grep vscovid-crawler:queue| cut -d' ' -f 2 `
	url=`redis-cli GET ${key}`
	echo $url
	domain=`echo $url | cut -d'/' -f 3`
	govname=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 1|cut -d':' -f 2`
	echo $govname
	md5=`echo $url | md5sum | cut -d' ' -f 1`
	member_id=${member:1:-1}
	# vscovid-crawler:offered-members にいない人にDMを送る
	already_offered=`redis-cli SISMEMBER ${member_id} vscovid-crawler:offered-members`
	if [ $already_offered = "1" ]; then
		continue
	fi
	echo $member_id
	# vscovid-crawler:offered-members をSET
	#redis-cli SADD vscovid-crawler:offered-members $member_id
	# vscovid-crawler:queue-{URLのMD5ハッシュ} をDEL
	#redis-cli DEL vscovid-crawler:queue-$md5
	# vscovid-crawler:job-{URLのMD5ハッシュ} をSET
	timestamp=`date '+%s'`
	#redis-cli ADD vscovid-crawler:job-$md5 "${url},${member_id},${timestamp}"
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
			"text": "${url}"
		}
	},
	{
		"type": "section",
		"text": {
			"type": "mrkdwn",
			"text": "*この制度は${govname}独自の経済支援制度ですか？*"
		}
	},
	{
		"type": "actions",
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
			}
		]
	}
  ]
}
EOF
`

	#wget -q -O /dev/null --post-data "$json" \
	wget -q -O - --post-data "$json" \
	--header="Content-type: application/json" \
	--header="Authorization: Bearer ${slack_token}" \
	https://slack.com/api/chat.postMessage
	echo ""
done
