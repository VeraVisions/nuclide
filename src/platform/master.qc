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

/* We cache these, because the engine may purge our cache anyway */
static int g_masterInternetServers;
static int g_masterLANServers;

static bool
Server_IsLan(string address)
{
	tokenizebyseparator(address, ".");

	if (argv(0) == "192" && argv(1) == "168") {
		return (1);
	} else {
		return (0);
	}
}

string
Master_Resolve(void)
{
	string out = netaddress_resolve(MASTER_DNS,MASTER_PORT);
	dprint("Resolving master at ");
	dprint(MASTER_DNS);
	dprint(":");
	dprint(ftos(MASTER_PORT));
	dprint("...\n");

	if (!out) {
		ncError("Failed to resolve master server address.");
		return __NULL__;
	}

	return out;
}

int
Master_GetTotalServers(void)
{
	int a = gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);

	if (a) {
		ncLog("Master reports a total of %i servers.", a);
	}

	return gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
}

int
Master_GetLANServers(void)
{
	return g_masterLANServers;
}

int
Master_GetInternetServers(void)
{
	return g_masterInternetServers;
}

void
Master_RecountServers(void)
{
	int count = 0i;
	g_masterInternetServers = 0i;
	g_masterInternetServers = 0i;

	count = (int)gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);

	for (int i = 0; i < count; i++) {
		string address;
		address = gethostcachestring(srv_fldAdress, i);

		/* skip empty entries */
		if not (address)
			continue;

		/* skip LAN */
		if (Server_IsLan(address)) {
			g_masterLANServers++;
		} else {
			g_masterInternetServers++;
		}
	}
}

void
Master_RefreshCache(void)
{
	ncLog("Refreshing host cache...");

	resethostcachemasks();
	sethostcachemaskstring(0, gethostcacheindexforkey("gamedir"), cvar_string("game"), SLIST_TEST_EQUAL);
	sethostcachesort(gethostcacheindexforkey("ping"), FALSE);
	refreshhostcache(FALSE);
	resorthostcache();
	Master_RecountServers();
	int a = Master_GetLANServers() + Master_GetInternetServers();

	if (a) {
		ncLog("Master reports a total of %i servers.", a);
	}
}

void
Master_ResortCache(void)
{
	resorthostcache();
	srv_fldAdress = gethostcacheindexforkey("cname");
	srv_fldName = gethostcacheindexforkey("name");
	srv_fldPing = gethostcacheindexforkey("ping");
	srv_fldPlayers = gethostcacheindexforkey("numhumans");
	srv_fldMaxplayers = gethostcacheindexforkey("maxplayers");
	srv_fldMap = gethostcacheindexforkey("map");
	srv_fldGame = gethostcacheindexforkey("game");
	srv_fldServerInfo = gethostcacheindexforkey("serverinfo");
	srv_fldPlayer0 = gethostcacheindexforkey("player");
}

void
Master_UpdateCache(void)
{
	ncLog("Updating host cache...");
	resethostcachemasks();
	sethostcachemaskstring(0, gethostcacheindexforkey("gamedir"), cvar_string("fs_game"), SLIST_TEST_EQUAL);
	sethostcachesort(gethostcacheindexforkey("ping"), FALSE);
	refreshhostcache(TRUE);
	Master_ResortCache();
	Master_RecountServers();
	int a = Master_GetLANServers() + Master_GetInternetServers();

	if (a) {
		ncLog("Master reports a total of %i servers.", a);
	}
}


void
Master_GetInternetList(void)
{
	/*string url = sprintf("%s:%d",MASTER_DNS,MASTER_PORT);
	cvar_set("net_master1", url);
	localcmd("net_master2 \"\"\n");
	localcmd("net_master3 \"\"\n");
	localcmd("net_master4 \"\"\n");
	localcmd("net_master5 \"\"\n");
	localcmd("net_master6 \"\"\n");
	localcmd("net_master7 \"\"\n");
	localcmd("net_master8 \"\"\n");
	localcmd("net_masterextra1 \"\"\n");
	localcmd("net_masterextra2 \"\"\n");
	localcmd("net_masterextra3 \"\"\n");
	localcmd("net_masterextra4 \"\"\n");
	localcmd("net_masterextra5 \"\"\n");
	localcmd("net_masterextra6 \"\"\n");
	localcmd("net_masterextra7 \"\"\n");
	localcmd("net_masterextra8 \"\"\n");*/

	Master_UpdateCache();
}

void
Master_GetLANList(void)
{
	/*localcmd("net_master1 \"255.255.255.255:27500\"\n");
	localcmd("net_master2 \"\"\n");
	localcmd("net_master3 \"\"\n");
	localcmd("net_master4 \"\"\n");
	localcmd("net_master5 \"\"\n");
	localcmd("net_master6 \"\"\n");
	localcmd("net_master7 \"\"\n");
	localcmd("net_master8 \"\"\n");
	localcmd("net_masterextra1 \"\"\n");
	localcmd("net_masterextra2 \"\"\n");
	localcmd("net_masterextra3 \"\"\n");
	localcmd("net_masterextra4 \"\"\n");
	localcmd("net_masterextra5 \"\"\n");
	localcmd("net_masterextra6 \"\"\n");
	localcmd("net_masterextra7 \"\"\n");
	localcmd("net_masterextra8 \"\"\n");*/

	Master_UpdateCache();
}
