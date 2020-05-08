#!/bin/bash
set -e

. ./lib/test-helper.sh
. ./lib/string-helper.sh

echo "test remove_newline_and_comma"
result=$(echo -e "abc def
GHI,A,B,C" | remove_newline_and_comma)
assert_equal "abc defGHI A B C" "$result"


echo "test remove_comment_lines"
result=$(echo -e "あいう
かきく
# さしす
たちつ # XYZ
#
##
なにぬ
#はまや" | remove_comment_lines)

assert_equal "あいう
かきく
たちつ # XYZ
なにぬ" "$result"

