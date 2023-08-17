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

void
customgame_btnactivate_start(void)
{
	GameLibrary_Activate(customgame_lbMods.GetSelected());
}

void
customgame_installframe(void)
{
	/* graphical frame */
	customgame_dlgWait.Draw();
	WField_Static(162, 180, "Installing mod data...", 320, 260,
		col_prompt_text, 1.0f, 2, font_label_p);

	WField_Static(162, 220, sprintf("%d%%", GameLibrary_InstallProgress()), 320, 260,
		[1,1,1], 1.0f, 2, font_label_p);
	WField_Static(162, 260, "Service provided by frag-net.com through archive.org", 320, 260,
		[1,1,1], 1.0f, 2, font_label);
}

/* download the .fmf and switch games immediately */
void
customgame_btninstall_start(void)
{
	GameLibrary_Install(customgame_lbMods.GetSelected());
}

void 
customgame_btndeactivate_start(void)
{
	GameLibrary_Deactivate();
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
	int gameID = customgame_lbMods.GetSelected();

	if (GameLibrary_GetGameInfo(gameID, GAMEINFO_INSTALLED) == true) {
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

		/* once we started rendering the message, start parsing mods (stalls) */
		if (g_customgame_initialized == 1)
			GameLibrary_InitCustom();

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

	/* draw a frame for when we're refreshing the mod list */
	if (g_iModServerLoading) {
		customgame_dlgWait.Draw();
		WField_Static(162, 180, m_reslbl[IDS_MODREQ_TITLE], 320, 260,
			col_prompt_text, 1.0f, 2, font_label_p);
	}


	/* draw a frame with progress during package install */
	if (GameLibrary_IsInstalling()) {
		customgame_installframe();
	}

	customgame_sbMods.SetMax(gameinfo_count-1);
#endif
}

void
menu_customgame_input(float evtype, float scanx, float chary, float devid)
{
#ifndef WEBMENU
	Widget_Input(fn_customgame, evtype, scanx, chary, devid);
#endif
}
