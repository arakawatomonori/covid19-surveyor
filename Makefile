.PHONY: all usage release test wget grep aggregate publish slack-map slack-check-jobs slack-check-results

all: usage

usage:
	@cat USAGE

###
### crawler
###

release: wget grep aggregate publish

test:
	find ./test/ -regex '.*\.sh$$' | xargs -t -n1 bash

wget:
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv

grep:
	./crawler/grep.sh

aggregate:
	./crawler/aggregate.sh

publish:
	./crawler/publish.sh > ./www-data/index.html

###
### slack-bot
###

# start
slack-start-queue:
	./slack-bot/url-queue.sh

slack-start-map:
	while true; do ./slack-bot/url-map.sh; sleep 1; done

# clear
slack-clear-offer:
	redis-cli DEL vscovid-crawler:offered-members

# check
slack-check-offer:
	redis-cli SMEMBERS vscovid-crawler:offered-members

slack-check-queue:
	redis-cli KEYS vscovid-crawler:queue-*

slack-check-jobs:
	redis-cli KEYS vscovid-crawler:job-*

slack-check-results:
	redis-cli KEYS vscovid-crawler:result-*
