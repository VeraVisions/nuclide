#!/bin/sh

GAMEDIR="$1"
GAMEROOT="$(pwd)"
OUTDIR="$2"
PAKLST=/tmp/pak.lst

if ! [ -x "$(command -v zip)" ]; then
	printf "'zip' is not installed.\n" >&2
	exit 2
fi
if ! [ -x "$(command -v tree)" ]; then
	printf "'tree' is not installed.\n" >&2
	exit 2
fi

if [ $# -lt 2 ]; then
	printf "$0 [gamedir] [output dir]\n" >&2
	exit 2
fi

if [ ! -d "$GAMEDIR" ]
then
	printf "$GAMEDIR not found\n" >&2
	exit 2
fi

if [ ! -d "$OUTDIR" ]
then
	printf "$OUTDIR not found\n" >&2
	exit 2
fi

# build the archives from the pk3dir directories
find "./$GAMEDIR" -name "*.pk3dir" -maxdepth 1 | sort | xargs -I @ sh -c 'echo `basename "@"`' | while read PK3DIR
do
	if [ -f "$GAMEROOT/$GAMEDIR/$PK3DIR/PAK_NAME" ]
	then
		PAKNAME=$(head -n 1 "$GAMEROOT/$GAMEDIR/$PK3DIR/PAK_NAME")
	else
		PAKNAME=""
	fi

	if [ -n "$PAKNAME" ]
	then

	# go into the pk3dir and compile your zip file listing
	cd "$GAMEROOT/$GAMEDIR/$PK3DIR"
	find ./ -type f -print > "$PAKLST"

	# all the file types we'd like to strip out
	sed -i '/PAK_NAME/d' "$PAKLST"
	sed -i '/PAK_COPYRIGHT/d' "$PAKLST"
	sed -i '/\.gwdir/d' "$PAKLST"
	sed -i '/\.lno/d' "$PAKLST"
	sed -i '/\.xcf/d' "$PAKLST"
	sed -i '/\.smd/d' "$PAKLST"
	sed -i '/\.map/d' "$PAKLST"
	sed -i '/\.qc/d' "$PAKLST"
	sed -i '/\.srf/d' "$PAKLST"
	sed -i '/\.prt/d' "$PAKLST"
	sed -i '/\.bak/d' "$PAKLST"

	# if it already exists, add it
	if [ -f "$OUTDIR/$PAKNAME" ]
	then
		zip -r -0 "$OUTDIR/$PAKNAME" -@ < "$PAKLST"
	else
		zip -0 "$OUTDIR/$PAKNAME" -@ < "$PAKLST"

		# embed copyright information
		if [ -f "$GAMEROOT/$GAMEDIR/$PK3DIR/PAK_COPYRIGHT" ]
		then
			zip -z "$OUTDIR/$PAKNAME" < "$GAMEROOT/$GAMEDIR/$PK3DIR/PAK_COPYRIGHT"
		else
			if [ -f "$GAMEROOT/$GAMEDIR/COPYRIGHT" ]
			then
				zip -z "$OUTDIR/$PAKNAME" < "$GAMEROOT/$GAMEDIR/COPYRIGHT"
			fi
		fi
	fi

	PAKNAME=""

	fi
done
