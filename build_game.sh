#!/bin/sh
set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
PATH="$SCRPATH"/bin:"$PATH"

if [ -f "$SCRPATH"/bin/fteqcc ]; then
	cd ./src
	make
else
	printf "FTEQCC compiler is not present, please run build_engine.sh\n"
fi
