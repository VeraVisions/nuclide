#!/bin/sh

# ensure we use the tools provided in root
export PATH="$(pwd):$PATH"
CWD="$(pwd)"

# texture wads
build_wads()
{
	if [ ! -d "$CWD/$1/texturesrc/" ]
	then
		exit 0
	fi
	
	echo "building texturesrc/*.wad"

	cd "$CWD/$1/texturesrc/"

	# will make a .wad out of every sub directory.
	find ./ -type d -maxdepth 1 | while read WADDIR
	do
		DIRNAME=$(basename "$WADDIR")

		if [ ! "$DIRNAME" = "." ]
		then
			printf "WAD3 building %s:\n" "$DIRNAME"
			imgtool --genwad3 ../"$DIRNAME".wad ./"$DIRNAME"
		fi
	done
}

build_wads $1
