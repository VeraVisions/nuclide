/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

int g_iModInstallCache;
string g_strModInstallCache;

var int gameinfo_current = -1;

/* local game/mod info parsing */
static void
GameLibrary_Set(int id)
{
	gameinfo_current = id;
	setwindowcaption(games[id].game);
	cvar_set("com_fullgamename", games[id].game);
}

static int
GameLibrary_IDForPackageName(string packageName)
{
	string f;

	for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string name;
		name = getpackagemanagerinfo(i, GPMI_NAME);

		/* Spike started randomly putting version numbers into package names */
		f = sprintf("%s=%s", packageName, getpackagemanagerinfo(i, GPMI_VERSION));

		if (name == f) {
			return i;
		}
	}

	/* no package id whatsoever */
	return (-1i);
}

/** Looks for a single file inside a gamedir, including its pk3s and returns a valid filehandle if it is found. */
static filestream
GameLibrary_FindInGameDir(string filename, string gamedirname)
{
	searchhandle sh;
	searchhandle gsh;
	searchhandle psh;
	filestream fh;

	/* if we're querying a file in our mounted game, we can exit early */
	if (gamedirname == cvar_string("fs_game")) {
		fh = fopen(filename, FILE_READ);

		if (fh >= 0) {
			return fh;
		}
	}

	/* first let's see if we've got a liblist.gam just floating inside the gamedir */
	gsh = search_begin(filename, SB_FULLPACKAGEPATH | SB_FORCESEARCH | SEARCH_ALLOWDUPES, FALSE, gamedirname);
	fh = search_fopen(gsh, 0);

	/* we do not. let's search for pk3's to sift through */
	if (fh < 0) {
		/* let's search for every pk3 in the gamedir and search for a liblist, one at a time. */
		psh = search_begin("*.pk3", SB_FULLPACKAGEPATH | SB_FORCESEARCH, FALSE, gamedirname);

		/* loop through each pk3 in reverse (newest to old) */
		for (int i = search_getsize(psh); i >= 0; i--) {
			string full = search_getfilename(psh, i);

			if (!full)
				continue;

			sh = search_begin(filename, SB_FULLPACKAGEPATH | SB_FORCESEARCH, FALSE, strcat(gamedirname, "/", full));
			fh = search_fopen(sh, 0);
			//print(sprintf("looking for %s in %s\n", filename, strcat(gamedirname, "/", full)));

			/* we found one */
			if (fh >= 0) {
				search_end(sh);
				break;
			}
			search_end(sh);
		}
		search_end(psh);
	}

	/* still nothing. let's search for pk4's to sift through */
	if (fh < 0) {
		/* let's search for every pk4 in the gamedir and search for a liblist, one at a time. */
		psh = search_begin("*.pk4", SB_FULLPACKAGEPATH | SB_FORCESEARCH | SEARCH_ALLOWDUPES, FALSE, gamedirname);

		/* loop through each pk4 in reverse (newest to old) */
		for (int i = search_getsize(psh); i >= 0; i--) {
			string full = search_getfilename(psh, i);

			if (!full)
				continue;

			sh = search_begin(filename, SB_FULLPACKAGEPATH | SB_FORCESEARCH | SEARCH_ALLOWDUPES, FALSE, strcat(gamedirname, "/", full));
			fh = search_fopen(sh, 0);

			/* we found one */
			if (fh >= 0) {
				search_end(sh);
				break;
			}
			search_end(sh);
		}
		search_end(psh);
	}

	search_end(gsh);
	return (fh);
}

