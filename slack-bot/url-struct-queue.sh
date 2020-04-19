# reduce.csvの内容をredisのqueueとして投入する
# すでに投入済みの場合はスキップする

. ./lib/url-helper.sh

namespace="vscovid-crawler-url-struct"

while read line; do
    orgname=`echo $line| cut -d',' -f 1`
    url=`echo $line| cut -d',' -f 2`
    title=`echo $line| cut -d',' -f 3`
    desc=`echo $line| cut -d',' -f 4`
    md5=`echo $url | md5sum | cut -d' ' -f 1`
    # redisに存在しないことを確認する
    queue_num=`redis-cli GET $namespace:queue-${md5}`
    job_num=`redis-cli GET $namespace:job-${md5}`
    result_num=`redis-cli GET $namespace:result-${md5}`
    if [ ${#queue_num} = "0" ] && [ ${#job_num} = "0" ] && [ ${#result_num} = "0" ]; then
      redis-cli SET "$namespace:queue-$md5" "$url,$orgname,$title,$desc"
    fi
done < reduce.csv