env_filename=.env

# テスト時には ENV_FILENAME により .env ファイル名を差し替える
if [ "$ENV_FILENAME" != "" ]; then
    env_filename="$ENV_FILENAME"
fi


# .env ファイルの存在チェック
if [ ! -f "$env_filename" ]; then
    >&2 echo "ENV ERROR: $env_filename is required. See .env.sample, README, or Wiki of Repository."
    exit 1
fi


# .env 読み取り
. "$env_filename"


# 必要値の存在チェック
keys=("environment" "slack_token" "slack_channel" "slack_channel_develop")
for key in "${keys[@]}"; do
    if [ "${!key}" == "" ]; then
        >&2 echo -e "ENV ERROR: $env_filename parameter '$key' is required. See .env.sample, README, or Wiki of Repository."
        exit 1
    fi
done
