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

#include "../menu-fn/tcp.cpp"

entity g_ircbridge;
tcpinfo_t tcp_irc;

const string g_irc_channeltarget = "#lobby";
var string g_bridge_nick;

/* irc processing functions */
void
irc_send(string msg)
{
	TCP_Send(&tcp_irc, msg);
}

void
irc_autoname(void)
{
	string nick;
	nick = sprintf("Server%d", rint(random(0,9999)));
	irc_send(sprintf("NICK %s\n", nick));
}

void
irc_receive(string buffer)
{
	int l;
	string src;

	if (!buffer)
		return;

	l = tokenize(buffer);

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
		break;
	case "321":
	case "322":
	case "323":
	case "332": /* topic upon joining channel */
	case "TOPIC": /* topic change */
	case "NOTICE": /* server notice */
	case "JOIN": /* a player joined */
	case "QUIT": /* a player quit */
	case "PART": /* a player left the channel */
	case "353": /* channel user list */
	case "366": /* end of user list */
		break;
	case "431": /* no nickname given */
	case "432": /* erroneus nickname */
	case "433": /* nick already in use */
		irc_autoname();
		break;
	case "475": /* password protected/wrong */
		print(sprintf("%s is a password protected channel. Access denied.", g_irc_channeltarget));
		break;
	case "376": /* logging done */
		irc_send(sprintf("JOIN %s\n", g_irc_channeltarget));
		break;
	case "NICK": /* nick changed */
		tokenizebyseparator(buffer, ":");
		g_bridge_nick = argv(2);
		break;
	default:
	}
}

void
IRCBridge_Frame(void)
{
	TCP_Frame(&tcp_irc);
	irc_receive(TCP_Receive(&tcp_irc));
	self.nextthink = time;
}

void
IRCBridge_ServerConnect(void)
{
	int i;
	i = TCP_Connect(&tcp_irc, "tcp://irc.frag-net.com:6667");
	irc_send(sprintf("USER guest fn irc.won.net :%s\n", cvar_string("hostname")));
	irc_autoname();
	self.think = IRCBridge_Frame;
	self.nextthink = time;
}

void
FMX_PlayerObituary(entity attk, entity targ, int weapon, int body, int dmg)
{
	irc_send(sprintf("PRIVMSG %s :%s whooped %s\n", g_irc_channeltarget, attk.netname, targ.netname));
}

string
FMX_ParseClientCommand(string cmd)
{
	if (!g_ircbridge) {
		g_ircbridge = spawn();
		g_ircbridge.think = IRCBridge_ServerConnect;
		g_ircbridge.nextthink = time;
	}

	tokenize(cmd);
	switch (argv(0)) {
	case "say":
		irc_send(sprintf("PRIVMSG %s :<%s> %s\n", g_irc_channeltarget, self.netname, argv(1)));
		break;
	}
	return cmd;
}
