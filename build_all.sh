#!/bin/sh
source ./build.cfg
./build_engine.sh
./get_gamepacks.sh
./build_game.sh
./build_editor.sh
