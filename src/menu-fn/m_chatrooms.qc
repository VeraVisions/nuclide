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
CTextBuffer cr_lbHistory;
CListBox cr_lbUsers;
CDialog cr_dgConnect;

void crl_addroom(string);
void crl_clearrooms(void);
void crl_roomsdone(void);

/* Ladies and gentlemen, here's the very first IRC client written purely
 * in QuakeC. I have no regrets. */

typedef struct
{
	string m_strChannel;
	string m_strTopic;
	int m_iStatus;
	int m_iReady;
	string m_strNick;
} ircroom_t;
ircroom_t g_ircroom;
tcpinfo_t tcp_irc;

/* we've got a Internet servers button in this menu therefore */
void(void) cr_btnservers_start;

void
cr_print(string buffer)
{
	print(sprintf("%s\n", buffer));
	cr_lbHistory.InsertWrapped(buffer);
}

void
irc_send(string msg)
{
	TCP_Send(&tcp_irc, msg);
}

void
irc_adduser(string user)
{
	int present = FALSE;
	user = strreplace("@", "", user);
	user = strreplace("+", "", user);

	for (int i = 0; i < cr_lbUsers.GetCount(); i++) {
		if (cr_lbUsers.GetItem(i) == user) {
			present = TRUE;
		}
	}

	if (present == FALSE) {
		cr_lbUsers.AddEntry(user);
	}
}

void
irc_remuser(string user)
{
	user = strreplace("@", "", user);
	user = strreplace("+", "", user);

	for (int i = 0; i < cr_lbUsers.GetCount(); i++) {
		if (cr_lbUsers.GetItem(i) == user) {
			int last = cr_lbUsers.GetCount()-1;
			cr_lbUsers.SetItem(i, cr_lbUsers.GetItem(last));
			cr_lbUsers.DelEntry(last);
		}
	}
}

void
irc_clear(void)
{
	cr_lbUsers.Clear();
	cr_lbHistory.Clear();
	g_ircroom.m_iReady = 0;
}

void
irc_autoname(void)
{
	g_ircroom.m_strNick = sprintf("Guest%d", rint(random(0,9999)));
	irc_send(sprintf("NICK %s\n", g_ircroom.m_strNick));
}

int
irc_charisnum(int i)
{
	if (i >= 48 && i <= 57)
		return TRUE;

	return FALSE;
}

string
irc_hexfrommirc(float num)
{
	switch (num) {
	case 1:
		return Colors_RGB255_to_HEX([0,0,0]);
		break;
	case 2:
		return Colors_RGB255_to_HEX([0,0,127]);
		break;
	case 3:
		return Colors_RGB255_to_HEX([0,147,0]);
		break;
	case 4:
		return Colors_RGB255_to_HEX([255,0,0]);
		break;
	case 5:
		return Colors_RGB255_to_HEX([127,0,0]);
		break;
	case 6:
		return Colors_RGB255_to_HEX([156,0,156]);
		break;
	case 7:
		return Colors_RGB255_to_HEX([252,127,0]);
		break;
	case 8:
		return Colors_RGB255_to_HEX([255,255,0]);
		break;
	case 9:
		return Colors_RGB255_to_HEX([0,252,0]);
		break;
	case 10:
		return Colors_RGB255_to_HEX([0,147,147]);
		break;
	case 11:
		return Colors_RGB255_to_HEX([0,255,255]);
		break;
	case 12:
		return Colors_RGB255_to_HEX([0,0,252]);
		break;
	case 13:
		return Colors_RGB255_to_HEX([255,0,255]);
		break;
	case 14:
		return Colors_RGB255_to_HEX([127,127,127]);
		break;
	case 15:
		return Colors_RGB255_to_HEX([210,210,210]);
		break;
	default:
		return Colors_RGB255_to_HEX([255,255,255]);
	}
}

/* decodes mIRC color messages */
string
irc_decode_colors(string msg)
{
	int out[1024]; /* maxline */
	int m;
	string ret;

	m = 0;
	for (float i = 0; i < strlen(msg);) {
		/* we're in color territory now */
		if ((int)msg[i] == 3) {
			i++; /* forward */
			
			/* we've got a two symbol foreground code */
			if (irc_charisnum((int)msg[i]) && irc_charisnum((int)msg[i+1])) {
				float ci = stof(sprintf("%c%c", msg[i], msg[i+1]));
				string col = irc_hexfrommirc(ci);
				out[m] = col[0];
				out[m+1] = col[1];
				out[m+2] = col[2];
				out[m+3] = col[3];
				out[m+4] = col[4];
				m += 5; /* ^xFFF is 5 chars */
				i += 2; /* already skipped ^C, so now skip the num */
			}
		} else {
			out[m] = msg[i];
			m++;
			i++;
		}
	}

	ret = (string)memalloc(m);
	for (float i = 0; i < m; i++)
		ret[i] = out[i];

	return ret;
}

