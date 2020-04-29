
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
	./test/test.sh

.PHONY: clean
clean:
	rm -f tmp/*
	rm -f www-data/index.html
	rm -f www-data/index.json

###
### crawler
###

.PHONY: wget
wget:
	# csv内の全ドメインをwww-data以下にミラーリングする
ifeq ($(ENV),production)
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv
else
	./crawler/wget.sh data/test.csv
endif
	# tmp/urls.txt内の全URLをwww-data以下にミラーリングする
	# tmp/urls.txtは「経済支援制度ですか？」に「はい」と答えられたURLのみ
	cd www-data
	cat ../tmp/urls.txt |xargs -I{} wget --force-directories --no-check-certificate {}
	cd -

# www-data内の巨大なファイルを削除する
.PHONY: remove-large-files
remove-large-files:
	./crawler/remove-large-files.sh

# www-data内のHTMLとPDFをgrepで検索する
# tmp/grep_コロナ.txt.tmp を生成する
.PHONY: grep
grep: tmp/grep_コロナ.txt.tmp

tmp/grep_コロナ.txt.tmp: remove-large-files
	./crawler/grep.sh

# grep結果を集計する
# 複数のキーワードでgrepしているので重複があったりするのをuniqする
# tmp/results.txt, tmp/urls.txt を生成する
.PHONY: aggregate
aggregate: tmp/results.txt

tmp/results.txt: grep
	./crawler/aggregate.sh

# www-data/index.html, www-data/index.jsonを生成する
.PHONY: publish
publish: www-data/search/index.html www-data/map/index.json
	@echo index files are generated

www-data/map/index.html:
	make -C map-client

www-data/map/index.json: www-data/map/index.html reduce.csv
	./lib/csv2json.sh "orgname" "prefname" "url" "title" "description" < reduce.csv > ./www-data/map/index.json

www-data/search/index.html: reduce.csv
	./crawler/publish.sh > ./www-data/search/index.html

.PHONY: deploy
deploy:
	rm -f www-data/map/index.html www-data/map/index.json
	make publish
ifeq ($(ENV),production)
	aws cloudfront create-invalidation --distribution-id E2JGL0B7V4XZRW --paths '/*'
	./slack-bot/post-git-commit-log.sh
else
	@echo "environment isn't production."
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

.PHONY: slack-bool-reduce
slack-bool-reduce: data/reduce-bool.csv

data/reduce-bool.csv:
	./slack-bot/url-bool-reduce.sh > ./data/reduce-bool.csv

# redisのデータを集計しreduce.csvを生成する
.PHONY: slack-vote-reduce
slack-vote-reduce: data/reduce-vote.csv

data/reduce-vote.csv:
	./slack-bot/url-vote-reduce.sh > ./data/reduce.csv
	cp reduce.csv ./data/reduce-vote.csv

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
