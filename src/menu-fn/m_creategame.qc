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

string(searchhandle handle, float num) search_getpackagename = #0:search_getpackagename;

CWidget fn_create;
CWidget fn_createshared;
CMainButton create_btnAdv;
CMainButton create_btnOk;
CMainButton create_btnCancel;

CTextBox create_tbHostname;
CTextBox create_tbMaxplayers;
CTextBox create_tbPassword;

CFrame create_frMaps;
CListBox create_lbMaps;
CScrollbar create_sbMaps;

void
create_btnok_start(void)
{
	static string startmap;
	static void create_btnok_end(void) {
		localcmd("stopmusic\nset sv_public 0\n");
		localcmd(sprintf("hostname %s\n", create_tbHostname.m_text));
		localcmd(sprintf("sv_playerslots %s\n", create_tbMaxplayers.m_text));
		localcmd(sprintf("password %s\n", create_tbPassword.m_text));
		localcmd(sprintf("map %s\n", startmap));
		g_menupage = PAGE_MULTIPLAYER;
		RichPresence_Clear();
		RichPresence_Set("status", sprintf("Multiplayer (LAN): %s", startmap));
	}
	/* Strip .bsp extension before submitting */
	startmap = substring(create_lbMaps.GetSelectedItem(), 0, -5);

	if (startmap == __NULL__) {
		return;
	}

	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,30,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(create_btnok_end);
}

void
create_btnadvanced_start(void)
{
	static void create_btnadvanced_end(void) {
		g_menupage = PAGE_ADVANCEDMPOPTIONS;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(create_btnadvanced_end);
}

void
create_btncancel_start(void)
{
	static void create_btncancel_end(void) {
		g_menupage = PAGE_LANGAMES;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,30,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(create_btncancel_end);
}

void
create_sbmaps_changed(int val)
{
	create_lbMaps.SetScroll(val);
}

void
menu_creategame_init(void)
{
	int mapCount = 0i;

	fn_create = spawn(CWidget);
	create_btnAdv = spawn(CMainButton);
	create_btnAdv.SetImage(BTN_ADVOPTIONS);
	create_btnAdv.SetExecute(create_btnadvanced_start);
	create_btnAdv.SetPos(50,140);
	Widget_Add(fn_create, create_btnAdv);

	create_btnOk = spawn(CMainButton);
	create_btnOk.SetImage(BTN_OK);
	create_btnOk.SetExecute(create_btnok_start);
	create_btnOk.SetPos(50,172);
	Widget_Add(fn_create, create_btnOk);

	create_btnCancel = spawn(CMainButton);
	create_btnCancel.SetImage(BTN_CANCEL);
	create_btnCancel.SetExecute(create_btncancel_start);
	create_btnCancel.SetPos(50,204);
	Widget_Add(fn_create, create_btnCancel);

	create_tbHostname = spawn(CTextBox);
	create_tbHostname.SetPos(216,167);
	create_tbHostname.m_length = 156;
	create_tbHostname.SetText(cvar_string("hostname"));
	Widget_Add(fn_createshared, create_tbHostname);

	create_tbMaxplayers = spawn(CTextBox);
	create_tbMaxplayers.SetPos(216,226);
	create_tbMaxplayers.m_length = 156;
	Widget_Add(fn_createshared, create_tbMaxplayers);

	/* if it's 1, that means we recently played a SP game, reset to default for now */
	if (cvar("sv_playerslots") <= 1)
		create_tbMaxplayers.SetText("8");
	else
		create_tbMaxplayers.SetText(cvar_string("sv_playerslots"));

	create_tbPassword = spawn(CTextBox);
	create_tbPassword.SetPos(216,280);
	create_tbPassword.m_length = 156;
	create_tbPassword.SetText(cvar_string("password"));
	Widget_Add(fn_createshared, create_tbPassword);
	
	create_frMaps = spawn(CFrame);
	create_frMaps.SetPos(382,172);
	create_frMaps.SetSize(208,288);
	Widget_Add(fn_createshared, create_frMaps);

	create_lbMaps = spawn(CListBox);
	create_lbMaps.SetPos(384,175);
	create_lbMaps.SetSize(202-16,282);
	Widget_Add(fn_createshared, create_lbMaps);
	
	create_sbMaps = spawn(CScrollbar);
	create_sbMaps.SetPos(571,175);
	create_sbMaps.SetHeight(282);
	create_sbMaps.SetCallback(create_sbmaps_changed);
	Widget_Add(fn_createshared, create_sbMaps);

	/* fill in our list box */
	mapCount = MapLibrary_GetMapCount();

	for (int i = 0i; i < mapCount; i++) {
		string mapName = MapLibrary_GetInfo(i, MAPINFO_NAME);
		create_lbMaps.AddEntry(mapName);
	}

	create_sbMaps.SetMax(mapCount);
}

void
menu_creategame_draw(void)
{
	Header_Draw(HEAD_CREATEGAME);

	WLabel_Static(216, 143, m_reslbl[IDS_CREATESERVER_NAME], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(216, 202, m_reslbl[IDS_CREATESERVER_MAXPLAYERS], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(216, 256, m_reslbl[IDS_NEWPROFILE_PASSWORD], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(381, 143, m_reslbl[IDS_CREATESERVER_MAP], 14, 14, [1,1,1],
					1.0f, 0, font_arial);

	Widget_Draw(fn_create);
	Widget_Draw(fn_createshared);
}

void
menu_creategame_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_create, evtype, scanx, chary, devid);
	Widget_Input(fn_createshared, evtype, scanx, chary, devid);
}
