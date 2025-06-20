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

static int g_ent_spawned;
var bool g_gamemode_done = false;
.bool gotData;

/** Called once every single tic on the server. */
void
StartFrame(void)
{
	/* For entity parenting to work, we need to go through and run on every
	 * this method on every ncEntity class */
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		ncEntity ent = (ncEntity)a;
		ent.ParentUpdate();
	}

	if (g_ruleCProgs) {
		externset(g_ruleCProgs, frametime, "frametime");
	}

	if (g_mapCProgs) {
		externset(g_mapCProgs, frametime, "frametime");
	}

	if (g_ents_initialized && g_grMode)
		if (g_grMode.FrameStart && time > 1)
			g_grMode.FrameStart();

	Vote_Frame();
}

/** Called when the client-slot is being prepared for a player.
The client may not fully spawn into the world (yet), as they're still
loading or receiving packets.

The `self` global is the connecting client in question.
*/
void
ClientConnect(void)
{
	/* this will hide/remove the player from other clients */
	ncPlayer pl = (ncPlayer)self;
	spawnfunc_ncPlayer();
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
	self.gotData = false;

	/* don't carry over team settings from a previous session */
	self.team = TEAM_CONNECTING;
	self.flags |= FL_CLIENT;
	userinfo.SetString(self, "*team", "0");

	if (g_ents_initialized) {
		g_grMode.PlayerConnect((ncPlayer)self);

		for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
			addonEnum.PlayerConnect((ncPlayer)self);
		}
	}
}

/** Called when a player leaves the server. At the end of the function the
client slot referred to by the `self` global will be cleared.
This means the fields will still be accessible inside of this function.
*/
void
ClientDisconnect(void)
{
	if (g_ents_initialized) {
		g_grMode.PlayerDisconnect((ncPlayer)self);
	}

	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.PlayerDisconnect((ncPlayer)self);
	}

	/* this will hide/remove the player from other clients */
	ncPlayer pl = (ncPlayer)self;
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
}

/** Called by the `kill` console command.
The `self` global is the client issuing the command.
*/
void
ClientKill(void)
{
	if (g_ents_initialized) {
		g_grMode.PlayerKill((ncPlayer)self);
	}
}

/** This is run every frame on every spectator.
The `self` global refers to one of any given amount of spectator.
*/
void
SpectatorThink(void)
{
	if (self.classname == "spectator") {
		ncSpectator spec = (ncSpectator)self;
		spec.PreFrame();
		spec.PostFrame();
		return;
	}
}

/** Called when a ncSpectator joins the server.
The `self` global is the connecting ncSpectator in question.
*/
void
SpectatorConnect(void)
{
	ents.ChangeToClass(self, "spectator");
}

/** Called when a ncSpectator leaves the server.
The `self` global is the leaving ncSpectator in question.
Attributes cleared when this function is done executing.
*/
void
SpectatorDisconnect(void)
{
}

