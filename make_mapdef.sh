#!/bin/sh

ent_for_mod()
{
    mkdir -p ./bin/$1.game/$1/
    ENT_OUTFILE="./bin/$1.game/$1/entities.def"
    rm "$ENT_OUTFILE"

    find ./$1/src/ -type f \( -iname \*.cpp -o -iname \*.c \) | while read EDEF_N; do
        echo "Scanning for definitions inside $EDEF_N"
        sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$ENT_OUTFILE"
    done;
}

BASE_ENT=./bin/platform.game/platform/entities_base.def
rm "$BASE_ENT"

find ./src/gs-entbase/ -type f \( -iname \*.cpp -o -iname \*.c \) | while read EDEF_N; do
    echo "Scanning for definitions inside $EDEF_N"
    sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$BASE_ENT"
done;

ent_for_mod $1
