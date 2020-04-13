.PHONY: all wget grep index


all:
	./wget.sh
	./grep.sh
	./result.sh
	./index.sh > ./index.html

wget:
	./wget.sh

grep:
	./grep.sh

result:
	./result.sh

index:
	./index.sh > ./index.html
