
urls=`cat gov.csv pref.csv`
domains=${urls//http:\/\//}
domains=${domains//https:\/\//}

echo $urls | xargs -n 1 echo | xargs -P 0 -I{} wget -l 2 -r --no-check-certificate {}
echo $domains | xargs -n 1 echo | xargs -I{} cp -f robots.txt {}


./grep.sh
./index.sh > index.html