#ifndef WEBMENU
/** Parses a key/value pair from liblist.gam files */
static void
GameLibrary_LibListParse(int id, string strKey, string strValue)
{
	//if (id == 0)
		//print(sprintf("%i %S %S\n", id, strKey, strValue));

	switch(strKey) {
	case "game":
		games[id].game = strValue;
		break;
	case "gamedir":
		games[id].gamedir = strValue;
		break;
	case "fallback_dir":
		games[id].fallback_dir = strValue;
		break;
	case "url_info":
		games[id].url_info = strValue;
		break;
	case "url_dl":
		games[id].url_dl = strValue;
		break;
	case "version":
		games[id].version = strValue;
		break;
	case "size":
		games[id].size = (int)stof(strValue);
		break;
	case "svonly":
		games[id].svonly = (int)stof(strValue);
		break;
	case "cldll":
		games[id].cldll = (int)stof(strValue);
		break;
	case "type":
		switch (strtolower(strValue)) {
		case "multiplayer_only":
		case "multiplayer only":
			games[id].type = "Multiplayer";
			break;
		case "singleplayer_only":
		case "singleplayer only":
			games[id].type = "Singleplayer";
			break;
		/* this... kind of sucks, but some games (gearbox) never updated
		 * their liblist to reflect that they do multiplayer */
		case "sp":
		case "single":
		case "singleplayer":
		case "mp":
		case "multi":
		case "multiplayer":
		default:
			games[id].type = "Both";
		}
		break;
	case "minversion":
	case "minversion":
		games[id].minversion = strValue;
		break;
	case "nomodels":
		games[id].nomodels = (int)stof(strValue);
		break;
	case "nosprays":
		games[id].nosprays = (int)stof(strValue);
		break;
	case "mpentity":
		games[id].mpentity = strValue;
		break;
	case "gamedll":
		games[id].gamedll = strValue;
		break;
	case "startmap":
		games[id].startmap = strcat("map ", strValue, "\n");
		break;
	case "trainmap":
	case "trainingmap":
		games[id].trainingmap = strcat("map ", strValue, "\n");
		break;
	/* newly added with Nuclide */
	case "pkgname":
		games[id].pkgname = strValue;
		games[id].pkgid = GameLibrary_IDForPackageName(games[id].pkgname);
		break;
	case "pkgfile":
		games[id].pkgfile = strValue;
		break;
	case "chatroom":
		games[id].chatroom = strValue;
		break;
	case "readme":
		games[id].readme = strValue;
		break;
	case "menumap":
		games[id].menumap = strValue;
		break;
	case "introvideo":
		games[id].introvideo = strValue;
		break;
	case "base_dir":
		games[id].base_dir = strValue;
		break;
	default:
		break;
	}
}

/** Check if a gameinfo.txt for the gamedir contains gameinfo, parse it if present. Returns true on success. */
static bool
GameLibrary_CheckGameInfo(int id, string gamedirname)
{
	string temp;
	filestream fh;
	int ret = 0;

	fh = GameLibrary_FindInGameDir("gameinfo.txt", gamedirname);

	if (fh < 0)
		fh = GameLibrary_FindInGameDir("GameInfo.txt", gamedirname);

	/* we have found a liblist.gam */
	if (fh >= 0) {
		string gamedirchain = "";
		int braced = 0;

		while ((temp = fgets(fh))) {
			string token;
			tokenize_console(temp);
			token = strtolower(argv(0));

			if (!token)
				continue;

			if (token == "{")
				braced++;

			if (token == "}")
				braced--;

			if (braced == 1) {
				/* GameInfo */
				switch (token) {
				case "game":
					games[id].game = argv(1);
					break;
				case "type":
					games[id].type = argv(1);
					break;
				}
			} else if (braced == 2) {
				/* FileSystem */
				switch (token) {
				case "steamappid":
					break;
				case "toolsappid":
					break;
				}
			} else if (braced == 3) {
				/* SearchPaths */
				switch (token) {
				case "game":
					if (argv(1) == "|gameinfo_path|.")
						gamedirchain = strcat(gamedirchain, games[id].gamedir, " ");
					else
						gamedirchain = strcat(gamedirchain, argv(1), " ");
					break;
				}
			}
		}

		/* in gameinfo.txt files, we list game load-order in reverse */
		if (gamedirchain) {
			string maindir = games[id].gamedir;
			float c = tokenize(gamedirchain);

			for (float i = c-1; i >= 0; i--) {
				if (argv(i) == maindir)
					continue;

				if (i == 0)
					games[id].gamedir = strcat(games[id].gamedir, argv(i));
				else
					games[id].gamedir = strcat(games[id].gamedir, argv(i), ";");
			}
		}

		fclose(fh);
		ret = 1;
	}

	return (ret);
}

