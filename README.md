# covid19-surveryor
シェルスクリプトで書かれた主要省庁と都道府県のWebサイトを収集し分類するシステム。

## Warning
`make wegt` を実行するとかなりのディスク容量を消費します。また、全国の各自治体のサイトに負荷をかけることになるので、基本的には実行をしないようにしてください。

動作確認が必要でデータをクロールしたい場合は、代わりに下記のコマンドを実行してください。

```
./crawler/wget.sh data/test.csv
```

## Setup for Ubuntu

### Requirements
```
sudo apt install make wget jq nginx fcgiwrap squid poppler-utils
```

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

## Run with docker

```
docker build -t vscovid-crawler .
docker run -it --rm -p 8080:80 -v $(pwd):/app vscovid-crawler
docker run -it --rm -v $(pwd):/app vscovid-crawler bash
```

## Run with docker-compose

```
docker-compose build
docker-compose up
```

## For developers

開発についての議論などは [Code for Japan](https://www.code4japan.org/) が運営する Slack Workspace で行っています。

開発に参加したい方は下記の招待リンクから Slack の Workspace に参加いただき、 `#covid19-surveyor-dev` チャンネルに参加してください。

- https://cfjslackin.herokuapp.com/
