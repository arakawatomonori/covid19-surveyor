files="./*"
filearray=()
dirarray=()
for path in $files; do
	if [[ -f $path && $path =~ ^\.\/.*\.txt*$ ]] ; then
		filearray+=("$path")
	fi
	if [ -d $path ] ; then
		dirarray+=("$path")
	fi
done


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
while read line; do
	url=$(cut -d':' -f 1 <<< $line)
	url="//${url:2:-1}l"
	domain=$(cut -d'/' -f 3 <<< $url)
	text=$(cut -d':' -f 2 <<< $line)
	echo "<span class='line' style='display: block;'>"
	echo "<a href='${url}'>"
	echo $domain
	echo ": "
	echo $text
	echo "</a>"
	echo "</span>"
done < uniq.txt
echo "</div>"

echo "<hr />"

for i in ${dirarray[@]}; do
	domain=$(cut -d'/' -f 2 <<< $i)
	link="<a href='http://${domain}.gov.yuiseki.net'>${domain}</a><br />"
	echo $link
done
