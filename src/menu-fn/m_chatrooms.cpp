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

CFrame cr_frLog;
CFrame cr_frUsers;
CTextBox cr_tbInput;
CWidget fn_chatrooms;
CMainButton cr_btnListRooms;
CMainButton cr_btnSearch;
CMainButton cr_btnServers;
CMainButton cr_btnDone;
CListBox cr_lbUsers;
CDialog cr_dgConnect;

typedef struct
{
	string cur_tab;
	string show_tab;
	int channel_grabbed;
	float user_refresh;
	float timer;
} ircsession_t;
ircsession_t g_irc;

var string g_crIRCchannel;
var int g_iIRCActive;

/* we've got a Internet servers button on here, so we require these */
void(void) cr_btnservers_start;

void cr_closeconnection(void)
{
	if (!g_iIRCActive) {
		return;
	}
	/* how is this meant to work? neither do! */
	con_printf(g_irc.show_tab, "/clear\n");
	con_getset(g_irc.show_tab, "clear");
	localcmd("irc /disconnect irc.frag-net.com:6667\n");
	g_iIRCActive = FALSE;
}

void cr_btndone_start(void)
{
	static void cr_btndone_end(void) {
		g_menupage = PAGE_MULTIPLAYER;
	}
	//cr_closeconnection();
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,239);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ROOMS);
	header.SetExecute(cr_btndone_end);
}

