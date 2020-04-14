#!/bin/sh
echo 'Content-type: text/html'  
echo ''
### 上記2行がないと動作しない
echo '<html>'
echo '<head></head>'
echo '<body>'
echo '<h1>hello world!!</h1>'
echo "<p>your query parameter is ${QUERY_STRING} .</p>"
echo "<p>your form parameter is `cat` .</p>"
echo '</body>'
echo '</html>'
