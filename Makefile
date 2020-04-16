.PHONY: all usage release test wget grep aggregate publish slack-map slack-check-jobs slack-check-results

all: usage

usage:
	@cat USAGE
	

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
	while true; do ./slack-bot/url-map.sh; sleep 1; done

slack-clear-offer:
	redis-cli DEL vscovid-crawler:offered-members

slack-check-offer:
	redis-cli SMEMBERS vscovid-crawler:offered-members

slack-check-jobs:
	redis-cli KEYS vscovid-crawler:job-*

slack-check-results:
	redis-cli KEYS vscovid-crawler:result-*
