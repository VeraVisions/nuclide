
typedef struct
{
 	string m_channelHandle;
 	string m_channelTopic;
	int m_connectionEstablished;
	string m_nickName;
} chatSystem_t;

chatSystem_t g_chatService;
tcpinfo_t tcp_fragNet;
var string g_chatMotd = "No Message Of The Day received.";

static void
FragNet_ChatUserJoined(string user)
{
	int present = FALSE;
	user = strreplace("@", "", user);
	user = strreplace("+", "", user);
#if 0
	for (int i = 0; i < cr_lbUsers.GetCount(); i++) {
		if (cr_lbUsers.GetItem(i) == user) {
			present = TRUE;
		}
	}

	if (present == FALSE) {
		cr_lbUsers.AddEntry(user);
	}
#endif
}

static void
FragNet_ChatUserLeft(string user)
{
	user = strreplace("@", "", user);
	user = strreplace("+", "", user);
#if 0
	for (int i = 0; i < cr_lbUsers.GetCount(); i++) {
		if (cr_lbUsers.GetItem(i) == user) {
			int last = cr_lbUsers.GetCount()-1;
			cr_lbUsers.SetItem(i, cr_lbUsers.GetItem(last));
			cr_lbUsers.DelEntry(last);
		}
	}
#endif
}

static void
FragNet_DebugPrint(string buffer)
{
	printf("%s\n", buffer);
// 	cr_lbHistory.InsertWrapped(buffer);
}


static void
FragNet_DispatchMessage(string msg)
{
	TCP_Send(&tcp_fragNet, msg);
}

static void
FragNet_RequestGuestNickname(void)
{
	g_chatService.m_nickName = sprintf("Guest%d", rint(random(0,9999)));
	FragNet_DispatchMessage(sprintf("NICK %s\n", g_chatService.m_nickName));
}

static int
FragNet_ChatCharIsNum(int i)
{
	if (i >= 48 && i <= 57)
		return TRUE;

	return FALSE;
}


