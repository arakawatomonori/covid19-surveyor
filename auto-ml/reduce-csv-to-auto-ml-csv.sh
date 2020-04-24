#!/bin/bash
set -e



main() {
    # AutoMLの学習用CSVの形式
    # Text Text Text..., covid19_help
    # Text Text Text..., not_covid19_help
    while read line; do
        orgname=`echo $line| cut -d',' -f 1`
        prefname=`echo $line| cut -d',' -f 2`
        url=`echo $line| cut -d',' -f 3`
        title=`echo $line| cut -d',' -f 4`
        desc=`echo $line| cut -d',' -f 5`
        echo "$title $desc, covid19_help"
    done < reduce.csv
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main $@
fi
