#!/bin/bash
set -e

###
### About
### ./www-dataに収集した全サイトから新型コロナウイルスに関連するHTMLファイルの一覧を取得するスクリプト
###
### Dependency
### - make wget
###
### Usage
### - make grep
###

# 配列初期化
export WORDS=`cat <<EOM
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

export INTERMEDIATE_FILE_PATH="./tmp/grep_コロナ.txt.tmp"
export SANITIZED_FILE_PATH="./tmp/sanitize_コロナ.txt.tmp"

remove_exist_index() {
    rm -f www-data/index.html
}

init_intermediate_file() {
    echo "" > $INTERMEDIATE_FILE_PATH
}

# tested
sanitize_grep_result() {
    # 半角スペース除去
    # 全角スペース除去
    # タブ除去
    # HTMLタグ除去
    sed -e 's/ //g' -e 's/　//g' -e 's/[ \t]*//g' -e 's/<[^>]*>//g'
}

export_corona_html_files() {
    set +e
    # www-data内の全HTMLファイルをコロナでgrepして中間ファイルに出力
    find ./www-data/ -regex '.*\.html$' | xargs -P 16 -I{} grep -H -r コロナ {} >> $INTERMEDIATE_FILE_PATH
    set -e
}

export_corona_pdf_files() {
    # PDFファイルをテキストファイルに変換
    find ./www-data/ -regex '.*\.pdf$' | xargs -n1 -P 16 -I@ pdftotext @ @.txt
    set +e
    # www-data内の全PDFファイルをコロナでgrepして中間ファイルに出力
    find ./www-data/ -regex '*.pdf.txt' | xargs -P 16 -I{} grep -H -r コロナ {} |\
        sed 's/\.pdf\.txt:/\.pdf:/' >>\
        $INTERMEDIATE_FILE_PATH
    set -e
}

sanitize_intermediate_file() {
    set +e
    cat $INTERMEDIATE_FILE_PATH | sanitize_grep_result >> $SANITIZED_FILE_PATH
    set -e
}

export_keyword_files()  {
    set +e
    for word in ${WORDS}; do
        echo $word
        # 中間ファイルを各キーワードでgrepして結果を出力
        grep $word $SANITIZED_FILE_PATH > ./tmp/grep_コロナ_$word.txt.tmp
    done
    set -e
}

main() {
    remove_exist_index
    init_intermediate_file
    export_corona_html_files
    #export_corona_pdf_files
    sanitize_intermediate_file
    export_keyword_files
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
