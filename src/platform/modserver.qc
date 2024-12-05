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

#ifndef WEBMENU
/* the same as GameLibrary_IDForPackageName */
static int
ModServer_IDForPackageName(string packageName)
{
	string f;

	for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string name;
		name = getpackagemanagerinfo(i, GPMI_NAME);

		/* Spike started randomly putting version numbers into package names */
		f = sprintf("%s=%s", packageName, getpackagemanagerinfo(i, GPMI_VERSION));

		if (name == f) {
			return i;
		}
	}

	/* no package id whatsoever */
	return (-1i);
}

void
ModServer_Refresh(void)
{
	uri_get("http://www.frag-net.com/mods/_list.txt", MODSERVER_REQ_LIST);
	g_iModServerLoading = TRUE;
	g_iModServerReqCount = 0;
}

void
ModServer_ParseList(string data)
{
	int c = 0;
	int finalcount = 0;
	c = tokenize(data);

	for (int i = 0; i < c; i++) {
		int skip = 0;
		string gamedir = argv(i);

		for (int x = 0; x < GameLibrary_GetGameCount(); x++) {
			/* skip mods we already have. */
			if (gamedir == GameLibrary_GetGameInfo(x, GAMEINFO_GAMEDIR)) {
				skip = 1;
				break;
			}
		}

		if (skip) {
			print(sprintf("^2ModServer_ParseList^7: Skipping %s\n", gamedir));
			continue;
		}

		print(sprintf("^2ModServer_ParseList^7: Querying mod-data for %s\n", gamedir));
		uri_get(sprintf("http://www.frag-net.com/mods/%s.fmf",uri_escape(gamedir)), MODSERVER_REQ_ITEM);
		finalcount++;
	}

	/* only count the ones that'll actually be queried */
	g_iModServerReqCount = finalcount;

	/* URI_GET never happens, so we can't count them down */
	if (g_iModServerReqCount == 0) {
		g_iModServerLoading = FALSE;
	}
}

void
ModServer_ParseItem(string data)
{
	int gameID;
	int c = tokenize(data);

	/* new id */
	gameID = gameinfo_count;
	gameinfo_count++;
	games = (gameEntry_t *)memreallocOld(games, sizeof(gameEntry_t), gameID, gameinfo_count);

	if (!games) {
		print("No more memory. Bye bye.\n");
		return;
	}

	/* set up defaults */
	games[gameID].url_info = "";
	games[gameID].url_dl = "";
	games[gameID].version = "1.0";
	games[gameID].size = 0;
	games[gameID].type = "";
	games[gameID].nomodels = 0;
	games[gameID].mpentity = "info_player_deathmatch";
	games[gameID].gamedll = "progs.dat";
	games[gameID].startmap = "c0a0";
	games[gameID].trainingmap = "t0a0";
	games[gameID].cldll = 1;
	games[gameID].minversion = "1110";
	games[gameID].svonly = 0;
	games[gameID].installed = 0;
	games[gameID].pkgid = -1;

	for (int i = 0; i < c; i++) {
		switch(argv(i)) {
		case "gameinfo_game":
			games[gameID].game = argv(i+1);
			break;
		case "gameinfo_gamedir":
			games[gameID].gamedir = argv(i+1);
			break;
		case "gameinfo_fallback_dir":
			games[gameID].fallback_dir = argv(i+1);
			break;
		case "gameinfo_url_info":
			games[gameID].url_info = argv(i+1);
			break;
		case "gameinfo_url_dl":
			games[gameID].url_dl = argv(i+1);
			break;
		case "gameinfo_version":
			games[gameID].version = argv(i+1);
			break;
		case "gameinfo_size":
			games[gameID].size = stof(argv(i+1));
			break;
		case "gameinfo_svonly":
			games[gameID].svonly = stof(argv(i+1));
			break;
		case "gameinfo_cldll":
			games[gameID].cldll = stof(argv(i+1));
			break;
		case "gameinfo_type":
			games[gameID].type = argv(i+1);
			break;
		case "gameinfo_minversion":
			games[gameID].minversion = argv(i+1);
			break;
		case "gameinfo_nomodels":
			games[gameID].nomodels = stof(argv(i+1));
			break;
		case "gameinfo_mpentity":
			games[gameID].mpentity = argv(i+1);
			break;
		case "gameinfo_gamedll":
			games[gameID].gamedll = argv(i+1);
			break;
		case "gameinfo_startmap":
			games[gameID].startmap = argv(i+1);
			break;
		case "gameinfo_trainingmap":
			games[gameID].trainingmap = argv(i+1);
			break;
		case "gameinfo_pkgname":
			games[gameID].pkgname = argv(i+1);
			games[gameID].pkgid = ModServer_IDForPackageName(games[gameID].pkgname);
			break;
		default:
			break;
		}
	}
}

void Updater_URI_Callback(float gameID, float code, string data, int resourcebytes);

/* Called as an eventual result of the uri_get builtin. */
void
ModServer_URI_Callback(float uriID, float code, string data, int resourcebytes)
{
	/* count our requests down */
	if (uriID == MODSERVER_REQ_ITEM) {
		g_iModServerReqCount--;

		/* free the loading screen */
		if (g_iModServerReqCount <= 0) {
			g_iModServerLoading = FALSE;
		}
	}

	/* unvailable */
	if (code && uriID == MODSERVER_REQ_LIST) {
		print("^1ModServer_URI_Callback^7: Unable to retrieve list.\n");
		g_iModServerLoading = FALSE;
		return;
	}
	if (code && uriID == MODSERVER_REQ_ITEM) {
		print("^1ModServer_URI_Callback^7: Unable to retrieve mod entry.\n");
		return;
	}

	switch (uriID) {
	case MODSERVER_REQ_LIST:
		ModServer_ParseList(data);
		break;
	case MODSERVER_REQ_ITEM:
		ModServer_ParseItem(data);
		break;
	case MODSERVER_REQ_PKGNAMES:
		Updater_URI_Callback(uriID, code, data, resourcebytes);
		break;
	case ACTIVITYPUB_ACCOUNTS:
		ActivityPub_UpdatePlayerInfo(data);
		break;
	default:
		print(sprintf("^1ModServer_URI_Callback^7: Unknown request id %d with code %d\n", uriID, code));
	}
}
#endif
