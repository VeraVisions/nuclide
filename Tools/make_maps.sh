#!/bin/sh

if [ $# -lt 1 ]
then
	exit 1
fi

GAMEDIR="$1"

if [ -d "$GAMEDIR/mapsrc/" ]
then
	OLDDIR="$(pwd)"
	
	find "$GAMEDIR/mapsrc/" -name "*.map" | while read QEDMAP
	do
		cd "$(dirname "$QEDMAP")"
		MAPFILE="$(basename "$QEDMAP")"
		PATH="$PATH:$OLDDIR" vmap -fs_basepath "$OLDDIR" -fs_game "$GAMEDIR" "$MAPFILE"
		PATH="$PATH:$OLDDIR" vmap -vis -fs_basepath "$OLDDIR" -fs_game "$GAMEDIR" "$MAPFILE"
		PATH="$PATH:$OLDDIR" vmap -light -fs_basepath "$OLDDIR" -fs_game "$GAMEDIR" "$MAPFILE"
		cd "$OLDDIR"
	done
	
	find "$GAMEDIR/mapsrc/" -name "*.bsp" | while read MAPFILE
	do
		NEWPATH="$(echo "$MAPFILE" | sed 's/\/mapsrc\//\/maps\//g')"
		NEWPATHDIR=$(dirname "$NEWPATH")
		mkdir -p "$NEWPATHDIR"
		mv -v "$MAPFILE" "$NEWPATH"
	done
fi
