/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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

static string g_lastSpawnData;
static entityDef_t g_entDefTable[ENTITYDEF_MAX];
static int g_entDefCount;
static string g_entDefInclude;

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
	currentDef.inheritID = -1i;

	/* bounds check */
	if (g_entDefCount >= ENTITYDEF_MAX) {
		NSError("Reached limit of %d defs.", ENTITYDEF_MAX);
		error("Crash.");
	}

	/* open file */
	defFile = fopen(filePath, FILE_READ);
	if (defFile < 0) {
		NSError("Unable to read %S\n", filePath);
		error("Crash.");
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
						g_entDefTable[g_entDefCount].inheritID = EntityDef_IDFromName(currentDef.inheritKeys);
						g_entDefTable[g_entDefCount].tweakDefs = currentDef.tweakDefs;
						g_entDefTable[g_entDefCount].tweakKeys = currentDef.tweakKeys;
						g_entDefTable[g_entDefCount].eventList = currentDef.eventList;

						/* increment the def count */
						if (g_entDefCount < ENTITYDEF_MAX)
							g_entDefCount++;

						if (g_entDefCount >= ENTITYDEF_MAX) {
							NSError("Reached limit of %d defs.", ENTITYDEF_MAX);
							return;
						}
					}
					currentDef.entClass = "";
					currentDef.spawnClass = "";
					currentDef.spawnData = "";
					currentDef.inheritKeys = "";
					currentDef.tweakDefs = "";
					currentDef.tweakKeys = "";
					currentDef.eventList = "";
					currentDef.inheritID = -1i;
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
				} else if (braceDepth == 0 && lastWord == "#include") {
					g_entDefInclude = strcat(g_entDefInclude, word, ";");
				}  else if (braceDepth == 0 && lastWord == "#define") {
					Constants_Add(argv(i), argv(i+1));
				} else if (braceDepth == 1) {
					/* spawnclass is reserved and the next keyword specs it */
					if (word == "spawnclass") {
						currentDef.spawnClass = argv(i+1);
						i++;
					} else if (word == "inherit") {
						currentDef.inheritKeys = argv(i+1);
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
	string mapDef = sprintf("maps/%s.def", cvar_string("mapname"));
	searchhandle pm;

	InitStart();

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

	/* load the map specific def file */
	if (FileExists(mapDef)) {
		EntityDef_ReadFile(mapDef);
	}

	/* if spawnclass wasn't set, read the one from the inheritkeys entityDef */
	for (int i = 0i; i < g_entDefCount; i++) {
		if (!g_entDefTable[i].spawnClass) {
			if (g_entDefTable[i].inheritID != -1i) {
				int baseID = g_entDefTable[i].inheritID;

				if (baseID == -1i) {
					NSError("def %S inherits keys from non-existent def %S", 
						g_entDefTable[i].entClass,
						g_entDefTable[i].inheritKeys );
				}

				g_entDefTable[i].spawnClass = g_entDefTable[baseID].spawnClass;
			}
		}
	}

	InitEnd();
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
			/* no break here on purpose. */
		case EDEFTWEAK_CONTAINS:
			tmp1 = stof(keyValue);
			tmp2 = stof(value);

			print(sprintf("%d & %d\n", tmp1, tmp2));

			if (key == keyWord && tmp2 & tmp1)
				return true;
			break;
		}
	}

	return false;
}



string
EntityDef_GetKeyValue(string className, string keyName)
{
	float spawnWords = 0;
	string inheritKeys = __NULL__;

	//breakpoint();

	/* not a valid classname. */
	if (!className)
		return "";

	/* loop through all defs */
	for (int i = 0i; i < g_entDefCount; i++) {
		entityDef_t *defChain;

		/* found the right def */
		if (className == g_entDefTable[i].entClass) {
			defChain = &g_entDefTable[i];

			/* loop over all inherit chains */
			while (defChain) {
				spawnWords = tokenize_console(defChain->spawnData);

				/* iterate over our own spawnkeys first */
				for (int c = 0i; c < spawnWords; c+= 2i) {
					if (argv(c) == keyName) {
						return argv(c+1);
					}
				}

				/* if set, set it as the next def to parse from */
				if (defChain->inheritID != -1i) {
					defChain = &g_entDefTable[defChain->inheritID];
				} else {
					defChain = __NULL__;
				}
			}
		}
	}

	return "";
}

#ifdef SERVER

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

		if (!isfunction(spawnClass)) {
			NSError("Unable to find entityDef spawnclass %S", spawnClass);
			targetEnt.Destroy();
			return __NULL__;
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

	/* now we rename the classname for better visibility,
	   but also because some classes need to know. */
	targetEnt.classname = g_entDefTable[id].entClass;
	targetEnt.entityDefID = EntityDef_IDFromName(targetEnt.classname);

	targetEnt.Spawned();
	targetEnt.Respawn();

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
		} else if (substring(strKey, 0, 6) == "smoke_") {
			particleeffectnum(strValue);
		} else if (strKey == "model_detonate") {
			particleeffectnum(strValue);
		} else if (substring(strKey, 0, 4) == "def_") {
			int defID = EntityDef_IDFromName(strValue);

			if (defID != -1) {
				EntityDef_Precaches(defID);
			}
		}
		spawnWords = tokenize_console(g_entDefTable[index].spawnData);
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

bool
EntityDef_Precache(string defName)
{
	int baseID = EntityDef_IDFromName(defName);
	int inheritID;

	if (baseID == -1i) {
		NSError("Can't precache %S. Not found.", defName);
		return (false);
	}

	inheritID = g_entDefTable[baseID].inheritID;
	EntityDef_Precaches(baseID);

	/* precache the entire inherit chain. */
	while (inheritID != -1i) {
		EntityDef_Precaches(inheritID);
		inheritID = EntityDef_IDFromName(g_entDefTable[inheritID].inheritKeys);
	}

	return (true);
}

NSEntity
EntityDef_SpawnClassname(string className)
{
	g_lastSpawnData = __fullspawndata;

	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			if (time < 5.0) {
				EntityDef_Precaches(i);
			}

			NSLog("Spawning eDef %S", className);
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
	NSEntity test;
	self = new;
	test = EntityDef_SpawnClassname(className);
	self = oldSelf;

	/* Failure */
	if (test == __NULL__) {
		new.Destroy();
		return __NULL__;
	}

	return new;
}

static void
CallSpawnfuncByName(entity target, string className)
{
	entity oldSelf = self;
	string spawnClass = strcat("spawnfunc_", className);
	self = target;
	callfunction(spawnClass);
	self = oldSelf;
}

/** Always returns a valid entity. Even if the entity def does not exist. */
NSEntity
Entity_CreateClass(string className)
{
	NSEntity newEntity = EntityDef_CreateClassname(className);

	if (!newEntity) {
		newEntity = spawn(NSEntity);
		CallSpawnfuncByName(newEntity, className);
	}

	return newEntity;
}
#endif

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

void
EntityDef_DebugList(void)
{
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
}


int
EntityDef_IDFromName(string defName)
{
	if (defName) {
		for (int i = 0i; i < g_entDefCount; i++) {
			if (defName == g_entDefTable[i].entClass) {
				return (i);
			}
		}
	}

	return (-1i);
}

string
EntityDef_NameFromID(int defNum)
{
	if (defNum == -1i) {
		return "";
	}

	return g_entDefTable[defNum].entClass;
}


string
EntityDef_GetSpawnData(int defNum)
{
	if (defNum == -1i) {
		return "";
	}

	return g_entDefTable[defNum].spawnData;
}
