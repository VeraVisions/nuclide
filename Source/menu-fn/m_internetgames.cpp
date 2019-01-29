/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
CServerList inet_lbServers;
CScrollbar inet_sbServers;

/* Button Callbacks */
void inet_btnjoin(void)
{
	string addr = inet_lbServers.GetSelectedItem();
	
	if (addr) {
		localcmd(sprintf("connect %s\n", addr));
	}
}
void inet_btncreate_start(void)
{
	static void inet_btncreate_end(void) {
		g_menupage = PAGE_CREATEGAMEINET;
	}
	cvar_set("sv_public", "1");
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(30,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CREATEGAME);
	header.SetExecute(inet_btncreate_end);
}

void inet_btndone_start(void)
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

void inet_btnrefresh(void)
{
	int count = 0;
	int added = 0;

	//Master_RefreshCache();
	count = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	inet_lbServers.Clear();

	for (int i = 0; i < count; i++) {
		string address = gethostcachestring(srv_fldAdress, i);
		if (!address || Server_IsLan(address)) {
			continue;
		}
		inet_lbServers.AddEntry(address);
		print(sprintf("Adding %s to the Internet server list\n", address));
		added++;
	}
	
	print(sprintf("Added %i Internet servers.\n", added));
	inet_sbServers.SetMax(added);
}

void menu_internetgames_init(void)
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

	inet_lbServers = spawn(CServerList);
	inet_lbServers.SetPos(166+3,141+3);
	inet_lbServers.SetSize(464-6-16,294-6);
	Widget_Add(fn_inet, inet_lbServers);

	inet_sbServers = spawn(CScrollbar);
	inet_sbServers.SetPos(614,141);
	inet_sbServers.SetHeight(294);
	//inet_sbServers.SetCallback(vm_sbres_changed);
	//xinet_sbServers.SetMax(g_resolutions.length);
	Widget_Add(fn_inet, inet_sbServers);

	inet_btnDone = spawn(CMainButton);
	inet_btnDone.SetImage(BTN_DONE);
	inet_btnDone.SetExecute(inet_btndone_start);
	inet_btnDone.SetPos(30,396);
	Widget_Add(fn_inet, inet_btnDone);
}

void menu_internetgames_draw(void)
{
	Widget_Draw(fn_inet);
	Master_ResortCache();
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_INETGAMES],[460,80], [1,1,1], 1.0f, 1);
	
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
}

void menu_internetgames_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_inet, evtype, scanx, chary, devid);
}
