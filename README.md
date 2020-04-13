# vscovid-crawler
シェルスクリプトで書かれた主要省庁と都道府県のWebサイトをミラーリングするスクリプト

## Warning
このスクリプトを実行すると50GBくらいのディスク容量を消費します

## Usage

### Setup
- `sudo apt install wget nginx squid`

#### macOS

Install GNU xargs in macOS

```
$ brew install findutils
$ export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
```
Intall GNU grep in macOS

```
$ brew install grep
$ export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
```

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

```
$ make
```

## TODO
- grepを並列処理にする
- grep結果をインクリメンタル検索
- HTML以外のファイルの文字列も検索したい
- 市区町村のサイトもミラーリングしたい
