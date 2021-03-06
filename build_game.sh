#!/bin/sh
set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
PATH="$SCRPATH"/bin:"$PATH"

if [ -f "$SCRPATH"/bin/fteqcc ]; then
	export OLDDIR=$(pwd)
	cd ./src
	make
	cd "$OLDDIR"

	find "$SCRPATH" -name Makefile | grep 'src\/Makefile' | grep -v engine | while read MFILE_N; do
		cd $(dirname $MFILE_N)
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