void cr_btnlistrooms_start(void)
{
	static void cr_btnlistrooms_end(void) {
		g_menupage = PAGE_CHATROOMS_LIST;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(30,70,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ROOMS);
	header.SetExecute(cr_btnlistrooms_end);
}

/* 'Done' button */
void cr_btnservers_prepare(void)
{
	//cr_closeconnection();
	cr_btnservers_start();
}

/* initial connect */
void cr_makeconnection(void)
{
	localcmd("plug_load irc\n");
	localcmd(sprintf("seta irc_nick %.9s\n", cvar_string("name")));
	localcmd(sprintf("seta irc_altnick %.5s%.4d\n", cvar_string("name"), rint(random(1000,9999))));
	g_crIRCchannel = "#lobby";
	localcmd(sprintf("irc /open irc.frag-net.com:6667 %s\n", g_crIRCchannel));
}

/* when ENTER is pressed on the message box */
void cr_input_enter(string text)
{
	localcmd(sprintf("irc /msg %s %s\n", g_crIRCchannel, text));
	cr_tbInput.SetText("");
}

void menu_chatrooms_init(void)
{
	fn_chatrooms = spawn(CWidget);
	cr_btnListRooms = spawn(CMainButton);
	cr_btnListRooms.SetImage(BTN_LISTROOMS);
	cr_btnListRooms.SetExecute(cr_btnlistrooms_start);
	cr_btnListRooms.SetPos(30,70);
	Widget_Add(fn_chatrooms, cr_btnListRooms);

	cr_btnSearch = spawn(CMainButton);
	cr_btnSearch.SetImage(BTN_SEARCH);
	//cr_btnSearch.SetExecute(cr_btncancel_start);
	cr_btnSearch.SetPos(156,70);
	Widget_Add(fn_chatrooms, cr_btnSearch);

	cr_btnServers = spawn(CMainButton);
	cr_btnServers.SetImage(BTN_INTERNET);
	cr_btnServers.SetExecute(cr_btnservers_prepare);
	cr_btnServers.SetPos(252,70);
	Widget_Add(fn_chatrooms, cr_btnServers);

	cr_btnDone = spawn(CMainButton);
	cr_btnDone.SetImage(BTN_DONE);
	cr_btnDone.SetExecute(cr_btndone_start);
	cr_btnDone.SetPos(408,70);
	Widget_Add(fn_chatrooms, cr_btnDone);

	cr_tbInput = spawn(CTextBox);
	cr_tbInput.SetPos(135,440);
	cr_tbInput.SetText("");
	cr_tbInput.SetCallOnEnter(cr_input_enter);
	cr_tbInput.SetLength(495);
	Widget_Add(fn_chatrooms, cr_tbInput);

	cr_frLog = spawn(CFrame);
	cr_frLog.SetPos(30,101);
	cr_frLog.SetSize(472,337);
	Widget_Add(fn_chatrooms, cr_frLog);

	cr_frUsers = spawn(CFrame);
	cr_frUsers.SetPos(502,101);
	cr_frUsers.SetSize(128,337);
	Widget_Add(fn_chatrooms, cr_frUsers);

	cr_lbUsers = spawn(CListBox);
	cr_lbUsers.SetPos(505,104);
	cr_lbUsers.SetSize(122,331);
	//cr_lbUsers.SetChanged(inet_lb_clicked);
	Widget_Add(fn_chatrooms, cr_lbUsers);
	cr_dgConnect = spawn(CDialog);
}

string menu_chatrooms_gettopic(void)
{
	string t = cvar_string("irc_currenttopic");
	if (t == "") {
		return "No topic";
	} else {
		tokenizebyseparator(t, " - "); /* strip long descriptions */
		return argv(0);
	}
}

void menu_chatrooms_draw(void)
{
	int tab_id;
	string tmp;

	Widget_Draw(fn_chatrooms);
	drawpic([g_menuofs[0]+550,g_menuofs[1]+10], "gfx/shell/fragnet",[80,80], [1,1,1], 1.0f, 0);

	/* we need to figure out which console buffer belongs to our chat. */
	g_irc.show_tab = g_irc.cur_tab;
	for (tmp = "", tab_id = 0; tmp; tmp = con_getset(tmp, "next")) {
		if (substring(tmp, 0, 3) == "IRC") {
			con_getset(tmp, "hidden", "1");
			string title = con_getset(tmp, "title");
		}
	}
	if not (g_irc.channel_grabbed)
		for (tmp = ""; tmp; tmp = con_getset(tmp, "next")) {
			if (substring(tmp, 0, 3) == "IRC" && substring(tmp, -strlen(g_crIRCchannel), -1) == g_crIRCchannel) {
				g_irc.show_tab = tmp;
				g_irc.channel_grabbed = TRUE;
				break;
			}
		}
	if (!g_irc.show_tab) {
		for (tmp = ""; tmp; tmp = con_getset(tmp, "next")) {
			if (substring(tmp, 0, 3) == "IRC" && substring(tmp, -1, -1) == ":") {
				g_irc.show_tab = tmp;
				break;
			}
		}
	}
	g_irc.cur_tab = g_irc.show_tab;

	/* establish the connection if nothing is found */
	if (!g_iIRCActive && !g_irc.show_tab) {
		cr_makeconnection();
		g_iIRCActive = TRUE;
		g_irc.timer = 10.0f;
	}

	/* draw the irc-log buffer when ready */
	if (g_irc.show_tab) {
		drawsetcliparea(g_menuofs[0] + 33, g_menuofs[1] + 104, 450,331);
		con_draw(g_irc.show_tab, [g_menuofs[0] + 33, g_menuofs[1] + 104], [450,331], 12);
		drawresetcliparea();
	} else {
		/* connecting... dialog */
		cr_dgConnect.Draw();
		WField_Static(162, 180, m_reslbl[IDS_WON_LOGIN], 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		WField_Static(162, 280, sprintf(m_reslbl[IDS_CHAT_JOIN], g_crIRCchannel), 320, 260,
						col_prompt_title, 1.0f, 2, font_label_p);
		g_irc.timer -= frametime;
		
		if (g_irc.timer < 0.0) {
			cr_btndone_start();
		}
	}

	/* draw the labels */
	WLabel_Static(30, 38, m_reslbl[IDS_MULTI_CHATROOMCAPTION], 22, 22, [0.4,0.4,0.4],
		1.0f, 0, font_label_p);
	WLabel_Static(155, 38, menu_chatrooms_gettopic(), 22, 22, [1,1,1],
		1.0f, 0, font_label_p);
	WLabel_Static(30, 446, m_reslbl[IDS_CHAT_PROMPT], 12, 12, [1,1,1],
		1.0f, 0, font_arial);

	/* update the user list periodically */
	if (g_irc.user_refresh > time) {
		return;
	}
	int c = tokenize(cvar_string("irc_currentusers"));
	g_irc.user_refresh = time + 2.0f;
	cr_lbUsers.Clear();
	for (int i = 0; i < c; i++) {
		cr_lbUsers.AddEntry(argv(i));
	}
}

void menu_chatrooms_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_chatrooms, evtype, scanx, chary, devid);
}
