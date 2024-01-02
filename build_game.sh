#!/bin/sh
. ./build.cfg

safe_copy()
{
	if [ -f "$1" ]
	then
		cp -v "$1" "$2"
	fi
}

radiant_build()
{
	./make_mapdef.sh "$1"

	# copy files over to RADIANT
	if [ ! -z "$RADIANT_PATH" ]
	then
		if [ -d "$RADIANT_PATH/gamepacks/games" ];
		then
			mkdir -p "$RADIANT_PATH/gamepacks/$1.game/$1/"
			safe_copy "./$1/radiant.game" "$RADIANT_PATH/gamepacks/games/$1.game"
			safe_copy "./$1/entities.def" "$RADIANT_PATH/gamepacks/$1.game/$1/entities.def"
			safe_copy "./$1/radiant.xml" "$RADIANT_PATH/gamepacks/$1.game/default_build_menu.xml"
		fi
	fi
}

if [ "$SKIP_UPDATE" = "1" ]; then
	BUILD_UPDATE=0
fi

# if we're attempting to update the projects, check for git
if [ "$BUILD_UPDATE" -eq 1 ]; then
	if ! [ -x "$(command -v git)" ]; then
		printf "'git' is not installed.\n"
		exit 1
	fi
fi

set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
PATH="$SCRPATH/bin:$PATH"

if [ -x "$(command -v fteqcc)" ]; then
	# We want to compile a specific game
	if [ $# -gt 0 ]; then
		if [ "$BUILD_UPDATE" -eq 1 ]; then
			# git pull on the main repo
			git pull
		fi

		cd "$SCRPATH/$1"/src

		if [ "$BUILD_UPDATE" -eq 1 ]; then
			# git pull on the main repo
			git pull
		fi

		make
		cd "$SCRPATH"
		radiant_build "$1"
		exit 0
	fi

	export OLDDIR=$(pwd)
	cd ./src

	if [ "$BUILD_UPDATE" -eq 1 ]; then
		# git pull on the main repo
		git pull
	fi

	make
	cd "$OLDDIR"

	# update repos first in case there's dependencies 
	find "$SCRPATH" -name Makefile | grep 'src\/Makefile' | grep -v engine | grep -v worldspawn | while read MFILE_N; do
		NEWDIR=$(dirname "$MFILE_N")
		cd "$NEWDIR"
		if [ -f "$NEWDIR/../.git/config" ]; then
			printf "Updating git repo inside $NEWDIR\n"
			if [ "$BUILD_UPDATE" -eq 1 ]; then
				git pull
			fi
		fi
		cd $OLDDIR
	done;

	# now loop through _again_ to build
	find "$SCRPATH" -name Makefile | grep 'src\/Makefile' | grep -v engine | grep -v worldspawn | while read MFILE_N; do
		NEWDIR=$(dirname "$MFILE_N")
		cd "$NEWDIR"
		make
		cd ..
		export GAMEDIR=$(basename $PWD)
		cd $OLDDIR
		radiant_build "$GAMEDIR"
	done;
else
	printf "FTEQCC compiler is not present, please run build_engine.sh\n"
fi