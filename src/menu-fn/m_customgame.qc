/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
	return -1;
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
				return 1;
			} else if (updates[id].installed == "pending") {
				return 1;
			}
			break;
		case "pending":
			return 1;
			break;
		case "enabled":
			break;
		case "present":
			return 1;
			break;
		case "corrupt":
			return 1;
			break;
		default:
			/* we're currently installing stuff */
			return 1;
			break;
		}
	}

	/* everything is installed */
	return 0;
}

int
game_updateinstallcount(void)
{
	int count = 0;

	/* always return something positive when no packages are defined */
	if (games[gameinfo_current].pkgname == "") {
		return 1;
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

#if 0
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

/* local game/mod info parsing */
void
games_set(int id)
{
	gameinfo_current = id;
	setwindowcaption(games[id].game);
	cvar_set("com_fullgamename", games[id].game);
}

void
games_init(void)
{
	int id;
	float county;
	string gamedirname;
	string gamedescription;
	gameinfo_count = 0;

	for (id = 0; (gamedirname = getgamedirinfo(id, 0)); id++) {
		/* skip any manifest (or modinfo) without cvars setting things */
		if (getgamedirinfo(id, 2) == "") {
			continue;
		}

		gameinfo_count++;
	}

	if (!gameinfo_count) {
		print("^1FATAL ERROR: NO VALID MOD DIRECTORIES FOUND!\n");
		crash();
		return;
	}

	games = memalloc(sizeof(gameinfo_t) * gameinfo_count);

	if (!games)
		error(sprintf("Attempting to allocate mod data for %i entries failed\n", gameinfo_count));

	for (id = 0; (gamedirname = getgamedirinfo(id, 0)); id++) {
		gamedescription = getgamedirinfo(id, 2);

		/* CONT: skip any manifest (or modinfo) without cvars setting things */
		if (gamedescription == "") {
			continue;
		}

		county = tokenize_console(gamedescription);

		/* Fill in the defaults */
		games[id].game = gamedirname;
		games[id].gamedir = gamedirname;
		games[id].url_info = "";
		games[id].url_dl = "";
		games[id].version = "1.0";
		games[id].size = 0;
		games[id].type = "Both";
		games[id].nomodels = 0;
		games[id].nosprays = 0;
		games[id].mpentity = "info_player_deathmatch";
		games[id].gamedll = "progs.dat";
		games[id].startmap = "c0a0";
		games[id].trainingmap = "t0a0";
		games[id].cldll = 1;
		games[id].hlversion = "1000";
		games[id].svonly = 0;
		games[id].installed = 1;
		games[id].chatroom = gamedirname;
		games[id].readme = "readme.txt";
		games[id].pkgid = -1;

		for (int i = 0; i < county; i++) {
			switch(argv(i)) {
			case "gameinfo_game":
				games[id].game = argv(i+1);
				break;
			case "gameinfo_gamedir":
				games[id].gamedir = argv(i+1);
				break;
			case "gameinfo_fallback_dir":
				games[id].fallback_dir = argv(i+1);
				break;
			case "gameinfo_url_info":
				games[id].url_info = argv(i+1);
				break;
			case "gameinfo_url_dl":
				games[id].url_dl = argv(i+1);
				break;
			case "gameinfo_version":
				games[id].version = argv(i+1);
				break;
			case "gameinfo_size":
				games[id].size = (int)stof(argv(i+1));
				break;
			case "gameinfo_svonly":
				games[id].svonly = (int)stof(argv(i+1));
				break;
			case "gameinfo_cldll":
				games[id].cldll = (int)stof(argv(i+1));
				break;
			case "gameinfo_type":
				switch (strtolower(argv(i+1))) {
					case "multiplayer_only":
					case "multiplayer only":
					case "mp":
					case "multi":
					case "multiplayer":
						games[id].type = "Multiplayer";
						break;
					case "singleplayer_only":
					case "singleplayer only":
					case "sp":
					case "single":
					case "singleplayer":
						games[id].type = "Singleplayer";
						break;
					default:
						games[id].type = "Both";
				}
				break;
			case "gameinfo_hlversion":
				games[id].hlversion = argv(i+1);
				break;
			case "gameinfo_nomodels":
				games[id].nomodels = (int)stof(argv(i+1));
				break;
			case "gameinfo_nosprays":
				games[id].nosprays = (int)stof(argv(i+1));
				break;
			case "gameinfo_mpentity":
				games[id].mpentity = argv(i+1);
				break;
			case "gameinfo_gamedll":
				games[id].gamedll = argv(i+1);
				break;
			case "gameinfo_startmap":
				games[id].startmap = argv(i+1);
				break;
			case "gameinfo_trainingmap":
				games[id].trainingmap = argv(i+1);
				break;
			case "gameinfo_pkgname":
				games[id].pkgname = argv(i+1);
				games[id].pkgid = game_getpackageid(games[id].pkgname);
				break;
			case "gameinfo_pkgfile":
				games[id].pkgfile = argv(i+1);
				break;
			case "gameinfo_chatroom":
				games[id].chatroom = argv(i+1);
				break;
			case "gameinfo_readme":
				games[id].readme = argv(i+1);
				break;
			case "gameinfo_introvideo":
				games[id].introvideo = argv(i+1);
				break;
			default:
				break;
			}
		}
		if (games[id].gamedir == cvar_string("gameinfo_gamedir")) {
			games_set(id);
		}
	}

#if 0
	game_getinstallcache();
#endif

	if (gameinfo_current == -1) {
		print("^1FATAL ERROR: NO MODINFO.TXT FOR CURRENT MOD FOUND!\n");
		crash();
		return;
	}
}

#if 0
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

void
customgame_btnactivate_start(void)
{
	int nextgame = customgame_lbMods.GetSelected();

	games_set(nextgame);

#if 1
	localcmd(sprintf("fs_changegame %s %s.fmf\nfs_changegame %s -\n", games[nextgame].gamedir, games[nextgame].gamedir, games[nextgame].gamedir));
#else
	/* some games/mods inherit other directories */
	if (games[nextgame].fallback_dir) {
		localcmd(sprintf("gamedir \"%s;%s\"\n", games[nextgame].fallback_dir, games[nextgame].gamedir));
	} else {
		localcmd(sprintf("gamedir \"%s\"\n", games[nextgame].gamedir));
	}
#endif

	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
	localcmd("menu_musicstart\n");
}

/* download the .fmf and switch games immediately */
void
customgame_btninstall_start(void)
{
#if 0
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
	localcmd(sprintf("fs_changegame %s %s.fmf\n", GAME_DIR, GAME_DIR));
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

void
menu_customgame_init(void)
{
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
	customgame_frMods.SetSize(463,289);
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
}

void
menu_customgame_draw(void)
{
	Header_Draw(HEAD_CUSTOM);
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

	customgame_sbMods.SetMax(gameinfo_count-1); /* don't show our current game */

#if 0
	if (g_iModInstallCache >= 0) {
		customgame_installframe();
	}
#endif
}

void
menu_customgame_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customgame, evtype, scanx, chary, devid);
}