/* irc processing functions */
void
irc_receive(string buffer)
{
	int l;
	string src;

	if (!buffer)
		return;

	l = tokenize(buffer);

	/* IRC tokenization goes like this:
		[SOURCE] [CODE] [TARGET] [DATA]
	   example would be something like:

	   A message 'test' from eukara to channel #debug:
		:eukara!eukara@irc.won.net PRIVMSG #debug :test

	   A message 'hello' from eukara to user Frank:
		:eukara!eukara@irc.won.net PRIVMSG Frank :hello
	*/

	if (substring(buffer, 0, 4) == "PING") {
		irc_send(sprintf("PONG :%s\n", substring(buffer, 6, -1)));
		return;
	}

	/* define the source */
	src = substring(argv(1), 0, strstrofs(argv(1), "!"));

	if (src == "")
		src = "Server";

	/* process the code */
	switch (argv(2)) {
	case "PRIVMSG": /* a message */
		string msg = substring(buffer, strstrofs(buffer, ":", 1) + 1, -1);
		string out = irc_decode_colors(msg);
		cr_print(
			sprintf("%s<%s>%s %s",
				Colors_RGB255_to_HEX([192,192,192]),
				src,
				Colors_RGB255_to_HEX([255,255,255]),
				out
			)
		);
		localcmd(sprintf("_fnchat_msg \"^2[Chat-room] ^7%s^7: %s\"\n", src, out));
		memfree((__variant *)out);
		break;
	case "321":
		crl_clearrooms();
		break;
	case "322":
		crl_addroom(argv(4));
		break;
	case "323":
		crl_roomsdone();
		break;
	case "332": /* topic upon joining channel */
	case "TOPIC": /* topic change */
		tokenizebyseparator(buffer, ":");
		tokenizebyseparator(argv(2), " - ");
		g_ircroom.m_strTopic = argv(0);
		break;
	case "NOTICE": /* server notice */
		break;
	case "JOIN": /* a player joined */
		if (src == g_ircroom.m_strNick) {
			cr_print(sprintf("You are now speaking in %s", g_ircroom.m_strChannel));
			break;
		}

		irc_adduser(src);
		cr_print(sprintf("%s joined the chat.", src));
		break;
	case "QUIT": /* a player quit */
	case "PART": /* a player left the channel */
		if (src == g_ircroom.m_strNick)
			break;

		irc_remuser(src);
		cr_print(sprintf("%s left the chat.", src));
		break;
	case "353": /* channel user list */
		tokenizebyseparator(buffer, ":");
		int c = tokenize(argv(2));
		for (int i = 0; i < c; i++)
			irc_adduser(argv(i));
		break;
	case "366": /* end of user list */
		g_ircroom.m_iReady = 1;
		break;
	case "431": /* no nickname given */
	case "432": /* erroneus nickname */
	case "433": /* nick already in use */
		irc_autoname();
		break;
	case "475": /* password protected/wrong */
		cr_print(sprintf("%s is a password protected channel. Access denied.", g_ircroom.m_strChannel));
		g_ircroom.m_iReady = 1;
		break;
	case "376": /* logging done */
		irc_send(sprintf("JOIN %s\n", g_ircroom.m_strChannel));
		break;
	case "NICK": /* nick changed */
		tokenizebyseparator(buffer, ":");
		for (int i = 0; i < cr_lbUsers.GetCount(); i++) {
			if (cr_lbUsers.GetItem(i) == src) {
				cr_lbUsers.SetItem(i, argv(2));
				break;
			}
		}
		cr_print(sprintf("%s is now known as %s", src, argv(2)));
	default:
		dprint(buffer);
		dprint("\n");
	}
}

/* initial connect */
void
cr_makeconnection(void)
{
	int i;
	string channel;
	i = TCP_Connect(&tcp_irc, "tcp://irc.frag-net.com:6667");

	channel = games[gameinfo_current].chatroom;

	/* we're already setting a default channel, but a mod might set it
	   set it to something empty to mess with us */
	if (!channel)
		channel = cvar_string("game");

	g_ircroom.m_strChannel = sprintf("#%s", channel);
	irc_send("USER guest fn irc.won.net :Player\n");

	/* attempt to force our nickname to be the same as in-game.
	 * we'll probably have to keep track of event 433 though. */
	g_ircroom.m_strNick = cvar_string("name");
	irc_send(sprintf("NICK %s\n", g_ircroom.m_strNick));
}

