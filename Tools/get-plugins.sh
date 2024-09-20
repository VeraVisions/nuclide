#!/bin/sh

if [ $# -lt 1 ]
then
	printf "Unknown\n"
else
	if [ -f "$1/PLUGINS" ]
	then
		head -n 1 "$1/PLUGINS"
	fi
fi
