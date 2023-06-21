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

	as you can see, key/value pairs can also split across multiple lines,
	although that is discouraged.

	we also have things exclusive to our entityDef format:

	entityDef foobar {
		[...]

		when "body" equals 1 {
			"skin" "4"
		}
	}

	will allow developers to configure other fields when certain
   conditions are met.

	this is also expanded to include model event callbacks to the tried
	and true I/O system:

	entityDef foobar {
		[...]

		events {
			1004 "SpawnDef" "foobar_projectile"
		}
	}
*/

/* games can feel free to set this to whatever you need. */
#ifndef ENTITYDEF_MAX
#define ENTITYDEF_MAX 128
#endif

var string g_lastSpawnData;

enum
{
	EDEFTWEAK_EQ = 0,
	EDEFTWEAK_LT,
	EDEFTWEAK_GT,
	EDEFTWEAK_NOT,
	EDEFTWEAK_CONTAINS
};

typedef struct
{
	string entClass;
	string spawnClass;
	string spawnData;
	string inheritKeys;

	string tweakDefs; /* when (field) equals/greater-than/less-than/is-not (value) */
	string tweakKeys;

	string eventList; /* model events */
} entityDef_t;

entityDef_t g_entDefTable[ENTITYDEF_MAX];
var int g_entDefCount;

string g_entDefInclude;

