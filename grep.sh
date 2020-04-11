words=`cat <<EOM
助成
補助
給付
収入
減額
支援
資金
税金
税制
納税
融資
貸付
制度
相談
窓口
猶予
延長
学校
授業
リモート
EOM
`

for word in ${words}; do
	echo $word
	grep -r コロナ --include="*.html" ./ | grep $word > grep_コロナ_$word.txt
done

