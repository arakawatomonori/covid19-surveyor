files=("data/gov.csv data/pref.csv")
echo $files
urls=()
domains=()

for file in $files; do
	for line in `cat ${file}`; do
		url=`echo ${line} | cut -d',' -f 3`
		urls=("${urls} $url")
		domain=${url//http:\/\//}
		domain=${domain//https:\/\//}
		domains=("${domains} $domain")
	done
done

echo $urls | xargs -n 1 echo | xargs -P 0 -I{} wget -l 2 -r --no-check-certificate {}
echo $domains | xargs -n 1 echo | xargs -I{} cp -f robots.txt {}


./grep.sh
./index.sh > index.html
