#!/bin/sh
echo 'Content-type: text/plain'
echo ''
### 上記2行がないと動作しない
echo "<p>your query parameter is ${QUERY_STRING} .</p>"
echo "<p>your form parameter is `cat` .</p>"

# vscovid-crawler:offered-membersからIDをDEL
# vscovid-crawler:job-{URLのMD5ハッシュ} をDEL
# vscovid-crawler:result-{URLのMD5ハッシュ} をSET
