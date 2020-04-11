files="./*"
dirarray=()
for path in $files; do
	if [ -d $path ] ; then
		dirarray+=("$path")
	fi
done

for i in ${dirarray[@]}; do
	domain=$(cut -d'/' -f 2 <<< $i)
	link="<a href='http://${domain}.gov.yuiseki.net'>${domain}</a><br />"
	echo $link
done
