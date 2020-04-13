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
県税
融資
貸付
制度
相談
窓口
猶予
延長
学校
授業
労働
特例
措置
雇用
事業
休業
リモートワーク
テレワーク
EOM
`

for word in ${words}; do
	echo $word
	grep -r コロナ --include="*.html" ./ |\
	# AND 条件で絞り込み
	grep $word |\
	# 長過ぎる行は無視
	sed '/^.\{1,200\}$/!d' |\
	# 半角スペース除去
	sed 's/ //g' |\
	# 全角スペース除去
	sed 's/　//g' |\
	# タブ除去
	sed 's/[ \t]*//g' |\
	# HTMLタグ除去
	sed -e 's/<[^>]*>//g' >\
	grep_コロナ_$word.txt.tmp
done

