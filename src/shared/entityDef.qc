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

static entityDef_t g_entDefTable[ENTITYDEF_MAX];
static int g_entDefCount;
static string g_entDefInclude;

#ifdef SERVER
static string g_lastSpawnData;
#endif

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
		ncError("Reached limit of %d defs.", ENTITYDEF_MAX);
		error("Crash.");
	}

	/* open file */
	defFile = fopen(filePath, FILE_READ);
	if (defFile < 0) {
		ncError("Unable to read %S\n", filePath);
		error("Crash.");
	}

	/* line by line */
	while ((tempString = fgets(defFile))) {
		/* word for word */
		for (int i = 0i; i < tokenize_console(tempString); i++) {
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
							ncError("Reached limit of %d defs.", ENTITYDEF_MAX);
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

	pm = search_begin("decls/def/*.def", TRUE, TRUE);
	for (int i = 0; i < search_getsize(pm); i++) {
		EntityDef_ReadFile(search_getfilename(pm, i));
	}
	search_end(pm);

	if (STRING_SET(g_entDefInclude)) {
		for (int i = 0; i < (tokenizebyseparator(g_entDefInclude, ";")-1); i++) {
			string fileName = strcat("decls/def/", argv(i));
			EntityDef_ReadFile(fileName);
		}
	}

	/* load the map specific def file */
	if (fileExists(mapDef)) {
		EntityDef_ReadFile(mapDef);
	}

	/* if spawnclass wasn't set, read the one from the inheritkeys entityDef */
	for (int i = 0i; i < g_entDefCount; i++) {
		if (!STRING_SET(g_entDefTable[i].spawnClass)) {
			if (g_entDefTable[i].inheritID != -1i) {
				int baseID = g_entDefTable[i].inheritID;

				if (baseID == -1i) {
					ncError("def %S inherits keys from non-existent def %S",
						g_entDefTable[i].entClass,
						g_entDefTable[i].inheritKeys );
				} else {
					g_entDefTable[i].spawnClass = g_entDefTable[baseID].spawnClass;
				}
			}
		}
	}

	InitEnd();
}

static bool
EntityDef_CheckCondition(ncEntity target, int id, string keyWord, float tweakCondition, string keyValue)
{
	string key, value;
	float tmp1, tmp2;

	//print(sprintf("%i %S %d %S\n", id, keyWord, tweakCondition, keyValue));

	for (int i = 1; i < (tokenize_console(target.m_rawSpawnData) - 1); i+= 2) {
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

			if (key == keyWord && tmp2 & tmp1)
				return true;
			break;
		}
	}

	return (false);
}


var bool autocvar_entityDef_profile = false;