/** Check if a manifest for the gamedir contains gameinfo, parse it if present. Returns true on success. */
static bool
GameLibrary_CheckManifest(int id, string gamedirname)
{
	int ret = 0;
	float count;

	string gamedescription = getgamedirinfo(id, 2);

	/* no manifest, or no cvar strings inside */
	if (gamedescription == "") {
		return (0);
	}

	count = tokenize_console(gamedescription);

	for (int i = 0; i < count; i++) {
		string full = argv(i);
		string first = substring(full, 0, 9);
		string second = substring(full, 9, -1);

		/* we may have a game manifest, but if it doesn't
		 * contains any gameinfo entries a different file
		 * should probably be parsed later */
		if (first == "gameinfo_") {
			GameLibrary_LibListParse(id, second, argv(i+1));
			ret = 1;
		}
	}

	return (ret);
}

/** Check if a liblist exists, and parse it if present. Returns true on success. */
static bool
GameLibrary_CheckLibList(int id, string gamedirname)
{
	string temp;
	filestream fh;
	int ret = 0;

	/* first let's see if we've got a liblist.gam just floating inside the gamedir */
	fh = GameLibrary_FindInGameDir("liblist.gam", gamedirname);

	/* we have found a liblist.gam */
	if (fh >= 0) {
		while ((temp = fgets(fh))) {
			tokenize(temp);
			GameLibrary_LibListParse(id, argv(0), argv(1));
		}
		fclose(fh);
		ret = 1;
	}

	return (ret);
}

/** Set some sane game defaults into a game id slot based on gamedir name. */
static void
GameLibrary_SetDefaults(int id, string gamedirname)
{
	/* Fill in the defaults */
	games[id].game = gamedirname;
	games[id].gamedir = gamedirname;
	games[id].base_dir = GAME_DIR;
	games[id].url_info = "";
	games[id].url_dl = "";
	games[id].version = "1.0";
	games[id].size = 0;
	games[id].type = "Both";
	games[id].nomodels = 0;
	games[id].nosprays = 0;
	games[id].mpentity = "info_player_deathmatch";
	games[id].gamedll = "progs.dat";
	games[id].startmap = "map c0a0\n";
	games[id].trainingmap = "map t0a0\n";
	games[id].cldll = 1;
	games[id].minversion = "1000";
	games[id].svonly = 0;
	games[id].installed = 1;
	games[id].chatroom = gamedirname;
	games[id].readme = "readme.txt";
	games[id].pkgid = -1;

	if (games[id].gamedir == "valve") {
		games[id].chatroom = "halflife";
	}
}

/** Checks if a given game directory was installed manually. */
static bool
GameLibrary_CheckLocalPresence(string gameDir)
{
	string testPkgDir = __NULL__;
	bool returnSuccess = true;

	for (int x = 0i; (testPkgDir = getgamedirinfo(x, 0)); x++) {
		if (gameDir == testPkgDir) {
			return true;
		}
	}

	return false;
}

