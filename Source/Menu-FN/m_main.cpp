/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

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
void btn_console(void)
{
	localcmd("toggleconsole\n");
}

void btn_resume(void)
{
	m_hide();
}

/* Button Callbacks */
void btn_newgame_start(void)
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
void btn_configuration_start(void)
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
void btn_multiplayer_start(void)
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

void btn_training(void)
{
	localcmd("maxplayers 1\nmap t0a0\n");
}

void btn_quit(void)
{
	main_quitdialog = TRUE;
}
void btn_quit_ok(void)
{
	localcmd("quit\n");
}
void btn_quit_cancel(void)
{
	main_quitdialog = FALSE;
}

/* Init */
void menu_main_init(void)
{
	/* Main Menu (Disconnected) */
	fn_main = spawn(CWidget);
	main_btnConsole = spawn(CMainButton);
	main_btnConsole.SetImage(BTN_CONSOLE);
	main_btnConsole.SetExecute(btn_console);
	main_btnConsole.SetPos(70,180);
	Widget_Add(fn_main, main_btnConsole);

	main_btnNewGame = spawn(CMainButton);
	main_btnNewGame.SetImage(BTN_NEWGAME);
	main_btnNewGame.SetExecute(btn_newgame_start);
	main_btnNewGame.SetPos(70,208);
	Widget_Add(fn_main, main_btnNewGame);

	main_btnTraining = spawn(CMainButton);
	main_btnTraining.SetImage(BTN_TRAINING);
	main_btnTraining.SetExecute(btn_training);
	main_btnTraining.SetPos(70,236);
	Widget_Add(fn_main, main_btnTraining);

	main_btnConfiguration = spawn(CMainButton);
	main_btnConfiguration.SetImage(BTN_CONFIG);
	main_btnConfiguration.SetExecute(btn_configuration_start);
	main_btnConfiguration.SetPos(70,264);
	Widget_Add(fn_main, main_btnConfiguration);

	main_btnLoadGame = spawn(CMainButton);
	main_btnLoadGame.SetImage(BTN_LOADGAME);
	main_btnLoadGame.SetPos(70,292);
	Widget_Add(fn_main, main_btnLoadGame);

	main_btnMultiplayer = spawn(CMainButton);
	main_btnMultiplayer.SetImage(BTN_MULTIPLAYER);
	main_btnMultiplayer.SetPos(70,320);
	main_btnMultiplayer.SetExecute(btn_multiplayer_start);
	Widget_Add(fn_main, main_btnMultiplayer);

	main_btnCustomGame = spawn(CMainButton);
	main_btnCustomGame.SetImage(BTN_CUSTOMGAME);
	main_btnCustomGame.SetPos(70,348);
	Widget_Add(fn_main, main_btnCustomGame);

	main_btnReadme = spawn(CMainButton);
	main_btnReadme.SetImage(BTN_README);
	main_btnReadme.SetPos(70,376);
	Widget_Add(fn_main, main_btnReadme);

	main_btnPreviews = spawn(CMainButton);
	main_btnPreviews.SetImage(BTN_PREVIEWS);
	main_btnPreviews.SetPos(70,404);
	Widget_Add(fn_main, main_btnPreviews);

	main_btnQuit = spawn(CMainButton);
	main_btnQuit.SetImage(BTN_QUIT);
	main_btnQuit.SetExecute(btn_quit);
	main_btnQuit.SetPos(70,432);	
	Widget_Add(fn_main, main_btnQuit);

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
	
	/* Main Menu (Connected) */
	fn_main2 = spawn(CWidget);
	main_btn2Console = spawn(CMainButton);
	main_btn2Console.SetImage(BTN_CONSOLE);
	main_btn2Console.SetExecute(btn_console);
	main_btn2Console.SetPos(70,180);
	Widget_Add(fn_main2, main_btn2Console);

	main_btn2Resume = spawn(CMainButton);
	main_btn2Resume.SetImage(BTN_RESUMEGAME);
	main_btn2Resume.SetExecute(btn_resume);
	main_btn2Resume.SetPos(70,208);
	Widget_Add(fn_main2, main_btn2Resume);

	main_btn2NewGame = spawn(CMainButton);
	main_btn2NewGame.SetImage(BTN_NEWGAME);
	main_btn2NewGame.SetExecute(btn_newgame_start);
	main_btn2NewGame.SetPos(70,236);
	Widget_Add(fn_main2, main_btn2NewGame);

	main_btn2Training = spawn(CMainButton);
	main_btn2Training.SetImage(BTN_TRAINING);
	main_btn2Training.SetExecute(btn_training);
	main_btn2Training.SetPos(70,264);
	Widget_Add(fn_main2, main_btn2Training);

	main_btn2Configuration = spawn(CMainButton);
	main_btn2Configuration.SetImage(BTN_CONFIG);
	main_btn2Configuration.SetExecute(btn_configuration_start);
	main_btn2Configuration.SetPos(70,292);
	Widget_Add(fn_main2, main_btn2Configuration);

	main_btn2LoadGame = spawn(CMainButton);
	main_btn2LoadGame.SetImage(BTN_SAVELOAD);
	main_btn2LoadGame.SetPos(70,320);
	Widget_Add(fn_main2, main_btn2LoadGame);

	main_btn2Multiplayer = spawn(CMainButton);
	main_btn2Multiplayer.SetImage(BTN_MULTIPLAYER);
	main_btn2Multiplayer.SetPos(70,348);
	main_btn2Multiplayer.SetExecute(btn_multiplayer_start);
	Widget_Add(fn_main2, main_btn2Multiplayer);

	main_btn2CustomGame = spawn(CMainButton);
	main_btn2CustomGame.SetImage(BTN_CUSTOMGAME);
	main_btn2CustomGame.SetPos(70,376);
	Widget_Add(fn_main2, main_btn2CustomGame);

	main_btn2Previews = spawn(CMainButton);
	main_btn2Previews.SetImage(BTN_PREVIEWS);
	main_btn2Previews.SetPos(70,404);
	Widget_Add(fn_main2, main_btn2Previews);

	main_btn2Quit = spawn(CMainButton);
	main_btn2Quit.SetImage(BTN_QUIT);
	main_btn2Quit.SetExecute(btn_quit);
	main_btn2Quit.SetPos(70,432);	
	Widget_Add(fn_main2, main_btn2Quit);
}

