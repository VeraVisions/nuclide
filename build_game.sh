#!/bin/sh
set -e
SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH="$SCRIPT_LOCATION"/bin:"$PATH"

if [ -f "$SCRIPT_LOCATION"/bin/fteqcc ]; then
	cd ./src
	make
else
	printf "FTEQCC compiler is not present, please run build_engine.sh\n"
fi