void
GameLibrary_InitCustom(void)
{
	int id;
	int foundself = 0;
	string gamedirname = __NULL__;
	int old_count = gameinfo_count;
	int packageinfo_count = 0i;
	int c = 0i;

	gameinfo_count = 0i;

	/* first count let's all manually installed mods */
	for (id = 0; (gamedirname = getgamedirinfo(id, 0)); id++) {
		gameinfo_count++;
	}

	/* count the package installed mods after */
	for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string packageName = getpackagemanagerinfo(i, GPMI_NAME);
		string installStatus = getpackagemanagerinfo(i, GPMI_INSTALLED);
		string prefix = substring(packageName, 0, 3);

		/* only care about installed mods (custom games) */
		if (prefix == "cg_" && installStatus == "enabled") {
			string gameDir = substring(packageName, 3, -1);
			tokenizebyseparator(gameDir, "=");
			gameDir = argv(0);

			/* check if this mod was installed manually already */
			if (GameLibrary_CheckLocalPresence(gameDir) == true) {
				continue;
			}

			packageinfo_count++;
		}
	}

	/* re-allocate the game list */
	games = (gameinfo_t *)memrealloc(games, sizeof(gameinfo_t), old_count, (gameinfo_count + packageinfo_count));

	/* The things we do for frequent flyer mileage. */
	if (!games) {
		NSError("Attempting to allocate mod data for %i entries failed.", gameinfo_count);
		crash();
		return;
	}

	/* now loop through all the mods we found and load in the metadata */
	for (id = 1; id < gameinfo_count; id++) {
		gamedirname = getgamedirinfo(id, 0);
		GameLibrary_SetDefaults(id, gamedirname);

		if (GameLibrary_CheckManifest(id, gamedirname) == true) {
			NSLog("[MENU] Found manifest for %s", gamedirname);
			games[id].info_type = GAMEINFO_MANIFEST;
		} else if (GameLibrary_CheckGameInfo(id, gamedirname) == true) {
			NSLog("[MENU] Found gameinfo for %s", gamedirname);
			games[id].info_type = GAMEINFO_GITXT;
		} else if (GameLibrary_CheckLibList(id, gamedirname) == true) {
			NSLog("[MENU] Found liblist for %s", gamedirname);
			games[id].info_type = GAMEINFO_LIBLIST;
		} else {
			NSLog("[MENU] Found nothing for %s", gamedirname);
			games[id].info_type = GAMEINFO_NONE;
		}
		c = id + 1;
	}

	/* iterate through all packages again */
	for (int i = 0i; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string packageName = getpackagemanagerinfo(i, GPMI_NAME);
		string installStatus = getpackagemanagerinfo(i, GPMI_INSTALLED);
		string prefix = substring(packageName, 0, 3);

		/* same check as above in the counter */
		if (prefix == "cg_" && installStatus == "enabled") {
			string gameDir = substring(packageName, 3, -1);
			tokenizebyseparator(gameDir, "=");
			gameDir = argv(0);

			if (GameLibrary_CheckLocalPresence(gameDir) == true) {
				continue;
			}

			string titleString = getpackagemanagerinfo(i, GPMI_TITLE);
			string versionString = getpackagemanagerinfo(i, GPMI_VERSION);
			string authorString = getpackagemanagerinfo(i, GPMI_AUTHOR);
			string sizeString = getpackagemanagerinfo(i, GPMI_FILESIZE);
			string websiteString = getpackagemanagerinfo(i, GPMI_WEBSITE);

			//print(sprintf("Adding packaged game %S\n", gameDir));
			GameLibrary_SetDefaults(c, gameDir);

			games[c].game = substring(titleString, 5, -1); /* strip 'Mod: '*/
			games[c].url_info = websiteString;
			games[c].version = versionString;
			games[c].size = (int)stof(sizeString);
			games[c].type = "Both";
			games[c].info_type = GAMEINFO_PACKAGE;
			games[c].pkgname = strcat("cg_", gameDir, ";game_", gameDir, ";");
			c++;
		}
	}

	/* now we can pretend that these weren't their own thing */
	gameinfo_count += packageinfo_count;

	/* we may have some mods, but we're not running any of them. Fatal */
	if (gameinfo_current == -1) {
		NSError("No definition for current game found. Fatal.");
		crash();
		return;
	}

	NSLog("...GameLibrary initialized (%i entries).", gameinfo_count);
}
#endif

