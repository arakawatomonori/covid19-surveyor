. ./slack-bot/url-map.sh

send_message() {
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
            "text": "URL: ${url}"
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
            "text": " *このURLの制度は、以下のいずれの経済支援ですか？* "
        }
    },
    {
        "type": "section",
        "block_id": "section678",
        "text": {
          "type": "mrkdwn",
          "text": "制度種別"
        },
        "accessory": {
          "action_id": "${md5}-select",
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Select an item"
        },
        "options": [
          {
            "text": {
              "type": "plain_text",
              "text": "お金が貰える"
            },
            "value": "1"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "お金が借りられる"
            },
            "value": "2"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "支払いや返済が猶予される"
            },
            "value": "3"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "相談窓口"
            },
            "value": "4"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "いずれでもない/わからない"
            },
            "value": "0"
          }
        ]
      }
    }
  ]
}
EOF
`
echo $json
wget -q -O - --post-data "$json" \
--header="Content-type: application/json" \
--header="Authorization: Bearer ${slack_token}" \
https://slack.com/api/chat.postMessage
echo ""
}



	members_list="xUUL8QC8BUx xU011H85CM0Wx xUUQ99JY5Rx xU011C3YGDABx"
	for member in $members_list; do
		member_id=${member:1:-1}
		send_message $member_id
	done