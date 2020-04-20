#!/bin/bash
set -e

declare -A users

keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
    result=`redis-cli GET $key`
    user=`echo $result| cut -d',' -f 2`
    count=${users[${user}]}
    if [ -z ${users[${user}]} ]; then
        users[${user}]=0
    fi
    count=${users[${user}]}
    users[${user}]=$(( count + 1 ))
done

for k in "${!users[@]}"; do
    echo $k,${users["$k"]}
done | sort -t , -rn -k2 | head -n 10 > tmp/rank.txt

rank=""
for line in `cat tmp/rank.txt`; do
    user_id=`echo $line | cut -d',' -f 1`
    count=`echo $line | cut -d',' -f 2`
    rank=$rank"\r\n<@$user_id> さん、 $count 回"
done

source .env

. ./slack-bot/url-map.sh
channels_id=`get_channels_id`

json=`cat <<EOF
{
  "channel": "${channels_id}",
  "text": "回答者ランキング",
  "blocks": [
                {
                        "type": "section",
                        "text": {
                                "type": "mrkdwn",
                                "text": "現在の回答者ランキングです！"
                        }
                },
                {
                        "type": "section",
                        "text": {
                                "type": "mrkdwn",
                                "text": "${rank}"
                        }
                },
        ]
}
EOF
`
wget -q -O - --post-data "$json" \
--header="Content-type: application/json" \
--header="Authorization: Bearer ${slack_token}" \
https://slack.com/api/chat.postMessage
echo ""
