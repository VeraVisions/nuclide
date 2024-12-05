/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/* early maptweaks implementation (RFC)

	design notes:

	needed system that handles entity renaming
	or edits in an easy to understand syntax

	replaces .ent file overrides for a lot of tasks
	and can apply rules on all relevant maps based on
	custom filters, either via serverinfo or via cvar.

	TODO: immediately throw out things where cvar/infokey
	checks fail and don't even cache them.
*/

static mapTweak_t *g_mapTweakTable;
static int g_mapTweakCount;
const string g_maptweakFile = "scripts/maptweaks.txt";

void
MapTweaks_Init(void)
{
	filestream tweakFile;
	string tempString;
	string newCvar, newInfo, newItem, newName;
	int atTweak = 0i;

	InitStart();

	tweakFile = fopen(g_maptweakFile, FILE_READ);
	g_mapTweakCount = 0;
	tempString = newCvar = newInfo = newItem = newName = "";

	/* count valid entries. */
	if (tweakFile >= 0) {
		while ((tempString = fgets(tweakFile))) {
			if (tokenize_console(tempString) == 1) {
				if (argv(0) == "}")
					g_mapTweakCount += 1;
			}
		}
	} else {
		NSWarning("No map tweaks, missing %S", g_maptweakFile);
		InitEnd();
		return;
	}

	g_mapTweakTable = memalloc(sizeof(mapTweak_t) * g_mapTweakCount);
	fseek(tweakFile, 0);

	while ((tempString = fgets(tweakFile))) {
		int segments = tokenize_console(tempString);
		if (segments == 1) {
			if (argv(0) == "}") {
				g_mapTweakTable[atTweak].name = newName;
				g_mapTweakTable[atTweak].cvarCheck = newCvar;
				g_mapTweakTable[atTweak].serverinfoCheck = newInfo;
				g_mapTweakTable[atTweak].itemTable = newItem;
				newName = newCvar = newInfo = newItem = "";
				atTweak++;
			} else if (argv(0) == "{") {
				/* ??? */
			} else {
				newName = argv(0);
			}
		} else if (segments == 4) {
			switch (argv(0)) {
			case "when-cvar":
				newCvar = strcat(newCvar, argv(1), " ", argv(2), " ", argv(3), " ");
				break;
			case "when-serverinfo":
				newInfo = strcat(newInfo, argv(1), " ", argv(2), " ", argv(3), " ");
				break;
			}
		} else if (segments == 3) {
			switch (argv(0)) {
			case "replace":
				newItem = strcat(newItem, argv(1), " ", argv(2), " ");
				break;
			}
		}
	}

	fclose(tweakFile);
	InitEnd();
}

static bool
MapTweak_Check(int num)
{
	int segments = tokenize(g_mapTweakTable[num].cvarCheck);

	/* cvars first */
	for (int i = 0; i < segments; i += 3) {
		string cvarName = argv(i);
		string checkType = argv(i + 1);
		float cvarValue = stof(argv(i + 2));

		switch (checkType) {
		case "equals":
			if not (cvar(cvarName) == cvarValue)
				return (false);
			break;
		case "less-than":
			if not (cvar(cvarName) < cvarValue)
				return (false);
			break;
		case "greater-than":
			if not (cvar(cvarName) > cvarValue)
				return (false);
			break;
		case "is-not":
			if not (cvar(cvarName) != cvarValue)
				return (false);
			break;
		}
	}

	segments = tokenize(g_mapTweakTable[num].serverinfoCheck);

	/* infokeys second */
	for (int i = 0; i < segments; i += 3) {
		string infoName = argv(i);
		string checkType = argv(i + 1);
		float infoValue = stof(argv(i + 2));

		switch (checkType) {
		case "equals":
			if not (serverkeyfloat(infoName) == infoValue)
				return (false);
			break;
		case "less-than":
			if not (serverkeyfloat(infoName) < infoValue)
				return (false);
			break;
		case "greater-than":
			if not (serverkeyfloat(infoName) > infoValue)
				return (false);
			break;
		case "is-not":
			if not (serverkeyfloat(infoName) != infoValue)
				return (false);
			break;
		}
	}

	return (true);
}

static bool
MapTweak_FinishSpawn(entity targetEntity, string newClassname)
{
	/* found the edef alternative. */
	if (EntityDef_SwitchClass((ncEntity)targetEntity, newClassname) != __NULL__) {
		return (true);
	}

	return (false);
}

bool
MapTweak_EntitySpawn(entity targetEntity)
{
	string classCheck = targetEntity.classname;

	if (g_mapTweakCount <= 0) {
		return (false);
	}

	for (int i = 0; i < g_mapTweakCount; i++) {
		for (int y = 0; y < tokenize(g_mapTweakTable[i].itemTable); y += 2) {
			string newEnt, oldEnt;

			oldEnt = argv(y);
			newEnt = argv(y + 1);

			if (classCheck == oldEnt) {
				if (MapTweak_Check(i) == true) {
					return MapTweak_FinishSpawn(targetEntity, newEnt);
				} else {
					break;
				}
			}
		}
	}

	return (false);
}

void
MapTweak_ListActive(void)
{
	for (int i = 0; i < g_mapTweakCount; i++) {
		if (MapTweak_Check(i) == true) {
			printf("%i %S:\n", i, g_mapTweakTable[i].name);

			for (int y = 0; y < tokenize(g_mapTweakTable[i].itemTable); y += 2) {
				string newEnt, oldEnt;

				oldEnt = argv(y);
				newEnt = argv(y + 1);

				printf("\t%s > %s\n", oldEnt, newEnt);
			}
		}
	}
}
