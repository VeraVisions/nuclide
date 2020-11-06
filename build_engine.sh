#!/bin/sh
set -e

FTE_MAKEFILE=./src/engine/engine/Makefile

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

make -j $(nproc) makelibs FTE_TARGET=SDL2
make -j $(nproc) m-rel FTE_TARGET=SDL2
cp -v ./release/fteqw-sdl2 ../../../bin/fteqw
make -j $(nproc) qcc-rel
cp -v ./release/fteqcc ../../../bin/fteqcc

