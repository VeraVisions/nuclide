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

CWidget fn_main;
CMainButton main_btnConsole;
CMainButton main_btnNewGame;
CMainButton main_btnTraining;
CMainButton main_btnConfiguration;
CMainButton main_btnLoadGame;
CMainButton main_btnMultiplayer;
CMainButton main_btnCustomGame;
CMainButton main_btnReadme;
CMainButton main_btnPreviews;
CMainButton main_btnQuit;

CWidget fn_main2;
CMainButton main_btn2Console;
CMainButton main_btn2Resume;
CMainButton main_btn2NewGame;
CMainButton main_btn2Training;
CMainButton main_btn2Configuration;
CMainButton main_btn2LoadGame;
CMainButton main_btn2Multiplayer;
CMainButton main_btn2CustomGame;
CMainButton main_btn2Previews;
CMainButton main_btn2Quit;

CDialog main_dgQuit;
CMainButton main_btnQuitOk;
CMainButton main_btnQuitCancel;

int main_quitdialog;

/* Button Callbacks */
void
btn_console(void)
{
	localcmd("toggleconsole\n");
}

void
btn_resume(void)
{
	m_hide();
}

/* Button Callbacks */
void
btn_newgame_start(void)
{
	static void btn_newgame_end(void) {
		g_menupage = PAGE_NEWGAME;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(70,208,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_NEWGAME);
	header.SetExecute(btn_newgame_end);
}

void
btn_training(void)
{
	localcmd("stopmusic\n");
	localcmd("maxplayers 1\n");
	localcmd(GameLibrary_GetInfo(GAMEINFO_TRAININGMAP));

	/* TODO: Some mods may choose to put movies in this... */
	RichPresence_Clear();
	RichPresence_Set("status", "Singleplayer: Training");
}

void
btn_configuration_start(void)
{
	static void btn_configuration_end(void) {
		g_menupage = PAGE_CONFIGURATION;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(70,264,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CONFIG);
	header.SetExecute(btn_configuration_end);
}

void
btn_loadgame_start(void)
{
	static void btn_loadgame_end(void) {
		g_menupage = PAGE_LOADGAME;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(70,292,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_LOAD);
	header.SetExecute(btn_loadgame_end);
}

void
btn_multiplayer_start(void)
{
	static void btn_multiplayer_end(void) {
		g_menupage = PAGE_MULTIPLAYER;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(70,320,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_MULTI);
	header.SetExecute(btn_multiplayer_end);
}

void
btn_customgame_start(void)
{
	static void btn_customgame_end(void) {
		g_menupage = PAGE_CUSTOMGAME;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(70,348,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CUSTOM);
	header.SetExecute(btn_customgame_end);
}

void
btn_readme_start(void)
{
	static void btn_readme_end(void) {
		g_menupage = PAGE_VIEWREADME;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(70,376,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_README);
	header.SetExecute(btn_readme_end);
}

void
btn_quit(void)
{
	main_quitdialog = TRUE;
}

void
btn_quit_ok(void)
{
	localcmd("quit\n");
}

void
btn_quit_cancel(void)
{
	main_quitdialog = FALSE;
}

/* Init */
void
menu_main_init(void)
{
	/* Main Menu (Disconnected) */
	fn_main = spawn(CWidget);
	main_btnConsole = spawn(CMainButton);
	main_btnConsole.SetImage(BTN_CONSOLE);
	main_btnConsole.SetExecute(btn_console);
	main_btnConsole.SetPos(70,180);
	Widget_Add(fn_main, main_btnConsole);

	/* New Game */
	main_btnNewGame = spawn(CMainButton);
	main_btnNewGame.SetImage(BTN_NEWGAME);
	main_btnNewGame.SetPos(70,208);
	/* new game not available in multiplayer_only */
	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		main_btnNewGame.SetExecute(btn_newgame_start);
	Widget_Add(fn_main, main_btnNewGame);

	/* Training */
	main_btnTraining = spawn(CMainButton);
	main_btnTraining.SetImage(BTN_TRAINING);
	main_btnTraining.SetPos(70,236);
	/* some mods actively try to hide the option */
	if (GameLibrary_GetInfo(GAMEINFO_TRAININGMAP) != "")
		main_btnTraining.SetExecute(btn_training);
	Widget_Add(fn_main, main_btnTraining);

	/* Configuration */
	main_btnConfiguration = spawn(CMainButton);
	main_btnConfiguration.SetImage(BTN_CONFIG);
	main_btnConfiguration.SetExecute(btn_configuration_start);
	main_btnConfiguration.SetPos(70,264);
	Widget_Add(fn_main, main_btnConfiguration);

	/* Load Game */
	main_btnLoadGame = spawn(CMainButton);
	main_btnLoadGame.SetImage(BTN_LOADGAME);
	main_btnLoadGame.SetPos(70,292);
	/* disable in multiplayer_only */
	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		main_btnLoadGame.SetExecute(btn_loadgame_start);
	Widget_Add(fn_main, main_btnLoadGame);

	/* Multiplayer */
	main_btnMultiplayer = spawn(CMainButton);
	main_btnMultiplayer.SetImage(BTN_MULTIPLAYER);
	main_btnMultiplayer.SetPos(70,320);
	/* disable when it's singleplayer_only */
	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Singleplayer")
		main_btnMultiplayer.SetExecute(btn_multiplayer_start);
	Widget_Add(fn_main, main_btnMultiplayer);

	/* Custom game */
	main_btnCustomGame = spawn(CMainButton);
	main_btnCustomGame.SetImage(BTN_CUSTOMGAME);
	main_btnCustomGame.SetExecute(btn_customgame_start);
	main_btnCustomGame.SetPos(70,348);
	Widget_Add(fn_main, main_btnCustomGame);

	/* View readme */
	main_btnReadme = spawn(CMainButton);
	main_btnReadme.SetImage(BTN_README);
	main_btnReadme.SetExecute(btn_readme_start);
	main_btnReadme.SetPos(70,376);
	Widget_Add(fn_main, main_btnReadme);

	/* Previews */
	main_btnPreviews = spawn(CMainButton);
	main_btnPreviews.SetImage(BTN_PREVIEWS);
	main_btnPreviews.SetPos(70,404);
	Widget_Add(fn_main, main_btnPreviews);

	/* Quit */
	main_btnQuit = spawn(CMainButton);
	main_btnQuit.SetImage(BTN_QUIT);
	main_btnQuit.SetExecute(btn_quit);
	main_btnQuit.SetPos(70,432);	
	Widget_Add(fn_main, main_btnQuit);

	/* Quit dialog */
	main_dgQuit = spawn(CDialog);	
	main_btnQuitOk = spawn(CMainButton);
	main_btnQuitOk.SetImage(BTN_OK);
	main_btnQuitOk.SetPos(233,291);
	main_btnQuitOk.SetLength(68);
	main_btnQuitOk.SetExecute(btn_quit_ok);
	Widget_Add(main_dgQuit, main_btnQuitOk);

	main_btnQuitCancel = spawn(CMainButton);
	main_btnQuitCancel.SetImage(BTN_CANCEL);
	main_btnQuitCancel.SetPos(331,291);
	main_btnQuitCancel.SetLength(68);
	main_btnQuitCancel.SetExecute(btn_quit_cancel);
	Widget_Add(main_dgQuit, main_btnQuitCancel);

	/* Now comes the 'connected' / ingame variation of this menu */
	fn_main2 = spawn(CWidget);
	main_btn2Console = spawn(CMainButton);
	main_btn2Console.SetImage(BTN_CONSOLE);
	main_btn2Console.SetExecute(btn_console);
	main_btn2Console.SetPos(70,180);
	Widget_Add(fn_main2, main_btn2Console);

	/* Resume game */
	main_btn2Resume = spawn(CMainButton);
	main_btn2Resume.SetImage(BTN_RESUMEGAME);
	main_btn2Resume.SetExecute(btn_resume);
	main_btn2Resume.SetPos(70,208);
	Widget_Add(fn_main2, main_btn2Resume);

	/* New Game */
	main_btn2NewGame = spawn(CMainButton);
	main_btn2NewGame.SetImage(BTN_NEWGAME);
	main_btn2NewGame.SetPos(70,236);
	/* disable in multiplayer_only */
	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		main_btn2NewGame.SetExecute(btn_newgame_start);
	Widget_Add(fn_main2, main_btn2NewGame);

	/* Training */
	main_btn2Training = spawn(CMainButton);
	main_btn2Training.SetImage(BTN_TRAINING);
	if (GameLibrary_GetInfo(GAMEINFO_TRAININGMAP) != "")
		main_btn2Training.SetExecute(btn_training);
	main_btn2Training.SetPos(70,264);
	Widget_Add(fn_main2, main_btn2Training);

	/* Configuration */
	main_btn2Configuration = spawn(CMainButton);
	main_btn2Configuration.SetImage(BTN_CONFIG);
	main_btn2Configuration.SetExecute(btn_configuration_start);
	main_btn2Configuration.SetPos(70,292);
	Widget_Add(fn_main2, main_btn2Configuration);

	/* Save/Load */
	main_btn2LoadGame = spawn(CMainButton);
	main_btn2LoadGame.SetImage(BTN_SAVELOAD);
	main_btn2LoadGame.SetPos(70,320);
	/* disable in multiplayer_only */
	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Multiplayer")
		main_btn2LoadGame.SetExecute(btn_loadgame_start);
	Widget_Add(fn_main2, main_btn2LoadGame);

	/* Multiplayer */
	main_btn2Multiplayer = spawn(CMainButton);
	main_btn2Multiplayer.SetImage(BTN_MULTIPLAYER);
	main_btn2Multiplayer.SetPos(70,348);
	if (GameLibrary_GetInfo(GAMEINFO_TYPE) != "Singleplayer")
		main_btn2Multiplayer.SetExecute(btn_multiplayer_start);
	Widget_Add(fn_main2, main_btn2Multiplayer);

	/* Custom game */
	main_btn2CustomGame = spawn(CMainButton);
	main_btn2CustomGame.SetImage(BTN_CUSTOMGAME);
	main_btn2CustomGame.SetPos(70,376);
	Widget_Add(fn_main2, main_btn2CustomGame);

	/* Previews */
	main_btn2Previews = spawn(CMainButton);
	main_btn2Previews.SetImage(BTN_PREVIEWS);
	main_btn2Previews.SetPos(70,404);
	Widget_Add(fn_main2, main_btn2Previews);

	/* Quit */
	main_btn2Quit = spawn(CMainButton);
	main_btn2Quit.SetImage(BTN_QUIT);
	main_btn2Quit.SetExecute(btn_quit);
	main_btn2Quit.SetPos(70,432);	
	Widget_Add(fn_main2, main_btn2Quit);
}

var vector autocvar_menu_logoOffset = [0,0];

/* Drawing */
void
menu_main_draw(void)
{
	if (clientstate() == 2 && !g_background) {
		Widget_Draw(fn_main2);
		WLabel_Static(235, 216, m_reslbl[IDS_MAIN_RETURNHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 244, m_reslbl[IDS_MAIN_NEWGAMEHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 272, m_reslbl[IDS_MAIN_TRAININGHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 300, m_reslbl[IDS_MAIN_CONFIGUREHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 328, m_reslbl[IDS_MAIN_LOADSAVEHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 356, m_reslbl[IDS_MAIN_MULTIPLAYERHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 384, m_reslbl[IDS_MAIN_CUSTOMHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 412, m_reslbl[IDS_MAIN_PREVIEWSHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 440, m_reslbl[IDS_MAIN_QUITHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);

		/* Don't even attempt to display the logo.avi otherwise */
		if (autocvar_menu_steambg == false) {
			drawpic([g_menuofs[0],g_menuofs[1] + 70] + autocvar_menu_logoOffset, g_bmp[LOGO_AVI_INGAME],
					g_logosize, [1,1,1], 1.0f);
			g_logosize = gecko_get_texture_extent(g_bmp[LOGO_AVI_INGAME]);
			
			if (g_logosize == g_vec_null) {
				g_logosize = drawgetimagesize(g_bmp[LOGO_AVI_INGAME]);
			}
		}
	} else {
#ifndef WEBMENU
		/* Don't even attempt to display the logo.avi otherwise */
		if (autocvar_menu_steambg == false) {
			drawpic([g_menuofs[0],g_menuofs[1] + 70] + autocvar_menu_logoOffset, g_bmp[LOGO_AVI],
					g_logosize, [1,1,1], 1.0f);
			g_logosize = gecko_get_texture_extent(g_bmp[LOGO_AVI]);
			
			if (g_logosize == g_vec_null) {
				g_logosize = drawgetimagesize(g_bmp[LOGO_AVI]);
			}
		}

		{
			vector ofs = drawgetimagesize(g_bmp[LOGO_STATIC]);
			drawpic([g_menuofs[0] + 320 - (ofs[0] / 2),g_menuofs[1] + 48], g_bmp[LOGO_STATIC],
				ofs, [1,1,1], 1.0f);
		}
#endif
		Widget_Draw(fn_main);
		WLabel_Static(235, 216, m_reslbl[IDS_MAIN_NEWGAMEHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 244, m_reslbl[IDS_MAIN_TRAININGHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 272, m_reslbl[IDS_MAIN_CONFIGUREHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 300, m_reslbl[IDS_MAIN_LOADHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 328, m_reslbl[IDS_MAIN_MULTIPLAYERHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 356, m_reslbl[IDS_MAIN_CUSTOMHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 384, m_reslbl[IDS_MAIN_READMEHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 412, m_reslbl[IDS_MAIN_PREVIEWSHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 440, m_reslbl[IDS_MAIN_QUITHELP], HELPTXT_SIZE, HELPTXT_SIZE,
						col_help,1.0f, 0, font_label);
	}

	if (main_quitdialog) {
		main_dgQuit.Draw();
		/*WLabel_Static(203, 180, m_reslbl[IDS_MAIN_QUITPROMPT], 16, 16,
						col_prompt_text, 1.0f, 0, font_label_b);*/
		WField_Static(162, 180, m_reslbl[IDS_MAIN_QUITPROMPT], 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		Widget_Draw(main_dgQuit);
	}

	if (autocvar_menu_intro == TRUE) {
		if (g_intro_progress < INTRO_TIME) {
			m_intro_draw();
		}
	}
}

void
menu_main_input(float evtype, float scanx, float chary, float devid)
{
	if (autocvar_menu_intro == TRUE) {
		if (g_intro_progress < INTRO_TIME) {
			m_intro_input(evtype, scanx, chary, devid);
			return;
		}
	}

	if (main_quitdialog) {
		Widget_Input(main_dgQuit, evtype, scanx, chary, devid);
	} else {
		if (clientstate() == 2 && !g_background) {
			Widget_Input(fn_main2, evtype, scanx, chary, devid);
		} else {
			Widget_Input(fn_main, evtype, scanx, chary, devid);
		}
	}
}
