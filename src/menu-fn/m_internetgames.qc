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

var int g_inetrefresh = FALSE;

CWidget fn_inet;
CMainButton inet_btnJoin;
CMainButton inet_btnCreate;
CMainButton inet_btnViewGame;
CMainButton inet_btnRefresh;
CMainButton inet_btnUpdate;
CMainButton inet_btnFilter;
CMainButton inet_btnAddServer;
CMainButton inet_btnChatRooms;
CMainButton inet_btnDone;

CFrame inet_frServers;
CListBox inet_lbServers_Name;
CListBox inet_lbServers_Ping;
CListBox inet_lbServers_Map;
CListBox inet_lbServers_Game;
CListBox inet_lbServers_Players;
CListBox inet_lbServers_Addresses;
CScrollbar inet_sbServers;

CDialog inet_dgRefresh;
CMainButton inet_btnRefDone;

/* Button Callbacks */
void
inet_btnjoin(void)
{
	string addr = inet_lbServers_Addresses.GetSelectedItem();
	
	if (addr) {
		localcmd("stopmusic\n");
		localcmd(sprintf("connect %s\n", addr));
		RichPresence_Clear();
		RichPresence_Set("connect", strcat("+connect ", addr));
		g_menupage = PAGE_MULTIPLAYER;
	}
}

