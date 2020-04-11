files="./*"
filearray=()
dirarray=()
for path in $files; do
	if [[ -f $path && $path =~ ^\.\/grep_.*$ ]] ; then
		filearray+=("$path")
	fi
	if [ -d $path ] ; then
		dirarray+=("$path")
	fi
done

for i in ${filearray[@]}; do
	filepath=$(cut -d'/' -f 2 <<< $i)
	link="<a href='http://gov.yuiseki.net/${filepath}'>${filepath}</a><br />"
	echo $link
done

echo "<hr />"

for i in ${dirarray[@]}; do
	domain=$(cut -d'/' -f 2 <<< $i)
	link="<a href='http://${domain}.gov.yuiseki.net'>${domain}</a><br />"
	echo $link
done
