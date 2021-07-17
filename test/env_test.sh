#!/bin/bash

. ./lib/test-helper.sh

# .env のファイル存在チェック.
echo "test .env: file non-existing error case"
set +e
rm -f .env-test # わざと消す
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "ENV ERROR: .env-test is required. See .env.sample, README, or Wiki of Repository." "$msg"
set -e


# .env 内パラメーター slack_channel の存在チェック.
echo "test .env: param 'slack_channel' non-existing error case"
set +e
cat << EOF > .env-test
environment=test
slack_token=aaaa
slack__channel=bbbb # slack_channel パラメーター名をわざと間違える
slack_channel_develop=cccc
EOF
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "ENV ERROR: .env-test parameter 'slack_channel' is required. See .env.sample, README, or Wiki of Repository." "$msg"
set -e


# .env 内パラメーター slack_channel_develop の存在チェック.
echo "test .env: OPTIONAL param 'slack_channel_develop' non-existing success case"
cat << EOF > .env-test
environment=test
slack_token=aaaa
slack_channel=bbbb
# slack_channel_develop パラメーターをわざと省略する（このパラメーターは Optional なので省略可）
EOF
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "" "$msg"

ENV_FILENAME=.env-test source ./lib/env.sh
assert_equal "covid19-surveyor-dev" "$slack_channel_develop" # 省略するとデフォルト値が入ってくる.


# .env 内パラメーター正常読み取りチェック
echo "test .env: success case"
cat << EOF > .env-test
environment=test
slack_token=aaaa
slack_channel=bbbb
slack_channel_develop=cccc
EOF
msg=`ENV_FILENAME=.env-test source ./lib/env.sh 2>&1`
assert_equal "" "$msg"

ENV_FILENAME=.env-test source ./lib/env.sh
assert_equal "test" "$environment"
assert_equal "aaaa" "$slack_token"
assert_equal "bbbb" "$slack_channel"
assert_equal "cccc" "$slack_channel_develop"
