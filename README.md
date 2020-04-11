# vscovid-crawler
シェルスクリプトで書かれた主要省庁と都道府県のWebサイトをミラーリングするスクリプト

## Warngin
このスクリプトを実行すると50GBくらいのディスク容量を消費します

## Usage

### Setup
- `sudo apt install wget nginx squid`
#### nginx
- `cp nginx_config /etc/nginx/site-available/`
- `ln -s /etc/nginx/site-available/nginx_config /etc/nginx/site-enabled/nginx_config`
- `sudo service nginx restart`
#### squid
- `cp -f squid.conf /etc/squid/`
- `sudo service squid restart`
#### wget
- `cp .wgetrc ~/`

### Run
- `./wget.sh`
- `./grep.sh`
- `./index.sh > index.html`

## TODO
- 検索結果を見やすくしたい
- PDF内の文字列も検索したい
- 市区町村のサイトもミラーリングしたい
