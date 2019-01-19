/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
game:			The name of the mod
url_info:		The mod's informational web site
url_dl:			The ftp site from where the mod can be downloaded
version:		The mod's version number
size:			The size, in bytes, of the mod
svonly:			“1” if the mod is a server only mod ( no client side content or code ), “0” otherwise
cldll:			1 if the mod requires a matching client.dll
type:			If this mod is "multiplayer_only", then the single player buttons ( New Game/Hazard Course/Load game etc.) are disabled in the Half-Life launcher
hlversion:		The version of Half-Life for which the mod was generated.  Revisions to Half-Life will require updates by mod authors.
nomodels:		Set to “1” if model bitmaps should not be shown in the Multiplayer | Customize menu of the Half-Life launcher
mpentity:		When a user chooses to create a listen server from the interface, each BSP file in the maps\ folder for the mod is searched.  The entity data for the BSP is scanned for the presence of the string identified by mpentity.  For insance, in Half-Life, the string is "info_player_deathmatch" ( which is also the default if no string is specified )
gamedll:		The game DLL to load for running a server for this mod.
startmap:		When a user chooses "New Game" for a single player mod, this is the map that is loaded.
trainingmap:	When a user chooses "Hazard Course" for a single player mod, this is the map that is loaded.
*/

//string(string s) setwindowcaption = #0;

void game_printinfo(int i)
{
	print("==================================\n");
	print(sprintf("GAME ID %i\n", i));
	print("==================================\n");
	print(sprintf("game: %s\n", games[i].game));
	print(sprintf("gamedir: %s\n", games[i].gamedir));
	print(sprintf("url_info: %s\n", games[i].url_info));
	print(sprintf("url_dl: %s\n", games[i].url_dl));
	print(sprintf("version: %s\n", games[i].version));
	print(sprintf("size: %i bytes\n", games[i].size));
	print(sprintf("svonly: %i\n", games[i].svonly));
	print(sprintf("cldll: %i\n", games[i].cldll));
	print(sprintf("type: %s\n", games[i].type));
	print(sprintf("hlversion: %s\n", games[i].hlversion));
	print(sprintf("nomodels: %i\n", games[i].nomodels));
	print(sprintf("mpentity: %s\n", games[i].mpentity));
	print(sprintf("gamedll: %s\n", games[i].gamedll));
	print(sprintf("startmap: %s\n", games[i].startmap));
	print(sprintf("trainingmap: %s\n", games[i].trainingmap));
	print("==================================\n");
}

