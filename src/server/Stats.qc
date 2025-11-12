/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

var bool g_statLoggingEnabled;
filestream g_statLogHandle;
var float g_statMemoTime;
var string g_statMemoString;

typedef enum
{
	NGLOG_Q2OSP, /* NetGamesUSA provided their own tool with OSP */
	NGLOG_UT99,	/* compatible with UTStatsDB, supposedly (untested) */
	NGLOG_Q3A, /* compatible with a few different tools */
	NGLOG_IW, /* compatible with a few different tools */
} statloggingtype_t;

var statloggingtype_t autocvar_stats_logtype = NGLOG_IW;
var bool autocvar_stats_enabled = true;

string
ncStats::OutputFilename(void)
{
	string currentTime;
	string fileName;

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		currentTime = ncStats::NetGamesTime();
		fileName = strcat(currentTime, ".txt");
		return (fileName);
	case NGLOG_Q2OSP:
		currentTime = ncStats::NetGamesTime();
		fileName = strcat(currentTime, ".txt");
		return (fileName);
	default:
	case NGLOG_Q3A:
	case NGLOG_IW:
		float minutes = time / 60;
		float seconds = time % 60;
		return "games_mp.log";
	}
}

string
ncStats::NetGamesTime(void)
{
	string timeZoneString = strftime(true, "%z");
	float timeZoneFloat = stof(timeZoneString) * 0.01;
	string timeZone = strftime(true, "%Y.%m.%d.%H.%M.%S");

	/* not sure if we can get ms, so just put 000 there. this timestamp is never used for event logging */
	return sprintf("%s.000.%.1f", timeZone, timeZoneFloat);
}

string
ncStats::LocalTime(void)
{
	if (time == g_statMemoTime) {
		return (g_statMemoString);
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		return sprintf("%.2f", time);
	case NGLOG_Q2OSP:
		return sprintf("%.1f", time);
	default:
	case NGLOG_Q3A:
	case NGLOG_IW:
		float minutes = time / 60;
		float seconds = time % 60;
		g_statMemoTime = time;
		g_statMemoString = sprintf("%d:%02d", minutes, seconds);
		return (g_statMemoString);
	}
}

void
ncStats::Game(string keyName, string setValue)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tgame\t%s\t%s\n", LocalTime(), keyName, setValue));
		break;
	}

}

void
ncStats::Player(string keyName, string setValue)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tplayer\t%s\t%s\n", LocalTime(), keyName, setValue));
		break;
	}

}

void
ncStats::Map(string keyName, string setValue)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tmap\t%s\t%s\n", LocalTime(), keyName, setValue));
		break;
	}

}

void
ncStats::Info(string keyName, string setValue)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tinfo\t%s\t%s\n", LocalTime(), keyName, setValue));
		break;
	}

}

