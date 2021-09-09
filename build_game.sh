#!/bin/sh
. ./build.cfg

if [ "$SKIP_UPDATE" == "1" ]; then
	BUILD_UPDATE=0
fi

# if we're attempting to update the projects, check for git
if [ "$BUILD_UPDATE" -eq 1 ]; then
	if ! [ -x "$(command -v git)" ]; then
		printf "'git' is not installed.\n"
		exit
	fi
fi

set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
PATH="$SCRPATH"/bin:"$PATH"

if [ -f "$SCRPATH"/bin/fteqcc ]; then

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
		./make_mapdef.sh "$1"
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
				set +e
				git pull
				set -e
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
		if [ -f "$SCRPATH"/bin/worldspawn ]; then
			./make_mapdef.sh $GAMEDIR
		fi
	done;
else
	printf "FTEQCC compiler is not present, please run build_engine.sh\n"
fi
