
cat grep*.txt.tmp > cat.txt.tmp
sort cat.txt.tmp > sort.txt.tmp
uniq -d sort.txt.tmp > uniq.txt

urls=""
for line in `cat uniq.txt`; do
	echo $line
	url=`echo ${line} | cut -d':' -f 1`
	url="${url:2:-1}l"
	urls=("${urls}\n${url}")
done

echo -e $urls
echo -e $urls > urls.txt.tmp

uniq urls.txt.tmp > urls.txt
