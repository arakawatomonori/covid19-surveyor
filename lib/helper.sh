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

# テスト成功出力
test_passed(){
	echo_green "    passed"
	return 0
}

# テストエラー出力（exit 1 までしてしまう）
#   第1引数: expect value
#   第2引数: actual value
test_failed(){
	echo_red   "    failed"
	echo       "        expect: $1"
	echo       "        actual: $2"
	exit 1
}

# helper.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi