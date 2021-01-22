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

CWidget fn_lan;
CMainButton lan_btnJoin;
CMainButton lan_btnCreate;
CMainButton lan_btnViewGame;
CMainButton lan_btnRefresh;
CMainButton lan_btnDone;

CFrame lan_frServers;
CListBox lan_lbServers_Name;
CListBox lan_lbServers_Ping;
CListBox lan_lbServers_Map;
CListBox lan_lbServers_Game;
CListBox lan_lbServers_Players;
CListBox lan_lbServers_Addresses;
CScrollbar lan_sbServers;

/* Button Callbacks */
void
lan_btnjoin(void)
{
	string addr = lan_lbServers_Addresses.GetSelectedItem();
	
	if (addr) {
		localcmd("stopmusic\n");
		localcmd(sprintf("connect %s\n", addr));
		g_menupage = PAGE_MULTIPLAYER;
	}
}

void
lan_btncreate_start(void)
{
	static void lan_btncreate_end(void) {
		g_menupage = PAGE_CREATEGAME;
	}
	cvar_set("sv_public", "0");
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(30,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(lan_btncreate_end);
}

void
lan_btndone_start(void)
{
	static void lan_btndone_end(void) {
		g_menupage = PAGE_MULTIPLAYER;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,268);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_LAN);
	header.SetExecute(lan_btndone_end);
}

void
lan_btnrefresh(void)
{
	int count = 0;
	int added = 0;

	Master_RefreshCache();
	count = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	lan_lbServers_Name.Clear();
	lan_lbServers_Ping.Clear();
	lan_lbServers_Map.Clear();
	lan_lbServers_Game.Clear();
	lan_lbServers_Players.Clear();
	lan_lbServers_Addresses.Clear();

	for (int i = 0; i < count; i++) {
		string address;
		string players;
		string ping;

		address = gethostcachestring(srv_fldAdress, i);
		if (!address || !Server_IsLan(address)) {
			continue;
		}

		players = sprintf("%d/%d",
						stof(gethostcachestring(srv_fldPlayers, i)),
						stof(gethostcachestring(srv_fldMaxplayers, i))
					);
		ping = sprintf("%d", stof(gethostcachestring(srv_fldPing, i)));
		lan_lbServers_Name.AddEntry(gethostcachestring(srv_fldName, i));
		lan_lbServers_Ping.AddEntry(ping);
		lan_lbServers_Map.AddEntry(gethostcachestring(srv_fldMap, i));
		lan_lbServers_Game.AddEntry(gethostcachestring(srv_fldGame, i));
		lan_lbServers_Players.AddEntry(players);
		lan_lbServers_Addresses.AddEntry(address);
		print(sprintf("Adding %s to the LAN server list\n", address));
		added++;
	}
	print(sprintf("Added %i LAN servers.\n", added));
	lan_sbServers.SetMax(added);
}

void
lan_lb_clicked(int val)
{
	lan_lbServers_Name.SetSelected(val, FALSE);
	lan_lbServers_Ping.SetSelected(val, FALSE);
	lan_lbServers_Map.SetSelected(val, FALSE);
	lan_lbServers_Game.SetSelected(val, FALSE);
	lan_lbServers_Players.SetSelected(val, FALSE);
	lan_lbServers_Addresses.SetSelected(val, FALSE);
}

void
lan_lb_changed(int val)
{
	lan_lbServers_Name.SetScroll(val);
	lan_lbServers_Ping.SetScroll(val);
	lan_lbServers_Map.SetScroll(val);
	lan_lbServers_Game.SetScroll(val);
	lan_lbServers_Players.SetScroll(val);
	lan_lbServers_Addresses.SetScroll(val);
}

