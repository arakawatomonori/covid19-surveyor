#!/bin/bash
set -e

. ./lib/_common.sh

# 削除対象の拡張子
images=png,jpg,jpeg,gif
movies=mp4,wmv,webm,webp
sounds=mp3,wav,wma
documents=xls,xlsm,xlsx,xml,doc,docx
archives=zip,lzh

exts=$images,$movies,$sounds,$documents,$archives

# はじまりのメッセージ
echo ""
echo "Remove large files. Target exts are as follows."
echo "  $exts"
echo ""

# 拡張子毎に
for ext in $(echo $exts | sed "s/,/ /g")
do
    echo -n "$ext ..."

    # 検索の確認用（必要に応じてコメント外して実験）
    # echo ""
    # find $REPOS_ROOT/www-data/*/. -name "*.$ext"
    # find $REPOS_ROOT/www-data/*/. -name "*.$ext\?*"

    # 実際の削除
    find $REPOS_ROOT/www-data/*/. -name "*.$ext"    -exec rm -rf {} \;
    find $REPOS_ROOT/www-data/*/. -name "*.$ext\?*" -exec rm -rf {} \;

    echo " done"
done

echo ""
