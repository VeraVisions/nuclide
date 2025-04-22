static ncDict g_globalDictionary;

void
ncSessionManager::ncSessionManager(void)
{
}

ncEntity
ncSessionManager::_FindCarrierEntity(string globalName)
{
	for (ncEntity a = __NULL__; (a = (ncEntity)findfloat(a, ::identity, 1));) {
		if (a.m_globalName == globalName) {
			return a;
		}
	}

	return (__NULL__);
}

void
ncSessionManager::_LoadTransition(void)
{
	string lineFeed;
	bool isNew = false;
	ncEntity carrierEntity = __NULL__;

	filestream transFile = fopen("trans.dat", FILE_READ);

	if (transFile < 0) {
		ncError("Called to transition, but trans.dat does not exist.");
	}

	ncLog("Found transition file. Will transition over entities.");

	while ((lineFeed = fgets(transFile))) {
		int c = tokenize(lineFeed);

		/* start of an entity */
		if (argv(0) == "{") {
			continue;
		} else if (argv(0) == "}") {

			if (carrierEntity.solid == 0 && carrierEntity.movetype == 0) {
				carrierEntity.Destroy();
				carrierEntity = __NULL__;
			}

			if (carrierEntity) {
				carrierEntity.TransitionComplete();
				carrierEntity.SendFlags = -1;
				carrierEntity = __NULL__;
			}
			continue;
		}

		if (c == 3) {
			if (argv(0) == "CONTINUE") {
				carrierEntity = _FindCarrierEntity(argv(2));
				isNew = false;
			} else if (argv(0) == "ENTITY") {
				string desiredClass = argv(2);
				carrierEntity = Entity_CreateClass(desiredClass);
				isNew = true;
			}
		} else if (c == 2) { /* key value pairs */
			if (carrierEntity) {
				switch (argv(0)) {
				/* modelindices don't carry over across levels */
				case "model":
					carrierEntity.model = argv(1);
				case "modelindex":
					break;
#if 0
				case "origin":
					vector newOrigin = stov(argv(1)) + Landmark_GetPosition();
					print(sprintf("Offsetting %S by %v\n", carrierEntity.m_globalName, Landmark_GetPosition()));
					carrierEntity.m_vecRestoredOrigin = newOrigin;
					carrierEntity.Restore("origin", vtos(newOrigin));
					break;
#endif
				default:
					carrierEntity.Restore(argv(0), argv(1));
				}
			}
		}
	}

	fremove("trans.dat");
}

void
ncSessionManager::_SaveTransition(ncEntity pvsTest, bool usePVS)
{
	int i = 0i;
	filestream transFile = fopen("trans.dat", FILE_WRITE);

	if (transFile < 0) {
		error("Unable to write trans.dat for transitioning.");
	}

	/* loop through all entities */
	for (ncEntity a = __NULL__; (a = (ncEntity)findfloat(a, ::identity, 1));) {
		bool replicateEntity = false;
		bool continueInNextMap = false;

		/* no classname? never allow */
		if not (a.classname) {
			continue;
		}

		//print(sprintf("TRANSITION: %i %S %S\n", i, a.classname, a.m_globalName));

		/* if we're using the PVS, use the info_landmark as a reference */
		if (usePVS == true) {
			if (checkpvs(pvsTest.origin, a) == true) {
				replicateEntity = true;

				if (a.classname == "info_landmark") {
					replicateEntity = false;
				}

				/* to get rid of the 'out of model slots' error */
				if (a.model == "" && pvsTest.solid != SOLID_NOT) {
					replicateEntity = false;
					continueInNextMap = false;
				}
			}
		} else if (pvsTest.WithinBounds(a) == true) {
			replicateEntity = true;
		}

		/* these checks are somewhat safe assumptions. */
		if (is.Player(a)) {
			replicateEntity = false;
			continueInNextMap = false;
		}

		/* only carry brushes with a global name */
		if (a.IsBrush() == true) {
			replicateEntity = false;
			continueInNextMap = false;
		}

		/* global name = always find target in next map */
		if (STRING_SET(a.m_globalName)) {
			continueInNextMap = true;
			replicateEntity = false;
		}

		if (replicateEntity == true) {
			fputs(transFile, sprintf("ENTITY \"%i\" %S\n", i, a.classname));
			fputs(transFile, "{\n");
			a.Save(transFile);
			fputs(transFile, "}\n");
		} else if (continueInNextMap == true) {
			fputs(transFile, sprintf("CONTINUE \"%i\" %S\n", i, a.m_globalName));
			fputs(transFile, "{\n");
			a.Save(transFile);
			fputs(transFile, "}\n");
		} else {
			continue;
		}

		i++;
	}

	fclose(transFile);
}

void
ncSessionManager::HandleLevelTransition(void)
{
	if (fileExists("data/trans.dat")) {
		_LoadTransition();

		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			ncEntity levelEnt = (ncEntity)a;
			levelEnt.TransitionComplete();
		}
	}
}

void
ncSessionManager::TransitionFromPVS(ncEntity pvsEnt)
{
	_SaveTransition(pvsEnt, true);
}

void
ncSessionManager::TransitionFromVolume(ncEntity volumeEnt)
{
	_SaveTransition(volumeEnt, false);
}

