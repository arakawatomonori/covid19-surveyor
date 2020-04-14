

echo $slack_token
channels_name=vscovid19-arkw
channels_list=`wget -q -O - --post-data "token=${slack_token}&exclude_archived=true" https://slack.com/api/channels.list`
channels_id=`echo $channels_list | jq '.channels[] | select(.name == "'${channels_name}'")' | jq .id`
channels_id=${channels_id:1:-1}
echo $channels_id

channels_info=`wget -q -O - --post-data "token=${slack_token}&channel=${channels_id}" https://slack.com/api/channels.info`
channels_members=`echo $channels_info | jq .channel.members[]`
for member in $channels_members; do
	echo $member
	member_id=${member:1:-1}
	im_open=`wget -q -O - --post-data "token=${slack_token}&user=${member_id}" https://slack.com/api/im.open`
	im_id=`echo $im_open | jq .channel.id`
	im_id=${im_id:1:-1}
	wget -q -O - --post-data "token=${slack_token}&channel=${im_id}&text='hello from bot'" https://slack.com/api/chat.postMessage
done
