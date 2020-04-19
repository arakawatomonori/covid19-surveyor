#!/bin/bash
set -e

. ./lib/helper.sh

. ./crawler/grep.sh

echo test sanitize_grep_result
## remove whitespace chars
input="foo.html:あいうえお　かきくけこ さしすせそ	たちつてと"
actual=$(echo $input | sanitize_grep_result)
assert_equal "foo.html:あいうえおかきくけこさしすせそたちつてと" "$actual"

echo test sanitize_grep_result
## remove too long line
input="foo.html:$(seq 100 | xargs)"
actual=$(echo $input | sanitize_grep_result)
assert_empty "$actual"

echo test sanitize_grep_result
## sanitize HTML tags
input="foo.html:<p><a href=\"bar.html\">テキストテキスト<br>テキスト</a></p>"
actual=$(echo $input | sanitize_grep_result)
assert_equal "foo.html:テキストテキストテキスト" "$actual"
