


get_domain_by_url() {
    url=$1
    domain=$(cut -d'/' -f 3 <<< $url)
    echo $domain
    return 0
}


get_govname_by_url() {
    url=$1
    domain=`get_domain_by_url $url`
    govname=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 1|cut -d':' -f 2`
    echo $govname
    return 0
}


# *.sh が直接実行されたら exit 0 する
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi
