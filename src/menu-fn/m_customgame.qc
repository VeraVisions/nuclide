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

/* the menu specific variables */
#ifndef WEBMENU
CWidget fn_customgame;
CFrame customgame_frMods;
CModList customgame_lbMods;
CScrollbar customgame_sbMods;
CDialog customgame_dlgWait;

CMainButton customgame_btnActivate;
CMainButton customgame_btnInstall;
CMainButton customgame_btnVisit;
CMainButton customgame_btnRefresh;
CMainButton customgame_btnDeactivate;
CMainButton customgame_btnDone;

int g_iModInstallCache;
string g_strModInstallCache;

#if 1
/* get installing id */
void
game_getinstallcache(void)
{
	int ret;
	filestream fs_cache;

	ret = 0;
	fs_cache = fopen("mcache.dat", FILE_READ);

	if (fs_cache >= 0) {
		g_iModInstallCache = (int)stof(fgets(fs_cache));
		g_strModInstallCache = fgets(fs_cache);
		fclose(fs_cache);
	} else {
		g_iModInstallCache = -1;
		g_strModInstallCache = "";
	}

	print(sprintf("id: %i, name: %s\n", ret, g_strModInstallCache));
}

/* write installing id */
void
game_writeinstallcache(int id, string gamedir)
{
	filestream fs_cache;

	fs_cache = fopen("mcache.dat", FILE_WRITE);
	g_iModInstallCache = id;
	g_strModInstallCache = gamedir;

	if (fs_cache >= 0) {
		fputs(fs_cache, sprintf("%i\n",id));
		fputs(fs_cache, gamedir);
		fclose(fs_cache);
	}
}
#endif

int
game_getpackageid(string pkgname)
{
	string f;

	for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string name;
		name = getpackagemanagerinfo(i, GPMI_NAME);

		/* Spike started randomly putting version numbers into package names */
		f = sprintf("%s=%s", pkgname, getpackagemanagerinfo(i, GPMI_VERSION));

		if (name == f) {
			return i;
		}
	}

	/* no package id whatsoever */
	return (-1);
}

/* return 1 if any of the packages are pending, installing, or corrupt */
int
game_updatesavailable(void)
{
	/* look for the valid packages in the gameinfo pkgname */
	int pkgcount = tokenize(games[gameinfo_current].pkgname);

	for (int i = 0i; i < pkgcount; i++) {
		int id = game_getpackageid(argv(i));
		string status = getpackagemanagerinfo(id, GPMI_INSTALLED);

		if (id == -1)
			continue;

		switch (status) {
		case "":
			if (updates[id].installed == "") {
				return (1);
			} else if (updates[id].installed == "pending") {
				return (1);
			}
			break;
		case "pending":
			return (1);
			break;
		case "enabled":
			break;
		case "present":
			return (1);
			break;
		case "corrupt":
			return (1);
			break;
		default:
			/* we're currently installing stuff */
			return (1);
			break;
		}
	}

	/* everything is installed */
	return (0);
}

int
game_updateinstallcount(void)
{
	int count = 0;

	/* always return something positive when no packages are defined */
	if (games[gameinfo_current].pkgname == "") {
		return (1);
	}

	/* look for the valid packages in the gameinfo pkgname */
	int pkgcount = tokenize(games[gameinfo_current].pkgname);

	for (int i = 0i; i < pkgcount; i++) {
		int id = game_getpackageid(argv(i));
		string status = getpackagemanagerinfo(id, GPMI_INSTALLED);
		
		switch (status) {
		case "":
			break;
		case "pending":
			break;
		case "enabled":
			count++;
			break;
		case "present":
			count++;
			break;
		case "corrupt":
			count++;
			break;
		default:
			/* we're currently installing stuff */
			break;
		}
	}

	/* everything is installed */
	return count;
}
#endif

/* local game/mod info parsing */
void
games_set(int id)
{
	gameinfo_current = id;
	setwindowcaption(games[id].game);
	cvar_set("com_fullgamename", games[id].game);
}

#ifndef WEBMENU
void
customgame_liblist_parse(int id, string strKey, string strValue)
{
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
	case "hlversion":
		games[id].hlversion = strValue;
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
	case "trainingmap":
		games[id].trainingmap = strcat("map ", strValue, "\n");
		break;
	/* newly added with Nuclide */
	case "pkgname":
		games[id].pkgname = strValue;
		games[id].pkgid = game_getpackageid(games[id].pkgname);
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
	case "steambg":
		games[id].steambg = (int)stof(strValue);
		break;
	case "base_dir":
		games[id].base_dir = strValue;
		break;
	default:
		break;
	}
}

/* looks for a single find inside a gamedir, including its pk3s and returns
 * a valid filehandle if it is found */
filestream
games_find_in_gamedir(string filename, string gamedirname)
{
	searchhandle sh;
	searchhandle gsh;
	searchhandle psh;
	filestream fh;

	/* first let's see if we've got a liblist.gam just floating inside the gamedir */
	gsh = search_begin(filename, SB_FULLPACKAGEPATH | SB_FORCESEARCH, FALSE, gamedirname);
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
		psh = search_begin("*.pk4", SB_FULLPACKAGEPATH | SB_FORCESEARCH, FALSE, gamedirname);

		/* loop through each pk4 in reverse (newest to old) */
		for (int i = search_getsize(psh); i >= 0; i--) {
			string full = search_getfilename(psh, i);

			if (!full)
				continue;

			sh = search_begin(filename, SB_FULLPACKAGEPATH | SB_FORCESEARCH, FALSE, strcat(gamedirname, "/", full));
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

/* check if a gameinfo.txt for the gamedir contains gameinfo, parse it if present */
int
games_check_gtxt(int id, string gamedirname)
{
	string temp;
	filestream fh;
	int ret = 0;

	fh = games_find_in_gamedir("gameinfo.txt", gamedirname);

	if (fh < 0)
		fh = games_find_in_gamedir("GameInfo.txt", gamedirname);

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

/* check if a manifest for the gamedir contains gameinfo, parse it if present */
int
games_check_manifest(int id, string gamedirname)
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
			customgame_liblist_parse(id, second, argv(i+1));
			ret = 1;
		}
	}

	return (ret);
}

/* check if a liblist, parse it if present */
int
games_check_liblist(int id, string gamedirname)
{
	string temp;
	filestream fh;
	int ret = 0;

	/* first let's see if we've got a liblist.gam just floating inside the gamedir */
	fh = games_find_in_gamedir("liblist.gam", gamedirname);

	/* we have found a liblist.gam */
	if (fh >= 0) {
		while ((temp = fgets(fh))) {
			tokenize(temp);
			customgame_liblist_parse(id, argv(0), argv(1));
		}
		fclose(fh);
		ret = 1;
	}

	return (ret);
}

void
customgame_btnactivate_start(void)
{
	int nextgame = customgame_lbMods.GetSelected();

	games_set(nextgame);

#if 0
	localcmd(sprintf("gamedir %s %s.fmf\nfs_changegame %s -\n", games[nextgame].gamedir, games[nextgame].gamedir, games[nextgame].gamedir));
#else
	if (games[nextgame].info_type == GAMEINFO_MANIFEST)
		localcmd(sprintf("gamedir %s %s.fmf\nfs_changegame %s -\n", games[nextgame].gamedir, games[nextgame].gamedir, games[nextgame].gamedir));
	else if (games[nextgame].info_type == GAMEINFO_LIBLIST) {
		/* some games/mods inherit other directories */
		if (games[nextgame].fallback_dir) {
			localcmd(sprintf("gamedir \"logos;platform;%s;%s;%s\"\n", games[nextgame].base_dir, games[nextgame].fallback_dir, games[nextgame].gamedir));
		} else {
			localcmd(sprintf("gamedir \"logos;platform;%s;%s\"\n", games[nextgame].base_dir, games[nextgame].gamedir));
		}
	} else
		localcmd(sprintf("gamedir \"logos;platform;%s;%s\"\n", games[nextgame].base_dir, games[nextgame].gamedir));
#endif

	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
	localcmd("menu_musicstart\n");
}



#if 1
void
customgame_installstart(int gameid)
{
	int count;
	count = tokenize(games[gameid].pkgname);

	for (int i = 0; i < count; i++) {
		int pkgid = game_getpackageid(argv(i));
		localcmd(sprintf("pkg add %s\n", argv(i)));
		print(sprintf("Marking package %s for install.\n",
		      argv(i)));
	}

	game_writeinstallcache(gameid, games[gameid].gamedir);
	localcmd("pkg apply\n");
	print("Starting installation of custom game packages\n");
}

void
customgame_installend(void)
{
	int gid = g_iModInstallCache;
	print("install-end!\n");

	localcmd(sprintf("fs_changegame %s http://www.frag-net.com/mods/%s.fmf\n", g_strModInstallCache, g_strModInstallCache));
	game_writeinstallcache(-1, g_strModInstallCache);
}

void
customgame_installframe(void)
{
	int id;
	float perc;
	float c;
	int loading;

	/* graphical frame */
	customgame_dlgWait.Draw();
	WField_Static(162, 180, "Installing mod data...", 320, 260,
		col_prompt_text, 1.0f, 2, font_label_p);

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
		pkgid = game_getpackageid(argv(i));
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
			loading = TRUE;
	}

	/* display download percentage we calculated */
	perc = perc / c;
	WField_Static(162, 220, sprintf("%d%%", perc), 320, 260,
		[1,1,1], 1.0f, 2, font_label_p);
	WField_Static(162, 260, "Service provided by frag-net.com through archive.org", 320, 260,
		[1,1,1], 1.0f, 2, font_label);

	/* not everything has been downloaded */
	if (loading == TRUE)
		return;

	customgame_installend();
}
#endif

/* download the .fmf and switch games immediately */
void
customgame_btninstall_start(void)
{
#if 1
	int id = customgame_lbMods.GetSelected();
	string st;

	st = getpackagemanagerinfo(games[id].pkgid, GPMI_INSTALLED);

	print(st);
	print("\n");

	if (st != "enabled") {
		customgame_installstart(id);
		return;
	}

	game_writeinstallcache(id, games[id].gamedir);
	customgame_installend();
#else
	int nextgame = customgame_lbMods.GetSelected();
	localcmd(sprintf("fs_changegame %s http://www.frag-net.com/mods/%s.fmf\n", games[nextgame].gamedir, games[nextgame].gamedir));
#endif
}

void 
customgame_btndeactivate_start(void)
{
	localcmd(sprintf("gamedir %s\n", GAME_DIR));
	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
	localcmd("menu_musicstart\n");
}

void
customgame_btndone_start(void)
{
	static void customgame_btndone_end(void) {
		g_menupage = PAGE_MAIN;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,70,348);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CUSTOM);
	header.SetExecute(customgame_btndone_end);
}

void
customgame_sbmods_changed(int val)
{
	customgame_lbMods.SetScroll(val);
}

void
customgame_lbmods_changed(void)
{
	int gid = customgame_lbMods.GetSelected();

	if (games[gid].installed == TRUE) {
		customgame_btnActivate.SetExecute(customgame_btnactivate_start);
		customgame_btnInstall.SetExecute(__NULL__);
	} else {
		customgame_btnActivate.SetExecute(__NULL__);
		customgame_btnInstall.SetExecute(customgame_btninstall_start);
	}
}

/* set some sane default packages, so that we don't need to ship a custom liblist */
void
games_setdefaultpkgs(int id)
{
	if (games[id].gamedir == "valve") {
		games[id].pkgname = "valve_dayone;valve_uplink;valve_realmedia;valve_opfordemo;valve_hlds;valve_patch1110;addon_furtherdata;addon_holidaymodels";
		games[id].pkgfile = "maps/crossfire.bsp";
	}
}

