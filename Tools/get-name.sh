#!/bin/sh

if [ $# -lt 1 ]
then
	printf "Unknown\n"
else
	if [ -f "$1/PROJECT" ]
	then
		head -n 1 "$1/PROJECT"
	else
		printf "%s\n" "$1"
	fi
fi