static string
FragNet_ChatColorToHex(float num)
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
static string
FragNet_DecodeFunString(string msg)
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
			if (FragNet_ChatCharIsNum((int)msg[i]) && FragNet_ChatCharIsNum((int)msg[i+1])) {
				float ci = stof(sprintf("%c%c", msg[i], msg[i+1]));
				string col = FragNet_ChatColorToHex(ci);
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


static void
FragNet_ChatMessageReceived(string src, string out)
{
	string noColorOut = strdecolorize(out);
	bool isAction = (substring(noColorOut, 0, 6) == "ACTION") ? true : false;

	/* is this a normal message? */
	if (isAction == false) {
		string finalOutput = FragNet_DecodeFunString(out);
		memfree((__variant *)finalOutput);
	} else {
		out = substring(out, 8, -1);
	}

	localcmd(sprintf("addChatLine \"^2[Direct] ^7%s^7: %s\"\n", src, out));
	ChatCallback_MessageReceived(src, out);
}



static void
FragNet_GroupMessageReceived(string src, string group, string out)
{
	string noColorOut = strdecolorize(out);
	bool isAction = (substring(noColorOut, 0, 6) == "ACTION") ? true : false;

	/* is this a normal message? */
	if (isAction == false) {
		string finalOutput = FragNet_DecodeFunString(out);
		memfree((__variant *)finalOutput);
	} else {
		out = substring(out, 8, -1);
	}

	localcmd(sprintf("addChatLine \"^3[%s] ^7%s^7: %s\"\n", group, src, out));
	ChatCallback_GroupMessageReceived(group, src, out);
}


void
FragNet_SendMessage(string toUser, string messageString)
{
	FragNet_DispatchMessage(sprintf("PRIVMSG %s :%s\n", toUser, messageString));
}

/* irc processing functions */
static void
FragNet_ReceiveNetworkBuffer(string buffer)
{
	int l;
	string src;
	string code;
	string target;
	string data;

	if (!buffer)
		return;

	l = tokenize(buffer);

	src = argv(1);
	code = argv(2);
	target = argv(3);
	data = argv(4);

	/* IRC tokenization goes like this:
		[SOURCE] [CODE] [TARGET] [DATA]
	   example would be something like:

	   A message 'test' from eukara to channel #debug:
		:eukara!eukara@irc.won.net PRIVMSG #debug :test

	   A message 'hello' from eukara to user Frank:
		:eukara!eukara@irc.won.net PRIVMSG Frank :hello
	*/

	if (substring(buffer, 0, 4) == "PING") {
		FragNet_DispatchMessage(sprintf("PONG :%s\n", substring(buffer, 6, -1)));
		return;
	}

	/* define the source */
	src = substring(src, 0, strstrofs(src, "!"));

	if (src == "")
		src = "Server";

	/* process the code */
	switch (code) {
	case "PRIVMSG": /* a message */
		string msg = substring(buffer, strstrofs(buffer, ":", 1) + 1, -1);

		/* is this a direct message? */
		if (target == g_chatService.m_nickName)
			FragNet_ChatMessageReceived(src, msg);
		else
			FragNet_GroupMessageReceived(src, target, msg);

		break;
	case "321":
// 		crl_clearrooms();
		break;
	case "322":
// 		crl_addroom(argv(4));
		break;
	case "323":
// 		crl_roomsdone();
		break;
	case "332": /* topic upon joining channel */
	case "TOPIC": /* topic change */
		tokenizebyseparator(buffer, ":");
		tokenizebyseparator(argv(2), " - ");
		g_chatService.m_channelTopic = argv(0);
		break;
	case "NOTICE": /* server notice */
		break;
	case "JOIN": /* a player joined */
		if (src == g_chatService.m_nickName) {
// 			FragNet_DebugPrint(sprintf("You are now speaking in %s", g_chatService.m_channelHandle));
			break;
		}

		FragNet_ChatUserJoined(src);
// 		FragNet_DebugPrint(sprintf("%s joined the chat.", src));
		break;
	case "QUIT": /* a player quit */
	case "PART": /* a player left the channel */
		if (src == g_chatService.m_nickName)
			break;

		FragNet_ChatUserLeft(src);
// 		FragNet_DebugPrint(sprintf("%s left the chat.", src));
		break;
	case "353": /* channel user list */
		tokenizebyseparator(buffer, ":");
		int c = tokenize(argv(2));
		for (int i = 0; i < c; i++)
			FragNet_ChatUserJoined(argv(i));
		break;
	case "366": /* end of user list */
		g_chatService.m_connectionEstablished = 1;
		break;
	case "431": /* no nickname given */
	case "432": /* erroneus nickname */
	case "433": /* nick already in use */
		FragNet_RequestGuestNickname();
		break;
	case "475": /* password protected/wrong */
// 		FragNet_DebugPrint(sprintf("%s is a password protected channel. Access denied.", g_chatService.m_channelHandle));
		break;
	case "375": /* motd started */
		g_chatMotd = "";
		break;
	case "372": /* motd line */
		string line = substring(buffer, strstrofs(buffer, ":", 1) + 3, -1);
		g_chatMotd = strcat(g_chatMotd, line, "\n");
		break;
	case "376": /* motd done, finished connecting to the server */
		g_chatService.m_connectionEstablished = 1;
		printf("Connection established. You're now ^2online^7.\n");
		OnlineCallback_ConnectionEstablished();
		FragNet_DispatchMessage(sprintf("JOIN %s\n", g_chatService.m_channelHandle));
		break;
	case "NICK": /* nick changed */
		tokenizebyseparator(buffer, ":");
#if 0
		for (int i = 0; i < cr_lbUsers.GetCount(); i++) {
			if (cr_lbUsers.GetItem(i) == src) {
				cr_lbUsers.SetItem(i, argv(2));
				break;
			}
		}
#endif
		FragNet_DebugPrint(sprintf("%s is now known as %s", src, argv(2)));

	default:
// 		dprint(buffer);
// 		dprint("\n");
	}
}


void
FragNet_SignOn(void)
{
	int i;
	string channel;

	if (FragNet_Status() != STATE_OFFLINE) {
		return;
	}

	printf("Establishing connection to online service...\n");

	i = TCP_Connect(&tcp_fragNet, "tcp://irc.frag-net.com:6667");

	if (i < 0) {
		printf("Unable to connect to online service.\n");
		return;
	}

	channel = GameLibrary_GetInfo(GAMEINFO_CHATROOM);

	/* we're already setting a default channel, but a mod might set it
	   set it to something empty to mess with us */
	if (!channel)
		channel = cvar_string("game");

	g_chatService.m_channelHandle = "#scihunt";
	FragNet_DispatchMessage("USER guest fn irc.won.net :Player\n");

	/* attempt to force our nickname to be the same as in-game.
	 * we'll probably have to keep track of event 433 though. */
	g_chatService.m_nickName = cvar_string("name");
	FragNet_DispatchMessage(sprintf("NICK %s\n", g_chatService.m_nickName));
}

void
FragNet_SignOff(void)
{
	if (FragNet_Status() == STATE_OFFLINE) {
		return;
	}

	FragNet_DispatchMessage("QUIT :Later!\n");
	TCP_Disconnect(&tcp_fragNet);
	printf("Closed connection to the online service.\n");
	g_chatService.m_connectionEstablished = 0;
	OnlineCallback_ConnectionClosed();
}

fnState_t
FragNet_Status(void)
{
	tcpstate_t currentState = TCP_GetState(&tcp_fragNet);

	switch (currentState) {
	case STATE_CONNECTING:
		return STATE_SIGNON;
		break;
	case STATE_CONNECTED:
		if (currentState == STATE_CONNECTED) {
			return (g_chatService.m_connectionEstablished) == 1 ? (STATE_ONLINE) : (STATE_AUTHORIZING);
		}
		break;
	case STATE_DISCONNECTED:
	default:
		return (STATE_OFFLINE);
	}

	return (STATE_OFFLINE);
}

void
FragNet_Frame(void)
{
	TCP_Frame(&tcp_fragNet);
	FragNet_ReceiveNetworkBuffer(TCP_Receive(&tcp_fragNet));
}

bool
FragNet_NickInFriendsList(string userNick)
{
	string oldList = cvar_string("ui_friends");

	for (int i = 0; i < tokenize_console(oldList); i++) {
		if (argv(i) == userNick) {
			return (true);
		}
	}

	return (false);
}

void
FragNet_AddFriend(string friendNick)
{
	if (FragNet_NickInFriendsList(friendNick) == true) {
		return;
	}

	string oldList = cvar_string("ui_friends");
	cvar_set("ui_friends", strcat(oldList, friendNick, " "));
}

void
FragNet_RemoveFriend(string friendNick)
{
	if (FragNet_NickInFriendsList(friendNick) == false) {
		return;
	}

	string oldList = cvar_string("ui_friends");
	string newList = "";

	/* assemble a new list */
	for (int i = 0; i < tokenize_console(oldList); i++) {
		if (argv(i) != friendNick) {
			newList = strcat(newList, argv(i), " ");
		}
	}

	cvar_set("ui_friends", newList);
}

void
FragNet_UpdateStatus(string foo, string bar)
{
	FragNet_DispatchMessage(sprintf("AWAY :In-Game: %s; %s\n", foo, bar));
}

string
FragNet_GetMessageOfTheDay(void)
{
	return (g_chatMotd);
}

/* The functions below should be overriden (redefine them) by a game specific progs */
__weak void
OnlineCallback_ConnectionEstablished(void)
{
	printf("Message of the Day:\n%s\n", g_chatMotd);
}

__weak void
OnlineCallback_ConnectionClosed(void)
{

}

__weak void
ChatCallback_MessageReceived(string fromUser, string messageString)
{

}

__weak void
ChatCallback_GroupMessageReceived(string groupName, string fromUser, string messageString)
{

}
