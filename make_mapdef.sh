#!/bin/sh

ent_for_mod()
{
    mkdir -p ./bin/platform.game/$1/
    ENT_OUTFILE="./bin/platform.game/$1/entities.def"
    rm "$ENT_OUTFILE"

    find ./$1/src/ -type f \( -iname \*.qc \) | while read EDEF_N; do
        echo "Scanning for definitions inside $EDEF_N"
        sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$ENT_OUTFILE"
    done;
    
    cat ./bin/platform.game/platform/entities.def >> $ENT_OUTFILE
}

BASE_ENT=./bin/platform.game/platform/entities.def
rm "$BASE_ENT"

find ./src/gs-entbase/ -type f \( -iname \*.qc \) | while read EDEF_N; do
    echo "Scanning for definitions inside $EDEF_N"
    sed -n '/\/*QUAKED/,/*\//p' $EDEF_N >> "$BASE_ENT"
done;

ent_for_mod $1