void
ncStats::Init(void)
{
	if (autocvar_stats_enabled == false || cvars.GetBool("sv_background") == true) {
		g_statLoggingEnabled = false;
		return;
	}

	string currentTime = NetGamesTime();
	string fileName = OutputFilename();

	g_statLogHandle = fopen(fileName, FILE_APPEND);

	if (g_statLogHandle < 0) {
		ncError("Unable to write log.txt");
		g_statLoggingEnabled = false;

		error(sprintf("Errored out of %s", fileName));
		return;
	}

	g_statLoggingEnabled = true;

	string serverAddress = serverinfo.GetString( "ip" );
	string serverPort = cvars.GetString("sv_port");
	string hostName = cvars.GetString("hostname");
	string maxClients = cvars.GetString("maxclients");
	string gameType = "Deathmatch";
	string gameVersion = "2";
	string gameModeVersion = "1";
	bool teamPlay = teams.TeamCount() > 1 ? (true) : (false);
	string adminName = "Admin";
	string adminMail = "admin@server.com";
	bool needPass = cvars.GetString("password") ? (true) : (false);

	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		string fullServerInfo = strcat("\\", "dmflags", "\\", "0");
		fullServerInfo = strcat(fullServerInfo, "\\", "fraglimit", "\\", cvars.GetString("fraglimit"));
		fullServerInfo = strcat(fullServerInfo, "\\", "timelimit", "\\", cvars.GetString("timelimit"));
		fullServerInfo = strcat(fullServerInfo, "\\", "sv_hostname", "\\", hostName);
		fullServerInfo = strcat(fullServerInfo, "\\", "sv_maxclients", "\\", maxClients);
		fullServerInfo = strcat(fullServerInfo, "\\", "com_gamename", "\\", "Nuclide");
		fullServerInfo = strcat(fullServerInfo, "\\", "g_gametype", "\\", "0");
		fullServerInfo = strcat(fullServerInfo, "\\", "mapname", "\\", serverinfo.GetString("mapname"));
		fullServerInfo = strcat(fullServerInfo, "\\", "gamename", "\\", cvars.GetString("fs_game"));
		fullServerInfo = strcat(fullServerInfo, "\\", "g_needpass", "\\", needPass ? "1" : "0");
		fputs(g_statLogHandle, sprintf("%s ------------------------------------------------------------\n", LocalTime()));
		fputs(g_statLogHandle, sprintf("%s InitGame: %s\n", LocalTime(), fullServerInfo));
		break;
	case NGLOG_UT99:
		Info("Log_Standard", "ngLog");
		Info("Log_Version", "1.2");
		Info("Log_Info", "http://www.netgamesusa.com/ngLog/");
		Info("Game_Name", "Nuclide");
		Info("Game_Version", gameVersion);
		Info("Game_Creator", "Vera Visions, L.L.C.");
		Info("Game_Creator_URL",  "http://www.vera-visions.com");
		Info("Game_Decoder_Ring_URL",  "http://www.vera-visions.com/Nuclide_Log_Decoder_Ring.html");
		Info("Absolute_time",  currentTime);
		Info("Server_ServerName", hostName);
		Info("Server_AdminName", adminName);
		Info("Server_AdminEmail", adminMail);
		Info("Server_Region", "0"); /* GameSpy Region. 0 - Anywhere */
		Info("Server_MOTDLine1", "");
		Info("Server_MOTDLine2", "");
		Info("Server_MOTDLine3", "");
		Info("Server_MOTDLine4", "");
		Info("Server_IP", serverAddress);
		Info("Server_Port", serverPort);
		Map("Name", world.model);
		Map("Title", world.message);
		Map("Author", ""); /* e.g. CliffyB */
		Map("IdealPlayerCount", "4");	/* is this a NetQuake reference? */
		Map("LevelEnterText", "");	/* is this a NetQuake reference? */
		Game("GameName", "Deathmatch");	/* mapping these is gonna be fun... */
		Game("GameVersion", gameModeVersion);
		Game("MinNetVersion", gameModeVersion);
		Game("NoMonsters", "False"); /* we can't actually force disable them for now. the gamerules delete monsters atm */
		Game("MuteSpectators", "False");
		Game("HumansOnly", "False");
		Game("WeaponsStay", "False");
		Game("ClassicDeathmessages", "False");
		Game("LowGore", "False");
		Game("VeryLowGore", "False");
		Game("TeamGame", teamPlay ? "True" : "False");
		Game("GameSpeed", "100"); /* TODO: map to sv_gamespeed */
		Game("MaxSpectators", cvars.GetString("maxspectators"));
		Game("MaxPlayers", cvars.GetString("sv_playerslots"));
		Game("FragLimit", cvars.GetString("fraglimit"));
		Game("TimeLimit", cvars.GetString("timelimit"));
		Game("MultiPlayerBots", "True"); /* always available */
		Game("HardCore", "False");
		Game("MegaSpeed", "False");
		Game("AirControl", "0.000000");
		Game("JumpMatch", "False");
		Game("UseTranslocator", "False");
		Game("TournamentMode", "False");
		Game("NetMode", "PracticeMatch");
		
		if (teamPlay) {
			Game("GoalTeamScore", "100");
			Game("FriendlyFireScale", "0");
		}
		break;
	case NGLOG_Q2OSP:
		Info("Log_Standard", "ngLog");
		Info("Log_Version", "1.2");
		Info("Log_Info", "http://www.netgamesusa.com/ngLog/");
		Info("Game_Name", "Nuclide");
		Info("Game_Version", "This Is A Versioning String");
		Info("Game_Author", "Vera Visions, L.L.C.");
		Info("Game_Author_URL",  "http://www.vera-visions.com");
		Info("Server_Adress", serverAddress);
		Info("Server_Port", serverPort);
		Info("Absolute_time",  currentTime);

		fputs(g_statLogHandle, sprintf("%s\tGame_Init\t%s\n", LocalTime(), currentTime));
		break;
	}

}

