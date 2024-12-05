#!/bin/sh

if [ $# -lt 1 ]
then
	exit 1
fi

GAMEDIR="$1"
TARGET="$2"
MAPFILE=$(echo "$TARGET" | sed 's/\.bsp/\.map/g' | sed 's/\/maps\//\/mapsrc\//g')
MAPOUT=$(echo "$TARGET" | sed 's/\/maps\//\/mapsrc\//g')
OLDDIR="$(pwd)"

if [ -d "$GAMEDIR/mapsrc/" ]
then
	cd "$(dirname "$MAPFILE")"
	MAPFILE="$(basename "$MAPFILE")"
	PATH="$PATH:$OLDDIR" vmap -fs_basepath "$OLDDIR" -fs_game "$GAMEDIR" "$MAPFILE"
	PATH="$PATH:$OLDDIR" vmap -vis -fs_basepath "$OLDDIR" -fs_game "$GAMEDIR" "$MAPFILE"
	PATH="$PATH:$OLDDIR" vmap -light -fs_basepath "$OLDDIR" -fs_game "$GAMEDIR" "$MAPFILE"
	cd "$OLDDIR"
	mv -v "$MAPOUT" "$TARGET"
fi
