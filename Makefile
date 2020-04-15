.PHONY: test all wget grep aggregate index

test:
	./wget.sh data/test.csv
	./grep.sh
	./aggregate.sh
	./index.sh > ./www-data/index.html

all:
	./wget.sh data/gov.csv data/pref.csv data/city.csv
	./grep.sh
	./aggregate.sh
	./index.sh > ./www-data/index.html

wget:
	./wget.sh data/gov.csv data/pref.csv data/city.csv

grep:
	./grep.sh

aggregate:
	./aggregate.sh

index:
	./index.sh > ./www-data/index.html