void
GameLibrary_Init(void)
{
	int id = 0i;
	string gamedirname = cvar_string("game");

	g_iModInstallCache = -1;
	g_strModInstallCache = __NULL__;
	gameinfo_count = 1; /* we start at 1 game, ours */
	games = memalloc(sizeof(gameinfo_t) * gameinfo_count);

	/* set the default packages for a given game */
	GameLibrary_SetDefaults(id, gamedirname);

	gameinfo_current = 0i;

	/* only run this when not in web-client mode */
#ifndef WEBMENU
	if (GameLibrary_CheckManifest(id, gamedirname) == 1) {
		NSLog("[MENU] Found manifest for %s", gamedirname);
		games[id].info_type = GAMEINFO_MANIFEST;
	} else if (GameLibrary_CheckGameInfo(id, gamedirname) == 1) {
		NSLog("[MENU] Found gameinfo for %s", gamedirname);
		games[id].info_type = GAMEINFO_GITXT;
	} else if (GameLibrary_CheckLibList(id, gamedirname) == 1) {
		NSLog("[MENU] Found liblist for %s", gamedirname);
		games[id].info_type = GAMEINFO_LIBLIST;
	} else {
		NSLog("[MENU] Found nothing for %s", gamedirname);
		games[id].info_type = GAMEINFO_NONE;
	}
#endif

	/* set the current game to be us */
	GameLibrary_Set(id);
}

static void
GameLibrary_EndInstall(void)
{
	int gid = g_iModInstallCache;
	NSLog("Installation ended for %S.", g_strModInstallCache);
	localcmd(sprintf("game %s\n", g_strModInstallCache));

	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
	localcmd("menu_musicstart\n");
	g_iModInstallCache = -1i;
	g_strModInstallCache = __NULL__;
}

bool
GameLibrary_IsInstalling(void)
{
	return (g_iModInstallCache == -1i) ? false : true;
}

float
GameLibrary_InstallProgress(void)
{
	int id;
	float perc;
	float c;
	bool loading = false;

	/* download percentage */
	perc = 0.0f;
	loading = FALSE;

	/* a game can have multiple packages associated */
	id = g_iModInstallCache;
	c = tokenize(games[id].pkgname);

	/* go through all invididual packages */
	for (float i = 0; i < c; i++) {
		string st;
		int pkgid;

		/* package query */
		pkgid = GameLibrary_IDForPackageName(argv(i));
		st = getpackagemanagerinfo(pkgid, GPMI_INSTALLED);

		/* filter out statuses so we can calculate percentage */
		switch (st) {
		case "":
		case "pending":
		case "enabled":
		case "present":
		case "corrupt":
			break;
		default:
			perc += stof(st);
		}

		/* all packages need to be 'enabled', else fail to end */
		if (st != "enabled")
			loading = true;
	}

	/* not everything has been downloaded */
	if (loading == TRUE)
		return perc / c;

	GameLibrary_EndInstall();

	return 0.0f;
}


static void
GameLibrary_InstallStart(int gameid)
{
	int count;

	count = tokenize(games[gameid].pkgname);

	for (int i = 0; i < count; i++) {
		int pkgid = GameLibrary_IDForPackageName(argv(i));
		localcmd(sprintf("pkg add %s\n", argv(i)));
		NSLog("Marking package %s for install.", argv(i));
	}

	g_iModInstallCache = gameid;
	g_strModInstallCache = games[gameid].gamedir;
	localcmd("pkg apply\n");
	NSLog("Starting installation of custom game packages.");
}

void
GameLibrary_Install(int gameID)
{
	string st;

	if (gameID >= gameinfo_count || gameID < 0i) {
		NSError("Invalid game id %i!\n", gameID);
		return;
	}

	st = getpackagemanagerinfo(games[gameID].pkgid, GPMI_INSTALLED);

	if (st != "enabled") {
		GameLibrary_InstallStart(gameID);
		return;
	}

	g_iModInstallCache = gameID;
	g_strModInstallCache = games[gameID].gamedir;
	GameLibrary_EndInstall();
}

