
include .env
export $(shell sed 's/=.*//' .env)
ENV=$(environment)

.PHONY: all
all: usage

.PHONY: usage
usage:
	@cat USAGE

.PHONY: test
test:
	find ./test/ -regex '.*\.sh$$' | xargs -t -n1 bash

.PHONY: clean
clean:
	rm -f reduce.csv
	rm -f tmp/*
	rm -f www-data/index.html
	rm -f www-data/index.json

###
### crawler
###

# csv内の全ドメインをwww-data以下にミラーリングする
.PHONY: wget
wget:
ifeq ($(ENV),production)
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv
else
	./crawler/wget.sh data/test.csv
endif
	make remove-large-files
	make grep

# tmp/urls.txt内の全URLをwww-data以下にミラーリングする
.PHONY: fetch
fetch:
	cd www-data
	cat ../tmp/urls.txt |xargs -I{} wget --force-directories --no-check-certificate {}
	cd -
	make remove-large-files
	make grep

# www-data内の巨大なファイルを削除する
.PHONY: remove-large-files
remove-large-files:
	./crawler/remove-large-files.sh

# www-data内のHTMLとPDFをgrepで検索する
.PHONY: grep
grep: tmp/sanitize_コロナ.txt.tmp

tmp/sanitize_コロナ.txt.tmp:
	rm -f ./tmp/grep_*
	./crawler/grep.sh
	make aggregate

# 検索結果を集計する
.PHONY: aggregate
aggregate: tmp/results.txt

tmp/results.txt:
	./crawler/aggregate.sh
	make slack-bool-reduce

# index.htmlとindex.jsonを生成する
.PHONY: publish
publish: www-data/index.html

www-data/index.html:
	./crawler/publish.sh > ./www-data/index.html
	./lib/csv2json.sh "govname" "url" "title" "description" < reduce.csv > ./www-data/index.json
ifeq ($(ENV),production)
	aws cloudfront create-invalidation --distribution-id E2JGL0B7V4XZRW --paths '/*'
endif

###
### slack-bot
###

# start
.PHONY: slack-bool-queue
slack-bool-queue:
	./slack-bot/url-bool-queue.sh

.PHONY: slack-bool-map
slack-bool-map:
	while true; do ./slack-bot/url-bool-map.sh; sleep 1; done
	make publish

.PHONY: slack-bool-reduce
slack-bool-reduce: reduce.csv

reduce.csv:
	./slack-bot/url-bool-reduce.sh > reduce.csv
	@echo you should do next: make publish


# clear
.PHONY: slack-bool-clear-offer
slack-bool-clear-offer:
	redis-cli DEL vscovid-crawler:offered-members

# check
.PHONY: slack-bool-check-offer
slack-bool-check-offer:
	redis-cli SMEMBERS vscovid-crawler:offered-members

.PHONY: slack-bool-check-queue
slack-bool-check-queue:
	redis-cli KEYS vscovid-crawler:queue-*

.PHONY: slack-bool-check-jobs
slack-bool-check-jobs:
	redis-cli KEYS vscovid-crawler:job-*

.PHONY: slack-bool-check-results
slack-bool-check-results:
	redis-cli KEYS vscovid-crawler:result-*
