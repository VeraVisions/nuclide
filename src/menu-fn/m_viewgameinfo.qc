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

CWidget fn_viewgameinfo;
CMainButton vgi_btnDone;
CFrame vgi_frPlayers;
CScrollbar vgi_sbPlayers;
CFrame vgi_frServerinfo;
CScrollbar vgi_sbServerinfo;

CListBox vgi_lbPlayerNum;
CListBox vgi_lbPlayerName;
CListBox vgi_lbPlayerKills;
CListBox vgi_lbPlayerTime;
CListBox vgi_lbServerKey;
CListBox vgi_lbServerValue;

string g_vgiLabelName;
string g_vgiLabelAddress;
string g_vgiLabelPing;

static void
vgi_btndone_start(void)
{
	static void vgi_btndone_end(void) {
		if (g_menuLAN == true)
			g_menupage = PAGE_LANGAMES;
		else
			g_menupage = PAGE_INTERNETGAMES;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45, 45, 50, 172);
	header.SetStartEndSize(460, 80, 156, 26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_MULTI);
	header.SetExecute(vgi_btndone_end);
}

static void
vgi_sbplayers_changed(int val)
{
	vgi_lbPlayerNum.SetScroll(val);
	vgi_lbPlayerName.SetScroll(val);
	vgi_lbPlayerKills.SetScroll(val);
	vgi_lbPlayerTime.SetScroll(val);
}

static void
vgi_sbserverinfo_changed(int val)
{
	vgi_lbServerKey.SetScroll(val);
	vgi_lbServerValue.SetScroll(val);
}

static void
vgi_lbplayers_clicked(int val)
{
	vgi_lbPlayerNum.SetSelected(val, FALSE);
	vgi_lbPlayerName.SetSelected(val, FALSE);
	vgi_lbPlayerKills.SetSelected(val, FALSE);
	vgi_lbPlayerTime.SetSelected(val, FALSE);
}

static void
vgi_lbserverinfo_clicked(int val)
{
	vgi_lbServerKey.SetSelected(val, FALSE);
	vgi_lbServerValue.SetSelected(val, FALSE);
}

/* this gets called every time we prepare a new menu for the player */
void
menu_viewgameinfo_setserver(float serverNum)
{
	float playerCount = stof(gethostcachestring(srv_fldPlayers, serverNum));
	string serverInfo = gethostcachestring(srv_fldServerInfo, serverNum);

	vgi_sbPlayers.SetMax(playerCount+1);

	//print(sprintf("Server Num? %d\n", serverNum));
	//print(sprintf("PlayerCount? %d\n", playerCount));
	//print(sprintf("ServerInfo? %S\n", serverInfo));
	//print(sprintf("Player? %S\n", gethostcachestring( srv_fldPlayer0, serverNum )));
	//print(sprintf("Player1? %S\n", gethostcachestring( gethostcacheindexforkey("player1"), serverNum )));
	//print(sprintf("Player2? %S\n", gethostcachestring( gethostcacheindexforkey("player0"), serverNum )));

	vgi_lbPlayerNum.Clear();
	vgi_lbPlayerName.Clear();
	vgi_lbPlayerKills.Clear();
	vgi_lbPlayerTime.Clear();
	vgi_lbServerKey.Clear();
	vgi_lbServerValue.Clear();

	g_vgiLabelName = gethostcachestring(srv_fldName, serverNum);
	g_vgiLabelAddress = gethostcachestring(srv_fldAdress, serverNum);

	float serverPing = stof(gethostcachestring(srv_fldPing, serverNum));

	if (serverPing == 65534)
		g_vgiLabelPing = _("PING_ICE");
	else
		g_vgiLabelPing = sprintf(_("PING_IN_MS"), serverPing);

	/* add the player info entries */
	for (int i = 0; i < playerCount; i++) {
#if 0
		string playerName = gethostcachestring(gethostcacheindexforkey(sprintf("player%i", i)), serverNum);
#else
		string playerName = sprintf("Player %i", i);
#endif
		vgi_lbPlayerNum.AddEntry(sprintf("%i", i+1i));
		vgi_lbPlayerName.AddEntry(playerName);
		vgi_lbPlayerKills.AddEntry(sprintf("%i", i));
		vgi_lbPlayerTime.AddEntry(sprintf("%i", i));
	}

	/* add the server info entries */
	int serverInfoCount = (int)tokenizebyseparator(serverInfo, "\\");
	vgi_sbServerinfo.SetMax((serverInfoCount/2)+1);
	for (int i = 0; i < serverInfoCount; i+=2) {
		vgi_lbServerKey.AddEntry(argv(i+1));
		vgi_lbServerValue.AddEntry(argv(i+0));
	}
}

