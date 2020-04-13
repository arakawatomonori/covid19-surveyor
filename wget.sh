#!/bun/bash
set -e

urls=`cat data/gov.csv data/pref.csv`
domains=${urls//http:\/\//}
domains=${domains//https:\/\//}

cd www-data
echo $urls | xargs -n 1 echo | xargs -P 0 -I{} wget -l 2 -r --no-check-certificate {}
echo $domains | xargs -n 1 echo | xargs -I{} cp -f robots.txt {}
cd -

./grep.sh
./index.sh > index.html

