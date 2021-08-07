#!/bin/sh
. ./build.cfg
set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
PATH="$SCRPATH"/bin:"$PATH"

if [ -f "$SCRPATH"/bin/fteqcc ]; then

	# We want to compile a specific game
	if [ $# -gt 0 ]; then
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
	make
	cd "$OLDDIR"

	if [ "$BUILD_UPDATE" -eq 1 ]; then
		# git pull on the main repo
		git pull
	fi

	find "$SCRPATH" -name Makefile | grep 'src\/Makefile' | grep -v engine | grep -v worldspawn | while read MFILE_N; do
		cd $(dirname $MFILE_N)
		git pull
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
