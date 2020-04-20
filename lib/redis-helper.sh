#!/bin/bash
set -e

redis_already_offered(){
	namespace=$1
	member_id=$2
	already_offered=`redis-cli SISMEMBER $namespace:offered-members ${member_id}`
	echo $already_offered
}

redis_offer(){
	# xxx:offered-members をSADD
	namespace=$1
	member_id=$2
	redis-cli SADD "$namespace:offered-members" $member_id
}

# redis に指定ハッシュが存在するかどうかを確認する
# 存在すれば 1、存在しなければ 0 を出力する
redis_exists_md5(){
	namespace=$1
	md5=$2
	queue_num=`redis-cli GET $namespace:queue-${md5}`
	job_num=`redis-cli GET $namespace:job-${md5}`
	result_num=`redis-cli GET $namespace:result-${md5}`
	if [ ${#queue_num} = "0" ] && [ ${#job_num} = "0" ] && [ ${#result_num} = "0" ]; then
		# 存在しなかった
		echo 0
  else
		# 存在していた
	  echo 1
	fi
}

redis_pop_url_from_queue() {
	namespace=$1
	# xxx:queue-* を一件GET
	key=`redis-cli KEYS $namespace:queue-* | tail -n 1`
	# URLを得る
	value=`redis-cli GET ${key}`
	# xxx:queue-{URLのMD5ハッシュ} をDEL
	redis-cli DEL $key
	echo $value
}

redis_push_job() {
	namespace=$1
	md5=$2
	url=$3
	member_id=$4
	timestamp=$5
	# xxx:job-{URLのMD5ハッシュ} をSET
	redis-cli SET "$namespace:job-$md5" "${url},${member_id},${timestamp}"

}