/** Called when a player enters the game, having fully connected and loaded into
the session.
The `self` global is the player in question.
The 'parmX' globals are also populated with any data carried over from
past levels for the player in question.
*/
void
PutClientInServer(void)
{
	ncPlayer ourPlayer = (ncPlayer)self;

	/* we're officially in-game now. */
	ourPlayer.team = TEAM_UNASSIGNED;

	if (g_ents_initialized) {
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

	/* the game and its triggers start when the player is ready to see it */
	trigger_auto_trigger();

	if (g_grMode.InIntermission() == true) {
		g_grMode.IntermissionToPlayer(ourPlayer);
	}
}

/** Run before game physics have taken place.
The `self` global refers to a single client, as this function is called
times the amount of players in a given game.
*/
void
PlayerPreThink(void)
{
	ncPlayer ourPlayer = (ncPlayer)self;
	bool isBot = is.Bot(ourPlayer);

	if (g_gamemode_done) {
		return;
	}

	if (!STRING_SET(ourPlayer.classname) && isBot) {
		Bot_InsertIntoGame(ourPlayer);
		return;
	}

	if (is.Player(ourPlayer)) {
		return;
	}

	if (ourPlayer.classname == "spectator") {
		//ncSpectator spec = (ncSpectator)self;
		//spec.PreFrame();
		return;
	}

	if (is.Bot(ourPlayer)) {
		((ncBot)ourPlayer).BotPreFrame();
	}


	if (g_ents_initialized) {
		g_grMode.PlayerPreFrame((ncPlayer) ourPlayer);
	}
}

/** Run after game physics have taken place.
The `self` global refers to a single client, as this function is called
times the amount of players in a given game.
*/
void
PlayerPostThink(void)
{
	ncPlayer ourPlayer = (ncPlayer)self;
	bool isBot = is.Bot(ourPlayer);

	if (g_gamemode_done) {
		return;
	}

	if (!STRING_SET(ourPlayer.classname) && isBot) {
		Bot_InsertIntoGame(ourPlayer);
		return;
	}

	if (ourPlayer.classname == "spectator") {
		SpectatorThink();
		return;
	}

	if (!is.Player(ourPlayer)) {
		return;
	}

	if (is.Bot(ourPlayer)) {
		((ncBot)ourPlayer).BotPostFrame();
	}

	if (g_ents_initialized) {
		g_grMode.PlayerPostFrame(ourPlayer);
		ourPlayer.EvaluateEntity();
		userinfo.SetString(ourPlayer, "*score", ftos(ourPlayer.score));
	}
}

/** Called when we spawn in a new map (both single and multiplayer) with no level
change ever having taken place.
The `self` global does not refer to anything.
*/
void
SetNewParms(void)
{
	InitPrint("Setting New Level Parameters");

	if (g_ents_initialized)
		g_grMode.LevelNewParms();
}

/** Called whenever a single-player level change is about to happen, carrying
over data from one level to the next. This is not called with the 'map' command.

The `self` global refers to a client that's partaking in the level-change.
Make sure we're saving important fields/attributes in the 'parmX' globals
allocated for every client.
*/
void
SetChangeParms(void)
{
	ncPlayer ourPlayer = (ncPlayer)self;

	InitPrint("Setting Level-Change Parameters");

	if (g_ents_initialized)
		g_grMode.LevelChangeParms(ourPlayer);
}

/** Run whenever an input packet by a client has been received.

The `self` global is the entity having sent the input packet,
with the input_X globals being set to the appropriate data.
*/
void
SV_RunClientCommand(void)
{
	ncClient cl = (ncClient)self;

	if (g_ents_initialized == false) {
		return;
	}

	if (!is.Player(cl)) {
		return;
	}

	CheatersLament((ncPlayer)cl, input_angles, input_buttons, input_timelength);
	cl.v_angle = input_angles;

	/* FIXME: before a splitscreen player disconnects, it often sends
	   one last SV_RunClientCommand which causes an error if we don't
	   check these two methods here */
	if (cl.SharedInputFrame)
		cl.SharedInputFrame();
	if (cl.ServerInputFrame)
		cl.ServerInputFrame();

	if (cl.gotData == false) {
		BreakModel_SendClientData(cl);
		cl.gotData = true;
	}

	cl.impulse = 0;
}

/** Any 'cmd' from the client get sent here and handled.
Unlike ConsoleCommmand() if you want to let the server engine
take over, you need to pass the string 'cmd' over via clientcommand().

Notable examples of client cmd's involve the chat system.
*/
void
SV_ParseClientCommand(string cmd)
{
	int argc;
	ncClient theClient = (ncClient)self;

	for (ncAddonDelegate addonEnum = __NULL__; (addonEnum = AddonManager_NextAddon(addonEnum));) {
		addonEnum.ClientCommand(theClient, cmd);
	}

	/* give the game-mode a chance to override us */
	if (g_ents_initialized == true) {
		if (g_grMode.ClientCommand(theClient, cmd) == true) {
			return;
		}
	}

	argc = (int)tokenize(cmd);

	Cmd_ParseClientCommand(theClient, cmd, argc);
}

/** Called when the QC module gets loaded.
No entities exist yet and we are unable to allocate any in here.
So avoid calling spawn() related functions here. */
void
init(float prevprogs)
{
	InitPrint("Initializing Server Game");
	ncLog("Built: %s %s", __DATE__, __TIME__);
	ncLog("QCC: %s", __QCCVER__);

	_server_main();
	_shared_main();

	Skill_Init();
	Constants_Init();
	EntityDef_Init();
	Ammo_Init();
	MapTweaks_Init();
	MapC_Init();
	RuleC_Init();

	SoundDef_Init();
	PropData_Init();
	SurfData_Init();
	DecalGroups_Init();

	/* DO NOT EVER CHANGE THESE. */
	cvars.SetString("r_meshpitch", "1");

	/* ENGINE, PLS FIX */
	input_cursor_entitynumber = 0;
	g_gamemode_done = false;
}

/** Called inside initents() to make sure the entities have their Respawn()
method called at the beginning of them having spawned.
*/
void
init_respawn(void)
{
	int spawnCounter = 0i;

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
	}

	forceinfokey(world, sprintf("teamspawn_%d", TEAM_CONNECTING), "");
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_UNASSIGNED), "info_player_start");
	forceinfokey(world, sprintf("teamspawn_%d", TEAM_SPECTATOR), "info_spectator_start");

	if (g_ents_initialized) {
		g_grMode.InitPostEnts();
	}

	/* of all the map entities that we wanted to spawn, how many are left? */
	for (entity a = world; (a = findfloat(a, ::_mapspawned, true));) {
		ncEntity ent = (ncEntity)a;
		ent.Respawn();
		spawnCounter++;
	}

	g_gamemode_done = true;
	ncLog("...%i entities spawned (%i inhibited)", g_ent_spawned, g_ent_spawned - spawnCounter);
	Nodes_Init();
	remove(self);
}