void
menu_langames_init(void)
{
	fn_lan = spawn(CWidget);

	lan_btnJoin = spawn(CMainButton);
	lan_btnJoin.SetImage(BTN_JOINGAME);
	lan_btnJoin.SetExecute(lan_btnjoin);
	lan_btnJoin.SetPos(30,140);
	Widget_Add(fn_lan, lan_btnJoin);

	lan_btnCreate = spawn(CMainButton);
	lan_btnCreate.SetImage(BTN_CREATEGAME);
	lan_btnCreate.SetExecute(lan_btncreate_start);
	lan_btnCreate.SetPos(30,172);
	Widget_Add(fn_lan, lan_btnCreate);

	lan_btnViewGame = spawn(CMainButton);
	lan_btnViewGame.SetImage(BTN_GAMEINFO);
	//lan_btnViewGame.SetExecute(btn_console);
	lan_btnViewGame.SetPos(30,204);
	Widget_Add(fn_lan, lan_btnViewGame);

	lan_btnRefresh = spawn(CMainButton);
	lan_btnRefresh.SetImage(BTN_REFRESH);
	lan_btnRefresh.SetExecute(lan_btnrefresh);
	lan_btnRefresh.SetPos(30,236);
	Widget_Add(fn_lan, lan_btnRefresh);

	lan_btnDone = spawn(CMainButton);
	lan_btnDone.SetImage(BTN_DONE);
	lan_btnDone.SetExecute(lan_btndone_start);
	lan_btnDone.SetPos(30,268);
	Widget_Add(fn_lan, lan_btnDone);

	lan_frServers = spawn(CFrame);
	lan_frServers.SetPos(196,140);
	lan_frServers.SetSize(434-16,309);
	Widget_Add(fn_lan, lan_frServers);

	lan_lbServers_Name = spawn(CListBox);
	lan_lbServers_Name.SetPos(199,140+3);
	lan_lbServers_Name.SetSize(178,309-6);
	lan_lbServers_Name.SetChanged(lan_lb_clicked);
	Widget_Add(fn_lan, lan_lbServers_Name);

	lan_lbServers_Ping = spawn(CListBox);
	lan_lbServers_Ping.SetPos(377,140+3);
	lan_lbServers_Ping.SetSize(45,309-6);
	lan_lbServers_Ping.SetChanged(lan_lb_clicked);
	Widget_Add(fn_lan, lan_lbServers_Ping);

	lan_lbServers_Map = spawn(CListBox);
	lan_lbServers_Map.SetPos(422,140+3);
	lan_lbServers_Map.SetSize(75,309-6);
	lan_lbServers_Map.SetChanged(lan_lb_clicked);
	Widget_Add(fn_lan, lan_lbServers_Map);

	lan_lbServers_Game = spawn(CListBox);
	lan_lbServers_Game.SetPos(497,140+3);
	lan_lbServers_Game.SetSize(75,309-6);
	lan_lbServers_Game.SetChanged(lan_lb_clicked);
	Widget_Add(fn_lan, lan_lbServers_Game);

	lan_lbServers_Players = spawn(CListBox);
	lan_lbServers_Players.SetPos(572,140+3);
	lan_lbServers_Players.SetSize(42,309-6);
	lan_lbServers_Players.SetChanged(lan_lb_clicked);
	Widget_Add(fn_lan, lan_lbServers_Players);

	lan_lbServers_Addresses = spawn(CListBox);

	lan_sbServers = spawn(CScrollbar);
	lan_sbServers.SetPos(614,141);
	lan_sbServers.SetHeight(309);
	lan_sbServers.SetCallback(lan_lb_changed);
	//xlan_sbServers.SetMax(g_resolutions.length);
	Widget_Add(fn_lan, lan_sbServers);
}

void
menu_langames_draw(void)
{
	Widget_Draw(fn_lan);
	Master_ResortCache();
	Header_Draw(HEAD_LAN);
	
	/* Labels */
	WLabel_Static(282, 128, m_reslbl[IDS_SERVER_GAMESERVER], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(377, 128, m_reslbl[IDS_SERVER_SPEED], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(422, 128, m_reslbl[IDS_SERVER_MAP], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(497, 128, m_reslbl[IDS_SERVER_GAME], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(572, 128, m_reslbl[IDS_SERVER_PLAYERS], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
}

void
menu_langames_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_lan, evtype, scanx, chary, devid);
}
