.PHONY: all wget grep aggregate index


all:
	./wget.sh
	./grep.sh
	./aggregate.sh
	./index.sh > ./index.html

wget:
	./wget.sh

grep:
	./grep.sh

aggregate:
	./aggregate.sh

index:
	./index.sh > ./index.html
