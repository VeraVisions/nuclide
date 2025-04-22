void
Saves_Init(void)
{
	searchhandle searchy;
	searchy = search_begin("saves/*/info.fsv", SEARCH_NAMESORT, TRUE);

	g_savegame_count = search_getsize(searchy);
	g_savegames = memalloc(sizeof(savegame_t) * g_savegame_count);

	for (int i = 0; i < g_savegame_count; i++) {
		string fullpath = search_getfilename(searchy, i);
		g_savegames[i].m_strName = substring(fullpath, 6, strlen(fullpath) - 15);
		g_savegames[i].m_strPic = sprintf("saves/%s/screeny.tga", g_savegames[i].m_strName );
		precache_pic(g_savegames[i].m_strPic);
	}

	search_end(searchy);
}

int
Saves_GetSaveCount(void)
{
	return (g_savegame_count);
}

__variant
Saves_GetInfo(int saveID, saveInfo_t saveInfo)
{
	if (saveID >= g_savegame_count || saveID < 0i) {
		ncError("Invalid save id %i", saveID);
		return __NULL__;
	}

	switch (saveInfo) {
	case SAVEINFO_NAME:
		return g_savegames[saveID].m_strName;
		break;
	case SAVEINFO_PREVIEW:
		return g_savegames[saveID].m_strPic;
		break;
	default:
		return __NULL__;
	}
}
