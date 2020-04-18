#!/bin/bash
set -e

. ./crawler/grep.sh

echo test sanitize_grep_result
## remove whitespace chars
input="foo.html:あいうえお　かきくけこ さしすせそ	たちつてと"
actual=$(echo $input | sanitize_grep_result)
expect="foo.html:あいうえおかきくけこさしすせそたちつてと"
if [ "$actual" = "$expect" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect $expect
	echo -e "\t" actual $actual
	exit 1
fi

echo test sanitize_grep_result
## remove too long line
input="foo.html:$(seq 100 | xargs)"
actual=$(echo $input | sanitize_grep_result)
expect=""
if [ "$actual" = "$expect" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect $expect
	echo -e "\t" actual $actual
	exit 1
fi

echo test sanitize_grep_result
## sanitize HTML tags
input="foo.html:<p><a href=\"bar.html\">テキストテキスト<br>テキスト</a></p>"
actual=$(echo $input | sanitize_grep_result)
expect="foo.html:テキストテキストテキスト"
if [ "$actual" = "$expect" ]; then
	echo -e "\t\e[32m passed \e[m"
else
	echo -e "\t\e[31m failed \e[m"
	echo -e "\t" expect $expect
	echo -e "\t" actual $actual
	exit 1
fi
