#!/bin/bash
set -e

if which gcloud > /dev/null 2>&1; then
    gcp_token=$(gcloud auth application-default print-access-token)
fi

. ./lib/url-helper.sh
. ./lib/string-helper.sh

build_predict_json() {
    text=$1
    json=`cat <<EOF
    {
        "payload": {
            "textSnippet": {
                "content": "$text",
                "mime_type": "text/plain"
            }
        }
    }
EOF
`
    echo $json
}

# TODO parseをかく
parse_predict_json() {
    res=$1
    echo $result
}

get_predict_by_url() {
    url=$1
    text=`get_text_by_url "$url"`
    json=`build_predict_json "$text"`
    echo $json > ./tmp/automl-req.json.log
    res=$(wget -q -O - --post-data "$json" \
    --header="Content-type: application/json" \
    --header="Authorization: Bearer ${gcp_token}" \
    https://automl.googleapis.com/v1/projects/11652160532/locations/us-central1/models/TCN2888562181702418432:predict)
    echo $res > ./tmp/automl-res.json.log
    echo $res | jq -r '.payload[0] | [.displayName, .classification.score] | @csv'
}

# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
