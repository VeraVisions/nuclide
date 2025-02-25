#!/bin/sh

if [ $# -lt 1 ]
then
	exit 1
fi

GAMEDIR="$1"

if [ -d "$GAMEDIR/texturesrc/" ]
then
	OLDDIR="$(pwd)"
	
	#find "$GAMEDIR/texturesrc/" -name "*.xcf" | while read TARGA
	#do
	#	PATH="$PATH:$OLDDIR" imgtool --ext ktx --bc3_rgba --premul "$TARGA"
	#done
	
	find "$GAMEDIR/texturesrc/" -name "*.tga" | while read TARGA
	do
		NEWPATH="$(echo "$TARGA" | sed 's/\/texturesrc\//\/textures\//g' | sed 's/\.tga/\.ktx/g')"

		# Only update new
		if [ ! -f "$NEWPATH" ]
		then
			PATH="$PATH:$OLDDIR" imgtool --ext ktx --bc3_rgba --premul "$TARGA"
		fi
	done
	
	find "$GAMEDIR/texturesrc/" -name "*.png" | while read TARGA
	do
		NEWPATH="$(echo "$TARGA" | sed 's/\/texturesrc\//\/textures\//g' | sed 's/\.png/\.ktx/g')"

		# Only update new
		if [ ! -f "$NEWPATH" ]
		then
			PATH="$PATH:$OLDDIR" imgtool --ext ktx --bc3_rgba --premul "$TARGA"
		fi
	done
	
	find "$GAMEDIR/texturesrc/" -name "*.ktx" | while read KTXFILE
	do
		NEWPATH="$(echo "$KTXFILE" | sed 's/\/texturesrc\//\/textures\//g')"
		NEWPATHDIR=$(dirname "$NEWPATH")
		mkdir -p "$NEWPATHDIR"
		mv -v "$KTXFILE" "$NEWPATH"
	done
	
	find "$GAMEDIR/texturesrc/" -name "*.mat" | while read MATFILE
	do
		NEWPATH="$(echo "$MATFILE" | sed 's/\/texturesrc\//\/textures\//g')"
		NEWPATHDIR=$(dirname "$NEWPATH")
		mkdir -p "$NEWPATHDIR"
		sed 's/\.tga/\.ktx/g' "$MATFILE" > "$NEWPATH"
	done
else
	printf "No %s/texturesrc directory.\n" "$GAMEDIR"
	exit 1
fi