void
ncStats::Shutdown(void)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		fputs(g_statLogHandle, sprintf("%s ShutdownGame:\n", LocalTime()));
		fputs(g_statLogHandle, sprintf("%s ------------------------------------------------------------\n", LocalTime()));
		break;
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tGame_Shutdown\n", LocalTime()));
		break;
	}

	fclose(g_statLogHandle);
	g_statLoggingEnabled = false;
}

void
ncStats::Connect(ncClient connectingClient)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string playerName = connectingClient.netname;
	int playerNum =  num_for_edict(connectingClient) - 1;
	bool teamPlay = teams.TeamCount() > 1 ? (true) : (false);
	string playerInfoString = sprintf("n\\%s\\t\\%d\\u\\%s", playerName, connectingClient.team, infokey(connectingClient, "*cert_sha1"));


	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		fputs(g_statLogHandle, sprintf("%s ClientConnect: %i\n", LocalTime(), playerNum));
		fputs(g_statLogHandle, sprintf("%s ClientUserinfoChanged: %i %s\n", LocalTime(), playerNum, playerInfoString));
		break;
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\tplayer\tRename\t%s\t%i\n", LocalTime(), playerName, playerNum));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tTeamchange\t%i\t%i\n", LocalTime(), playerNum, 255i));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tConnect\t%s\t%s\n", LocalTime(), playerName, "False"));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tTeamName\t%i\n", LocalTime(), playerNum));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tTeam\t%i\t%i\n", LocalTime(), playerNum, 255i));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tTeamID\t%i\t%i\n", LocalTime(), playerNum, 0i));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tPing\t%i\t%i\n", LocalTime(), playerNum, 0i));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tIsABot\t%i\t%s\n", LocalTime(), playerNum, "False"));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tSkill\t%i\t%f\n", LocalTime(), playerNum, 1.0f));
		fputs(g_statLogHandle, sprintf("%s\tplayer\tNovice\t%i\t%s\n", LocalTime(), playerNum, "False"));
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Connect\t%s\t%i\n", LocalTime(), playerName, playerNum));
		break;
	}

}

void
ncStats::Enter(ncPlayer enteringPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string playerName = enteringPlayer.netname;
	int playerNum =  num_for_edict(enteringPlayer) - 1;


	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		fputs(g_statLogHandle, sprintf("%s ClientBegin: %i\n", LocalTime(), playerNum));
		break;
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Enter\t%s\t%i\n", LocalTime(), playerName, playerNum));
		break;
	}

}

void
ncStats::Leave(ncPlayer leavingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}
}

void
ncStats::Disconnect(ncPlayer disconnectingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string playerName = disconnectingPlayer.netname;
	int playerNum =  num_for_edict(disconnectingPlayer) - 1;


	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Leave\t%s\t%i\n", LocalTime(), playerName, playerNum));
		break;
	}

}

void
ncStats::Respawn(ncPlayer respawningPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	int playerNum =  num_for_edict(respawningPlayer) - 1;


	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Respawn\t%i\n", LocalTime(), playerNum));
		break;
	}

}

void
ncStats::NameChange(ncPlayer changedPlayer, string newName)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string oldName =  changedPlayer.netname;
	int playerNum =  num_for_edict(changedPlayer) - 1;
	int playerPing =  userinfo.GetInteger(changedPlayer, "ping");

	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		string playerInfoString = sprintf("n\\%s\\t\\%d", newName, changedPlayer.team);
		fputs(g_statLogHandle, sprintf("%s ClientUserinfoChanged: %i %s\n", LocalTime(), playerNum, playerInfoString));
		break;
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\tplayer\tRename\t%s\t%i\n", LocalTime(), newName, playerNum));
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Rename\t%s\t%s\t%i\t%i\n", LocalTime(), oldName, newName, playerNum, playerPing));
		break;
	}

}

