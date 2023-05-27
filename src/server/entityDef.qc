/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/* entityDef implementation

	these definitions are a further abstraction from how we view
	entity definitions. this system tries to be mostly compatible
	with the def system in id Tech 4 (Doom 3, Quake 4, Prey, etc.)

	however, we are not aiming for full compatibility right now as
	that will require further abstraction.

	that said, the origin of this idea dates way back to when
	Team Fortress Software created MapC for Team Fortress 2 when
	it was originally on Quake II's engine.

	http://www.teamfortress.com/tfii/mc2mapc.html (go to the wayback machine for this)

	the gist is, that an entity def can set a base spawnclass (e.g. func_door)
	and populate it with key/value pairs. the amount of code the programmers
	has to implement is massively reduced and we can create prefabs much easier
	as a result.

	overview:

	entityDef func_illusionary {
		"spawnclass" "func_wall"
		"solid" "0"
		"movetype"
		"0"
	}
*/

/* games can feel free to set this to whatever you need. */
#ifndef ENTITYDEF_MAX
#define ENTITYDEF_MAX 128
#endif

typedef struct
{
	string entClass;
	string spawnClass;
	string spawnData;
	string inheritKeys;
} entityDef_t;

entityDef_t g_entDefTable[ENTITYDEF_MAX];
var int g_entDefCount;

void
EntityDef_ReadFile(string filePath)
{
	filestream defFile;
	string tempString = "";
	entityDef_t currentDef;
	int braceDepth = 0i;
	string lastWord = __NULL__;

	currentDef.entClass = "";
	currentDef.spawnClass = "";
	currentDef.spawnData = "";
	currentDef.inheritKeys = "";

	/* bounds check */
	if (g_entDefCount >= ENTITYDEF_MAX) {
		error(sprintf("EntityDef_ReadFile: reached limit of %d defs\n", ENTITYDEF_MAX));
	}

	/* open file */
	defFile = fopen(filePath, FILE_READ);
	if (defFile < 0) {
		error(sprintf("EntityDef_ReadFile: unable to read %S\n", filePath));
	}

	/* line by line */
	while ((tempString = fgets(defFile))) {
		int lineSegments = tokenize_console(tempString);

		/* word for word */
		for (int i = 0i; i < lineSegments; i++) {
			string word = argv(i);

			switch (word) {
			case "{":
				braceDepth++;
				break;
			case "}":
				braceDepth--;

				/* we've reached the end of a definition */
				if (braceDepth == 0) {
					/* we have something somewhat valid I guess */
					if (currentDef.entClass != "" /*&& currentDef.spawnClass != ""*/) {
						g_entDefTable[g_entDefCount].entClass = currentDef.entClass;
						g_entDefTable[g_entDefCount].spawnClass = currentDef.spawnClass;
						g_entDefTable[g_entDefCount].spawnData = currentDef.spawnData;
						g_entDefTable[g_entDefCount].inheritKeys = currentDef.inheritKeys;

						/* increment the def count */
						if (g_entDefCount < ENTITYDEF_MAX)
							g_entDefCount++;
					}
					currentDef.entClass = "";
					currentDef.spawnClass = "";
					currentDef.spawnData = "";
					currentDef.inheritKeys = "";
				}
				break;
			default:
				/* anything outside braces defines the classname for the next def */
				if (braceDepth == 0 && lastWord == "entityDef") {
					currentDef.entClass = word;
				} else if (braceDepth == 1) {
					/* spawnclass is reserved and the next keyword specs it */
					if (word == "spawnclass") {
						currentDef.spawnClass = argv(i+1);
						i++;
					} else if (word == "inherit") {
						currentDef.inheritKeys = argv(i+1);
						i++;
					} else if (substring(word, 0, 7) == "editor_") {
						/* do nothing */
						i++;
					} else { /* rest gets dumped into spawndata */
						currentDef.spawnData = strcat(currentDef.spawnData, "\"", word, "\"", " ");
					}
				}
			}
			lastWord = word;
		}
	}

	/* clean up */
	fclose(defFile);
}

