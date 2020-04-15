#!/bin/bash

###
### SlackのEventを受け取るためのCGI
###

# HTTP POSTされてきたリクエストボディが標準入力に入っている
formdata=`cat`
echo $event_type > /home/ubuntu/wget/tmp/slack-event.formdata.log
json=$formdata
token=`echo $json | jq .token`
token=${token:1:-1}
event_type=`echo $json | jq .type`
event_type=${event_type:1:-1}
echo $event_type > /home/ubuntu/wget/tmp/slack-event.event-type.log

if [ "$event_type" == "url_verification" ]; then
	challenge=`echo $json | jq .challenge`
	challenge=${challenge:1:-1}
	echo 'Content-type: text/plain'
	echo ''
	echo $challenge
	exit
fi

echo 'Content-type: text/plain'
echo ''
echo 'hello'
echo $event_type
