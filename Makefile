
include .env
export $(shell sed 's/=.*//' .env)
ENV=$(environment)

.PHONY: all
all: usage

.PHONY: usage
usage:
	@cat USAGE

###
### crawler
###

.PHONY: release
release: wget grep aggregate publish

.PHONY: test
test:
	find ./test/ -regex '.*\.sh$$' | xargs -t -n1 bash

.PHONY: wget
wget:
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv
	./crawler/remove-large-files.sh

.PHONY: remove-large-files
remove-large-files:
	./crawler/remove-large-files.sh

.PHONY: grep
grep:
	./crawler/grep.sh

.PHONY: aggregate
aggregate:
	./crawler/aggregate.sh

.PHONY: publish
publish:
	./crawler/publish.sh > ./www-data/index.html
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

.PHONY: slack-bool-reduce
slack-bool-reduce:
	./slack-bot/url-bool-reduce.sh > reduce.csv

# clear
.PHONY: slack-clear-offer
slack-bool-clear-offer:
	redis-cli DEL vscovid-crawler:offered-members

# check
.PHONY: slack-check-bool-offer
slack-check-bool-offer:
	redis-cli SMEMBERS vscovid-crawler:offered-members

.PHONY: slack-check-bool-queue
slack-check-bool-queue:
	redis-cli KEYS vscovid-crawler:queue-*

.PHONY: slack-check-bool-jobs
slack-check-bool-jobs:
	redis-cli KEYS vscovid-crawler:job-*

.PHONY: slack-check-bool-results
slack-check-bool-results:
	redis-cli KEYS vscovid-crawler:result-*
