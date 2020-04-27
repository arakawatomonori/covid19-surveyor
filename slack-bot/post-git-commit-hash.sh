#!/bin/bash

#
# Setup:
#   Set .env properly
#

#
# Usage:
#   cd {REPOS_ROOT}
#   ./slack-bot/post-git-commit-hash.sh
#

set -e

source .env

echo -e "environment: $environment"

. ./lib/slack-helper.sh

channels_id=`get_channels_id $slack_channel_develop`
echo -e "channels_id: $channels_id"

git_commit_hash=`git rev-list --max-count=1 HEAD`
echo -e "git_commit_hash: $git_commit_hash"


commit_hash=$git_commit_hash

echo -e "commit_hash: $commit_hash"
commit_hash='```'
commit_hash=$commit_hash"\r\n"
commit_hash=$commit_hash"$git_commit_hash"
commit_hash=$commit_hash"\r\n"
commit_hash=$commit_hash'```'

json=`cat <<EOF
{
    "channel": "${channels_id}",
    "text": "現在のコミットハッシュ",
    "blocks": [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "現在のコミットハッシュです！"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "${commit_hash}"
            }
        }
    ]
}
EOF
`

echo -e "json: $json"

if [ x"$environment" == x"production" ]; then
    wget -q -O - --post-data "$json" \
    --header="Content-type: application/json" \
    --header="Authorization: Bearer ${slack_token}" \
    https://slack.com/api/chat.postMessage | jq .
    echo ""
fi






