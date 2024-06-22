#!/bin/sh

if ! [ -x "$(command -v zip)" ]; then
	printf "'zip' is not installed.\n"
	exit
fi
if ! [ -x "$(command -v tree)" ]; then
	printf "'tree' is not installed.\n"
	exit
fi

if [ $# -lt 0 ]; then
	printf "At least supply the name of the mod/game dir you want to pack.\n"
	exit
fi

GAME_DIR="$1"
BUILD_DIR="release-$GAME_DIR"
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

# copy plain text files included within the game-dir
find ./$GAME_DIR -name '*.txt' | xargs -I @ sh -c 'echo `basename "@"`' | while read TEXTNAME; do
	cp "./$GAME_DIR/$TEXTNAME" "./$BUILD_DIR/$GAME_DIR/$TEXTNAME"
done;

# copy over the shell scripts inside the game-dir
find ./$GAME_DIR -name 'install_*.sh' | xargs -I @ sh -c 'echo `basename "@"`' | while read SCRIPTNAME; do
	cp "./$GAME_DIR/$SCRIPTNAME" "./$BUILD_DIR/$GAME_DIR/$SCRIPTNAME"
done;

cp "./$GAME_DIR/progs.dat" "./$BUILD_DIR/$GAME_DIR/progs.dat"
cp "./$GAME_DIR/csprogs.dat" "./$BUILD_DIR/$GAME_DIR/csprogs.dat"
cp "./$GAME_DIR/menu.dat" "./$BUILD_DIR/$GAME_DIR/menu.dat"
cp -R "./$GAME_DIR/src/." "./$BUILD_DIR/$GAME_DIR/src"

if [ "$EXCLUDE_PLATFORM" ]; then
	echo "excluding platform"
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
	cp -R "./src/." "./$BUILD_DIR/src"
	rm "./$BUILD_DIR/platform/test_maps.pk3"

	# copy readme over
	if [ -f "./$GAME_DIR/readme.txt" ]; then
		cp "./$GAME_DIR/readme.txt" ./$BUILD_DIR/README.txt
	else
		cp ./Documentation/release-readme.txt ./$BUILD_DIR/README.txt
	fi

	# put the entire platform directory in a central pak
	cd "./$BUILD_DIR/platform"
	zip -9 -r "../$GAME_DIR/platform.pk3" "./"
	cd "$OLD_DIR"
	rm -r "./$BUILD_DIR/platform"
fi

cd "$OLD_DIR"
tree ./$BUILD_DIR

if [ "$BUILD_AUTO" ]
then
	printf "DONE, press ENTER to create .zip with gpg signature (or CTRL+C to cancel)\n"
	read cont
fi

cd "$BUILD_DIR"
zip -9 -r "../$BUILD_DIR".zip "./"

if ! [ -x "$(command -v gpg)" ]; then
	printf "'gpg' is not installed.\n"
	exit
fi