void
EntityDef_Init(void)
{
	searchhandle pm;
	pm = search_begin("def/*.def", TRUE, TRUE);
	for (int i = 0; i < search_getsize(pm); i++) {
		EntityDef_ReadFile(search_getfilename(pm, i));
	}
	search_end(pm);

#if 0
	for (int i = 0i; i < g_entDefCount; i++) {
		int numKeys = tokenize_console(g_entDefTable[i].spawnData);
		print(sprintf("edef %i: %S\n", i, g_entDefTable[i].entClass));
		print(sprintf("\tspawnclass: %S\n", g_entDefTable[i].spawnClass));
		print(sprintf("\tinheritKeys: %S\n", g_entDefTable[i].inheritKeys));
		print(sprintf("\tspawnData:\n", g_entDefTable[i].spawnData));
		
		for (int c = 0; c < numKeys; c+=2) {
			print(sprintf("\t\t%S %S\n", argv(c), argv(c+1)));
		}
	}
#endif
}

static NSEntity
EntityDef_PrepareEntity(entity target, int id)
{
	string spawnClass;
	int spawnWords = 0i;
	NSEntity targetEnt = (NSEntity)target;
	entity oldSelf = self;
	bool isEntDefBased = false;

	/* check if the spawnclass is an entityDef */
	for (int i = 0i; i < g_entDefCount; i++) {
		if (g_entDefTable[id].spawnClass == g_entDefTable[i].entClass) {
			EntityDef_PrepareEntity(target, i);
			isEntDefBased = true;
			break;
		}
	}

	if (isEntDefBased == false) {
		/* first we spawn it as the base spawnclass */
		if (!isfunction(g_entDefTable[id].spawnClass)) {
			spawnClass = strcat("spawnfunc_", g_entDefTable[id].spawnClass);
		} else {
			spawnClass = g_entDefTable[id].spawnClass;
		}

		/* init */
		self = target;
		callfunction(spawnClass);
		self = oldSelf;

		/* first load all keys we inherit from the 'inherited' class */
		for (int x = 0; x < g_entDefCount; x++) {
			/* found the thing we're supposed to inherit */
			if (g_entDefTable[x].entClass == g_entDefTable[id].inheritKeys) {
				spawnWords = tokenize_console(g_entDefTable[x].spawnData);
				for (int i = 0; i < spawnWords; i+= 2) {
					targetEnt.SpawnKey(argv(i), argv(i+1));
				}
			}
		}
	}

	/* now we load the field overrides from the entDef */
	spawnWords = tokenize_console(g_entDefTable[id].spawnData);
	for (int i = 0; i < spawnWords; i+= 2) {
		targetEnt.SpawnKey(argv(i), argv(i+1));
	}

	/* now we load our own spawndata, which starts and ends with braces */
	spawnWords = tokenize_console(__fullspawndata);
	for (int i = 1; i < (spawnWords - 1); i+= 2) {

		/* ignore this, always */
		if (argv(i) != "classname")
			targetEnt.SpawnKey(argv(i), argv(i+1));
	}
	targetEnt.Spawned();
	targetEnt.Respawn();

	/* now we rename the classname for better visibility */
	targetEnt.classname = g_entDefTable[id].entClass;
	__fullspawndata = "";
	return targetEnt;
}

NSEntity
EntityDef_SpawnClassname(string className)
{
	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			return EntityDef_PrepareEntity(self, i);
		}
	}

	return __NULL__;
}

NSEntity
EntityDef_CreateClassname(string className)
{
	entity oldSelf = self;
	NSEntity new = spawn(NSEntity);
	self = new;
	EntityDef_SpawnClassname(className);
	self = oldSelf;
	return new;
}

string
EntityDef_GetKeyValue(string className, string keyName)
{
	float spawnWords = 0;
	string inheritKeys = __NULL__;

	/* loop through all defs */
	for (int i = 0i; i < g_entDefCount; i++) {
		/* found the right def */
		//print(sprintf("%S %S\n", className, g_entDefTable[i].entClass));
		if (className == g_entDefTable[i].entClass) {
			inheritKeys = g_entDefTable[i].inheritKeys;
			spawnWords = tokenize_console(g_entDefTable[i].spawnData);

			/* iterate over our own spawnkeys first */
			for (int c = 0i; c < spawnWords; c+= 2i) {
				if (argv(c) == keyName) {
					return argv(c+1);
				}
			}

			/* not found, look into the inherit keyword's spawndata */
			if (inheritKeys == __NULL__)
				return "";

			for (int b = 0i; b < g_entDefCount; i++) {
				if (inheritKeys == g_entDefTable[b].entClass) {
					spawnWords = tokenize_console(g_entDefTable[b].spawnData);
					for (int c = 0i; c < spawnWords; c+= 2i) {
						if (argv(c) == keyName) {
							return argv(c+1);
						}
					}
				}
			}
		}
	}

	return "";
}