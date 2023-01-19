#!/bin/sh
. ./build.cfg
set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"

grab_mod()
{
	if [ -f "$SCRPATH/$1"/LICENSE ]; then
		cd "$SCRPATH/$1"

		if [ "$BUILD_UPDATE" -eq 1 ]; then
			git pull
		fi
	else
		cd "$SCRPATH"
		git clone "$2" "$1"
	fi

	cd "$SCRPATH"
}

grab_mod gearbox https://vcs.vera-visions.com/nuclide-ports/gearbox
grab_mod rewolf https://vcs.vera-visions.com/nuclide-ports/rewolf
grab_mod poke646 https://vcs.vera-visions.com/nuclide-ports/poke646
grab_mod tfc https://vcs.vera-visions.com/nuclide-ports/tfc
grab_mod scihunt https://vcs.vera-visions.com/nuclide-ports/scihunt
grab_mod hunger https://vcs.vera-visions.com/nuclide-ports/hunger
grab_mod valve https://vcs.vera-visions.com/nuclide-ports/valve
grab_mod cstrike https://vcs.vera-visions.com/nuclide-ports/cstrike
grab_mod ts https://vcs.vera-visions.com/nuclide-ports/ts
