var bool g_mapEntitiesLoaded = false;
var bool g_menuBackgroundMapMode = false;
var int g_mapSpawnEntityCount;
.bool gotData;

void
ncServerGame::Init(void)
{
	InitStart();
	ncLog("Built: %s %s", __DATE__, __TIME__);
	ncLog("QCC: %s", __QCCVER__);

	_server_main();
	_shared_main();

	Skill_Init();
	Constants_Init();
	MapTweaks_Init();
	MapC_Init();
	RuleC_Init();

	ncStats::Init();

	/* DO NOT EVER CHANGE THESE. */
	cvars.SetString("r_meshpitch", "1");

	/* ENGINE, PLS FIX */
	input_cursor_entitynumber = 0;
	g_mapEntitiesLoaded = false;
	InitEnd();
}

void
ncServerGame::Shutdown(void)
{
	InitStart();
	if (g_grMode) {
		g_grMode.Shutdown();
	}

	ncStats::Shutdown();
	BotLib_Shutdown();
	InitEnd();
}

void
ncServerGame::InitEnts(void)
{
	ncRuleDelegate currentRule;
	ncMapDelegate currentMap;

	InitStart();

	forceinfokey(world, "teams", "");
	forceinfokey(world, "teamplay", "");
	forceinfokey(world, "coop", "");

	/* clean up... */
	for (int teamID = 1; teamID < 1000; teamID++) {
		forceinfokey(world, sprintf("team_%i", teamID), "");
		forceinfokey(world, sprintf("teamscore_%i", teamID), "");
		forceinfokey(world, sprintf("teamcolor_%i", teamID), "");
		forceinfokey(world, sprintf("teamclosed_%i", teamID), "");
		forceinfokey(world, sprintf("teamspawn_%i", teamID), "");
		forceinfokey(world, sprintf("teamclass_%i", teamID), "");
		forceinfokey(world, sprintf("teamflags_%i", teamID), "");
	}

	forceinfokey(world, sprintf("teamspawn_%d", TEAM_CONNECTING), "");
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_UNASSIGNED), "info_player_start");
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_SPECTATOR), "info_spectator_start");

	g_ents_initialized = false;
	EntityDef_Init();
	Ammo_Init();
	SoundDef_Init();
	PropData_Init();
	SurfData_Init();
	DecalGroups_Init();
	Materials_Init();
	MOTD_Init();
	PMove_Init();
	g_ents_initialized = true;

	BodyQue_Init();

	precache.Entity("player");

	currentRule.LinkProgs();
	currentMap.LinkProgs();

	Game_Worldspawn();
	Decals_Init();
	Sentences_Init();
	Activities_Init();

	/* menu background lock */
	if (cvars.GetBool("sv_background") == true) {
		/* trade them in. */
		serverinfo.SetBool("background", true);
		localcmd("sv_background 0\n");
		g_menuBackgroundMapMode = true;
	} else {
		serverinfo.SetBool("background", false);
		g_menuBackgroundMapMode = false;
	}

	/* the maxclients serverinfo key? yeah, that one lies to the client. so
	 * let's add our own that we can actually trust. */
	serverinfo.SetInteger("sv_playerslots", cvars.GetInteger("sv_playerslots"));

	currentRule = currentRule.ActiveInstance();
	currentMap = currentMap.ActiveInstance();

	g_ents_initialized = false;
	currentRule.Precache();
	currentMap.Precache();
	g_ents_initialized = true;

	Mapcycle_Init();
	Vote_Init();
	ChangeTarget_Activate();

	BotLib_Init();

	/* engine hacks for dedicated servers */
	cvars.SetFloat("s_nominaldistance", 1536.0f);

	/* other engine hacks */
	cvars.SetBool("sv_nqplayerphysics", false);

	/* if a player doesn't join, it'll happen eventually */
	entity respawn_ents = spawn();
	respawn_ents.think = InitPostEnts;
	respawn_ents.nextthink = time + 0.25f;
	InitEnd();
}

