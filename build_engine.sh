#!/bin/sh
set -e

FTE_MAKEFILE=./src/engine/engine/Makefile
BUILD_SDL2=0
BUILD_DEBUG=1
COMPILE_SYS=$(uname)
PLUGINS="bullet"

# Check how many cores/processors we should use for building
if ! [ -x "$(command -v nproc)" ]; then
	# nproc doesn't exist, so make a safe assumption of having at least 1
	BUILD_PROC=1
else
	BUILD_PROC=$(nproc)
fi

if [ "$BUILD_DEBUG" -eq 1 ]; then
	MAKETARGET=gl-dbg
	OUTPUT=./debug
else
	MAKETARGET=gl-rel
	OUTPUT=./release
fi

if [ "$BUILD_SDL2" -eq 1 ]; then
	PLATFORM=SDL2
	OUTPUT=$OUTPUT/fteqw64-sdl2
else
	if [[ "$COMPILE_SYS" == "Cygwin" ]]; then
		PLATFORM=win64
		OUTPUT=$OUTPUT/fteglqw64.exe
	elif [[ "$COMPILE_SYS" == "OpenBSD" ]]; then
		PLATFORM=bsd
		OUTPUT=$OUTPUT/fteqw-gl
		PLUGINS=""
	elif [[ "$COMPILE_SYS" == "FreeBSD" ]]; then
		PLATFORM=bsd
		OUTPUT=$OUTPUT/fteqw-gl
	elif [[ "$COMPILE_SYS" == "NetBSD" ]]; then
		PLATFORM=bsd
		OUTPUT=$OUTPUT/fteqw-gl
	elif [[ "$COMPILE_SYS" == "Linux" ]]; then
		PLATFORM=linux64
		OUTPUT=$OUTPUT/fteqw-gl64
	else
		printf "Unsupported platform.\n"
		exit
	fi
fi

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

gmake -j $BUILD_PROC makelibs NATIVE_PLUGINS=$PLUGINS FTE_TARGET=$PLATFORM
gmake -j $BUILD_PROC $MAKETARGET FTE_TARGET=$PLATFORM
cp -v "$OUTPUT" ../../../bin/fteqw

gmake -j $BUILD_PROC sv-dbg
cp -v ./debug/fteqw-sv ../../../bin/fteqw-sv
gmake -j $BUILD_PROC qcc-rel
cp -v ./release/fteqcc ../../../bin/fteqcc
gmake -j $BUILD_PROC iqm-rel
cp -v ./release/iqm ../../../bin/iqm
gmake -j $BUILD_PROC imgtool-rel
cp -v ./release/imgtool ../../../bin/imgtool
gmake -j $BUILD_PROC plugins-rel NATIVE_PLUGINS="bullet"
find ./release/ -name 'fteplug_bullet_*.so' -exec cp -prv '{}' '../../../bin/' ';'
gmake -j $BUILD_PROC plugins-rel NATIVE_PLUGINS="ffmpeg"
find ./release/ -name 'fteplug_ffmpeg_*.so' -exec cp -prv '{}' '../../../bin/' ';'


