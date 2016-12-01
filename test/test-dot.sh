#!/usr/bin/env bash

for i in `ls ./in | egrep -i "*[^README]"`
do
	filename="${i%.*}"
	myoutput="$filename.myout"
	output="$filename.dot"
	printf "Diff de $filename:\n"
	../trab3 < ./in/$i | diff ./out/$output -
	printf "\n\n"
done