void
ncServerGame::InitPostEnts(void)
{
	int spawnCounter = 0i;

	InitStart();

	if (g_mapEntitiesLoaded == true) {
		InitEnd();
		return;
	}

	ncMapDelegate::InitialRespawn();

	if (g_grMode) {
		g_grMode.InitPostEnts();
	}

	/* of all the map entities that we wanted to spawn, how many are left? */
	for (entity a = world; (a = findfloat(a, ::_mapspawned, true));) {
		ncEntity ent = (ncEntity)a;
		ent.OnMapFinishedLoading();
		spawnCounter++;
	}

	g_mapEntitiesLoaded = true;
	ncLog("...%i entities spawned (%i inhibited)", g_mapSpawnEntityCount, g_mapSpawnEntityCount - spawnCounter);
	Nodes_Init();
	ncStats::StartGame();
	InitEnd();
}
	
void
ncServerGame::StartFrame(void)
{
	/* For entity parenting to work, we need to go through and run on every
	 * this method on every ncEntity class */
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		ncEntity ent = (ncEntity)a;
		ent.ParentUpdate();
	}

	if (g_ruleCProgs) {
		externset(g_ruleCProgs, frametime, "frametime");
		externset(g_ruleCProgs, time, "time");
	}

	if (g_mapCProgs) {
		externset(g_mapCProgs, frametime, "frametime");
		externset(g_mapCProgs, time, "time");
	}

	if (g_grMode)
		if (g_grMode.FrameStart && time > 1)
			g_grMode.FrameStart();

	Vote_Frame();
}

void
ncServerGame::ClientConnect(ncClient connectingClient)
{
	/* this will hide/remove the player from other clients */
	ncPlayer pl = (ncPlayer)self;

	if (g_menuBackgroundMapMode == false) {
		if (ncAuthManager::Connect(pl) == false) {
			return;
		}
	}

	/* not necessary to do this again */
	if (pl.spawnclass != "ncPlayer") {
		spawnfunc_ncPlayer();
	}

	pl.SetSolid(SOLID_NOT);
	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetModelindex(0);
	pl.SetTeam(0);
	pl.Disappear();
	pl.classname = "";
	pl.flags = 0;
	pl.deaths = 0;
	pl.frags = 0;
	pl.score = 0;
	pl.gotData = false;
	pl.team = TEAM_CONNECTING;
	pl.flags |= FL_CLIENT;

	userinfo.SetString(pl, "*team", "0");

	ncStats::Connect(pl);

	g_grMode.PlayerConnect((ncPlayer)self);

	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerConnect((ncPlayer)self);
	}

	if (physics_supported() == TRUE) {
		serverinfo.SetBool("physics", true);
	} else {
		serverinfo.SetBool("physics", false);
	}
}

void
ncServerGame::ClientDisconnect(ncClient disconnectingClient)
{
	if (g_grMode) {
		g_grMode.PlayerDisconnect((ncPlayer)self);
	}

	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerDisconnect((ncPlayer)self);
	}

	/* this will hide/remove the player from other clients */
	ncPlayer pl = (ncPlayer)self;
	ncStats::Disconnect(pl);
	pl.SetSolid(SOLID_NOT);
	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetModelindex(0);
	pl.SetHealth(0);
	pl.MakeInvulnerable();
	pl.SetTeam(0);
	pl.Disappear();
	pl.classname = "";
	pl.flags = 0;
	pl.deaths = 0;
	pl.frags = 0;
	pl.score = 0;

	ncAuthManager::Disconnect(pl);
}

void
ncServerGame::ClientKill(ncClient targetClient)
{
	if (g_menuBackgroundMapMode == true) {
		return;
	}

	if (g_grMode) {
		g_grMode.PlayerKill(targetClient);
	}
}

