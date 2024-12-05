#!/bin/sh

if [ $# -lt 1 ]
then
	exit 1
fi

GAMEDIR="$1"

if [ -d "$GAMEDIR/modelsrc/" ]
then
	OLDDIR="$(pwd)"
	
	find "$GAMEDIR/modelsrc/" -name "*.qc" | while read MODELQC
	do
		cd "$(dirname "$MODELQC")"
		QCFILE="$(basename "$MODELQC")"
		PATH="$PATH:$OLDDIR" vvmtool "$QCFILE"
		cd "$OLDDIR"
	done
	
	find "$GAMEDIR/modelsrc/" -name "*.vvm" | while read MODELFILE
	do
		NEWPATH="$(echo "$MODELFILE" | sed 's/\/modelsrc\//\/models\//g')"
		NEWPATHDIR=$(dirname "$NEWPATH")
		mkdir -p "$NEWPATHDIR"
		mv -v "$MODELFILE" "$NEWPATH"
	done

	# Convert the textures.
	find "$GAMEDIR/modelsrc/" -name "*.png" | while read TARGA
	do
		NEWPATH="$(echo "$TARGA" | sed 's/\/modelsrc\//\/textures\/models\//g' | sed 's/\.tga/\.ktx/g' | sed 's/\.png/\.ktx/g')"

		# Only update new
		if [ ! -f "$NEWPATH" ]
		then
			PATH="$PATH:$OLDDIR" imgtool --ext ktx --bc3_rgba --premul "$TARGA"
		fi
	done
	
	find "$GAMEDIR/modelsrc/" -name "*.ktx" | while read KTXFILE
	do
		NEWPATH="$(echo "$KTXFILE" | sed 's/\/modelsrc\//\/textures\/models\//g')"
		NEWPATHDIR=$(dirname "$NEWPATH")
		mkdir -p "$NEWPATHDIR"
		mv -v "$KTXFILE" "$NEWPATH"
	done
	
	find "$GAMEDIR/modelsrc/" -name "*.mat" | while read MATFILE
	do
		NEWPATH="$(echo "$MATFILE" | sed 's/\/modelsrc\//\/textures\/models\//g')"
		NEWPATHDIR=$(dirname "$NEWPATH")
		mkdir -p "$NEWPATHDIR"
		sed 's/\.tga/\.ktx/g' "$MATFILE" > "$NEWPATH"
	done
fi
