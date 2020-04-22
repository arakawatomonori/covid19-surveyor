
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

###
### crawler
###

.PHONY: release
release: wget remove-large-files grep aggregate publish

.PHONY: wget
wget:
ifeq ($(ENV),production)
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv
else
	./crawler/wget.sh data/test.csv
endif
	./crawler/remove-large-files.sh
	@echo you should do next: make grep

.PHONY: remove-large-files
remove-large-files:
	./crawler/remove-large-files.sh

.PHONY: grep
grep:
	rm -f ./tmp/grep_*
	./crawler/grep.sh
	@echo you should do next: make aggregate

.PHONY: aggregate
aggregate:
	./crawler/aggregate.sh
	@echo you should do next: make slack-bool-reduce

.PHONY: fetch
fetch:
	cd www-data
	cat ../urls.txt |xargs -I{} wget --force-directories --no-check-certificate {}
	cd -

.PHONY: publish
publish:
	./crawler/publish.sh > ./www-data/index.html
	./lib/csv2json.sh "orgname" "prefname" "url" "title" "description" < reduce.csv > ./www-data/index.json
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