void
GameLibrary_Activate(int gameID)
{
	if (gameID >= gameinfo_count || gameID < 0i) {
		NSError("Invalid game id %i.", gameID);
		return;
	}

	GameLibrary_Set(gameID);

	if (games[gameID].info_type == GAMEINFO_MANIFEST)
		localcmd(sprintf("gamedir %s %s.fmf\nfs_changegame %s -\n", games[gameID].gamedir, games[gameID].gamedir, games[gameID].gamedir));
	else if (games[gameID].info_type == GAMEINFO_LIBLIST) {
		/* some games/mods inherit other directories */
		if (games[gameID].fallback_dir) {
			localcmd(sprintf("gamedir \"%s;%s;%s\"\n", games[gameID].base_dir, games[gameID].fallback_dir, games[gameID].gamedir));
		} else {
			localcmd(sprintf("gamedir \"%s;%s\"\n", games[gameID].base_dir, games[gameID].gamedir));
		}
	} else
		localcmd(sprintf("gamedir \"%s;%s\"\n", games[gameID].base_dir, games[gameID].gamedir));

	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
	localcmd("menu_musicstart\n");
}

void
GameLibrary_Deactivate(void)
{
	localcmd(sprintf("gamedir %s\n", GAME_DIR));
	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
	localcmd("menu_musicstart\n");
}

int
GameLibrary_GetCurrentGame(void)
{
	return gameinfo_current;
}

int
GameLibrary_GetGameCount(void)
{
	return gameinfo_count;
}

__variant
GameLibrary_GetInfo(gameInfo_t infoType)
{
	return GameLibrary_GetGameInfo(gameinfo_current, infoType);
}

__variant
GameLibrary_GetGameInfo(int gameID, gameInfo_t infoType)
{
	if (gameID >= gameinfo_count || gameID < 0i) {
		NSError("Invalid game id %i.", gameID);
		return __NULL__;
	}

	switch (infoType) {
	case GAMEINFO_TITLE:
		return (string)games[gameID].game;
		break;
	case GAMEINFO_GAMEDIR:
		return (string)games[gameID].gamedir;
		break;
	case GAMEINFO_FALLBACKDIR:
		return (string)games[gameID].fallback_dir;
		break;
	case GAMEINFO_BASEDIR:
		return (string)games[gameID].base_dir;
		break;
	case GAMEINFO_WEBSITE:
		return (string)games[gameID].url_info;
		break;
	case GAMEINFO_VERSION:
		return (string)games[gameID].version;
		break;
	case GAMEINFO_SIZE:
		return (int)games[gameID].size;
		break;
	case GAMEINFO_TYPE:
		return (string)games[gameID].type;
		break;
	case GAMEINFO_NOPLAYERMODELS:
		return games[gameID].nomodels == 1 ? true : false;
		break;
	case GAMEINFO_NOSPRAYS:
		return games[gameID].nosprays == 1 ? true : false;
		break;
	case GAMEINFO_STARTMAP:
		return (string)games[gameID].startmap;
		break;
	case GAMEINFO_TRAININGMAP:
		return (string)games[gameID].trainingmap;
		break;
	case GAMEINFO_MINVERSION:
		return (string)games[gameID].minversion;
		break;
	case GAMEINFO_CHATROOM:
		return (string)games[gameID].chatroom;
		break;
	case GAMEINFO_READMEFILE:
		return (string)games[gameID].readme;
		break;
	case GAMEINFO_INTROVIDEO:
		return (string)games[gameID].introvideo;
		break;
	case GAMEINFO_MENUMAP:
		return (string)games[gameID].menumap;
		break;
	case GAMEINFO_AUTHOR:
		return (string)"Unknown";
		break;
	case GAMEINFO_AUTHORSITE:
		return (string)"Unknown";
		break;
	case GAMEINFO_PACKAGELIST:
		return (string)games[gameID].pkgname;
		break;
	case GAMEINFO_INSTALLED:
		return games[gameID].installed == 1 ? true : false;
	default:
		return __NULL__;
	}
}

void
GameLibrary_DebugList(void)
{
	for (int i = 0; i < gameinfo_count; i++) {
		print(sprintf("%i %s (%s)\n", i, games[i].game, games[i].gamedir));
	}

	print(sprintf("\t%i game(s) loaded.", gameinfo_count));
}
