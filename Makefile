.PHONY: test all wget grep aggregate index

test:
	./crawler/wget.sh data/test.csv
	./crawler/grep.sh
	./crawler/aggregate.sh
	./crawler/publish.sh > ./www-data/index.html

all:
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv
	./crawler/grep.sh
	./crawler/aggregate.sh
	./crawler/publis.sh > ./www-data/index.html

wget:
	./crawler/wget.sh data/gov.csv data/pref.csv data/city.csv

grep:
	./crawler/grep.sh

aggregate:
	./crawler/aggregate.sh

index:
	./crawler/publish.sh > ./www-data/index.html