string
EntityDef_GetKeyValue(string className, string keyName)
{
	float spawnWords = 0;
	string inheritKeys = __NULL__;

	static string lastClass, lastKey, lastResult;

	if (className == lastClass && keyName == lastKey) {
		return (lastResult);
	}

	/* not a valid classname. */
	if (!STRING_SET(className)) {
		return "";
	}

	if (autocvar_entityDef_profile) {
		breakpoint();
	}

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
						lastClass = className;
						lastKey = keyName;
						lastResult = argv(c+1);
						return (lastResult);
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

static ncEntity
EntityDef_PrepareEntity(entity target, int id)
{
	string spawnClass;
	int spawnWords = 0i;
	ncEntity targetEnt = (ncEntity)target;
	entity oldSelf = self;
	bool isEntDefBased = false;
	
	if (!STRING_SET(g_entDefTable[id].spawnClass)) {
		ncError("%S (%i) doesn't define spawnclass", g_entDefTable[id].entClass, id);
		g_lastSpawnData = "";
		return (__NULL__);
	}

	/* check if the spawnclass is an entityDef */
	for (int i = 0i; i < g_entDefCount; i++) {
		if (g_entDefTable[id].spawnClass == g_entDefTable[i].entClass) {
			isEntDefBased = true;
			return EntityDef_PrepareEntity(target, i);
		}
	}

	if (!targetEnt) {
		targetEnt = spawn(ncEntity);
	}

	targetEnt.declclass = g_entDefTable[id].entClass;
	targetEnt.spawnclass = g_entDefTable[id].spawnClass;

	if (isEntDefBased == false) {
		/* first we spawn it as the base spawnclass */
		if (!isfunction(g_entDefTable[id].spawnClass)) {
			spawnClass = strcat("spawnfunc_", g_entDefTable[id].spawnClass);
		} else {
			spawnClass = g_entDefTable[id].spawnClass;
		}

		if (!isfunction(spawnClass)) {
			ncError("Unable to find entityDef spawnclass %S", spawnClass);
			remove(targetEnt);
			g_lastSpawnData = "";
			return (__NULL__);
		}

		/* init */
		oldSelf = self;
		self = target;
		callfunction(spawnClass);
		targetEnt.classname = g_entDefTable[id].entClass;
		targetEnt.spawnclass = g_entDefTable[id].spawnClass;
		self = oldSelf;

		/* first load all keys we inherit from the 'inherited' class */
		for (int x = 0; x < g_entDefCount; x++) {
			/* found the thing we're supposed to inherit */
			if (g_entDefTable[x].entClass == g_entDefTable[id].inheritKeys) {

				for (int i = 0; i < tokenize_console(g_entDefTable[x].spawnData); i+= 2) {
					targetEnt.SpawnKey(argv(i), argv(i+1));
				}
			}
		}
	}

	if (STRING_SET(targetEnt.declclass)) {
		/* used to network our shared ID */
		targetEnt.entityDefID = EntityDef_NetIDFromName(targetEnt.declclass);
		targetEnt.ReloadCachedAttributes();
	}

	/* now we load the field overrides from the entDef */
	for (int i = 0; i < tokenize_console(g_entDefTable[id].spawnData); i+= 2) {
		string keyName = argv(i);
		string setValue = argv(i+1);

		targetEnt.SpawnKey(keyName, setValue);
	}

	/* now we load our own spawndata, which starts and ends with braces */
	for (int i = 1; i < (tokenize_console(g_lastSpawnData) - 1); i+= 2) {

		/* ignore this, always */
		if (argv(i) != "classname") {
			targetEnt.SpawnKey(argv(i), argv(i+1));
		}
	}

	/* now after everything else is done, check our entityDef tweaks */
	for (int i = 0; i < tokenizebyseparator(g_entDefTable[id].tweakDefs, ";"); i++) {
		string groupSegment = argv(i);

		//print(sprintf("group: %S\n", groupSegment));
		tokenize_console(groupSegment); /* split the group segment into 3 */

		string keyWord = argv(0);
		float tweakCondition = stof(argv(1));
		string keyValue = argv(2);

		/* iterate through a bunch of different data to check our condition */
		if (EntityDef_CheckCondition((ncEntity)target, id, keyWord, tweakCondition, keyValue)) {
			//print(sprintf("%S passed the check\n", keyWord));

			/* iterate through the ; key groups */
			for (int x = 0; x < tokenizebyseparator(g_entDefTable[id].tweakKeys, ";"); x++) {
				string currentTweak = argv(x);

				/* ignore any other key group */
				if (x == i) {
					/* iterate through key/value pairs within the ; key groups */
					for (int y = 0; y < tokenize_console(currentTweak); y+= 2) {
						string keyName = argv(y);
						string setValue = argv(y+1);
						//print(sprintf("applying %S and %S\n", argv(y), argv(y+1)));
						targetEnt.SpawnKey(keyName, setValue);
						targetEnt.m_rawSpawnData = sprintf("%s \"TWEAK\" %S %S }", targetEnt.m_rawSpawnData, keyName, setValue);
					}
				}
			}
		}
	}

	/* now that that all methods have been called, we're ready to decide whether to continue this spawn */
	if (wasfreed(targetEnt) == false) {
		/* we have a gametype filter set */
		if (STRING_SET(targetEnt.m_gameModeFilter)) {
			bool foundMode = false;

			for (int y = 0; y < tokenize_console(targetEnt.m_gameModeFilter); y++) {
				string mode = argv(y);

				if (mode == g_ruleCName) {
					foundMode = true;
				}
			}

			if (foundMode == false) {
				targetEnt.Destroy();
				targetEnt = __NULL__;
				g_lastSpawnData = "";
				return (targetEnt);
			}
		}

		targetEnt.m_modelEventCallbacks = g_entDefTable[id].eventList; /* pass over the event listing */

		/* now we rename the classname for better visibility,
		   but also because some classes need to know. */
		targetEnt.classname = g_entDefTable[id].entClass;
		targetEnt.entityDefID = EntityDef_NetIDFromName(targetEnt.classname);

		targetEnt.Spawn();
	}

	g_lastSpawnData = "";
	return (targetEnt);
}

/* precache resources inside an entityDef */
static void
EntityDef_Precaches(int index)
{
	int defID = 0i;

	if (g_ents_initialized == true) {
		return;
	}

	for (int i = 0; i < tokenize_console(g_entDefTable[index].spawnData); i+= 2) {
		string keyName = argv(i);
		string setValue = argv(i+1);

		if (substring(keyName, 0, 4) == "snd_") {
			precache.Sound(setValue);
		} else if (substring(keyName, 0, 6) == "smoke_") {
			particleeffectnum(setValue);
		} else if (keyName == "model_detonate") {
			particleeffectnum(setValue);
		} else if (keyName == "model") {
			precache.Model(setValue);
		} else if (substring(keyName, 0, 6) == "model_") {
			precache.Model(setValue);
		} else if (substring(keyName, 0, 4) == "def_" || (keyName == "item")) {
			defID = EntityDef_IDFromName(setValue);

			/* only precache valid def, and avoid recursion */
			if (defID != -1 && defID != index) {
				EntityDef_Precaches(defID);
			}
		} else if (keyName == "weapon") {
			for (int w = 0; w < tokenizebyseparator(setValue, ","); w++) {
				string weaponName = argv(w);
				defID = EntityDef_IDFromName(weaponName);

				/* only precache valid def, and avoid recursion */
				if (defID != -1 && defID != index) {
					EntityDef_Precaches(defID);
				}
			}
		}
	}

	/* handle soundDef events */
	for (int i = 0; i < tokenize(g_entDefTable[index].eventList); i+=3) {
		int testCode = stoi(argv(i+0));
		string testInput = argv(i+1);
		string testData = argv(i+2);

		if (testInput == "StartSoundDef") {
			precache.Sound(testData);
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
		ncError("Can't precache %S. Not found.", defName);
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

ncEntity
EntityDef_NewClassname(string className)
{
	g_lastSpawnData = __fullspawndata;

	if (!STRING_SET(className)) {
		return (__NULL__);
	}

	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			EntityDef_Precache(className);
			return EntityDef_PrepareEntity(self, i);
		}
	}

	return (__NULL__);
}

ncEntity
EntityDef_SpawnClassname(string className)
{
	g_lastSpawnData = __fullspawndata;

	if (!STRING_SET(className)) {
		return (__NULL__);
	}

	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			EntityDef_Precache(className);
			return EntityDef_PrepareEntity(self, i);
		}
	}

	return (__NULL__);
}