entity g_respawntimer;

/** Called by the engine when we're ready to spawn entities.
Before this, we are not able to spawn, touch or allocate any entity slots.
*/
void
initents(void)
{
	ncRuleDelegate currentRule;
	ncMapDelegate currentMap;

	g_ents_initialized = false;
	g_gamemode_done = false;

	/* sound shader init */
	Materials_Init();
	MOTD_Init();
	PMove_Init();

#warning Move these into player decl
	precache.Sound("Player.Death");
	precache.Sound("Player.Pain");
	precache.Sound("SprayCan.Paint");

#warning These sound defs need renaming.
	precache.Sound("damage_bullet.hit");
	precache.Sound("step_ladder.left");
	precache.Sound("step_ladder.right");

	BodyQue_Init();

	ncRuleDelegate::LinkProgs();
	ncMapDelegate::LinkProgs();

	Game_Worldspawn();
	Decals_Init();
	Sentences_Init();
	Activities_Init();

	/* append entities from external .add file */
	string appendEntitiesFile = strcat("maps/", mapname, ".add");
	if (fileExists(appendEntitiesFile)) {
		loadfromfile(appendEntitiesFile);
	}

	/* TODO: Make sure every entity calls Respawn inside the constructor, then
	 * remove this */
	g_respawntimer = spawn();
	g_respawntimer.think = init_respawn;
	g_respawntimer.nextthink = time + 0.25f;

	/* menu background lock */
	if (cvars.GetBool("sv_background") == true) {
		/* trade them in. */
		serverinfo.SetBool("background", true);
		localcmd("sv_background 0\n");
	} else {
		serverinfo.SetBool("background", false);
	}

	/* the maxclients serverinfo key? yeah, that one lies to the client. so
	 * let's add our own that we can actually trust. */
	serverinfo.SetInteger("sv_playerslots", cvars.GetInteger("sv_playerslots"));

	currentRule = ncRuleDelegate::ActiveInstance();
	currentMap = ncMapDelegate::ActiveInstance();
	currentRule.Precache();
	currentMap.Precache();

	Mapcycle_Init();
	Vote_Init();
	ChangeTarget_Activate();

	g_ents_initialized = true;

	BotLib_Init();

	/* engine hacks for dedicated servers */
	cvars.SetFloat("s_nominaldistance", 1536.0f);

	/* other engine hacks */
	cvars.SetBool("sv_nqplayerphysics", false);
}

/** Any command executed on the server (either tty, rcon or `sv`) gets
sent here first.

When returning FALSE the server will interpret the command.
Returning TRUE will mark the command as 'resolved' and the engine
will not attempt handling it.

The client-side equivalent is `CSQC_ConsoleCommand` (src/client/entry.qc)
*/
float
ConsoleCmd(string cmd)
{
	ncPlayer pl;

	/* some sv commands can only be executed by a player in-world */
	if (!self) {
		other = world;

		while ((other = nextent(other))) {
			if (clienttype(other) == CLIENTTYPE_REAL) {
				self = other;
				break;
			}
		}
	}

	pl = (ncPlayer)self;

	/* give the game-mode a chance to override us */
	if (g_ents_initialized) {
		if (g_grMode.ConsoleCommand(pl, cmd) == TRUE) {
			return (1);
		}
	}

	/* time to handle commands that apply to all games */
	tokenize(cmd);
	return Cmd_ParseServerCommand();
}

/** Returns TRUE if the server can pause the server when the 'pause' command
is being executed.
*/
float
SV_ShouldPause(float newstatus)
{
	if (serverinfo.GetFloat("background") == 1) {
		return (0);
	}

	if (cvars.GetFloat("pausable") == 1) {
		return (1);
	}

	if (cvars.GetFloat("sv_playerslots") > 1) {
		return (0);
	}

	return (newstatus);
}

/** Called by the engine when we're loading a savegame file.

This deals with the de and re-allocation of all map entities from
the passed file handle.
*/
void
SV_PerformLoad(float fh, float entcount, float playerslots)
{
	ncSessionManager::RestoreStateFromHandle(fh, entcount, playerslots);
}

/** Called when we are saving our game. We only get passed a file handle
to work with and dump entity data as well as some global info directly
into it.
*/
void
SV_PerformSave(float fh, float entcount, float playerslots)
{
	ncSessionManager::SaveStateToHandle(fh, entcount, playerslots);
}

/** Called by the engine to check with us if a spawn function exists.

The `self` global refers to an already allocated entity, which we have
to remove in case we won't initialize it.
*/
void
CheckSpawn(void() spawnfunc)
{
	ncEntity ent = (ncEntity)self;
	string desiredClass = ent.classname;
	static string lastClass;
	bool skipLoad = false; /* entity data will be loaded elsewhere */

	g_ents_initialized = false;

	/* cancel out early */
	if (ent == world) {
		worldspawn();
		g_ents_initialized = true;
		return;
	}

	/* give it a copy of its spawndata. */
	ent.m_rawSpawnData = __fullspawndata;
	ent.spawnclass = desiredClass; /* EntityDef_ will override this later, needed for saves */

	/* no longer needed, immediately discard. */
	__fullspawndata = "";

	/* we have to diverge here in order to support in-code class entities,
	   decl entities and overrides of both.

	   this switch also controls the priority:

	   1. maptweaks, can override anything.
	   2. entitydef, can even override built-in class names
	      2.0 entitydef, defined in a map (maps/foobar.def)
		  2.1 entitydef, defined within decls/def/X.def
	   3. in-code classes */
	if (MapTweak_EntitySpawn(ent) == true) {
		skipLoad = true;
	} else if (EntityDef_SwitchClass(ent, desiredClass) != __NULL__) {
		skipLoad = true;
	} else if (spawnfunc) {
		spawnfunc();
		ent.classname = desiredClass;
	} else {
		ent.identity = 0;
	}

	/* check if this entity was meant to spawn on the client-side only */
	if (ent.identity) {
		if (ent.CanSpawn(false) == false) {
			ent.Destroy();
			g_ent_spawned--;
		}
	} else {
		/* don't need to spam repetitive messages */
		if (lastClass != desiredClass) {
			ncError("Unimplemented entity class %S.", desiredClass);
		}

		lastClass = desiredClass;
		remove(ent);
		g_ents_initialized = true;
		return;
	}

	ent._mapspawned = true;
	ent._loading = true;

	if (skipLoad == false) {
		/* this entity is good, attempt to spawn it. */
		if (STRING_SET(ent.m_rawSpawnData)) {
			for (int i = 1; i < (tokenize(ent.m_rawSpawnData) - 1); i += 2) {
				ent.SpawnKey(argv(i), argv(i+1));
			}
		}
		
		
 
		if (STRING_SET(ent.m_gameModeFilter)) {
			if (ent.m_gameModeFilter != g_ruleCName) {
				if (ent.identity) {
					ent.Destroy();
				} else {
					remove(ent);
				}
				ent = __NULL__;
				g_ents_initialized = true;
				return;
			}
		}

		ent._loading = false;
		ent.Spawn();
	}

	/* count and mark as map spawned */
	g_ent_spawned++;
	g_ents_initialized = true;
}
