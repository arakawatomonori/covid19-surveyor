#!/bin/bash
set -e

# 色替え echo
echo_green(){
    echo -e "\e[32m$1\e[m"
    return 0
}
echo_red() {
    echo -e "\e[31m$1\e[m"
    return 0
}

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# テスト結果出力
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# テスト成功出力
test_passed(){
	echo_green "\tpassed"
	return 0
}

# テストエラー出力（exit 1 までしてしまう）
test_failed(){
	# 引数
	expect=$1
	actual=$2

	# 出力
	echo_red   "\tfailed"
	echo -e    "\t\texpect: $expect"
	echo -e    "\t\tactual: $actual"
	exit 1
}

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Assert 系の関数
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# 2値が等しいことを確認
assert_equal(){
	# 引数
	expect=$1
	actual=$2

	# 判定
	if [ "$actual" = "$expect" ]; then
		test_passed
	else
		test_failed "$expect" "$actual"
	fi
}

# 値が空っぽであることを確認
assert_empty(){
	# 引数
	actual=$1

	# 判定
	if [ "$actual" = "" ]; then
		test_passed
	else
		test_failed "(empty)" "$actual"
	fi
}

# 値が空っぽでないことを確認
assert_not_empty(){
	# 引数
	actual=$1

	# 判定
	if [ "$actual" != "" ]; then
		test_passed
	else
		test_failed "(not empty)" "$actual"
	fi
}

# helper.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi