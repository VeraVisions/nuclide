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

CWidget fn_createinet;
CMainButton createinet_btnAdv;
CMainButton createinet_btnOk;
CMainButton createinet_btnCancel;

void
createinet_btnok_start(void)
{
	static string startmap;
	static string gameType;
	static void createinet_btnok_end(void) {
		int r = random(1000,9999);
		localcmd(sprintf("stopmusic\nset sv_public /%i\n", r));
		localcmd(sprintf("set hostname %s\n", create_tbHostname.m_text));
		localcmd(sprintf("set sv_playerslots %S\n", create_tbMaxplayers.m_text));
		localcmd(sprintf("set password %S\n", create_tbPassword.m_text));
		localcmd(sprintf("set g_gametype %S\n", gameType));

		if (cvar("ui_fillServer") > 0) {
			localcmd(sprintf("set bot_minClients %S\n", create_tbMaxplayers.m_text));
		} else {
			localcmd(sprintf("set bot_minClients %S\n", "0"));
		}
	
		localcmd(sprintf("map %s\n", startmap));
		g_menupage = PAGE_MULTIPLAYER;
		cr_input_enter(sprintf("ACTION is now hosting '%s' on the map %s\n", create_tbHostname.m_text, startmap));

		RichPresence_Clear();
		RichPresence_Set("status", sprintf("Multiplayer: %s", startmap));
		RichPresence_Set("connect", sprintf("+connect /%i", r));
	}

	/* Strip .bsp extension before submitting */
	startmap = substring(create_lbMaps.GetSelectedItem(), 0, -5);
	gameType = substring(create_lbModes.GetSelectedItem(), 0, -5);

	if (startmap == __NULL__) {
		return;
	}

	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,30,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(createinet_btnok_end);
}

void
createinet_btncancel_start(void)
{
	static void createinet_btncancel_end(void) {
		g_menupage = PAGE_INTERNETGAMES;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,30,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(createinet_btncancel_end);
}

void
menu_creategameinet_init(void)
{
	fn_createinet = spawn(CWidget);
	createinet_btnAdv = spawn(CMainButton);
	createinet_btnAdv.SetImage(BTN_ADVOPTIONS);
	//createinet_btnAdv.SetExecute(btn_console);
	createinet_btnAdv.SetPos(50,140);
	Widget_Add(fn_createinet, createinet_btnAdv);

	createinet_btnOk = spawn(CMainButton);
	createinet_btnOk.SetImage(BTN_OK);
	createinet_btnOk.SetExecute(createinet_btnok_start);
	createinet_btnOk.SetPos(50,172);
	Widget_Add(fn_createinet, createinet_btnOk);

	createinet_btnCancel = spawn(CMainButton);
	createinet_btnCancel.SetImage(BTN_CANCEL);
	createinet_btnCancel.SetExecute(createinet_btncancel_start);
	createinet_btnCancel.SetPos(50,204);
	Widget_Add(fn_createinet, createinet_btnCancel);
}

void
menu_creategameinet_draw(void)
{
	Header_Draw(HEAD_CREATEGAME);
	drawpic([g_menuofs[0]+550,g_menuofs[1]+10], g_bmp[FN_LOGO],[80,80], [1,1,1], 1.0f, 0);

	WLabel_Static(216, 143, m_reslbl[IDS_CREATESERVER_NAME], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(216, 202, m_reslbl[IDS_CREATESERVER_MAXPLAYERS], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(216, 256, m_reslbl[IDS_NEWPROFILE_PASSWORD], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(381, 143, m_reslbl[IDS_CREATESERVER_MAP], 14, 14, [1,1,1],
					1.0f, 0, font_arial);

	WField_Static(52 + 26, 234, "Bots", 115, 64, [0.75, 0.75, 0.75],
					1.0f, 3, font_label_b);

	Widget_Draw(fn_createinet);
	Widget_Draw(fn_createshared);
}

void
menu_creategameinet_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_createinet, evtype, scanx, chary, devid);
	Widget_Input(fn_createshared, evtype, scanx, chary, devid);
}
