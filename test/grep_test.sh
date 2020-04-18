#!/bin/bash
set -e

. ./crawler/grep.sh

# test sanitize_grep_result
## remove whitespace chars
input="foo.html:あいうえお　かきくけこ さしすせそ	たちつてと"
result=$(echo $input | sanitize_grep_result)
echo $result
expect="foo.html:あいうえおかきくけこさしすせそたちつてと"
echo $expect
if [ "$result" = "$expect" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi

## remove too long line
input="foo.html:$(seq 100 | xargs)"
result=$(echo $input | sanitize_grep_result)
echo $result
expect=""
echo $expect
if [ "$result" = "$expect" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi

## sanitize HTML tags
input="foo.html:<p><a href=\"bar.html\">テキストテキスト<br>テキスト</a></p>"
result=$(echo $input | sanitize_grep_result)
echo $result
expect="foo.html:テキストテキストテキスト"
echo $expect
if [ "$result" = "$expect" ]; then
	echo "passed"
else
	echo "failed"
	exit 1
fi
