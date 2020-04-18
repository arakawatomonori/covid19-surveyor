#!/bin/bash
set -e

# 色替え echo
echo_green(){
    echo -e "\e[32m$1\e[m"
    return 0
}
echo_red() {
    echo -e "\e[31m$1\e[m"
    return 0
}

echo_indent(){
    echo -e "\t" $1 $2
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 0
fi