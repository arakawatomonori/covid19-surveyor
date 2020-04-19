now_ts=`date '+%s'`

keys=`redis-cli KEYS "vscovid-crawler:job-*"`
for key in $keys; do
	job=`redis-cli GET $key`
  echo $job
  url=`echo $job| cut -d',' -f 1`
	md5=`echo $url | md5sum | cut -d' ' -f 1`
  job_ts=`echo $job| cut -d',' -f 3`
  if [ $job_ts = "159.html" ]; then
    continue
  fi
  if [ $job_ts = "157.html" ]; then
    continue
  fi
  echo $job_ts
  ts_diff=$((now_ts - job_ts))
  # TODO resultに存在しないかチェックしておく
	if [ $ts_diff -gt 3600 ]; then
    redis-cli DEL $key
    redis-cli SET "vscovid-crawler:queue-$md5" $url
  fi
done