void games_init(void)
{
	int gameidx;
	float county;
	string gamedirname;
	string gamedescription;
	gameinfo_count = 0;

	for (gameidx = 0; (gamedirname = getgamedirinfo(gameidx, 0)); gameidx++) {
		gameinfo_count++;
	}

	print(sprintf("[MENU] Scanned %i game directories.\n", gameinfo_count));

	if (!gameinfo_count) {
		print("^1FATAL ERROR: NO VALID GAME DIRECTORIES HAVE BEEN FOUND!\n");
		crash();
		return;
	}

	games = memalloc(sizeof(gameinfo_t) * gameinfo_count);

	for (gameidx = 0; (gamedirname = getgamedirinfo(gameidx, 0)); gameidx++) {
		gamedescription = getgamedirinfo(gameidx, 1);
		county = tokenize(gamedescription);
		
		/* Fill in the defaults */
		games[gameidx].game = gamedirname;
		games[gameidx].gamedir = gamedirname;
		games[gameidx].url_info = "";
		games[gameidx].url_dl = "";
		games[gameidx].version = "1.0";
		games[gameidx].size = 0;
		games[gameidx].svonly = 0;
		games[gameidx].cldll = 1;
		games[gameidx].type = "";
		games[gameidx].hlversion = "1110";
		games[gameidx].nomodels = 0;
		games[gameidx].mpentity = "info_player_deathmatch";
		games[gameidx].gamedll = "progs.dat";
		games[gameidx].startmap = "c0a0";
		games[gameidx].trainingmap = "t0a0";

		for ( int i = 0; i < county; i+=2 ) {
			switch( argv(i) ) {
				case "game":
					games[gameidx].game = argv(i + 1);
					print(sprintf("[GAME] Found %s (%s)\n", games[gameidx].game, gamedirname));
					break;
				case "gamedir":
					games[gameidx].gamedir = argv(i + 1);
					break;
				case "url_info":
					games[gameidx].url_info = argv(i + 1);
					break;
				case "url_dl":
					games[gameidx].url_dl = argv(i + 1);
					break;
				case "version":
					games[gameidx].version = argv(i + 1);
					break;
				case "size":
					games[gameidx].size = stof(argv(i + 1));
					break;
				case "svonly":
					games[gameidx].svonly = stof(argv(i + 1));
					break;
				case "cldll":
					games[gameidx].cldll = stof(argv(i + 1));
					break;
				case "type":
					games[gameidx].type = argv(i + 1);
					break;
				case "hlversion":
					games[gameidx].hlversion = argv(i + 1);
					break;
				case "nomodels":
					games[gameidx].nomodels = stof(argv(i + 1));
					break;
				case "mpentity":
					games[gameidx].mpentity = argv(i + 1);
					break;
				case "gamedll":
					games[gameidx].gamedll = argv(i + 1);
					break;
				case "startmap":
					games[gameidx].startmap = argv(i + 1);
					break;
				case "trainingmap":
				case "trainmap":
					games[gameidx].trainingmap = argv(i + 1);
					break;
				default:
					break;
			}
		}
		if (games[gameidx].gamedir == cvar_string("game")) {
			gameinfo_current = gameidx;
		}
		game_printinfo(gameidx);
	}
	
	if (gameinfo_current == -1) {
		print("^1FATAL ERROR: NO MODINFO.TXT FOR RUNNING GAME DETECTED!\n");
		crash();
		return;
	} else {
		//cvar_set("fs_gamename", games[gameinfo_current].game);
		print("[MENU] Found game we're running! Great success.\n");
	}
}

CWidget fn_customgame;
CFrame customgame_frMods;
CModList customgame_lbMods;

CMainButton customgame_btnActivate;
CMainButton customgame_btnInstall;
CMainButton customgame_btnVisit;
CMainButton customgame_btnRefresh;
CMainButton customgame_btnDeactivate;
CMainButton customgame_btnDone;

void customgame_btnactivate_start(void)
{
	int nextgame = customgame_lbMods.GetSelected();
	if (!nextgame) {
		return;
	}
	
	gameinfo_current = nextgame;
	localcmd(sprintf("gamedir \"%s\"\n", games[nextgame].gamedir));
	// TODO: Re-init important menu bits and bobs.

	//m_shutdown();
	//m_init();
}
void customgame_btndeactivate_start(void)
{
	localcmd("gamedir \"\"\n");
	// TODO: Re-init important menu bits and bobs.

	//m_shutdown();
	//m_init();
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

void menu_customgame_init(void)
{
	fn_customgame = spawn(CWidget);

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
	Widget_Add(fn_customgame, customgame_lbMods);

	//customgame_lbMods.SetMax(gameinfo_count);
}

void menu_customgame_draw(void)
{
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CUSTOM],[460,80], [1,1,1], 1.0f, 1);
	Widget_Draw(fn_customgame);

	WLabel_Static(g_menuofs[0] + 155, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_TYPE], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 201, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_NAME], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 321, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_VERSION], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 371, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_SIZE], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 421, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_RATING], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 471, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_INSTALLED], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 521, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_SERVERS], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 571, g_menuofs[1] + 143, m_reslbl[IDS_MODLIST_PLAYERS], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
}

void menu_customgame_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customgame, evtype, scanx, chary, devid);
}
