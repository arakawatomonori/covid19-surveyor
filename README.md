# covid19-surveryor
シェルスクリプト書かれた主要省庁と都道府県のWebサイトを収集し分類するシステム

## Warning
このスクリプトを実行するとかなりのディスク容量を消費します

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
- `brew install wget jq nginx fcgiwrap squid poppler`

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

Join our Slack workspace!
- https://join.slack.com/t/cfj/shared_invite/zt-88tbjehh-_ANL8iwMkwAuuBtXqiyPYg
- Join #covid19-surveyor-dev channel!

```
$ make test
```

## Run with docker-compose

```
docker-compose build
docker-compose up # add `-d` to run in background
docker-compose exec crawler make publish
docker-compose exec crawler bash
```
