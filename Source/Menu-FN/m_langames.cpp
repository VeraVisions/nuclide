/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

CWidget fn_lan;
CMainButton lan_btnJoin;
CMainButton lan_btnCreate;
CMainButton lan_btnViewGame;
CMainButton lan_btnRefresh;
CMainButton lan_btnDone;

CFrame lan_frServers;
CServerList lan_lbServers;
CScrollbar lan_sbServers;

/* Button Callbacks */
void lan_btnjoin(void)
{
	string addr = lan_lbServers.GetSelectedItem();
	
	if (addr) {
		localcmd(sprintf("connect %s\n", addr));
	}
}
void lan_btncreate_start(void)
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

void lan_btndone_start(void)
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
void lan_btnrefresh(void)
{
	int count = 0;
	int added = 0;

	//Master_RefreshCache();
	count = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	lan_lbServers.Clear();

	for (int i = 0; i < count; i++) {
		string address = gethostcachestring(srv_fldAdress, i);
		if (!address || !Server_IsLan(address)) {
			continue;
		}
		lan_lbServers.AddEntry(address);
		print(sprintf("Adding %s to the LAN server list\n", address));
		added++;
	}
	print(sprintf("Added %i LAN servers.\n", added));
	lan_sbServers.SetMax(added);
}

void menu_langames_init(void)
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

	lan_lbServers = spawn(CServerList);
	lan_lbServers.SetPos(196+3,140+3);
	lan_lbServers.SetSize(434-6-16,309-6);
	Widget_Add(fn_lan, lan_lbServers);

	lan_sbServers = spawn(CScrollbar);
	lan_sbServers.SetPos(614,141);
	lan_sbServers.SetHeight(309);
	//lan_sbServers.SetCallback(vm_sbres_changed);
	//xlan_sbServers.SetMax(g_resolutions.length);
	Widget_Add(fn_lan, lan_sbServers);
}

void menu_langames_draw(void)
{
	Widget_Draw(fn_lan);
	Master_ResortCache();
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_LAN],[460,80], [1,1,1], 1.0f, 1);
	
	/* Labels */
	WLabel_Static(g_menuofs[0] + 282, g_menuofs[1] + 128, m_reslbl[IDS_SERVER_GAMESERVER], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 377, g_menuofs[1] + 128, m_reslbl[IDS_SERVER_SPEED], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 422, g_menuofs[1] + 128, m_reslbl[IDS_SERVER_MAP], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 497, g_menuofs[1] + 128, m_reslbl[IDS_SERVER_GAME], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(g_menuofs[0] + 572, g_menuofs[1] + 128, m_reslbl[IDS_SERVER_PLAYERS], 10, 10, [1,1,1],
					1.0f, 0, font_arial);
}

void menu_langames_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_lan, evtype, scanx, chary, devid);
}
