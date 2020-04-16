# vscovid-crawler
シェルスクリプトで書かれた主要省庁と都道府県のWebサイトをミラーリングするスクリプト

## Warning
このスクリプトを実行すると50GBくらいのディスク容量を消費します

## Setup for Ubuntu
- `sudo apt install make wget jq nginx fcgiwrap squid`

### copy nginx config
```
cp nginx_config /etc/nginx/site-available/
ln -s /etc/nginx/site-available/nginx_config /etc/nginx/site-enabled/nginx_config
sudo service nginx restart
```

### copy squid config
```
cp -f squid.conf /etc/squid/
sudo service squid restart
```

### copy wget config
```
cp .wgetrc ~/
```

## Setup for macOS
- `brew install wget jq nginx fcgiwrap squid`

### Install GNU xargs in macOS

```
$ brew install findutils
$ export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
```

### Intall GNU grep in macOS

```
$ brew install grep
$ export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
```

### Intall GNU sed in macOS

```
$ brew install gnu-sed
$ export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
```


## Development

```
$ make test
```


