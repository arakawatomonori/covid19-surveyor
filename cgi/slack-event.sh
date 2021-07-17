#!/bin/bash
set -e

###
### SlackのEventを受け取るためのCGI
###

# HTTP POSTされてきたリクエストボディが標準入力に入っている
formdata=`cat`
echo $event_type > /home/ubuntu/wget/tmp/slack-event.formdata.log
json=$formdata
token=`echo $json | jq -r .token`
event_type=`echo $json | jq -r .type`
echo $event_type > /home/ubuntu/wget/tmp/slack-event.event-type.log

if [ "$event_type" == "url_verification" ]; then
    challenge=`echo $json | jq -r .challenge`
    echo 'Content-type: text/plain'
    echo ''
    echo $challenge
    exit
fi

echo 'Content-type: text/plain'
echo ''
echo 'hello'
echo $event_type
