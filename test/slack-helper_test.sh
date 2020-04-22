#!/bin/bash
set -e

. ./lib/test-helper.sh

. ./lib/slack-helper.sh

echo test get_channels_id
## setup
rm -f "tmp/channels_list.json"
actual=`get_channels_id`
assert_not_empty "${#actual}"

echo test get_members_list
## setup
rm -f "tmp/members_list.json"
channels_id=`get_channels_id`
actual=`get_members_list $channels_id`
assert_not_empty "${#actual}"
