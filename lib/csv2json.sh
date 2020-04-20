#!/bin/bash

# 引数から jq の map 関数に渡す filter 文字列を作成する
create_jq_mapper() {
	keys=($@)

	mapper="{"
	for i in "${!keys[@]}"; do
		# "key:type" 形式の文字列から $key と $type を取り出す
		key=`echo "${keys[$i]}" | sed -e 's/:.*$//'`
		type=`echo "${keys[$i]}" | sed -ne 's/^[^:]*://p'`

		# 2つ目以降の要素の前にカンマを追加
		if [ $i -gt 0 ]; then mapper="$mapper,"; fi

		# $type に応じて jq の filter を指定
		case "$type" in
			'number'  ) filter='| tonumber' ;;
			'boolean' ) filter='| test("true")' ;;
			*         ) filter='' ;;
		esac

		mapper="$mapper \"$key\": .[$i] $filter"
	done
	mapper="$mapper }"

	echo $mapper
}

# csv2json()
#   標準入力で与えられた CSV を JSON に変換して標準出力に返す
#   args: key1[:type1] key2[:type2] ... keyN[:typeN]
#     - key: CSV の n 番目の要素に対応する JSON key名
#     - type: key の型。number か boolean を指定できる。省略した場合は string として扱う。
csv2json() {
	mapper=`create_jq_mapper "$@"`
	tr '\r\n' '\n' | jq -csR "
		split(\"\n\") |
		map(if length > 0 then . else empty end) |
		map(split(\",\")) |
		map($mapper)
	"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	csv2json "$@"
fi
