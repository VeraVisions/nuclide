#!/bin/sh
set -e
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"

grab_mod()
{
	if [ -f "$SCRPATH/$1"/LICENSE ]; then
		cd "$SCRPATH/$1"
		git pull
	else
		cd "$SCRPATH"
		git clone "$2" "$1"
	fi

	cd "$SCRPATH"
}

grab_mod gearbox https://www.github.com/eukara/freegearbox
grab_mod rewolf https://www.github.com/eukara/freegunman
grab_mod poke646 https://www.github.com/eukara/freepoke646
grab_mod tfc https://www.github.com/eukara/freetfc
grab_mod scihunt https://www.github.com/eukara/freesci
grab_mod hunger https://www.github.com/eukara/freehunger
grab_mod valve https://www.github.com/eukara/freehl
grab_mod cstrike https://www.github.com/eukara/freecs
