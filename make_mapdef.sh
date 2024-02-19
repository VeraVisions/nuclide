#!/bin/sh

# takes one argument: path to .def file
ed_for_def()
{
printf -- "" > "/tmp/def_name"
printf -- "1 0 1" > "/tmp/def_color"
printf -- "" > "/tmp/def_mins"
printf -- "" > "/tmp/def_mins"
printf -- "" > "/tmp/def_maxs"
printf -- "" > "/tmp/def_usage"
printf -- "" > "/tmp/def_model"

{ cat "$1"; echo; } | while read LINE
do
	SEG1=$(echo "$LINE" | awk '{ print $1 }')
	SEG2=$(echo "$LINE" | awk '{ print $2 }')
	KEY="$(echo "$LINE" | awk -F"\"" '{ print $2 }')"
	VAL="$(echo "$LINE" | awk -F"\"" '{ print $4 }')"

	if [ "$KEY" = "entityDef" ]
	then
		printf -- "$VAL" > "/tmp/def_name"
	fi
	
	if [ "$SEG1" = "entityDef" ]
	then
		printf -- "$SEG2" > "/tmp/def_name"
	fi

	if [ "$KEY" = "editor_color" ]
	then
		printf -- "$VAL" > "/tmp/def_color"
	fi

	if [ "$KEY" = "editor_mins" ]
	then
		printf -- "$VAL" > "/tmp/def_mins"
	fi

	if [ "$KEY" = "editor_maxs" ]
	then
		printf -- "$VAL" > "/tmp/def_maxs"
	fi

	if [ "$KEY" = "mins" ]
	then
		if [ -z "$(cat /tmp/def_mins)" ]
		then
			printf -- "$VAL" > "/tmp/def_mins"
		fi
	fi

	if [ "$KEY" = "maxs" ]
	then
		if [ -z "$(cat /tmp/def_maxs)" ]
		then
			printf -- "$VAL" > "/tmp/def_maxs"
		fi
	fi

	if [ "$KEY" = "editor_usage" ]
	then
		printf -- "$VAL" > "/tmp/def_usage"
	fi

	if [ "$KEY" = "netname" ]
	then
		if [ -z "$(cat /tmp/def_usage)" ]
		then
			printf -- "$VAL" > "/tmp/def_usage"
		fi
	fi

	if [ "$KEY" = "editor_model" ]
	then
		printf -- "$VAL" > "/tmp/def_model"
	fi

	if [ "$KEY" = "model" ]
	then
		if [ -z "$(cat /tmp/def_model)" ]
		then
			printf -- "$VAL" > "/tmp/def_model"
		fi
	fi

	if [ "$SEG1" = "}" ]
	then
		KEY_NAME="$(cat /tmp/def_name)"
		KEY_COLOR="$(cat /tmp/def_color)"
		KEY_MINS="$(cat /tmp/def_mins)"
		KEY_MAXS="$(cat /tmp/def_maxs)"
		KEY_USAGE="$(cat /tmp/def_usage)"
		KEY_MODEL="$(cat /tmp/def_model)"
		printf -- "" > "/tmp/def_name"
		printf -- "" > "/tmp/def_color"
		printf -- "" > "/tmp/def_mins"
		printf -- "" > "/tmp/def_mins"
		printf -- "" > "/tmp/def_maxs"
		printf -- "" > "/tmp/def_usage"
		printf -- "" > "/tmp/def_model"

		if [ -z "$KEY_NAME" ]
		then
			exit 0
		fi

		if [ -z "$KEY_COLOR" ]
		then
			exit 0
		fi

		# no mins/maxs
		if [ -z "$KEY_MINS" ]
		then
			printf "/*QUAKED $KEY_NAME ($KEY_COLOR) ?\n"
		else
			printf "/*QUAKED $KEY_NAME ($KEY_COLOR) ($KEY_MINS) ($KEY_MAXS)\n"
		fi

		printf "$KEY_USAGE\n"

		# no model
		if [ ! -z "$KEY_MODEL" ]
		then
			printf -- "-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------\n"
			printf "model=\"$KEY_MODEL\"\n"
		fi

		printf "*/\n"
	fi
done
}

ent_for_mod()
{
	# don't bother if we don't have sources
	if ! [ -f "./$1/src/Makefile" ]; then
		exit
	fi

	ENT_OUTFILE="./$1/entities.def"
	echo '' > "$ENT_OUTFILE"

	echo "Scanning for definitions inside the game directory."
	find ./$1/src/ -type f \( -iname \*.qc \) | while read EDEF_N; do
		echo "... $EDEF_N"
		sed -n '/\/*!QUAKED/,/*\//p' $EDEF_N >> "$ENT_OUTFILE"
		# fix doxygen markup
		sed -i 's/*!QUAKED/*QUAKED/g' "$ENT_OUTFILE"
	done;
	find ./$1/ -type f \( -iname \*.def \) | while read EDEF_N; do
		ed_for_def "$EDEF_N" >> "$ENT_OUTFILE"
	done;

	cat ./platform/entities.def >> $ENT_OUTFILE
}

# first dump all the general purpose entities
BASE_ENT="./platform/entities.def"
echo '' > "$BASE_ENT"

echo "Scanning for definitions inside the general entity codebase."
find ./src/gs-entbase/ -type f \( -iname \*.qc \) | while read EDEF_N; do
	echo "... $EDEF_N"
	sed -n '/\/*!QUAKED/,/*\//p' $EDEF_N >> "$BASE_ENT"
	# fix doxygen markup
	sed -i 's/*!QUAKED/*QUAKED/g' "$BASE_ENT"
done;

# each game gets its own ents + general purpose ents appended at the end
if [ $# -gt 0 ]; then
	ent_for_mod $1
fi