void
ncStats::Kill(ncPlayer killedPlayer, ncEntity inflicingEntity, ncEntity attackingEntity, int attackerScoreChange, string attackerWeapon, int killedScoreChange, string deadWeapon)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	int deadNum = (int)(num_for_edict(killedPlayer) - 1);
	int deadPing = userinfo.GetInteger(killedPlayer, "ping");

	int attackerNum = (int)(num_for_edict(attackingEntity) - 1);
	int attackerPing = userinfo.GetInteger(attackingEntity, "ping");


	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
		break;
	case NGLOG_Q3A:
		if (killedPlayer == attackingEntity) {
			fputs(g_statLogHandle, sprintf("%s Kill: %i %i %i: %s killed %s by %s\n", LocalTime(), attackerNum, deadNum, 1i, killedPlayer.netname, killedPlayer.netname, "<world>"));
			return;
		}

		fputs(g_statLogHandle, sprintf("%s Kill: %i %i %i: %s killed %s by %s\n", LocalTime(), attackerNum, deadNum, 1i, attackingEntity.netname, killedPlayer.netname, attackerWeapon));
		break;
	case NGLOG_UT99:
		if (killedPlayer == attackingEntity) {
			fputs(g_statLogHandle, sprintf("%s\tsuicide\t%i\t%s\t%s\t%s\n", LocalTime(), deadNum, deadWeapon, "Unknown", "Self"));
			return;
		}

		/* yes, UT99s doesn't care whether it's teamplay. I checked */
		if (killedPlayer.team == attackingEntity.team) {
			fputs(g_statLogHandle, sprintf("%s\tteamkill\t%i\t%s\t%i\t%s\t%s\n", LocalTime(), attackerNum, attackerWeapon, deadNum, deadWeapon, "shot"));
		} else {
			fputs(g_statLogHandle, sprintf("%s\tkill\t%i\t%s\t%i\t%s\t%s\n", LocalTime(), attackerNum, attackerWeapon, deadNum, deadWeapon, "shot"));
		}
		break;
	case NGLOG_Q2OSP:
		if (killedPlayer == attackingEntity) {
			fputs(g_statLogHandle, sprintf("%s\tSuicide\t%i\t%s\t%i\t%i\n", LocalTime(), deadNum, deadWeapon, killedScoreChange, deadPing));
			return;
		}

		fputs(g_statLogHandle, sprintf("%s\tKill\t%i\t%s\t%i\t%i\t", LocalTime(), attackerNum, attackerWeapon, attackerScoreChange, attackerPing));
		fputs(g_statLogHandle, sprintf("%i\t%s\t%i\t%i\n", deadNum, deadWeapon, killedScoreChange, deadPing));
		break;
	}

}

void
ncStats::PickupItem(ncItem takenItem, ncPlayer inflictingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string itemName = takenItem.declclass;
	int itemID =  num_for_edict(takenItem);
	int playerNum =  num_for_edict(inflictingPlayer) - 1;
	int playerPing =  userinfo.GetInteger(inflictingPlayer, "ping");


	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		fputs(g_statLogHandle, sprintf("%s Item: %i %s\n", LocalTime(), playerNum, itemName));
		break;
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\titem_get\t%s\t%i\n", LocalTime(), itemName, playerNum));
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tItem_Pickup\t%s\t%i\t%i\t%i\n", LocalTime(), itemName, itemID, playerNum, playerPing));
		break;
	}

}

void
ncStats::UseItem(ncItem useditem, ncPlayer inflictingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string itemName = useditem.declclass;
	int itemID =  num_for_edict(useditem);
	int playerNum =  num_for_edict(inflictingPlayer) - 1;
	int playerPing =  userinfo.GetInteger(inflictingPlayer, "ping");
	int ngItemID = 0;

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\titem_activate\t%s\t%i\n", LocalTime(), itemName, playerNum));
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tItem_Use\t%s\t%i\t%i\t%i\n", LocalTime(), itemName, ngItemID, playerNum, playerPing));
		break;
	}

}

