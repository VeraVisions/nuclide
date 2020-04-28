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

/* local game/mod info parsing */
void games_set(int id)
{
	gameinfo_current = id;
	setwindowcaption(games[id].game);
	cvar_set("com_fullgamename", games[id].game);
}

void games_init(void)
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
		games[id].mpentity = "info_player_deathmatch";
		games[id].gamedll = "progs.dat";
		games[id].startmap = "c0a0";
		games[id].trainingmap = "t0a0";
		games[id].cldll = 1;
		games[id].hlversion = "1000";
		games[id].svonly = 0;
		games[id].installed = 1;

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
					case "mp":
					case "multi":
					case "multiplayer":
						games[id].type = "Multiplayer";
						break;
					case "singleplayer_only":
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
			case "gameinfo_menutrack":
				cvar_set("gameinfo_menutrack", argv(i+1));
				break;
			case "gameinfo_pkgrepo":
				games[id].pkg_repo = argv(i+1);
				break;
			default:
				break;
			}
		}
		if (games[id].gamedir == cvar_string("game")) {
			games_set(id);
		}
	}

	if (gameinfo_current == -1) {
		print("^1FATAL ERROR: NO MODINFO.TXT FOR CURRENT MOD FOUND!\n");
		crash();
		return;
	}
}

/* the menu specific code */
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

void customgame_btnactivate_start(void)
{
	int nextgame = customgame_lbMods.GetSelected();

	games_set(nextgame);

#if 0
	localcmd(sprintf("fs_changegame %s.fmf\n", games[nextgame].gamedir));
#else
	/* some games/mods inherit other directories */
	if (games[nextgame].fallback_dir) {
		localcmd(sprintf("gamedir \"%s;%s\"\n", games[nextgame].fallback_dir, games[nextgame].gamedir));
	} else {
		localcmd(sprintf("gamedir \"%s\"\n", games[nextgame].gamedir));
	}
#endif

	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\nmenu_restart\nmenu_customgame\n");
	cvar_init();
}
void customgame_btninstall_start(void)
{
	int gid = customgame_lbMods.GetSelected();
	print(sprintf("Requesting download for http://www.frag-net.com/mods/%s.fmf...\n", games[gid].gamedir));
	localcmd(sprintf("fs_changegame %s http://www.frag-net.com/mods/%s.fmf\n", games[gid].gamedir, games[gid].gamedir));
}
void customgame_btndeactivate_start(void)
{
	localcmd("gamedir \"\"\n");
	localcmd("stopmusic\nsnd_restart\nwait\nvid_reload\n");
	localcmd("menu_restart\n");
	localcmd("menu_customgame\n");
}

void customgame_btndone_start(void)
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
void customgame_sbmods_changed(int val)
{
	customgame_lbMods.SetScroll(val);
}

void customgame_lbmods_changed(void)
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

void menu_customgame_init(void)
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
	customgame_sbMods.SetMax(gameinfo_count-1); /* don't show our current game */
	Widget_Add(fn_customgame, customgame_sbMods);
}

void menu_customgame_draw(void)
{
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CUSTOM],[460,80], [1,1,1], 1.0f, 1);
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
}

void menu_customgame_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customgame, evtype, scanx, chary, devid);
}
