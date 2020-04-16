#!/bin/bash
set -e

###
### About
### help.stopcovid19.jp/index.htmlを生成するスクリプト
###
### Usage
### ./index.sh
###


cd www-data
files="./*"
dirarray=()
for path in $files; do
	if [ -d $path ] ; then
		dirarray+=("$path")
	fi
done
cd -

js=`cat <<EOM
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<script type="text/javascript">
function quotemeta (string) {
	return string.replace(/(\W)/, "\\$1");
}
function isearch (pattern) {
	var regex = new RegExp(quotemeta(pattern), "i");
	var spans = document.getElementsByTagName('span');
	var length = spans.length;
	for (var i = 0; i < length; i++) {
		var e = spans[i];
		if (e.className == "line") {
			if (e.innerHTML.match(regex)) {
				e.style.display = "block";
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
<form onsubmit="return false;">
	<input type="text" name="pattern" placeholder="キーワードで絞り込み" onkeyup="isearch(this.value)" style="font-size:2em;">
</form>
EOM
`
echo $form


echo "<div style='height:600px;overflow:scroll;'>"
keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
        result=`redis-cli GET $key`
        url=`echo $result| cut -d',' -f 1`
        bool=`echo $result| cut -d',' -f 4`
				# ドメイン名から自治体名を得る
				domain=$(cut -d'/' -f 3 <<< $url)
				govname=`grep $domain --include="*.csv" ../data/*|cut -d',' -f 1|cut -d':' -f 2`
				# urlから詳細を得る
				path=${url//http:\/\//}
				path=${path//https:\/\//}
				title=`grep $path ../results.txt |cut -d':' -f 2`

        if [ $bool = "true" ]; then
                echo "<span class='line' style='display: block;'>"
                echo "<a href='${url}'>"
                echo $govname
                echo ": "
                echo $title
                echo "</a>"
                echo "</span>"
        fi
done
echo "</div>"


echo "<hr />"

for i in ${dirarray[@]}; do
	domain=$(cut -d'/' -f 2 <<< $i)
	link="<a href='http://${domain}.help.stopcovid19.jp'>${domain}</a><br />"
	echo $link
done