void
ncSessionManager::RestoreStateFromHandle(float fh, float entcount, float playerslots)
{
	entity e = world;
	entity eold;
	string l;
	float n = 0;
	ncEntity loadent = __NULL__;
	int num_loaded = 0i;

	InitPrint("Loading Existing Save");
	g_isloading = true;

	string firstLine = fgets(fh);
	tokenize_console(firstLine);
	string firstKey = argv(0);
	string firstValue = argv(1);

	if (firstKey == "GLOBAL") {
		g_globalDictionary = g_globalDictionary.InitWithSpawnData(firstValue);
	} else {
		ncError("Save game file invalid.");
	}

#if 0
	/* mark anything else for deletion */
	while ((e=nextent(e))) {
		if (edict_num(1) != e) {
			if (e.identity != 0) {
				e.think = Util_Destroy;
				e.nextthink = time + 0.05f;
			}
		}
	}
#endif

#ifdef REEDICT
	while ((e=nextent(e))) {
		if (edict_num(1) != e)
			if (e.identity) {
				ncEntity toRemove = (ncEntity)e;
				toRemove.Destroy();
			} else {
				remove(e);
			}
	}
#else
	e = world;
#endif

	/* read line per line of our file handle */
	while ((l=fgets(fh))) {
		float args = tokenize_console(l);

		if (!args)
			break;

		if (argv(0) == "ENTITY") {
			string cname;
			cname = argv(2);
#ifndef REEDICT
			n = stof(argv(1));
			e = edict_num(n);
			ncLog("Creating %s (edict %d)", cname, n);
#else
			entity e = spawn();
#endif
			loadent = __NULL__;

			__fullspawndata = fgets(fh);

			if (isfunction(strcat("spawnfunc_", cname))) {
				/* call the constructor if one is present, init the default fields */
				CallSpawnfuncByName(e, cname);
				loadent = (ncEntity)e;
			} else {
				ncError("failed spawning %s", cname);

				if (e.identity) {
					ncEntity toRemove = (ncEntity)e;
					toRemove.Destroy();
				} else {
					remove(e);
				}

				continue;
			}
		} else if (argv(0) == "{") {
		} else if (argv(0) == "}") {
			if (loadent) {
				loadent.RestoreComplete();
				num_loaded++;
				if (STRING_SET(loadent.spawnclass) && loadent.classname != loadent.spawnclass) {
					ncLog("instantiated %s (%s) (edict %d)", loadent.classname, loadent.spawnclass, n);
				} else {
					ncLog("created %s (edict %d)", loadent.classname, n);
				}
				loadent = __NULL__;
			}
		} else {
			if (loadent) {
				int c = tokenize(l);
				string keyName = argv(0);
				string setValue = argv(1);

				if (c == 2) {
					switch (keyName) {
					case "classname":
						loadent.classname = setValue;
						break;
					case "declclass":
						loadent.declclass = setValue;

						if (STRING_SET(setValue)) {
							/* used to network our shared ID */
							loadent.entityDefID = EntityDef_NetIDFromName(loadent.declclass);
							loadent.ReloadCachedAttributes();
						}
						break;
					default:
						loadent.Restore(keyName, setValue);
					}
					//print(sprintf("%s %s\n", argv(0), argv(1)));
				}
			}
		}
	}

	ncLog("...loaded %i entities", num_loaded);
	g_isloading = false;
}

string
ncSessionManager::GetGlobal(string globalName)
{
	if (g_globalDictionary) {
		return g_globalDictionary.GetString(globalName);
	}

	return ("");
}

void
ncSessionManager::SetGlobal(string globalName, string setValue)
{
	if (!g_globalDictionary) {
		g_globalDictionary = spawn(ncDict);
	}

	if (STRING_SET(setValue)) {
		g_globalDictionary.AddKey(globalName, setValue);
		EntLog("Set global %s to %S", globalName, setValue);
	} else if (STRING_SET(globalName)) {
		g_globalDictionary.RemoveKey(globalName);
		EntLog("Removed global %s", globalName, setValue);
	}
}

void
ncSessionManager::ListGlobals(void)
{
	print("List Global State:\n");

	if (g_globalDictionary) {
		print(strcat("\t", g_globalDictionary.GetDeclBody()));
	}

	print("\nEnd Of List\n");
}

void
ncSessionManager::SaveStateToHandle(float fh, float entcount, float playerslots)
{
	float i = 0;
	int num_saved = 0i;
	entity e;

	fputs(fh, sprintf("GLOBAL %S\n", g_globalDictionary.GetDeclBody()));

	for (i = 0; i < entcount; i++) {
		ncEntity willsave;
		e = edict_num(i);

		if (e==world && i) {
			continue;
		}

		if (wasfreed(e)) {
			continue;
		}

		if (e.identity == 0) {
			continue;
		}

		willsave = (ncEntity)e;

		if (!STRING_SET(willsave.declclass)) {
			willsave.spawnclass = willsave.classname;
		}

		fputs(fh, sprintf("ENTITY \"%d\" %S\n", i, willsave.spawnclass));
		fputs(fh, "{\n");
		fputs(fh, sprintf("%S %S\n", "classname", willsave.classname));
		fputs(fh, sprintf("%S %S\n", "declclass", willsave.declclass));
		willsave.Save(fh);
		fputs(fh, "}\n");
		num_saved++;
	}
	fclose(fh);

	ncLog("saved %i entities", num_saved);
}
