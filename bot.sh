

echo $slack_token
channels_name=vscovid19-arkw

# 全チャンネルの一覧を取得
channels_list=`wget -q -O - --post-data "token=${slack_token}&exclude_archived=true" https://slack.com/api/channels.list`
# channels_nameで絞り込んでchannels_idを得る
channels_id=`echo $channels_list | jq '.channels[] | select(.name == "'${channels_name}'")' | jq .id`
channels_id=${channels_id:1:-1}
echo $channels_id

# channels_nameのチャンネルの詳細情報を取得
channels_info=`wget -q -O - --post-data "token=${slack_token}&channel=${channels_id}" https://slack.com/api/channels.info`
# channels_infoからメンバー一覧を取り出す
channels_members=`echo $channels_info | jq .channel.members[]`
# 各メンバーにDMを送る
for member in $channels_members; do
	echo $member
	member_id=${member:1:-1}
	im_open=`wget -q -O - --post-data "token=${slack_token}&user=${member_id}" https://slack.com/api/im.open`
	im_id=`echo $im_open | jq .channel.id`
	im_id=${im_id:1:-1}
	wget -q -O - --post-data "token=${slack_token}&channel=${im_id}&text='hello from bot'" https://slack.com/api/chat.postMessage
done
