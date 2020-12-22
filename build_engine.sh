#!/bin/sh
set -e

FTE_MAKEFILE=./src/engine/engine/Makefile
BUILD_SDL2=0

mkdir -p ./bin

if [ -f "$FTE_MAKEFILE" ]; then
	printf "Engine is present, updating...\n"
	cd ./src/engine/
	svn up
	cd ./engine
else
	printf "Engine is NOT present, cloning...\n"
	cd ./src/
	svn checkout https://svn.code.sf.net/p/fteqw/code/trunk engine
	cd ./engine/engine
fi

if [ "$BUILD_SDL2" -eq 1 ]; then
	make -j $(nproc) makelibs FTE_TARGET=SDL2
	make -j $(nproc) m-rel FTE_TARGET=SDL2
	cp -v ./release/fteqw-sdl2 ../../../bin/fteqw
else
	make -j $(nproc) makelibs
	make -j $(nproc) m-rel
	cp -v ./release/fteqw ../../../bin/fteqw
fi

make -j $(nproc) sv-rel
cp -v ./release/fteqw-sv ../../../bin/fteqw-sv
make -j $(nproc) qcc-rel
cp -v ./release/fteqcc ../../../bin/fteqcc
make -j $(nproc) iqm-rel
cp -v ./release/iqm ../../../bin/iqm
make -j $(nproc) imgtool-rel
cp -v ./release/imgtool ../../../bin/imgtool
make -j $(nproc) plugins-rel NATIVE_PLUGINS="bullet"
find ./release/ -name 'fteplug_bullet_*.so' -exec cp -prv '{}' '../../../bin/' ';'
make -j $(nproc) plugins-rel NATIVE_PLUGINS="ffmpeg"
find ./release/ -name 'fteplug_ffmpeg_*.so' -exec cp -prv '{}' '../../../bin/' ';'


