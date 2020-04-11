# vscovid-crawler
シェルスクリプトで書かれた主要省庁と都道府県のWebサイトをミラーリングするスクリプト

## Usage

### Setup
`sudo apt install wget squid`
`cp -f squid.conf /etc/squid/`
`cp .wgetrc ~/`

### Run
`./wget.sh`
`./grep.sh`
`./index.sh > index.html`

## TODO
市区町村のサイトもミラーリングしたい
