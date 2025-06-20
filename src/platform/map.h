
/** Call to start a new game, at a set skill value. */
void
Map_NewGame(int skillValue)
{
	if (fileExists("cfg/chapter1.cfg")) {
		localcmd("set sv_background 0\nset sv_playerslots 1\nset maxclients 1\nset deathmatch 0\nset coop 0\nset g_gametype \"singleplayer\"\nexec cfg/chapter1.cfg");
	} else {
		localcmd( sprintf("set sv_background 0\nset skill %i\nset sv_playerslots 1\nset maxclients 1\nset deathmatch 0\nset coop 0\nset g_gametype \"singleplayer\"\n%s", skillValue, GameLibrary_GetInfo(GAMEINFO_STARTMAP)) );
	}

	RichPresence_Clear();
	switch (skillValue) {
	case 1:
		RichPresence_Set("status", "Singleplayer: Normal");
		break;
	case 2:
		RichPresence_Set("status", "Singleplayer: Medium");
		break;
	case 3:
		RichPresence_Set("status", "Singleplayer: Hard");
		break;
	}
}

/** Called to load the training level. */
void
Map_Training(void)
{
	RichPresence_Clear();
	RichPresence_Set("status", "Training");
	localcmd( sprintf("set sv_background 0\nmaxplayers 1\ndeathmatch 0\ncoop 0\nskill 2\nset g_gametype \"singleplayer\"\n%s", GameLibrary_GetInfo(GAMEINFO_TRAININGMAP)) );
}

/** Call to spawn a server with a desired level and gamemode. */
void
Map_SpawnServer(string hostName, string mapName, int maxPlayers, string gameType, string passWord)
{
	localcmd( sprintf( "set sv_background 0\nhostname %s\n", hostName ) );
	localcmd( sprintf( "maxplayers %i\n", maxPlayers ) );
	localcmd( sprintf( "sv_password %s\n", passWord ) );
	localcmd( sprintf( "g_gametype %s\n", gameType ) );
	localcmd( sprintf( "map %s\n", mapName ) );
	RichPresence_Clear();
	RichPresence_Set("status", sprintf("Multiplayer: %s", mapName));
}
