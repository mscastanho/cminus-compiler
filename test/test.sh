#!/usr/bin/env bash

for i in `ls ./in | egrep -i "*[^README]"`
do
	filename="${i%.*}"
	myoutput="$filename.myout"
	output="$filename.out"
	printf "Diff de $filename:\n"
	../parser < ./in/$i | diff ./out/$output -
	printf "\n\n"
done