void
ncStats::DropItem(ncItem droppedItem, ncPlayer inflictingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string itemName = droppedItem.declclass;
	int itemID =  num_for_edict(droppedItem);
	int playerNum =  num_for_edict(inflictingPlayer) - 1;
	int playerPing =  userinfo.GetInteger(inflictingPlayer, "ping");
	int ngItemID = 0;

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tItem_Drop\t%s\t%i\t%i\t%i\n", LocalTime(), itemName, ngItemID, itemID, playerNum));
		break;
	}

}

void
ncStats::ExpireItem(ncItem expiredItem, ncPlayer inflictingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string itemName = expiredItem.declclass;
	int itemID =  num_for_edict(expiredItem);
	int playerNum =  num_for_edict(inflictingPlayer) - 1;
	int playerPing =  userinfo.GetInteger(inflictingPlayer, "ping");

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\titem_deactivate\t%s\t%i\n", LocalTime(), itemName, playerNum));
		break;
	case NGLOG_Q2OSP:
		if (!inflictingPlayer)
			fputs(g_statLogHandle, sprintf("%s\tItem_Expire\t%s\t%i\t%i\n", LocalTime(), itemName, itemID, -1i));
		else
			fputs(g_statLogHandle, sprintf("%s\tItem_Expire\t%s\t%i\t%i\n", LocalTime(), itemName, itemID, playerNum));
		break;
	}

}

void
ncStats::JoinTeam(int teamID, ncPlayer leavingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	string playerName = leavingPlayer.netname;
	int playerNum =  num_for_edict(leavingPlayer) - 1;
	string teamName = teams.Name(teamID);
	int playerPing =  userinfo.GetInteger(leavingPlayer, "ping");

	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		string playerInfoString = sprintf("n\\%s\\t\\%d", playerName, leavingPlayer.team);
		fputs(g_statLogHandle, sprintf("%s ClientUserinfoChanged: %i %s\n", LocalTime(), playerNum, playerInfoString));
		break;
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Team_Join\t%s\t%i\t%s\t%i\n", LocalTime(), playerName, playerNum, teamName, playerPing));
		break;
	}

}

void
ncStats::LeaveTeam(int teamID, ncPlayer leavingPlayer)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	int playerNum =  num_for_edict(leavingPlayer) - 1;
	string teamName = teams.Name(teamID);
	int playerPing =  userinfo.GetInteger(leavingPlayer, "ping");

	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		string playerInfoString = sprintf("n\\%s\\t\\%d", leavingPlayer.netname, leavingPlayer.team);
		fputs(g_statLogHandle, sprintf("%s ClientUserinfoChanged: %i %s\n", LocalTime(), playerNum, playerInfoString));
		break;
	case NGLOG_UT99:
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tPlayer_Team_Leave\t%i\t%s\t%i\n", LocalTime(), playerNum, teamName, playerPing));
		break;
	}

}

void
ncStats::StartGame(void)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\tgame_start\n", LocalTime()));
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tGame_Start\n", LocalTime()));
		break;
	}

}

void
ncStats::EndGame(string reasonString)
{
	if (g_statLoggingEnabled == false) {
		return;
	}

	switch (autocvar_stats_logtype) {
	case NGLOG_IW:
	case NGLOG_Q3A:
		fputs(g_statLogHandle, sprintf("%s Exit: %s\n", LocalTime(), "serverquit"));

		/* prints scores out on end-game */
		for (entity playerChain = world; (playerChain = next.Player(playerChain));) {
			if (!STRING_SET(playerChain.netname)) {
				continue;
			}

			int playerScore = (int)playerChain.frags;
			int playerPing = userinfo.GetInteger(playerChain, "ping");
			int playerNum = (int)num_for_edict(playerChain) - 1;
			string playerName = playerChain.netname;

			fputs(g_statLogHandle, sprintf("%s score: %i  ping: %i  client: %i %s\n", LocalTime(), playerScore, playerPing, playerNum, playerName));
		}
		break;
	case NGLOG_UT99:
		fputs(g_statLogHandle, sprintf("%s\tgame_end\t%s\n", LocalTime(), "serverquit"));
		break;
	case NGLOG_Q2OSP:
		fputs(g_statLogHandle, sprintf("%s\tGame_End\t%s\n", LocalTime(), reasonString));
		break;
	}

	Shutdown();
}
