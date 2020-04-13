#!/bin/bash
set -e

cat grep*.txt.tmp > cat.txt.tmp
sort cat.txt.tmp > sort.txt.tmp
uniq -d sort.txt.tmp > uniq.txt
