#!/bin/sh

ENT_OUTFILE="./entities.def"
rm "$ENT_OUTFILE"

find ./gs-entbase -type f \( -iname \*.cpp -o -iname \*.c \) | while read EDEF_N; do
	echo "Scanning for definitions inside $EDEF_N"
	sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$ENT_OUTFILE"
done;
find ./client -type f \( -iname \*.cpp -o -iname \*.c \) | while read EDEF_N; do
	echo "Scanning for definitions inside $EDEF_N"
	sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$ENT_OUTFILE"
done;

find ./server -type f \( -iname \*.cpp -o -iname \*.c \) | while read EDEF_N; do
	echo "Scanning for definitions inside $EDEF_N"
	sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$ENT_OUTFILE"
done;

