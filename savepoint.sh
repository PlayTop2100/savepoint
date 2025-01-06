#!/bin/bash

saveloc="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)/saves/"
if [ -z $1 ]; then
	1="--help"
fi
if [  -z $2 ]; then
	label="default"
else
	label="$2"
fi
if [ $1 = "-s" ]; then
	pwd > "$saveloc$label.txt"
elif [ $1 = "-l" ]; then
	if [ -f "$saveloc$label.txt" ]; then
		labelloc=$(<"$saveloc$label.txt")
		cd $labelloc
	else
		echo "Label '$label' does not exist"
	fi
elif [ $1 = "-r" ]; then
	if [ -f "$saveloc$label.txt" ]; then
		rm "$saveloc$label.txt"
	else
		echo "Label '$label' does not exist"
	fi
elif [ $1 = "--list" ]; then
	lsoutput=$(ls -m $saveloc)
	lsoutput=${lsoutput//[$'\t\r\n']}
	lsoutput=${lsoutput//,/}
	len=$(grep -o '.txt' <<<"$lsoutput" | grep -c .)
	files=()
	longLen=0
	for (( i=0; i<${len}; i++ ));
	do
		cutind=$((i + 1))
		file=$(echo "$lsoutput" | cut -d ' ' -f "$cutind")
		if [ $longLen -lt ${#file} ]; then
			longLen=${#file}
		fi
		files+=($file)
	done
	for (( i=0; i<${len}; i++ ));
	do
		conts=$(cat "$saveloc${files[$i]}")
		fname=$(echo "${files[$i]}" | sed -e 's/\.txt$//')
		for (( j=${#fname}; j<${longLen}-4; j++ )); do echo -n " "; done
		echo -n "$fname : "
		echo "$conts"
	done
elif [ $1 = "--help" ]; then
	echo "-s [label] : Save current path"
	echo "-l [label] : Load saved path"
	echo "-r [label] : Remove label"
	echo "--list     : List saved labels and paths"
else
	echo "Invalid argument: Run with --help for info"
fi