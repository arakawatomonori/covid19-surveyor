#!/bin/bash
set -e

###
### About:
###   引数で指定されたCSVファイルを対象にミラーリングするシェルスクリプト
###   入力CSVのフォーマットは
###   組織名,略称,URL
###
### Usage (run script directly):
###   $ ./crawler/wget.sh {file1} [{file2}] [{file3}] ...
###
###   e.g.) $ ./crawler/wget.sh data/test.csv
###         $ ./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv
###
### Usage (make command):
###   $ make wget
###
### Input:
###   - コマンドライン引数で与えられた CSV ファイル群
###   - CSV に含まれる URL リソース（実際の通信を行いデータを引っ張ってくる）
###
### Output:
###   ./www-data/*
###
### TODO:
###   ・wget.sh 実行前の ./www-data/* は消去せずに「残す」挙動で本当に良いのかどうか要件等。
###     要は古いファイルが残り続ける挙動で本当に良いのかどうか。
###   ・wget.sh というシェルスクリプト名が wget コマンドと密結合しすぎているので、
###     抽象度を上げた名前にリネームしたほうがほうが良さそう。
###

. ./lib/string-helper.sh
. ./lib/url-helper.sh

# tested
# arguments: csvfiles
get_target_urls() {
    urls=()
    # $#は引数の個数
    while (( $# > 0 )); do
        # $1は1つ目の引数 (※「grep -v '^#'」でコメント行は除外)
        urls=("${urls[@]} $(cat $1 | remove_comment_lines | cut -d',' -f 3)")
        # shiftで次の引数を$1に入れている
        shift
    done
    echo ${urls}
    return 0
}

# tested
# arguments: urls
get_target_domains() {
    domains=()
    while (( $# > 0 )); do
        domain=$(get_domain_by_url $1)
        # domains配列に追加
        domains=("${domains} $domain")
        shift
    done
    echo $domains
    return 0
}

main() {
    args=$*
    urls=$(get_target_urls $args)
    domains=$(get_target_domains $urls)

    # ダウンロード対象の拡張子 -> ext
    # e.g.) ext="aspx|cgi|htm|html|pdf|php"
    ext=$(jq -r .ext[] ./accept-ext.json | tr '\n' '|' | rev | cut -c 2- | rev)

    depth=2
    if [ $environment = "test" ]; then
        depth=1
    fi
    pushd www-data
    # urls配列の中身をwgetに渡している
    echo ${urls} | xargs -n 1 echo | xargs -P 16 -I{} wget -l $depth -r --accept-regex "\.(${ext})$" --no-check-certificate {}
    # xargsでurls配列の中身をwgetに渡している
    # wgetのオプション
    # https://www.hariguchi.org/info/ja/wget-1.5.3/wget-ja.html
    # リンクを辿る
        #  --recursive \
    # リンクを2段階まで辿る
        #  --level 2 \
    # 親ページへのリンクは辿らない
        #  –-no-parent \
    # ページ表示のために必要な関連ファイルもダウンロードする
        # --page-requisites \
    # 既にダウンロード済みのファイルは再取得しない
    # --timestampingとは同時に指定できない
        #  –-no-clobber \
    # タイムスタンプを比較し、変更されていないならダウンロードしない
    # --no-clobberとは同時に指定できない
        #  --timestamping \
    # 相手先サーバーに負荷を掛けないようにランダムに待つ
        #  --random-wait \
    # 詳細なログ出力をしない
        #  --quiet \
    # 進捗だけはログ出力する
        #  --show-progress \
    # この正規表現にマッチするURLだけダウンロードする
        #  --accept-regex "\.(${ext})$" \
    # サーバーの証明書エラーを無視する
        #  --no-check-certificate \
    echo ${urls} | xargs -n 1 echo | xargs -P 16 -I{} wget \
      --recursive \
      --level 2 \
      –-no-parent \
      --page-requisites \
      --timestamping \
      --random-wait \
      --quiet \
      --show-progress \
      --accept-regex "\.(${ext})$" \
      --no-check-certificate \
      {}
    echo ${domains} | xargs -n 1 echo | xargs -I{} cp -f ../robots.txt {}
    popd
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
