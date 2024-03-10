#!/bin/sh

# Converts .mat files in a gamedir
# to a bunch of .shader files.
# It also overwrites scripts/shaderlist.txt
# So don't mix environments!

ROOT_DIR="$(pwd)"
LEGACY_OUT="$ROOT_DIR/$1/scripts"
SHADERLIST="$ROOT_DIR/$1/scripts/shaderlist.txt"

mkdir -p "$LEGACY_OUT"

echo "Dumping all ..mat files into one..."

if [ -f "$SHADERLIST" ]
then
	rm "$SHADERLIST"
fi

# scan a dir inside textures/???/
scan_dir()
{
	SHADER_FILE="$LEGACY_OUT/$1.shader"
	cd "$1"
	MAT_COUNT=$(ls | grep \.mat | wc -l | tr -d '\n')

	echo "...$MAT_COUNT .mat files counted"

	if [ "$MAT_COUNT" -eq 0 ]
	then
		exit
	fi

	echo "// THIS FILE HAS BEEN AUTOMATICALLY GENERATED!" > "$SHADER_FILE"
	echo "// Please refer to the original documentation." >> "$SHADER_FILE"
	echo "// This shader is for development purposes ONLY." >> "$SHADER_FILE"
	echo "" >> "$SHADER_FILE"

	find * -type f -name '*.mat'| while read SHADER_N; do
		BASENAME=$(echo "$SHADER_N" | cut -d '.' -f 1)
		NAME="textures/$1/$BASENAME"

		echo "$NAME" >> "$SHADER_FILE"
		cat "$SHADER_N" >> "$SHADER_FILE"
		sed -i 's|$diffusemap|'"${NAME}".tga'|g' "$SHADER_FILE"
	done;


	#echo "Stripping GLSL parameters..."

	sed -i '/Vera Visions Material/d' "$SHADER_FILE"
	sed -i 's/.mat//g' "$SHADER_FILE"
	sed -i '/if $programs/','/else/d' "$SHADER_FILE"
	sed -i '/endif/d' "$SHADER_FILE"
	sed -i '/nodraw2/d' "$SHADER_FILE"
	sed -i '/program /d' "$SHADER_FILE"
	sed -i '/normalmap/d' "$SHADER_FILE"
	sed -i '/alphaGen portal/d' "$SHADER_FILE"
	sed -i '/deformVertexes autoSprite/d' "$SHADER_FILE"

	#echo "Replacing diffusemap calls with qer_editorimage..."
	sed -i 's/diffusemap /qer_editorimage /g' "$SHADER_FILE"

	#echo "Swapping DDS references with TARGA..."
	sed -i 's/.dds/.tga/g' "$SHADER_FILE"
	sed -i 's/$rt:base/textures\/dev\/rtsurface.tga/g' "$SHADER_FILE"
	sed -i 's/.shader//g' "$SHADER_FILE"

	echo "$1" >> "$SHADERLIST"
	echo "...written $SHADER_FILE"
}

# iterate over all 'categories' inside textures/
scan_textures()
{
	NEW_ROOT="$(pwd)/$1/textures"
	cd "$NEW_ROOT"

	ls | while read TEXTURE_DIR
	do
		cd "$NEW_ROOT"
		if [ -d "$TEXTURE_DIR" ]
		then
			echo "Texture dir: $TEXTURE_DIR ($1)"
			scan_dir "$TEXTURE_DIR" "$LEGACY_OUT"
		fi
	done
}

#mkdir -p "$(dirname "$LEGACY_OUT")"

# Start with any possible pk3dirs
find "$1" -type d -name '*.pk3dir'| while read PKDIR; do
	cd "$ROOT_DIR"

	if [ -d "$PKDIR/textures/" ]
	then
		scan_textures "$PKDIR"
	fi
done

cd "$ROOT_DIR"

# Then look into the loose dir
if [ -d "$1/textures" ]
then
	scan_textures "$1"
fi
