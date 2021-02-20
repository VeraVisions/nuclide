#!/bin/sh
set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
PATH="$SCRPATH"/bin:"$PATH"

if [ -f "$SCRPATH"/bin/fteqcc ]; then
	export OLDDIR=$(pwd)
	find -name Makefile | grep 'src\/Makefile' | grep -v engine | while read MFILE_N; do
		cd $(dirname $MFILE_N)
		make
		cd $OLDDIR
	done;
else
	printf "FTEQCC compiler is not present, please run build_engine.sh\n"
fi
