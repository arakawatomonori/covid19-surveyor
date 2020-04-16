#!/bin/bash
set -e

###
### About
### help.stopcovid19.jp/index.htmlを生成するスクリプト
###
### Usage
### ./index.sh
###


js=`cat <<EOM
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>新型コロナウイルス各自治体の経済支援制度まとめ</title>
<style type="text/css">
<!--
li.line {font-size:1.4em; margin:5px;}
-->
</style>
<script type="text/javascript">
function quotemeta (string) {
	return string.replace(/(\W)/, "\\$1");
}
function isearch (pattern) {
	var regex = new RegExp(quotemeta(pattern), "i");
	var spans = document.getElementsByTagName('li');
	var length = spans.length;
	for (var i = 0; i < length; i++) {
		var e = spans[i];
		if (e.className == "line") {
			if (e.innerHTML.match(regex)) {
				e.style.display = "list-item";
			} else {
				e.style.display = "none";
			}
		}
	}
}
</script>
EOM
`
echo $js

form=`cat <<EOM
<h1>新型コロナウイルス各自治体の経済支援制度まとめ</h1>
<form onsubmit="return false;">
	<input type="text" name="pattern" placeholder="キーワードで絞り込み" onkeyup="isearch(this.value)" style="font-size:2em;">
</form>
EOM
`
echo $form


echo "<ul>"
keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
        result=`redis-cli GET $key`
        bool=`echo $result| cut -d',' -f 4`
        if [ $bool = "true" ]; then
		url=`echo $result| cut -d',' -f 1`
		# ドメイン名から自治体名を得る
		domain=$(cut -d'/' -f 3 <<< $url)
		govname=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 1|cut -d':' -f 2`
		# urlから詳細を得る
		path=${url//http:\/\//}
		path=${path//https:\/\//}
		title=`grep $path ./result.txt |cut -d':' -f 2`

                echo "<li class='line' style='display: list-item;'>"
                echo "<a href='${url}'>"
                echo $govname
                echo ": "
                echo $title
                echo "</a>"
                echo "</li>"
        fi
done
echo "</ul>"