ncEntity
EntityDef_SwitchClass(ncEntity target, string className)
{
	ncEntity returnEntity = __NULL__;
	g_lastSpawnData = target.m_rawSpawnData;

	if (!STRING_SET(className)) {
		return (__NULL__);
	}

	for (int i = 0i; i < g_entDefCount; i++) {
		if (className == g_entDefTable[i].entClass) {
			EntityDef_Precache(className);
			returnEntity = EntityDef_PrepareEntity(target, i);
			return (returnEntity);
		}
	}

	return (returnEntity);
}

ncEntity
EntityDef_CreateClassname(string className)
{
	entity oldSelf = self;
	ncEntity new = spawn(ncEntity);
	ncEntity test;
	self = new;
	test = EntityDef_SpawnClassname(className);

	/* Failure */
	if (test == __NULL__) {
		new.Destroy();
		return (__NULL__);
	}

	self = oldSelf;
	return (new);
}

/** Always returns a valid entity. Even if the entity def does not exist. */
ncEntity
Entity_CreateClass(string className)
{
	ncEntity newEntity = EntityDef_CreateClassname(className);

	if (!newEntity) {
		newEntity = spawn(ncEntity);
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
ourCRC(string name)
{
	int crcValue = (int)(stoh(digest_hex("CRC16", strtolower(name))));
	return (crcValue);
}

int
EntityDef_NetIDFromName(string defName)
{
#if 1
	return ourCRC(defName);
#else
	if (defName) {
		for (int i = 0i; i < g_entDefCount; i++) {
			if (defName == g_entDefTable[i].entClass) {
				return (i);
			}
		}
	}

	return (-1i);
#endif
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
EntityDef_NameFromNetID(int defNum)
{
	for (int i = 0i; i < g_entDefCount; i++) {
		int checkSum = ourCRC(g_entDefTable[i].entClass);

		if (checkSum == defNum) {
			return (g_entDefTable[i].entClass);
		}
	}

	return "";
}

void
EntityDef_SetFromEntNum(ncItem targetItem, int defNum)
{
	int endID = -1i;

	if (!targetItem) {
		return;
	}

	for (int i = 0i; i < g_entDefCount; i++) {
		int checkSum = ourCRC(g_entDefTable[i].entClass);

		if (checkSum == defNum) {
			endID = i;
		}
	}

	if (endID == -1i) {
		return;
	}

	targetItem.declclass = g_entDefTable[endID].entClass;
	targetItem.classname = g_entDefTable[endID].spawnClass;
	targetItem.ReloadCachedAttributes();
}

string
EntityDef_GetSpawnData(int defNum)
{
	if (defNum == -1i) {
		return "";
	}

	return g_entDefTable[defNum].spawnData;
}
