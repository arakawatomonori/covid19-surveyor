#!/bin/bash
set -e


gcp_token=$(gcloud auth application-default print-access-token)

. ./lib/url-helper.sh
. ./lib/string-helper.sh

get_predict_by_url() {
    url=$1
    text=`get_text_by_url $url`
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

    res=$(wget -q -O - --post-data "$json" \
    --header="Content-type: application/json" \
    --header="Authorization: Bearer ${gcp_token}" \
    https://automl.googleapis.com/v1/projects/11652160532/locations/us-central1/models/TCN2888562181702418432:predict)
    echo "$res | jq payload[0].dysplayName, payload[0].classification.score"
    
}

# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
