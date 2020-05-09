#!/bin/bash

. ./lib/test-helper.sh

# .env のファイル存在チェック.
echo "test .env: existing error case"
set +e
rm -f .env-test # わざと消す
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "ENV ERROR: .env-test is required. See .env.sample, README, or Wiki of Repository." "$msg"
set -e


# .env 内パラメーター slack_channel の存在チェック.
echo "test .env: param existing error case"
set +e
echo "environment=test
slack_token=aaaa
slack__channel=bbbb
slack_channel_develop=cccc" > .env-test # slack_channel パラメーター名をわざと間違える
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "ENV ERROR: .env-test parameter 'slack_channel' is required. See .env.sample, README, or Wiki of Repository." "$msg"
set -e


# .env 内パラメーター slack_channel_develop の存在チェック.
echo "test .env: param existing error case"
set +e
echo "environment=test
slack_token=aaaa
slack_channel=bbbb" > .env-test # slack_channel_develop パラメーターをわざと省略する
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "ENV ERROR: .env-test parameter 'slack_channel_develop' is required. See .env.sample, README, or Wiki of Repository." "$msg"
set -e


# .env 内パラメーター正常読み取りチェック
echo "test .env: success case"
echo "environment=test
slack_token=aaaa
slack_channel=bbbb
slack_channel_develop=cccc" > .env-test
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "" "$msg"

ENV_FILENAME=.env-test source ./lib/env.sh
assert_equal "test" "$environment"
assert_equal "aaaa" "$slack_token"
assert_equal "bbbb" "$slack_channel"
assert_equal "cccc" "$slack_channel_develop"
