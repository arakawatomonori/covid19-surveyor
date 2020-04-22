#!/bin/bash
set -e

source .env
ts=`date '+%s'`

# チームのチャンネルID取得
# 一日に一回でいい
# tested
get_channels_id() {
    channels_list_file="tmp/channels_list.json"
    channels_list_ts=0
    if [ -e $channels_list_file ]; then
        channels_list_ts=`date '+%s' -r $channels_list_file`
    fi
    # ファイルのタイムスタンプが一日経過しているか
    channels_list_diff=$((ts - channels_list_ts))
    if [ $channels_list_diff -gt 86400 ]; then
        # 全チャンネルの一覧を取得
        channels_list=`wget -q -O - --post-data "token=${slack_token}&exclude_archived=true" https://slack.com/api/channels.list`
        # ファイルにキャッシュ
        echo $channels_list > $channels_list_file
    else
        # キャッシュを復元
        channels_list=`cat $channels_list_file`
    fi
    # channels_listをslack_channelで絞り込んでchannels_idを得る
    channels_id=`echo $channels_list | jq '.channels[] | select(.name == "'${slack_channel}'")' | jq .id`
    channels_id=${channels_id:1:-1}
    echo $channels_id
    return 0
}

# チャンネルのメンバー取得
# 十分間に一回でいい
# tested
get_members_list() {
    channels_id=$1
    members_list_file="tmp/members_list.json"
    members_list_ts=0
    if [ -e $members_list_file ]; then
        members_list_ts=`date '+%s' -r $members_list_file`
    fi
    # ファイルのタイムスタンプが十分間経過しているか
    members_list_diff=$((ts - members_list_ts))
    if [ $members_list_diff -gt 600 ]; then
        # channels_idのチャンネルの詳細情報を取得
        channels_info=`wget -q -O - --post-data "token=${slack_token}&channel=${channels_id}" https://slack.com/api/channels.info`
        # channels_infoからメンバー一覧を取り出す
        members_list=`echo $channels_info | jq .channel.members[]`
        # ファイルにキャッシュ
        echo $members_list > $members_list_file
    else
        # キャッシュから復元
        members_list=`cat $members_list_file`
    fi
    echo $members_list
    return 0
}


open_im() {
    member_id=$1
    im_open=`wget -q -O - --post-data "token=${slack_token}&user=${member_id}" https://slack.com/api/im.open`
    im_id=`echo $im_open | jq .channel.id`
    im_id=${im_id:1:-1}
    echo $im_id
}