void
games_init_2(void)
{
	int id;
	int foundself = 0;
	string gamedirname;
	gameinfo_count = 0;

	for (id = 0; (gamedirname = getgamedirinfo(id, 0)); id++) {
		/* in case FTE does not report the current game we're playing, sigh */
		if (gamedirname == cvar_string("game"))
			foundself = 1;

		gameinfo_count++;
	}

	/* append current game to the very end */
	if (!foundself) {
		//games_set(gameinfo_count);
		gameinfo_count++;
	}

	memfree(games);
	games = memalloc(sizeof(gameinfo_t) * gameinfo_count);

	/* The things we do for frequent flyer mileage. */
	if (!games)
		error(sprintf("Attempting to allocate mod data for %i entries failed\n", gameinfo_count));

	/* now loop through all the mods we found and load in the metadata */
	for (id = 0; id < gameinfo_count; id++) {
		gamedirname = getgamedirinfo(id, 0);

		/* handle the case if we didn't get reported our own game */
		if (!foundself)
		if (id == (gameinfo_count-1)) {
			gamedirname = cvar_string("game");
		}

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
		games[id].hlversion = "1000";
		games[id].svonly = 0;
		games[id].installed = 1;
		games[id].chatroom = gamedirname;
		games[id].readme = "readme.txt";
		games[id].pkgid = -1;
		games[id].steambg = 0;

		games_setdefaultpkgs(id);

		if (games_check_manifest(id, gamedirname) == 1) {
			NSLog("[MENU] Found manifest for %s", gamedirname);
			games[id].info_type = GAMEINFO_MANIFEST;
		} else if (games_check_gtxt(id, gamedirname) == 1) {
			NSLog("[MENU] Found gameinfo for %s", gamedirname);
			games[id].info_type = GAMEINFO_GITXT;
		} else if (games_check_liblist(id, gamedirname) == 1) {
			NSLog("[MENU] Found liblist for %s", gamedirname);
			games[id].info_type = GAMEINFO_LIBLIST;
		} else {
			NSLog("[MENU] Found nothing for %s", gamedirname);
			games[id].info_type = GAMEINFO_NONE;
		}

		/* if we're this mod, make sure to let the rest of the menu know */
		if (games[id].gamedir == cvar_string("game")) {
			games_set(id);
		}
	}

	/* we may have some mods, but we're not running any of them. Fatal */
	if (gameinfo_current == -1) {
		print("^1FATAL ERROR: NO LIBLIST.GAM FOR CURRENT MOD FOUND!\n");
		crash();
		return;
	}
}
#endif

void
games_init(void)
{
	int id = 0;
	string gamedirname = cvar_string("game");
	gameinfo_count++;
	games = memalloc(sizeof(gameinfo_t) * gameinfo_count);
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
	games[id].hlversion = "1000";
	games[id].svonly = 0;
	games[id].installed = 1;
	games[id].chatroom = cvar_string("gameinfo_chatroom");

	if not (games[id].chatroom) {
		games[id].chatroom = gamedirname;
	}

	games[id].readme = "readme.txt";
	games[id].pkgid = -1;
	games[id].steambg = 0;
	gameinfo_current = 0;
	games_setdefaultpkgs(id);

#ifndef WEBMENU
	if (games_check_manifest(id, gamedirname) == 1) {
		NSLog("[MENU] Found manifest for %s", gamedirname);
		games[id].info_type = GAMEINFO_MANIFEST;
	} else if (games_check_gtxt(id, gamedirname) == 1) {
		NSLog("[MENU] Found gameinfo for %s", gamedirname);
		games[id].info_type = GAMEINFO_GITXT;
	} else if (games_check_liblist(id, gamedirname) == 1) {
		NSLog("[MENU] Found liblist for %s", gamedirname);
		games[id].info_type = GAMEINFO_LIBLIST;
	} else {
		NSLog("[MENU] Found nothing for %s", gamedirname);
		games[id].info_type = GAMEINFO_NONE;
	}
#endif
	games_set(id);
}

