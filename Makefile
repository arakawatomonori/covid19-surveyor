.PHONY: all usage release test wget grep aggregate publish slack-map slack-check-jobs slack-check-results

all: usage

usage:
	@echo "make wget"
	@echo "    data/ 内のすべてのURLに対してwget -rを実行します"
	@echo "make grep"
	@echo "    www-data/ 内のすべてのHTMLファイルに対してgrepを実行します"
	@echo "    make wgetを先に実行しておく必要があります"
	@echo "make aggregate"
	@echo "    grepした結果を集計します"
	@echo "    make grepを先に実行しておく必要があります"
	@echo "make publish"
	@echo "    集計結果を元にwww-data/index.htmlに出力します"
	@echo "    make aggregateを先に実行しておく必要があります"
	@echo "make release"
	@echo "    wget, grep, aggregate, publishを順に実行します"
	@echo "make slack-queue"
	@echo "    集計結果を元にSlackで質問DMを送るためのキューを追加します"
	@echo "    make aggregateを先に実行しておく必要があります"
	@echo "make slack-map"
	@echo "    slack-queueからURLを取り出してSlackのメンバーにDMを送信します"
	@echo "    make slack-queueを先に実行しておく必要があります"
	@echo "make slack-check-offer"
	@echo "    slackで質問DMを送って回答待ちのメンバーのID一覧を表示します"
	@echo "make slack-check-jobs"
	@echo "    slackで質問DMを送って回答待ちのjob一覧を表示します"
	@echo "make slack-check-results"
	@echo "    slackで質問DMを送って回答された結果の一覧を表示します"
	

release: wget grep aggregate publish

test:
	./crawler/wget.sh data/test.csv
	./crawler/grep.sh
	./crawler/aggregate.sh
	./crawler/publish.sh > ./www-data/index.html

wget:
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv

grep:
	./crawler/grep.sh

aggregate:
	./crawler/aggregate.sh

publish:
	./crawler/publish.sh > ./www-data/index.html

slack-queue:
	./slack-bot/url-queue.sh

slack-map:
	./slack-bot/url-map.sh

slack-check-offer:
	redis-cli SMEMBERS vscovid-crawler:offered-members

slack-check-jobs:
	redis-cli KEYS vscovid-crawler:job-*

slack-check-results:
	redis-cli KEYS vscovid-crawler:result-*