void
menu_viewgameinfo_init(void)
{
	fn_viewgameinfo = spawn(CWidget);

	vgi_btnDone = spawn(CMainButton);
	vgi_btnDone.SetImage(BTN_DONE);
	vgi_btnDone.SetExecute(vgi_btndone_start);
	vgi_btnDone.SetPos(50, 405);
	Widget_Add(fn_viewgameinfo, vgi_btnDone);

	vgi_frPlayers = spawn(CFrame);
	vgi_frPlayers.SetPos(216,156);
	vgi_frPlayers.SetSize(404,154);
	Widget_Add(fn_viewgameinfo, vgi_frPlayers);

	vgi_frServerinfo = spawn(CFrame);
	vgi_frServerinfo.SetPos(216,336);
	vgi_frServerinfo.SetSize(404,124);
	Widget_Add(fn_viewgameinfo, vgi_frServerinfo);

	vgi_sbPlayers = spawn(CScrollbar);
	vgi_sbPlayers.SetPos(604,156);
	vgi_sbPlayers.SetHeight(154);
	vgi_sbPlayers.SetCallback(vgi_sbplayers_changed);
	Widget_Add(fn_viewgameinfo, vgi_sbPlayers);

	vgi_sbServerinfo = spawn(CScrollbar);
	vgi_sbServerinfo.SetPos(604,336);
	vgi_sbServerinfo.SetHeight(124);
	vgi_sbServerinfo.SetCallback(vgi_sbserverinfo_changed);
	Widget_Add(fn_viewgameinfo, vgi_sbServerinfo);

	/* listboxes ahoy */
	vgi_lbPlayerNum = spawn(CListBox);
	vgi_lbPlayerNum.SetPos(219,159);
	vgi_lbPlayerNum.SetSize(25,148);
	vgi_lbPlayerNum.SetChanged(vgi_lbplayers_clicked);
	Widget_Add(fn_viewgameinfo, vgi_lbPlayerNum);

	vgi_lbPlayerName = spawn(CListBox);
	vgi_lbPlayerName.SetPos(244,159);
	vgi_lbPlayerName.SetSize(100, 148);
	vgi_lbPlayerName.SetChanged(vgi_lbplayers_clicked);
	Widget_Add(fn_viewgameinfo, vgi_lbPlayerName);

	vgi_lbPlayerKills = spawn(CListBox);
	vgi_lbPlayerKills.SetPos(344,159);
	vgi_lbPlayerKills.SetSize(35, 148);
	vgi_lbPlayerKills.SetChanged(vgi_lbplayers_clicked);
	Widget_Add(fn_viewgameinfo, vgi_lbPlayerKills);

	vgi_lbPlayerTime = spawn(CListBox);
	vgi_lbPlayerTime.SetPos(379,159);
	vgi_lbPlayerTime.SetSize(225, 148);
	vgi_lbPlayerTime.SetChanged(vgi_lbplayers_clicked);
	Widget_Add(fn_viewgameinfo, vgi_lbPlayerTime);


	vgi_lbServerKey = spawn(CListBox);
	vgi_lbServerKey.SetPos(220,339);
	vgi_lbServerKey.SetSize(150,118);
	vgi_lbServerKey.SetChanged(vgi_lbserverinfo_clicked);
	Widget_Add(fn_viewgameinfo, vgi_lbServerKey);

	vgi_lbServerValue = spawn(CListBox);
	vgi_lbServerValue.SetPos(370, 339);
	vgi_lbServerValue.SetSize(232,118);
	vgi_lbServerValue.SetChanged(vgi_lbserverinfo_clicked);
	Widget_Add(fn_viewgameinfo, vgi_lbServerValue);

	menu_viewgameinfo_setserver(0);
}

void
menu_viewgameinfo_draw(void)
{
	Widget_Draw(fn_viewgameinfo);
	Header_Draw(HEAD_MULTI);

	/* draw the left side-bar elements and descriptions */
	WLabel_Static(57, 156, m_reslbl[IDS_PLAYERINFO_SERVERNAME], 14, 14, col_button_bg,
					1.0f, 0, font_label_b);
	WLabel_Static(57, 240, m_reslbl[IDS_PLAYERINFO_SERVERIP], 14, 14, col_button_bg,
					1.0f, 0, font_label_b);
	WLabel_Static(57, 324, m_reslbl[IDS_PLAYERINFO_SERVERPING], 14, 14, col_button_bg,
					1.0f, 0, font_label_b);

	WField_Static(56, 189, g_vgiLabelName, 128, 64, [1,1,1],
					1.0f, AF_LEFT | AF_TOP, font_label);
	WLabel_Static(56, 272, g_vgiLabelAddress, 11, 11, [1,1,1],
					1.0f, 0, font_label);
	WLabel_Static(56, 356, g_vgiLabelPing, 11, 11, [1,1,1],
					1.0f, 0, font_label);

	/* the descriptions over the two frames */
	/* player list */
	WLabel_Static(220, 143, m_reslbl[IDS_PLAYERINFO_NUMBER], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(245, 143, m_reslbl[IDS_PLAYERINFO_NAME], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(345, 143, m_reslbl[IDS_PLAYERINFO_KILLS], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(380, 143, m_reslbl[IDS_PLAYERINFO_TIME], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	/* serverinfo */
	WLabel_Static(220, 323, m_reslbl[IDS_PLAYERINFO_RULENAME], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(370, 323, m_reslbl[IDS_PLAYERINFO_RULEVALUE], 11, 11, [1,1,1],
					1.0f, 0, font_arial);
}

void
menu_viewgameinfo_input(float evtype, float x, float y, float devid)
{
	Widget_Input(fn_viewgameinfo, evtype, x, y, devid);
}