/* when ENTER is pressed on the message box */
void
cr_input_enter(string text)
{
	if (!text)
		return;

	if (!g_ircroom.m_iStatus || TCP_GetState(&tcp_irc) != STATE_CONNECTED)
		return;

	cr_print(
		sprintf("%s<%s>%s %s",
			Colors_RGB255_to_HEX([128,100,0]),
			g_ircroom.m_strNick,
			Colors_RGB255_to_HEX([180,128,55]),
			text
		)
	);

	irc_send(sprintf("PRIVMSG %s :%s\n", g_ircroom.m_strChannel, text));
	cr_tbInput.SetText("");
}

void
cr_closeconnection(void)
{
	TCP_Disconnect(&tcp_irc);
}

void
cr_btndone_start(void)
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

void
cr_btnlistrooms_start(void)
{
	static void cr_btnlistrooms_end(void) {
		g_menupage = PAGE_CHATROOMS_LIST;
	}

	irc_send("LIST\n");

	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(30,70,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ROOMS);
	header.SetExecute(cr_btnlistrooms_end);
}

/* 'Done' button */
void
cr_btnservers_prepare(void)
{
	cr_btnservers_start();
}

void
menu_chatrooms_init(void)
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

	cr_lbHistory = spawn(CTextBuffer);
	cr_lbHistory.SetPos(33,104);
	cr_lbHistory.SetSize(450,331);
	//cr_lbHistory.SetChanged(inet_lb_clicked);
	Widget_Add(fn_chatrooms, cr_lbHistory);
	
	/*cr_sbHistory = spawn(CScrollbar);
	cr_sbHistory.SetPos(486,101);
	cr_sbHistory.SetHeight(337);
	cr_sbHistory.SetCallback(cr_sbhistory_changed);
	Widget_Add(fn_chatrooms, cr_sbHistory);*/

	cr_lbUsers = spawn(CListBox);
	cr_lbUsers.SetPos(505,104);
	cr_lbUsers.SetSize(122,331);
	//cr_lbUsers.SetChanged(inet_lb_clicked);
	Widget_Add(fn_chatrooms, cr_lbUsers);
	cr_dgConnect = spawn(CDialog);
}

string
menu_chatrooms_gettopic(void)
{
	if (g_ircroom.m_strTopic)
		return g_ircroom.m_strTopic;
	else
		return "No topic.";
}

void
menu_chatrooms_draw(void)
{
	static float timeout;

	Widget_Draw(fn_chatrooms);
	drawpic([g_menuofs[0]+550,g_menuofs[1]+10], g_bmp[FN_LOGO],[80,80], [1,1,1], 1.0f, 0);

	if (!g_ircroom.m_iStatus) {
		cr_makeconnection();
		timeout = 10.0f;
		g_ircroom.m_iStatus = TRUE;
	}

	if (TCP_GetState(&tcp_irc) == STATE_CONNECTING || !g_ircroom.m_iReady) {
		/* connecting... dialog */
		cr_dgConnect.Draw();
		WField_Static(162, 180, m_reslbl[IDS_FNET_LOGIN], 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		WField_Static(162, 200, sprintf("%d seconds remaining...\n", timeout), 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		WField_Static(162, 280, sprintf(m_reslbl[IDS_CHAT_JOIN], g_ircroom.m_strChannel), 320, 260,
						col_prompt_title, 1.0f, 2, font_label_p);
		timeout -= frametime;

		if (timeout < 0.0) {
			timeout = 10.0f;
			TCP_Disconnect(&tcp_irc);
			cr_btndone_start();
		}
	} else if (TCP_GetState(&tcp_irc) == STATE_CONNECTED) {
		drawsetcliparea(g_menuofs[0] + 33, g_menuofs[1] + 104, 450,331);
		drawresetcliparea();
		timeout = 10.0f;
	}

	/* draw the labels */
	WLabel_Static(30, 38, m_reslbl[IDS_MULTI_CHATROOMCAPTION], 22, 22, [0.4,0.4,0.4],
		1.0f, 0, font_label_p);
	WLabel_Static(155, 38, menu_chatrooms_gettopic(), 22, 22, [1,1,1],
		1.0f, 0, font_label_p);
	WLabel_Static(30, 446, m_reslbl[IDS_CHAT_PROMPT], 12, 12, [1,1,1],
		1.0f, 0, font_arial);
}

/* this function is run, even when the menu is visibly closed. we need to keep
 * the TCP session with the IRC server alive afterall */
void
menu_chatrooms_keepalive(void)
{
	TCP_Frame(&tcp_irc);
	irc_receive(TCP_Receive(&tcp_irc));
}

void
menu_chatrooms_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_chatrooms, evtype, scanx, chary, devid);
}