void
menu_customgame_init(void)
{
#ifndef WEBMENU
	fn_customgame = spawn(CWidget);
	customgame_dlgWait = spawn(CDialog);

	customgame_btnActivate = spawn(CMainButton);
	customgame_btnActivate.SetImage(BTN_ACTIVATE);
	customgame_btnActivate.SetPos(15,140);
	customgame_btnActivate.SetExecute(customgame_btnactivate_start);
	Widget_Add(fn_customgame, customgame_btnActivate);

	customgame_btnInstall = spawn(CMainButton);
	customgame_btnInstall.SetImage(BTN_INSTALL);
	customgame_btnInstall.SetPos(15,172);
	Widget_Add(fn_customgame, customgame_btnInstall);

	customgame_btnVisit = spawn(CMainButton);
	customgame_btnVisit.SetImage(BTN_VISITWEB);
	customgame_btnVisit.SetPos(15,204);
	Widget_Add(fn_customgame, customgame_btnVisit);

	customgame_btnRefresh = spawn(CMainButton);
	customgame_btnRefresh.SetImage(BTN_REFRESHLIST);
	customgame_btnRefresh.SetPos(15,236);
	customgame_btnRefresh.SetExecute(ModServer_Refresh);
	Widget_Add(fn_customgame, customgame_btnRefresh);

	customgame_btnDeactivate = spawn(CMainButton);
	customgame_btnDeactivate.SetImage(BTN_DEACTIVATE);
	customgame_btnDeactivate.SetPos(15,300);
	customgame_btnDeactivate.SetExecute(customgame_btndeactivate_start);
	Widget_Add(fn_customgame, customgame_btnDeactivate);

	customgame_btnDone = spawn(CMainButton);
	customgame_btnDone.SetImage(BTN_DONE);
	customgame_btnDone.SetPos(15,332);
	customgame_btnDone.SetExecute(customgame_btndone_start);
	Widget_Add(fn_customgame, customgame_btnDone);

	customgame_frMods = spawn(CFrame);
	customgame_frMods.SetPos(141,156);
	customgame_frMods.SetSize(463,296);
	Widget_Add(fn_customgame, customgame_frMods);
	
	customgame_lbMods = spawn(CModList);
	customgame_lbMods.SetPos(144,159);
	customgame_lbMods.SetSize(457,283);
	customgame_lbMods.SetChanged(customgame_lbmods_changed);
	Widget_Add(fn_customgame, customgame_lbMods);
	
	customgame_sbMods = spawn(CScrollbar);
	customgame_sbMods.SetPos(141+463,156);
	customgame_sbMods.SetItemheight(29);
	customgame_sbMods.SetHeight(289);
	customgame_sbMods.SetCallback(customgame_sbmods_changed);
	customgame_sbMods.SetMax(gameinfo_count);
	Widget_Add(fn_customgame, customgame_sbMods);
#endif
}

#ifndef WEBMENU
var int g_customgame_initialized = 0;
#endif

void
menu_customgame_draw(void)
{
#ifndef WEBMENU
	Header_Draw(HEAD_CUSTOM);

	/* init all the other mod directories here */
	if (g_customgame_initialized < 2) {
		customgame_dlgWait.Draw();
		WField_Static(162, 180, "Indexing all local games, please wait...", 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		if (g_customgame_initialized == 1)
			games_init_2();

		g_customgame_initialized++;
		return;
	}

	Widget_Draw(fn_customgame);

	WLabel_Static(155, 143, m_reslbl[IDS_MODLIST_TYPE], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(201, 143, m_reslbl[IDS_MODLIST_NAME], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(321, 143, m_reslbl[IDS_MODLIST_VERSION], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(371, 143, m_reslbl[IDS_MODLIST_SIZE], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(421, 143, m_reslbl[IDS_MODLIST_RATING], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(471, 143, m_reslbl[IDS_MODLIST_INSTALLED], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(521, 143, m_reslbl[IDS_MODLIST_SERVERS], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(571, 143, m_reslbl[IDS_MODLIST_PLAYERS], 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	if (g_iModServerLoading) {
		customgame_dlgWait.Draw();
		WField_Static(162, 180, m_reslbl[IDS_MODREQ_TITLE], 320, 260,
			col_prompt_text, 1.0f, 2, font_label_p);
	}


#if 1
	if (g_iModInstallCache >= 0) {
		customgame_installframe();
	}
#endif

	customgame_sbMods.SetMax(gameinfo_count-1); /* don't show our current game */
#endif
}

void
menu_customgame_input(float evtype, float scanx, float chary, float devid)
{
#ifndef WEBMENU
	Widget_Input(fn_customgame, evtype, scanx, chary, devid);
#endif
}
