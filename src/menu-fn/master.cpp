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

#define MASTER_DNS "master.frag-net.com"
#define MASTER_PORT 27950

float srv_fldAdress;
float srv_fldName;
float srv_fldPing;
float srv_fldPlayers;
float srv_fldMaxplayers;
float srv_fldMap;
float srv_fldGame;

string
Master_Resolve(void)
{
	string out = netaddress_resolve(MASTER_DNS,MASTER_PORT);
	print("Resolving master at ");
	print(MASTER_DNS);
	print(":");
	print(ftos(MASTER_PORT));
	print("...\n");

	if (!out) {
		print("Failed to resolve address.\n");
	}

	return out;
}

int
Master_GetTotalServers(void)
{
	int a = gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
	
	if (a) {
		print(sprintf("Master reports a total of %i servers.\n", a));
	}
	return gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
}

void
Master_RefreshCache(void)
{
	print("Refreshing host cache...\n");
	resethostcachemasks();
	//sethostcachemaskstring(0, gethostcacheindexforkey("gamedir"), cvar_string("game"), SLIST_TEST_EQUAL);
	sethostcachesort(gethostcacheindexforkey("ping"), FALSE);
	refreshhostcache(FALSE);
	resorthostcache();
	int a = gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
	
	if (a) {
		print(sprintf("Master reports a total of %i servers.\n", a));
	}
}

void
Master_UpdateCache(void)
{
	print("Updating host cache...\n");
	resethostcachemasks();
	//sethostcachemaskstring(0, gethostcacheindexforkey("gamedir"), cvar_string("game"), SLIST_TEST_EQUAL);
	sethostcachesort(gethostcacheindexforkey("ping"), FALSE);
	refreshhostcache(TRUE);
	resorthostcache();
	int a = gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
	
	if (a) {
		print(sprintf("Master reports a total of %i servers.\n", a));
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
}

void
Master_GetInternetList(void)
{
	/*string url = sprintf("%s:%d",MASTER_DNS,MASTER_PORT);
	localcmd("net_master1 \"localhost\"\n");
	localcmd("net_master2 \"\"\n");
	localcmd("net_master3 \"\"\n");
	localcmd("net_master4 \"\"\n");
	localcmd("net_master5 \"\"\n");
	localcmd("net_master6 \"\"\n");
	localcmd("net_master7 \"\"\n");
	localcmd("net_master8 \"\"\n");
	cvar_set("net_masterextra1", url);
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
	/*localcmd("net_master1 \"localhost\"\n");
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