void
EntityDef_ReadFile(string filePath)
{
	filestream defFile;
	string tempString = "";
	entityDef_t currentDef;
	int braceDepth = 0i;
	string lastWord = __NULL__;
	bool inEvent = false;

	currentDef.entClass = "";
	currentDef.spawnClass = "";
	currentDef.spawnData = "";
	currentDef.inheritKeys = "";
	currentDef.tweakDefs = "";
	currentDef.tweakKeys = "";
	currentDef.eventList = "";

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
						g_entDefTable[g_entDefCount].tweakDefs = currentDef.tweakDefs;
						g_entDefTable[g_entDefCount].tweakKeys = currentDef.tweakKeys;
						g_entDefTable[g_entDefCount].eventList = currentDef.eventList;

						/* increment the def count */
						if (g_entDefCount < ENTITYDEF_MAX)
							g_entDefCount++;
					}
					currentDef.entClass = "";
					currentDef.spawnClass = "";
					currentDef.spawnData = "";
					currentDef.inheritKeys = "";
					currentDef.tweakDefs = "";
					currentDef.tweakKeys = "";
					currentDef.eventList = "";
				}

				/* we came out of a tweak */
				if (braceDepth == 1) {
					if (inEvent == false && currentDef.tweakKeys != "") {
						currentDef.tweakKeys = strcat(currentDef.tweakKeys, ";"); /* mark the end of a key chain */
						//currentDef.tweakKeys = "";
					}
					inEvent = false;
				}
				break;
			default:
				/* anything outside braces defines the classname for the next def */
				if (braceDepth == 0 && lastWord == "entityDef") {
					currentDef.entClass = word;
				} else if (braceDepth == 0 && lastWord == "include") {
					g_entDefInclude = strcat(g_entDefInclude, word, ";");
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
					} else if (substring(word, 0, 4) == "when") {
						switch (argv(i+2)) {
						case "equals":
							currentDef.tweakDefs = strcat(currentDef.tweakDefs, argv(i+1), " 0 ", argv(i+3), ";");
							break;
						case "less-than":
							currentDef.tweakDefs = strcat(currentDef.tweakDefs, argv(i+1), " 1 ", argv(i+3), ";");
							break;
						case "greater-than":
							currentDef.tweakDefs = strcat(currentDef.tweakDefs, argv(i+1), " 2 ", argv(i+3), ";");
							break;
						case "is-not":
							currentDef.tweakDefs = strcat(currentDef.tweakDefs, argv(i+1), " 3 ", argv(i+3), ";");
							break;
						case "contains":
							currentDef.tweakDefs = strcat(currentDef.tweakDefs, argv(i+1), " 4 ", argv(i+3), ";");
							break;
						
						}
						inEvent = false;
						i+=3;
					} else if (substring(word, 0, 6) == "events") {
						inEvent = true;
					} else { /* rest gets dumped into spawndata */
						currentDef.spawnData = strcat(currentDef.spawnData, "\"", word, "\"", " ");
					}
				} else if (braceDepth == 2) {
					/* it's a 'when' tweak */
					if (inEvent == false) {
						currentDef.tweakKeys = strcat(currentDef.tweakKeys, "\"", word, "\"", " ");
					} else { /* it's a model event callback */
						currentDef.eventList = strcat(currentDef.eventList, "\"", word, "\"", " ");
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

	g_entDefInclude = "";

	pm = search_begin("def/*.def", TRUE, TRUE);
	for (int i = 0; i < search_getsize(pm); i++) {
		EntityDef_ReadFile(search_getfilename(pm, i));
	}
	search_end(pm);

	//print(sprintf("includes: %S\n", g_entDefInclude));

	if (g_entDefInclude != "") {
		int includeCount = tokenizebyseparator(g_entDefInclude, ";");

		for (int i = 0; i < (includeCount-1); i++) {
			string fileName = strcat("def/", argv(i));
			EntityDef_ReadFile(fileName);
			includeCount = tokenizebyseparator(g_entDefInclude, ";");
		}
	}

#if 0
	for (int i = 0i; i < g_entDefCount; i++) {
		int numKeys = tokenize_console(g_entDefTable[i].spawnData);
		print(sprintf("edef %i: %S\n", i, g_entDefTable[i].entClass));
		print(sprintf("\tspawnclass: %S\n", g_entDefTable[i].spawnClass));
		print(sprintf("\tinheritKeys: %S\n", g_entDefTable[i].inheritKeys));
		print(sprintf("\ttweakDefs %S\n", g_entDefTable[i].tweakDefs));
		print(sprintf("\ttweakKeys %S\n", g_entDefTable[i].tweakKeys));
		print(sprintf("\teventList %S\n", g_entDefTable[i].eventList));
		print("\tspawnData:\n");
		
		for (int c = 0; c < numKeys; c+=2) {
			print(sprintf("\t\t%S %S\n", argv(c), argv(c+1)));
		}
	}
#endif
}

static bool
EntityDef_CheckCondition(int id, string keyWord, float tweakCondition, string keyValue)
{
	int spawnWords = tokenize_console(g_lastSpawnData);
	string key, value;
	float tmp1, tmp2;

	//print(sprintf("%i %S %d %S\n", id, keyWord, tweakCondition, keyValue));

	for (int i = 1; i < (spawnWords - 1); i+= 2) {
		key = argv(i);
		value = argv(i+1);

		//print(sprintf("comparing %S with %S\n", key, value));

		/* fforward out */
		if (key != keyWord)
			continue;

		switch (tweakCondition) {
		case EDEFTWEAK_EQ:
			if (key == keyWord && value == keyValue)
				return true;
			break;
		case EDEFTWEAK_LT:
			tmp1 = stof(keyValue);
			tmp2 = stof(value);

			if (key == keyWord && tmp2 < tmp1)
				return true;
			break;
		case EDEFTWEAK_GT:
			tmp1 = stof(keyValue);
			tmp2 = stof(value);

			if (key == keyWord && tmp2 > tmp1)
				return true;
			break;
		case EDEFTWEAK_NOT:
			if (key == keyWord && value != keyValue)
				return true;
		case EDEFTWEAK_CONTAINS:
			tmp1 = stof(keyValue);
			tmp2 = stof(value);

			if (key == keyWord && tmp2 & tmp1)
				return true;
			break;
		}
	}

	return false;
}

static NSEntity
EntityDef_PrepareEntity(entity target, int id)
{
	string spawnClass;
	int spawnWords = 0i;
	NSEntity targetEnt = (NSEntity)target;
	entity oldSelf = self;
	bool isEntDefBased = false;

	if (!targetEnt) {
		targetEnt = spawn(NSEntity);
	}

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
	spawnWords = tokenize_console(g_lastSpawnData);
	for (int i = 1; i < (spawnWords - 1); i+= 2) {

		/* ignore this, always */
		if (argv(i) != "classname")
			targetEnt.SpawnKey(argv(i), argv(i+1));
	}

	/* now after everything else is done, check our entityDef tweaks */
	spawnWords = tokenizebyseparator(g_entDefTable[id].tweakDefs, ";");
	for (int i = 0; i < spawnWords; i++) {
		string groupSegment = argv(i);

		//print(sprintf("group: %S\n", groupSegment));
		tokenize_console(groupSegment); /* split the group segment into 3 */

		string keyWord = argv(0);
		float tweakCondition = stof(argv(1));
		string keyValue = argv(2);

		/* iterate through a bunch of different data to check our condition */
		if (EntityDef_CheckCondition(id, keyWord, tweakCondition, keyValue)) {
			int tweakGroups = tokenizebyseparator(g_entDefTable[id].tweakKeys, ";");

			//print(sprintf("%S passed the check\n", keyWord));

			/* iterate through the ; key groups */
			for (int x = 0; x < tweakGroups; x++) {
				int tweakSpawns = tokenize_console(argv(x));

				/* ignore any other key group */
				if (x == i) {
					/* iterate through key/value pairs within the ; key groups */
					for (int y = 0; y < tweakSpawns; y+= 2) {
						//print(sprintf("applying %S and %S\n", argv(y), argv(y+1)));
						targetEnt.SpawnKey(argv(y), argv(y+1));
					}
				}

				/* retokenize */
				tweakGroups = tokenizebyseparator(g_entDefTable[id].tweakKeys, ";");
			}
		}

		/* retokenize our condition */
		spawnWords = tokenizebyseparator(g_entDefTable[id].tweakDefs, ";");
	}

	targetEnt.m_strModelEventCB = g_entDefTable[id].eventList; /* pass over the event listing */
	targetEnt.Spawned();
	targetEnt.Respawn();

	/* now we rename the classname for better visibility */
	targetEnt.classname = g_entDefTable[id].entClass;
	g_lastSpawnData = "";
	return targetEnt;
}

/* precache resources inside an entityDef */
static void
EntityDef_Precaches(int index)
{
	int spawnWords = tokenize_console(g_entDefTable[index].spawnData);
	for (int i = 0; i < spawnWords; i+= 2) {
		string strKey = argv(i);
		string strValue = argv(i+1);

		if (substring(strKey, 0, 4) == "snd_") {
			Sound_Precache(strValue);
			spawnWords = tokenize_console(g_entDefTable[index].spawnData);
		}
	}

	/* handle soundDef events */
	spawnWords = tokenize(g_entDefTable[index].eventList);
	for (int i = 0; i < spawnWords; i+=3) {
		int testCode = stoi(argv(i+0));
		string testInput = argv(i+1);
		string testData = argv(i+2);
		
		if (testInput == "StartSoundDef") {
			Sound_Precache(testData);
			tokenize(g_entDefTable[index].eventList);
		}
	}
}

NSEntity
EntityDef_SpawnClassname(string className)
{
	g_lastSpawnData = __fullspawndata;

	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			EntityDef_Precaches(i);
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

bool
EntityDef_HasSpawnClass(string className)
{
	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			return (g_entDefTable[i].spawnClass != "") ? true : false;
		}
	}

	return false;
}