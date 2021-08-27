#!/bin/sh
. ./build.cfg

if ! [ -x "$(command -v svn)" ]; then
	printf "'svn' is not installed.\n"
	exit
fi

set -e

FTE_MAKEFILE=./src/engine/engine/Makefile
COMPILE_SYS=$(uname)

# Check how many cores/processors we should use for building
if ! [ -x "$(command -v nproc)" ]; then
	# check if we're on OpenBSD then
	if ! [ -x "$(command -v sysctl)" ]; then
		BUILD_PROC=1
	else
		BUILD_PROC=$(sysctl -n hw.ncpu)
	fi
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
	OUTPUT=$OUTPUT/fteqw-glsdl2
else
	if [[ "$COMPILE_SYS" == "CYGWIN_NT-10.0" ]] || [[ "$COMPILE_SYS" == "CYGWIN_NT-6.1-WOW64" ]]; then
		PLATFORM=win64
		OUTPUT=$OUTPUT/fteglqw64.exe
	elif [[ "$COMPILE_SYS" == "CYGWIN_NT-6.1" ]] || [[ "$COMPILE_SYS" == "CYGWIN_NT-5.1" ]]; then
		PLATFORM=win32
		OUTPUT=$OUTPUT/fteglqw32.exe
	elif [[ "$COMPILE_SYS" == "OpenBSD" ]]; then
		PLATFORM=bsd
		OUTPUT=$OUTPUT/fteqw-gl
	elif [[ "$COMPILE_SYS" == "FreeBSD" ]]; then
		PLATFORM=bsd
		OUTPUT=$OUTPUT/fteqw-gl
	elif [[ "$COMPILE_SYS" == "NetBSD" ]]; then
		PLATFORM=bsd
		OUTPUT=$OUTPUT/fteqw-gl
	elif [[ "$COMPILE_SYS" == "Linux" ]]; then
		PLATFORM=linux64
		OUTPUT=$OUTPUT/fteqw-gl64
	elif [[ "$COMPILE_SYS" == "GNU/Linux" ]]; then
		PLATFORM=linux64
		OUTPUT=$OUTPUT/fteqw-gl64
	else
		printf "Unsupported platform.\n"
		exit
	fi
fi

mkdir -p ./bin

if [ -f "$FTE_MAKEFILE" ]; then
	if [ "$BUILD_UPDATE" -eq 1 ]; then
		printf "Engine is present, updating...\n"
		cd ./src/engine/

		if [ "$BUILD_ENGINEREVISION" == 0 ]; then
			svn up
		else
			svn -r $BUILD_ENGINEREVISION up
		fi

		cd ./engine
	else
		cd ./src/engine/engine
	fi
else
	printf "Engine is NOT present, cloning...\n"
	cd ./src/

	if [ "$BUILD_ENGINEREVISION" == 0 ]; then
		svn checkout https://svn.code.sf.net/p/fteqw/code/trunk engine
	else
		svn -r $BUILD_ENGINEREVISION checkout https://svn.code.sf.net/p/fteqw/code/trunk engine
	fi
	cd ./engine/engine
fi

if [ "$BUILD_CLEAN" -eq 1 ]; then
	gmake clean
	printf "Cleaned the build directory.\n\n"
fi

if [ "$BUILD_ENGINE_DEPENDENCIES" -eq 1 ]; then
	gmake -j $BUILD_PROC makelibs FTE_TARGET=$PLATFORM
	printf "Built the static dependencies successfully.\n\n"
fi

gmake -j $BUILD_PROC $MAKETARGET FTE_TARGET=$PLATFORM
cp -v "$OUTPUT" ../../../bin/fteqw
printf "Built the client engine successfully.\n\n"

gmake -j $BUILD_PROC sv-dbg
cp -v ./debug/fteqw-sv ../../../bin/fteqw-sv
printf "Built the dedicated server successfully.\n\n"

gmake -j $BUILD_PROC qcc-rel
cp -v ./release/fteqcc ../../../bin/fteqcc
printf "Built the QuakeC compiler successfully.\n\n"

if [ "$BUILD_IMGTOOL" -eq 1 ]; then
	gmake -j $BUILD_PROC imgtool-rel
	cp -v ./release/imgtool ../../../bin/imgtool
	printf "Built the imgtool successfully.\n\n"
fi

if [ "$BUILD_BULLET" -eq 1 ]; then
	gmake -j $BUILD_PROC plugins-rel NATIVE_PLUGINS="bullet"
	find ./release/ -name 'fteplug_bullet_*.so' -exec cp -prv '{}' '../../../bin/' ';'
	printf "Built the bullet plugin successfully.\n\n"
fi

if [ "$BUILD_FFMPEG" -eq 1 ]; then
	gmake -j $BUILD_PROC plugins-rel NATIVE_PLUGINS="ffmpeg"
	find ./release/ -name 'fteplug_ffmpeg_*.so' -exec cp -prv '{}' '../../../bin/' ';'
	printf "Built the ffmpeg plugin successfully.\n\n"
fi

printf "DONE. Built ALL components successfully.\n"