void
ncServerGame::SpectatorConnect(ncSpectator thinkingSpectator)
{
	ents.ChangeToClass(thinkingSpectator, "spectator");
}

void
ncServerGame::SpectatorDisconnect(ncSpectator thinkingSpectator)
{

}

void
ncServerGame::SpectatorThink(ncSpectator thinkingSpectator)
{
	if (thinkingSpectator.classname == "spectator") {
		thinkingSpectator.PreFrame();
		thinkingSpectator.PostFrame();
		return;
	}
}

void
ncServerGame::PutClientInServer(ncPlayer ourPlayer)
{
	/* we're officially in-game now. */
	ourPlayer.team = TEAM_UNASSIGNED;

	/* this is the first player... */
	if (g_mapEntitiesLoaded == false) {
		InitPostEnts();
	}

	if (g_menuBackgroundMapMode == true) {
		/* the game and its triggers start when the player is ready to see it */
		ourPlayer.health = 100;
		ourPlayer.classname = "player";
		return;
	}

	if (ncAuthManager::AllowRespawn(ourPlayer) == false) {
		return;
	}

	ncStats::Enter(ourPlayer);

	if (g_grMode) {
		g_grMode.PlayerSpawn(ourPlayer);
	}

	/* handle transitions */
	ncSessionManager::HandleLevelTransition();

	/* handle plugins */
	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerSpawn(ourPlayer);
	}

	if (g_grMode.IsMultiplayer() == true && ourPlayer.deaths <= 0) {
		bprint(PRINT_HIGH, sprintf("%s^d entered the game.\n", ourPlayer.netname));
	}

	/* activate all game_playerspawn entities */
	for (entity a = world; (a = find(a, ::targetname, "game_playerspawn"));) {
		ncEntity t = (ncEntity)a;

		if (t.Trigger) {
			t.Trigger(ourPlayer, TRIG_TOGGLE);
		}
	}

	if (g_grMode.InIntermission() == true) {
		g_grMode.IntermissionToPlayer(ourPlayer);
	}
}

void
ncServerGame::PlayerPreThink(ncPlayer ourPlayer)
{
	bool isBot = is.Bot(ourPlayer);

	if (!STRING_SET(ourPlayer.classname) && isBot) {
		Bot_InsertIntoGame(ourPlayer);
		return;
	}

	if (ourPlayer.classname == "spectator") {
		return;
	}

	if (is.Bot(ourPlayer)) {
		((ncBot)ourPlayer).BotPreFrame();
	}

	if (g_grMode) {
		if (g_ruleCProgs) {
			externset(g_ruleCProgs, frametime, "frametime");
			externset(g_ruleCProgs, time, "time");
		}

		if (g_mapCProgs) {
			externset(g_mapCProgs, frametime, "frametime");
			externset(g_mapCProgs, time, "time");
		}

		if (ourPlayer.ruleSendInventory == true) {
			g_grMode.PlayerInventoryChanged(ourPlayer);
			ourPlayer.ruleSendInventory = false;
		}

		g_grMode.PlayerPreFrame((ncPlayer) ourPlayer);
	}
}

void
ncServerGame::PlayerPostThink(ncPlayer ourPlayer)
{
	bool isBot = is.Bot(ourPlayer);

	if (g_mapEntitiesLoaded) {
		return;
	}

	if (!STRING_SET(ourPlayer.classname) && isBot) {
		Bot_InsertIntoGame(ourPlayer);
		return;
	}

	if (ourPlayer.classname == "spectator") {
		SpectatorThink(ourPlayer);
		return;
	}

	if (!is.Player(ourPlayer)) {
		return;
	}

	if (is.Bot(ourPlayer)) {
		((ncBot)ourPlayer).BotPostFrame();
	}

	if (g_grMode) {
		g_grMode.PlayerPostFrame(ourPlayer);
		ourPlayer.EvaluateEntity();
		userinfo.SetString(ourPlayer, "*score", ftos(ourPlayer.score));
	}
}
