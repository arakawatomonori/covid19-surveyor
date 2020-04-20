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
    # 長過ぎる行は無視
    sed '/^.\{1,200\}$/!d' |\
    # 半角スペース除去
    sed 's/ //g' |\
    # 全角スペース除去
    sed 's/　//g' |\
    # タブ除去
    sed 's/[ \t]*//g' |\
    # HTMLタグ除去
    sed -e 's/<[^>]*>//g'
}

export_corona_files() {
    set +e
    # www-data内の全HTMLファイルをコロナでgrepして中間ファイルに出力
    grep -r コロナ --include="*.html" ./www-data > $INTERMEDIATE_FILE_PATH
    cat $INTERMEDIATE_FILE_PATH | sanitize_grep_result >> $SANITIZED_FILE_PATH
    set -e
}

export_pdf_corona_files() {
    find ./www-data/ -regex '.*\.pdf$' | xargs -n1 -I@ pdftotext @ @.txt
    set +e
    grep -r コロナ --include="*.pdf.txt" ./www-data |\
        sanitize_grep_result |\
        sed 's/\.pdf\.txt:/\.pdf:/' >>\
        $SANITIZED_FILE_PATH
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
    export_corona_files
    export_pdf_corona_files
    export_keyword_files
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