void
inet_btncreate_start(void)
{
	static void inet_btncreate_end(void) {
		g_menupage = PAGE_CREATEGAMEINET;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(30,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(inet_btncreate_end);
}

void
inet_btndone_start(void)
{
	static void inet_btndone_end(void) {
		g_menupage = PAGE_MULTIPLAYER;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_INETGAMES);
	header.SetExecute(inet_btndone_end);
}

void
inet_btnrefresh(void)
{
	g_inetrefresh = TRUE;
}

void
inet_refreshframe(void)
{
	static float refreshtime;
	int count = 0;
	int added = 0;

	Master_RefreshCache();

	/* only rebuild every half a frame */
	if (refreshtime > time)
		return;

	count = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	refreshtime = time + 0.5f;

	inet_lbServers_Name.Clear();
	inet_lbServers_Ping.Clear();
	inet_lbServers_Map.Clear();
	inet_lbServers_Game.Clear();
	inet_lbServers_Players.Clear();
	inet_lbServers_Addresses.Clear();

	for (int i = 0; i < count; i++) {
		string address;
		string players;
		string ping;

		address = gethostcachestring(srv_fldAdress, i);

		/* skip LAN */
		if (!address || Server_IsLan(address)) {
			continue;
		}

		players = sprintf("%d/%d",
						stof(gethostcachestring(srv_fldPlayers, i)),
						stof(gethostcachestring(srv_fldMaxplayers, i))
					);
		ping = sprintf("%d", stof(gethostcachestring(srv_fldPing, i)));
		inet_lbServers_Name.AddEntry(gethostcachestring(srv_fldName, i));
		inet_lbServers_Ping.AddEntry(ping);
		inet_lbServers_Map.AddEntry(gethostcachestring(srv_fldMap, i));
		inet_lbServers_Game.AddEntry(gethostcachestring(srv_fldGame, i));
		inet_lbServers_Players.AddEntry(players);
		inet_lbServers_Addresses.AddEntry(address);
		NSLog("Adding %s to the Internet server list", address);
		added++;
	}
	NSLog("Added %i Internet servers.", added);
	inet_sbServers.SetMax(added);
}

void
inet_refreshfinish(void)
{
	g_inetrefresh = FALSE;
}

void
inet_lb_clicked(int val)
{
	inet_lbServers_Name.SetSelected(val, FALSE);
	inet_lbServers_Ping.SetSelected(val, FALSE);
	inet_lbServers_Map.SetSelected(val, FALSE);
	inet_lbServers_Game.SetSelected(val, FALSE);
	inet_lbServers_Players.SetSelected(val, FALSE);
	inet_lbServers_Addresses.SetSelected(val, FALSE);
}

void
inet_lb_changed(int val)
{
	inet_lbServers_Name.SetScroll(val);
	inet_lbServers_Ping.SetScroll(val);
	inet_lbServers_Map.SetScroll(val);
	inet_lbServers_Game.SetScroll(val);
	inet_lbServers_Players.SetScroll(val);
}

void
menu_internetgames_init(void)
{
	fn_inet = spawn(CWidget);

	inet_btnJoin = spawn(CMainButton);
	inet_btnJoin.SetImage(BTN_JOINGAME);
	inet_btnJoin.SetExecute(inet_btnjoin);
	inet_btnJoin.SetPos(30,140);
	Widget_Add(fn_inet, inet_btnJoin);

	inet_btnCreate = spawn(CMainButton);
	inet_btnCreate.SetImage(BTN_CREATEGAME);
	inet_btnCreate.SetExecute(inet_btncreate_start);
	inet_btnCreate.SetPos(30,172);
	Widget_Add(fn_inet, inet_btnCreate);

	inet_btnViewGame = spawn(CMainButton);
	inet_btnViewGame.SetImage(BTN_GAMEINFO);
	//inet_btnViewGame.SetExecute(btn_console);
	inet_btnViewGame.SetPos(30,204);
	Widget_Add(fn_inet, inet_btnViewGame);

	inet_btnRefresh = spawn(CMainButton);
	inet_btnRefresh.SetImage(BTN_REFRESH);
	inet_btnRefresh.SetExecute(inet_btnrefresh);
	inet_btnRefresh.SetPos(30,236);
	Widget_Add(fn_inet, inet_btnRefresh);

	inet_btnUpdate = spawn(CMainButton);
	inet_btnUpdate.SetImage(BTN_UPDATELIST);
	inet_btnUpdate.SetExecute(Master_GetInternetList);
	inet_btnUpdate.SetPos(30,268);
	Widget_Add(fn_inet, inet_btnUpdate);
	
	inet_btnFilter = spawn(CMainButton);
	inet_btnFilter.SetImage(BTN_FILTER1);
	//inet_btnFilter.SetExecute(btn_console);
	inet_btnFilter.SetPos(30,300);
	Widget_Add(fn_inet, inet_btnFilter);
	
	inet_btnAddServer = spawn(CMainButton);
	inet_btnAddServer.SetImage(BTN_ADDSERVER);
	//inet_btnAddServer.SetExecute(btn_console);
	inet_btnAddServer.SetPos(30,332);
	Widget_Add(fn_inet, inet_btnAddServer);
	
	inet_btnChatRooms = spawn(CMainButton);
	inet_btnChatRooms.SetImage(BTN_CHATROOMS);
	//inet_btnChatRooms.SetExecute(btn_console);
	inet_btnChatRooms.SetPos(30,364);
	Widget_Add(fn_inet, inet_btnChatRooms);

	inet_frServers = spawn(CFrame);
	inet_frServers.SetPos(166,141);
	inet_frServers.SetSize(464-16,294);
	Widget_Add(fn_inet, inet_frServers);

	inet_lbServers_Name = spawn(CListBox);
	inet_lbServers_Name.SetPos(166+3,141+3);
	inet_lbServers_Name.SetSize(188,294-6);
	inet_lbServers_Name.SetChanged(inet_lb_clicked);
	Widget_Add(fn_inet, inet_lbServers_Name);

	inet_lbServers_Ping = spawn(CListBox);
	inet_lbServers_Ping.SetPos(357,141+3);
	inet_lbServers_Ping.SetSize(50,294-6);
	inet_lbServers_Ping.SetChanged(inet_lb_clicked);
	Widget_Add(fn_inet, inet_lbServers_Ping);

	inet_lbServers_Map = spawn(CListBox);
	inet_lbServers_Map.SetPos(407,141+3);
	inet_lbServers_Map.SetSize(69,294-6);
	inet_lbServers_Map.SetChanged(inet_lb_clicked);
	Widget_Add(fn_inet, inet_lbServers_Map);

	inet_lbServers_Game = spawn(CListBox);
	inet_lbServers_Game.SetPos(476,141+3);
	inet_lbServers_Game.SetSize(76,294-6);
	inet_lbServers_Game.SetChanged(inet_lb_clicked);
	Widget_Add(fn_inet, inet_lbServers_Game);

	inet_lbServers_Players = spawn(CListBox);
	inet_lbServers_Players.SetPos(552,141+3);
	inet_lbServers_Players.SetSize(62,294-6);
	inet_lbServers_Players.SetChanged(inet_lb_clicked);
	Widget_Add(fn_inet, inet_lbServers_Players);

	inet_lbServers_Addresses = spawn(CListBox);

	inet_sbServers = spawn(CScrollbar);
	inet_sbServers.SetPos(614,141);
	inet_sbServers.SetHeight(294);
	inet_sbServers.SetCallback(inet_lb_changed);
	//xinet_sbServers.SetMax(g_resolutions.length);
	Widget_Add(fn_inet, inet_sbServers);

	inet_btnDone = spawn(CMainButton);
	inet_btnDone.SetImage(BTN_DONE);
	inet_btnDone.SetExecute(inet_btndone_start);
	inet_btnDone.SetPos(30,396);
	Widget_Add(fn_inet, inet_btnDone);

	inet_dgRefresh = spawn(CDialog);
	inet_btnRefDone = spawn(CMainButton);
	inet_btnRefDone.SetImage(BTN_DONE);
	inet_btnRefDone.SetPos(233,291);
	inet_btnRefDone.SetLength(68);
	inet_btnRefDone.SetExecute(inet_refreshfinish);
	Widget_Add(inet_dgRefresh, inet_btnRefDone);
}

void
menu_internetgames_draw(void)
{
	Widget_Draw(fn_inet);
	resorthostcache();
	Header_Draw(HEAD_INETGAMES);
	drawpic([g_menuofs[0]+550,g_menuofs[1]+10], g_bmp[FN_LOGO],[80,80], [1,1,1], 1.0f, 0);

	/* Labels */
	WLabel_Static(252, 128, m_reslbl[IDS_SERVER_GAMESERVER], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(357, 128, m_reslbl[IDS_SERVER_SPEED], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(407, 128, m_reslbl[IDS_SERVER_MAP], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(476, 128, m_reslbl[IDS_SERVER_GAME], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(552, 128, m_reslbl[IDS_SERVER_PLAYERS], 10, 10, [1,1,1],
					1.0f, 0, font_arial);

	if (!g_inetrefresh)
		return;

	inet_refreshframe();
	inet_dgRefresh.Draw();
	Widget_Draw(inet_dgRefresh);
	WField_Static(162, 180, "Refreshing server list...", 320, 260,
					col_prompt_text, 1.0f, 2, font_label_p);
	WField_Static(162, 220, sprintf("Listing %i applicable servers\n",
					Master_GetInternetServers()), 320, 260,
					col_prompt_title, 1.0f, 2, font_label_p);
}

void
menu_internetgames_input(float evtype, float scanx, float chary, float devid)
{
	if (!g_inetrefresh)
		Widget_Input(fn_inet, evtype, scanx, chary, devid);
	else {
		Widget_Input(inet_dgRefresh, evtype, scanx, chary, devid);
	}
}
