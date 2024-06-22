#!/bin/sh

if [ $# -lt 3 ]; then
	printf "make_launcher.sh DIR COMMAND DESTINATION\n"
	exit
fi


DIR="$1"
COMMAND="$2"
DEST="$3"

printf "#/bin/sh\ncd \"$DIR\"\n$COMMAND\n" > "$DEST"
chmod +x "$DEST"