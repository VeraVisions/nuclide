#!/bin/sh

# make_shadertags.sh
# create a shadertags.xml file based on surfaceparms/keywords present in .mat
# files for use in Radiant
# (C) 2021 - Vera Visions L.L.C.

tags_for_mod()
{
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	echo "<root>"
	echo "<stock>"

	find ./$1/ -type f \( -iname \*.mat \) | while read EDEF_N; do
		# We want to cut out any pk3dirs in the name and filter out model textures
		MATPATH="textures/$(echo "$EDEF_N" | awk -F 'textures/' '{print $2}' | cut -f 1 -d '.')"

		# invalid path will simply be "textures/" which we shall ignore
		if [ "$MATPATH" != "textures/" ]; then
			SFPARM_ALIEN=$(grep 'alien' $EDEF_N)
			SFPARM_FLESH=$(grep 'flesh' $EDEF_N)
			SFPARM_FOLIAGE=$(grep 'foliage' $EDEF_N)
			SFPARM_COMPUTER=$(grep 'computer' $EDEF_N)
			SFPARM_DIRT=$(grep 'dirt' $EDEF_N)
			SFPARM_VENT=$(grep 'vent' $EDEF_N)
			SFPARM_GRATE=$(grep 'grate' $EDEF_N)
			SFPARM_METAL=$(grep 'metal' $EDEF_N)
			SFPARM_GLASS=$(grep 'glass' $EDEF_N)
			SFPARM_SAND=$(grep 'sand' $EDEF_N)
			SFPARM_SLOSH=$(grep 'slosh' $EDEF_N)
			SFPARM_SNOW=$(grep 'snow' $EDEF_N)
			SFPARM_TILE=$(grep 'tile' $EDEF_N)
			SFPARM_WOOD=$(grep 'wood' $EDEF_N)
			SFPARM_CONCRETE=$(grep 'concrete' $EDEF_N)

			echo "<shader path=\"$MATPATH\">"

			if [ "$SFPARM_ALIEN" != "" ]; then
				echo "<tag>Alien</tag>"
			fi
			if [ "$SFPARM_FLESH" != "" ]; then
				echo "<tag>Flesh</tag>"
			fi
			if [ "$SFPARM_FOLIAGE" != "" ]; then
				echo "<tag>Foliage</tag>"
			fi
			if [ "$SFPARM_COMPUTER" != "" ]; then
				echo "<tag>Computer</tag>"
			fi
			if [ "$SFPARM_DIRT" != "" ]; then
				echo "<tag>Dirt</tag>"
			fi
			if [ "$SFPARM_VENT" != "" ]; then
				echo "<tag>Vent</tag>"
			fi
			if [ "$SFPARM_GRATE" != "" ]; then
				echo "<tag>Grate</tag>"
			fi
			if [ "$SFPARM_METAL" != "" ]; then
				echo "<tag>Metal</tag>"
			fi
			if [ "$SFPARM_GLASS" != "" ]; then
				echo "<tag>Glass</tag>"
			fi
			if [ "$SFPARM_SAND" != "" ]; then
				echo "<tag>Sand</tag>"
			fi
			if [ "$SFPARM_SLOSH" != "" ]; then
				echo "<tag>Slosh</tag>"
			fi
			if [ "$SFPARM_SNOW" != "" ]; then
				echo "<tag>Snow</tag>"
			fi
			if [ "$SFPARM_TILE" != "" ]; then
				echo "<tag>Tile</tag>"
			fi
			if [ "$SFPARM_WOOD" != "" ]; then
				echo "<tag>Wood</tag>"
			fi
			if [ "$SFPARM_CONCRETE" != "" ]; then
				echo "<tag>Concrete</tag>"
			fi

			echo "</shader>"
		fi
	done;

	echo "</stock>"
	echo "<custom>"
	echo "</custom>"
	echo "</root>"
}

if [ $# -gt 0 ]; then
	tags_for_mod $1
else
	echo Usage: `basename $0` modname >&2
	exit 2
fi
