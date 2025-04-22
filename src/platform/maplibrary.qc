/*
 * Copyright (c) 2023 Vera Visions LLC.
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

mapLibrary_t *g_mapLibrary;
var int g_mapLibrary_count = 0i;
var int map_blacklist_count = 0i;
string *map_blacklist;

static string
MapLibrary_GetMapGamedir(void)
{
	string gdir = cvar_string("fs_game");

	/* HACK: work around FTEQW's path choices */
	if (gdir == "ftehl")
		gdir = "valve";

	if (gdir == "fteq2")
		gdir = "baseq2";

	if (gdir == "fteq3")
		gdir = "baseq3";

	return gdir;
}

static bool
MapLibrary_MapInGameDir(string fileName, string gameDir)
{
	bool list = true;

	if (autocvar(fs_mapFilter, 1) == 0) {
		return (true);
	}

	//printf("Checking %S %S...\n", fileName, gameDir);

	/* only look for maps in the current gamedir, requires SEARCH_FULLPACKAGE */
	if (gameDir != MapLibrary_GetMapGamedir()) {
		return false;
	}

	/* ignore test_ prefix maps */
	if (substring(fileName, 0, 5) == "test_") {
		return false;
	}

	/* see if any of our blacklisted names match */
	for (int b = 0i; b < map_blacklist_count; b++) {
		if (fileName == map_blacklist[b]) {
			list = false;
			break;
		}
	}

	return list;
}

static string
MapLibrary_FindPreview(string mapFile)
{
	string imageExtensions = strcat(cvar_string("r_imageextensions"), " mat");
	int imageFormats = (int)tokenize(imageExtensions);
	string previewFile = "";
	string mapName = substring(mapFile, 0, strlen(mapFile) - 4);

	/* cycle through all possible extensions */
	for (int i = 0; i < imageFormats; i++) {
		previewFile = strcat("levelshots/", mapName, ".", argv(i));

		if (whichpack(previewFile)) {
			return previewFile;
		}

		previewFile = strcat("maps/", mapName, ".", argv(i));
		if (whichpack(previewFile)) {
			return previewFile;
		}
	}

	return __NULL__;
}

void
MapLibrary_Init(void)
{
	int i = 0i;
	int c = 0i;
	int mapCount = 0i;
	string mapFile, mapDir;
	searchhandle mapsearch;
	string gameDir;

	/* already initialized */
	if (g_mapLibrary_count != 0i)
		return;

	g_mapLibrary_count = 0i;
	gameDir = MapLibrary_GetMapGamedir();

	/* map blacklist code */
	filestream fs_blacklist;
	fs_blacklist = fopen("scripts/map_blacklist", FILE_READ);

	if (fs_blacklist >= 0) {
		string temp;

		while ((temp = fgets(fs_blacklist))) {
			map_blacklist_count++;
		}

		map_blacklist = memalloc(sizeof(string) * map_blacklist_count);
		fseek(fs_blacklist, 0);

		while ((temp = fgets(fs_blacklist))) {
			map_blacklist[i] = temp;
			i++;
		}

		fclose(fs_blacklist);
	}

	/* search for all maps in the current PATH */
	mapsearch = search_begin("maps/*.bsp:maps/*/*.bsp", SEARCH_NAMESORT | SEARCH_FULLPACKAGE | SEARCH_MULTISEARCH, TRUE);
	mapCount = search_getsize(mapsearch);

	/* we now iterate over the search entries to filter results out */
	for (i = 0i; i < mapCount; i++) {
		mapFile = substring(search_getfilename(mapsearch, i), 5, -1);

		/* the strlen(gameDir) is technically wrong, but it'll work anyway because
		   we only care about maps in the current game directory */
		mapDir = substring(search_getpackagename(mapsearch, i), 0, strlen(gameDir));

		if (MapLibrary_MapInGameDir(mapFile, mapDir) == true) {
			g_mapLibrary_count++;
		}
	}
	search_end(mapsearch);

	g_mapLibrary = (mapLibrary_t *)memalloc(sizeof(mapLibrary_t) * g_mapLibrary_count);

	/* let's do it again, but this time we'll sort the data into our array */
	mapsearch = search_begin("maps/*.bsp:maps/*/*.bsp", SEARCH_NAMESORT | SEARCH_FULLPACKAGE | SEARCH_MULTISEARCH, TRUE);
	mapCount = search_getsize(mapsearch);

	for (i = 0i; i < mapCount; i++) {
		mapFile = substring(search_getfilename(mapsearch, i), 5, -1);
		mapDir = substring(search_getpackagename(mapsearch, i), 0, strlen(gameDir));

		if (MapLibrary_MapInGameDir(mapFile, mapDir) == true) {
			g_mapLibrary[c].name = mapFile;
			g_mapLibrary[c].title = mapFile;
			g_mapLibrary[c].author = "Unknown";
			g_mapLibrary[c].type = "Unknown";
			g_mapLibrary[c].preview = MapLibrary_FindPreview(mapFile);

			c++;
		}
	}
	search_end(mapsearch);

	ncLog("...MapLibrary initialized (%i entries).", g_mapLibrary_count);
}

int
MapLibrary_GetMapCount(void)
{
	return g_mapLibrary_count;
}

__variant
MapLibrary_GetInfo(int mapID, mapType_t infoType)
{
	if (mapID >= g_mapLibrary_count || mapID < 0i) {
		ncError("Invalid map id %i", mapID);
		return __NULL__;
	}

	switch (infoType) {
	case MAPINFO_NAME:
		return g_mapLibrary[mapID].name;
		break;
	case MAPINFO_TITLE:
		return g_mapLibrary[mapID].title;
		break;
	case MAPINFO_AUTHOR:
		return g_mapLibrary[mapID].author;
		break;
	case MAPINFO_TYPE:
		return g_mapLibrary[mapID].type;
		break;
	case MAPINFO_PREVIEW:
		return g_mapLibrary[mapID].preview;
		break;
	default:
		return __NULL__;
	}
}
