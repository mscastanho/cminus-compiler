#!/usr/bin/env bash

for i in `ls ./test/in | egrep -i "*[^README]"`
do
	filename="${i%.*}"
	myoutput="$filename.myout"
	output="$filename.out"
	printf "Diff de $filename:\n"
	./trab4 < ./test/in/$i | diff ./test/out/$output -
	printf "\n\n"
done