/* Drawing */
void menu_main_draw(void)
{
	if (clientstate() == 2) {
		Widget_Draw(fn_main2);
		WLabel_Static(235, 216, m_reslbl[IDS_MAIN_RETURNHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 244, m_reslbl[IDS_MAIN_NEWGAMEHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 272, m_reslbl[IDS_MAIN_TRAININGHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 300, m_reslbl[IDS_MAIN_CONFIGUREHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 328, m_reslbl[IDS_MAIN_LOADSAVEHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 356, m_reslbl[IDS_MAIN_MULTIPLAYERHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 384, m_reslbl[IDS_MAIN_CUSTOMHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 412, m_reslbl[IDS_MAIN_PREVIEWSHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 440, m_reslbl[IDS_MAIN_QUITHELP], 10, 10,
						col_help,1.0f, 0, font_label);
	} else {
		drawpic([g_menuofs[0],g_menuofs[1] + 70], "logo_avi",
				g_logosize, [1,1,1], 1.0f);
		g_logosize = gecko_get_texture_extent("logo_avi");

		Widget_Draw(fn_main);
		WLabel_Static(235, 216, m_reslbl[IDS_MAIN_NEWGAMEHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 244, m_reslbl[IDS_MAIN_TRAININGHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 272, m_reslbl[IDS_MAIN_CONFIGUREHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 300, m_reslbl[IDS_MAIN_LOADHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 328, m_reslbl[IDS_MAIN_MULTIPLAYERHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 356, m_reslbl[IDS_MAIN_CUSTOMHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 384, m_reslbl[IDS_MAIN_READMEHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 412, m_reslbl[IDS_MAIN_PREVIEWSHELP], 10, 10,
						col_help,1.0f, 0, font_label);
		WLabel_Static(235, 440, m_reslbl[IDS_MAIN_QUITHELP], 10, 10,
						col_help,1.0f, 0, font_label);
	}

	if (main_quitdialog) {
		main_dgQuit.Draw();
		WLabel_Static(203, 180, m_reslbl[IDS_MAIN_QUITPROMPT], 16, 16,
						col_prompt_text, 1.0f, 0, font_label_b);
		Widget_Draw(main_dgQuit);
	}

	if (autocvar_menu_intro == TRUE) {
		if (g_intro_progress < INTRO_TIME) {
			m_intro_draw();
		}
	}
}

void menu_main_input(float evtype, float scanx, float chary, float devid)
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
		if (clientstate() == 2) {
			Widget_Input(fn_main2, evtype, scanx, chary, devid);
		} else {
			Widget_Input(fn_main, evtype, scanx, chary, devid);
		}
	}
}
