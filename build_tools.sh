#!/bin/sh
. ./build.cfg

if ! [ -x "$(command -v git)" ]
then
	printf "'git' is not installed.\n"
	exit
fi

set -e

VVM_MAKEFILE=./src/vvmtool/Makefile
COMPILE_SYS=$(uname)

# Check how many cores/processors we should use for building
if ! [ -x "$(command -v nproc)" ]
then
	# check if we're on OpenBSD then
	if ! [ -x "$(command -v sysctl)" ]
	then
		BUILD_PROC=1
	else
		BUILD_PROC=$(sysctl -n hw.ncpu)
	fi
else
	BUILD_PROC=$(nproc)
fi

# Compiler choice
if [ "$COMPILE_SYS" = "OpenBSD" ]
then
	ENGINE_CC=cc
	ENGINE_CXX=c++
else
	if [ "$BUILD_CLANG" = "1" ]; then
		ENGINE_CC=clang
		ENGINE_CXX=clang++
	else
		ENGINE_CC=gcc
		ENGINE_CXX=g++
	fi
fi

mkdir -p ./bin

if [ -f "$VVM_MAKEFILE" ]
then
	if [ "$BUILD_UPDATE" -eq 1 ]
	then
		printf "vvmtool is present, updating...\n"
		cd ./src/vvmtool
		git pull
	else
		cd ./src/vvmtool
	fi
else
	printf "vvmtool is NOT present, cloning...\n"
	cd ./src/
	git clone https://github.com/VeraVisions/vvmtool
	cd ./vvmtool
fi

if [ "$BUILD_CLEAN" -eq 1 ]
then
	gmake clean
fi

CC=$ENGINE_CC CXX=$ENGINE_CXX gmake -j $BUILD_PROC
printf "Built vvmtool successfully.\n"
cp -v vvmtool ../../bin/vvmtool
printf "DONE. Built ALL components successfully.\n"
