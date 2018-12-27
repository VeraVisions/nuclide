/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

#define MASTER_DNS "frag-net.com"
#define MASTER_PORT 27950

float srv_fldAdress;
float srv_fldName;
float srv_fldPing;
float srv_fldPlayers;
float srv_fldMaxplayers;
float srv_fldMap;

string Master_Resolve(void)
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

int Master_GetTotalServers(void)
{
	int a = gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
	
	if (a) {
		print(sprintf("Master reports a total of %i servers.\n", a));
	}
	return gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
}

void Master_GetInternetList(void)
{
	print("Updating host cache...\n");
	string url = sprintf("%s:%d",MASTER_DNS,MASTER_PORT);
	cvar_set("net_masterextra1", url);
	localcmd("net_masterextra2 \"\"\n");
	localcmd("net_masterextra3 \"\"\n");
	localcmd("net_masterextra4 \"\"\n");
	localcmd("net_masterextra5 \"\"\n");
	localcmd("net_masterextra6 \"\"\n");
	localcmd("net_masterextra7 \"\"\n");
	localcmd("net_masterextra8 \"\"\n");
	resethostcachemasks();
	sethostcachesort( gethostcacheindexforkey( "ping" ), FALSE );
	refreshhostcache();
	resorthostcache();
}

void Master_GetLANList(void)
{
	localcmd("net_masterextra1 \"\"\n");
	localcmd("net_masterextra2 \"\"\n");
	localcmd("net_masterextra3 \"\"\n");
	localcmd("net_masterextra4 \"\"\n");
	localcmd("net_masterextra5 \"\"\n");
	localcmd("net_masterextra6 \"\"\n");
	localcmd("net_masterextra7 \"\"\n");
	localcmd("net_masterextra8 \"\"\n");
	resethostcachemasks();
	sethostcachesort( gethostcacheindexforkey( "ping" ), FALSE );
	refreshhostcache(TRUE);
	resorthostcache();
}

void Master_RefreshCache(void)
{
	print("Refreshing host cache...\n");
	resethostcachemasks();
	sethostcachesort( gethostcacheindexforkey( "ping" ), FALSE );
	refreshhostcache(FALSE);
}

void Master_ResortCache(void)
{
	resorthostcache();
	srv_fldAdress = gethostcacheindexforkey("cname");
	srv_fldName = gethostcacheindexforkey("name");
	srv_fldPing = gethostcacheindexforkey("ping");
	srv_fldPlayers = gethostcacheindexforkey("numhumans");
	srv_fldMaxplayers = gethostcacheindexforkey("maxplayers");
	srv_fldMap = gethostcacheindexforkey("map");
}

