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

void*
memrealloc(__variant *oldptr, int elementsize, int old_num, int new_num)
{
	void *n = memalloc(elementsize * new_num);

	if (!n) {
		print("^1memrealloc^7: Out of memory\n");
		return (0);
	}

	memcpy(n, oldptr, elementsize * old_num);
	memfree(oldptr);
	return n;
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

		for (int x = 0; x < gameinfo_count; x++) {
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
	int id;
	int c = tokenize(data);

	/* new id */
	id = gameinfo_count;
	gameinfo_count++;
	games = (gameinfo_t *)memrealloc(games, sizeof(gameinfo_t), id, gameinfo_count);

	if (!games) {
		print("No more memory. Bye bye.\n");
		return;
	}

	/* set up defaults */
	games[id].url_info = "";
	games[id].url_dl = "";
	games[id].version = "1.0";
	games[id].size = 0;
	games[id].type = "";
	games[id].nomodels = 0;
	games[id].mpentity = "info_player_deathmatch";
	games[id].gamedll = "progs.dat";
	games[id].startmap = "c0a0";
	games[id].trainingmap = "t0a0";
	games[id].cldll = 1;
	games[id].minversion = "1110";
	games[id].svonly = 0;
	games[id].installed = 0;
	games[id].pkgid = -1;

	for (int i = 0; i < c; i++) {
		switch(argv(i)) {
		case "gameinfo_game":
			games[id].game = argv(i+1);
			break;
		case "gameinfo_gamedir":
			games[id].gamedir = argv(i+1);
			break;
		case "gameinfo_fallback_dir":
			games[id].fallback_dir = argv(i+1);
			break;
		case "gameinfo_url_info":
			games[id].url_info = argv(i+1);
			break;
		case "gameinfo_url_dl":
			games[id].url_dl = argv(i+1);
			break;
		case "gameinfo_version":
			games[id].version = argv(i+1);
			break;
		case "gameinfo_size":
			games[id].size = stof(argv(i+1));
			break;
		case "gameinfo_svonly":
			games[id].svonly = stof(argv(i+1));
			break;
		case "gameinfo_cldll":
			games[id].cldll = stof(argv(i+1));
			break;
		case "gameinfo_type":
			games[id].type = argv(i+1);
			break;
		case "gameinfo_minversion":
			games[id].minversion = argv(i+1);
			break;
		case "gameinfo_nomodels":
			games[id].nomodels = stof(argv(i+1));
			break;
		case "gameinfo_mpentity":
			games[id].mpentity = argv(i+1);
			break;
		case "gameinfo_gamedll":
			games[id].gamedll = argv(i+1);
			break;
		case "gameinfo_startmap":
			games[id].startmap = argv(i+1);
			break;
		case "gameinfo_trainingmap":
			games[id].trainingmap = argv(i+1);
			break;
		case "gameinfo_pkgname":
			games[id].pkgname = argv(i+1);
			games[id].pkgid = ModServer_IDForPackageName(games[id].pkgname);
			break;
		default:
			break;
		}
	}
}

void Updater_URI_Callback(float id, float code, string data, int resourcebytes);

/* Called as an eventual result of the uri_get builtin. */
void
ModServer_URI_Callback(float id, float code, string data, int resourcebytes)
{
	/* count our requests down */
	if (id == MODSERVER_REQ_ITEM) {
		g_iModServerReqCount--;

		/* free the loading screen */
		if (g_iModServerReqCount <= 0) {
			g_iModServerLoading = FALSE;
		}
	}

	/* unvailable */
	if (code && id == MODSERVER_REQ_LIST) {
		print("^1ModServer_URI_Callback^7: Unable to retrieve list.\n");
		g_iModServerLoading = FALSE;
		return;
	}
	if (code && id == MODSERVER_REQ_ITEM) {
		print("^1ModServer_URI_Callback^7: Unable to retrieve mod entry.\n");
		return;
	}

	switch (id) {
	case MODSERVER_REQ_LIST:
		ModServer_ParseList(data);
		break;
	case MODSERVER_REQ_ITEM:
		ModServer_ParseItem(data);
		break;
	case MODSERVER_REQ_PKGNAMES:
		Updater_URI_Callback(id, code, data, resourcebytes);
		break;
	default:
		print(sprintf("^1ModServer_URI_Callback^7: Unknown request id %d with code %d\n", id, code));
	}
}
#endif
