#!/bin/sh

if [ $# -lt 0 ]; then
	printf "At least supply the name of the mod/game dir you want to pack.\n"
	exit
fi

GAME_DIR="$1"
BUILD_DIR=$1-$(date +%m-%d-%Y)
OLD_DIR=$(pwd)

if [ -f "$GAME_DIR"/src/Makefile ]; then
	mkdir -p "$BUILD_DIR/$GAME_DIR"
	mkdir -p "$BUILD_DIR/platform"
	cd $GAME_DIR/src
	make
else
	printf "Not a valid game to bundle.\n"
	exit
fi

cd "$OLD_DIR"

# build the pk3s
find ./$GAME_DIR -name *.pk3dir | xargs -I @ sh -c 'echo `basename "@"`' | while read PK3DIR; do
	# strip the .pk3dir from the folder name to get the final .pk3 basename
	PK3NAME=$(echo $PK3DIR | cut -f 1 -d '.')

	# go into the pk3dir and compile your zip
	cd "./$GAME_DIR/$PK3DIR"
	tree -fi > ./build_contents.txt
	sed -i '/build_contents/d' ./build_contents.txt
	sed -i '/directories,/d' ./build_contents.txt
	zip -0 "$PK3NAME".pk3 -@ < ./build_contents.txt
	rm ./build_contents.txt

	# Go back and move it over into the build directory
	cd "$OLD_DIR"
	mv "./$GAME_DIR/$PK3DIR/$PK3NAME.pk3" "./$BUILD_DIR/$GAME_DIR/$PK3NAME.pk3"
done;
cp "./$GAME_DIR/progs.dat" "./$BUILD_DIR/$GAME_DIR/progs.dat"
cp "./$GAME_DIR/csprogs.dat" "./$BUILD_DIR/$GAME_DIR/csprogs.dat"
cp "./$GAME_DIR/menu.dat" "./$BUILD_DIR/$GAME_DIR/menu.dat"

if [ "$EXCLUDE_PLATFORM" ]; then
	cp ./$GAME_DIR.fmf ./$BUILD_DIR/$GAME_DIR.fmf
else
	find 'platform' -name '*.pk3dir' | xargs -I @ sh -c 'echo `basename "@"`' | while read PK3DIR; do
		# strip the .pk3dir from the folder name to get the final .pk3 basename
		PK3NAME=$(echo $PK3DIR | cut -f 1 -d '.')

		# go into the pk3dir and compile your zip
		cd "./platform/$PK3DIR"
		tree -fi > ./build_contents.txt
		sed -i '/build_contents/d' ./build_contents.txt
		sed -i '/directories,/d' ./build_contents.txt
		zip -0 "$PK3NAME".pk3 -@ < ./build_contents.txt
		rm ./build_contents.txt

		# Go back and move it over into the build directory
		cd "$OLD_DIR"
		mv "./platform/$PK3DIR/$PK3NAME.pk3" "./$BUILD_DIR/platform/$PK3NAME.pk3"
	done;
	cp "./platform/platform_default.cfg" "./$BUILD_DIR/platform/platform_default.cfg"
	cp "./platform/readme.txt" "./$BUILD_DIR/platform/readme.txt"
	cp "./platform/menu.dat" "./$BUILD_DIR/platform/menu.dat"
	rm "./$BUILD_DIR/platform/test_maps.pk3"

	# copy platform
	#cp -R ./platform ./$BUILD_DIR/platform
	#cp -R ./doc ./$BUILD_DIR/doc
	echo "version 2" > ./$BUILD_DIR/installed.lst
	echo "set updatemode \"1\"" >> ./$BUILD_DIR/installed.lst
	echo "set declined \"\"" >> ./$BUILD_DIR/installed.lst
	echo "sublist \"http://www.frag-net.com/dl/valve_packages\" \"\" \"enabled\"" >> ./$BUILD_DIR/installed.lst

	# spray logos
	mkdir -p ./$BUILD_DIR/logos
	cp ./logos/README ./$BUILD_DIR/logos/README
	cp ./logos/fte.png ./$BUILD_DIR/logos/fte.png
	cp ./default.fmf ./$BUILD_DIR/default.fmf
	sed -i "s|base|$GAME_DIR|g" ./$BUILD_DIR/default.fmf
	cp ./doc/release-readme ./$BUILD_DIR/README.txt
fi

tree ./$BUILD_DIR
printf "ENTER to continue\n"
read cont
zip -9 -r "$BUILD_DIR".zip "./$BUILD_DIR"
gpg --output "./$BUILD_DIR.sig" --detach-sig "./$BUILD_DIR.zip"
