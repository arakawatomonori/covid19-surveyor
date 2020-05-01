#!/bin/bash
set -e



main() {
    # AutoMLの学習用CSVの形式
    # Text Text Text..., covid19_help
    # Text Text Text..., not_covid19_help
    while read line; do
        # 「#」で始まる csv 行はコメントとみなしスキップする
        if [[ $line =~ ^\# ]]; then
            continue
        fi

        orgname=`echo $line| cut -d',' -f 1`
        prefname=`echo $line| cut -d',' -f 2`
        url=`echo $line| cut -d',' -f 3`
        title=`echo $line| cut -d',' -f 4|sed s/\"/ /g`
        desc=`echo $line| cut -d',' -f 5|sed s/\"/ /g`
        echo "$title $desc, covid19_help"
    done < ./data/reduce-vote.csv
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
