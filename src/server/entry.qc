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
.bool gotData;

/** Called once every single tic on the server. */
void
StartFrame(void)
{
	PMove_StartFrame();

	/* For entity parenting to work, we need to go through and run on every
	 * this method on every NSEntity class */
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		NSEntity ent = (NSEntity)a;
		ent.ParentUpdate();
	}

	if (g_ents_initialized)
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
	int playercount = 0;
	self.gotData = false;

	/* don't carry over team settings from a previous session */
	forceinfokey(self, "*team", "0");

	/* bot needs special init */
#ifdef BOT_INCLUDED
	if (clienttype(self) == CLIENTTYPE_BOT) {
		/* from now on we're of type NSBot */
		EntityDef_SpawnClassname("bot");
	} else
#endif

	/* make sure you never change the classname. ever. */
	if (self.classname != "player") {
		spawnfunc_player();
	}

	if (g_ents_initialized)
		g_grMode.PlayerConnect((NSClientPlayer)self);

	for (entity a = world; (a = find(a, ::classname, "player"));)
		playercount++;
}

/** Called when a player leaves the server. At the end of the function the
client slot referred to by the `self` global will be cleared.
This means the fields will still be accessible inside of this function.
*/
void
ClientDisconnect(void)
{
	if (g_ents_initialized)
		g_grMode.PlayerDisconnect((NSClientPlayer)self);

	/* this will hide/remove the player from other clients */
	player pl = (player)self;
	pl.SetSolid(SOLID_NOT);
	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetModelindex(0);
	pl.SetHealth(0);
	pl.SetTakedamage(DAMAGE_NO);
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
	if (g_ents_initialized)
		g_grMode.PlayerKill((NSClientPlayer)self);
}

/** This is run every frame on every spectator.
The `self` global refers to one of any given amount of spectator.
*/
void
SpectatorThink(void)
{
	if (self.classname == "spectator") {
		NSClientSpectator spec = (NSClientSpectator)self;
		spec.PreFrame();
		spec.PostFrame();
		return;
	}
}

/** Called when a NSClientSpectator joins the server.
The `self` global is the connecting NSClientSpectator in question.
*/
void
SpectatorConnect(void)
{
	spawnfunc_NSClientSpectator();
}

/** Called when a NSClientSpectator leaves the server.
The `self` global is the leaving NSClientSpectator in question.
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
	if (g_ents_initialized)
		g_grMode.PlayerSpawn((NSClientPlayer)self);

	/* handle transitions */
	if (FileExists("data/trans.dat")) {
		
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			NSEntity levelEnt = (NSEntity)a;
			levelEnt.TransitionComplete();
		}

		trigger_transition::LoadTransition();
	}

	Plugin_PlayerEntered((NSClientPlayer)self);

	if (g_grMode.IsMultiplayer() == true && self.deaths <= 0) {
		bprint(PRINT_HIGH, sprintf("%s^d entered the game.\n", self.netname));
	}

	/* activate all game_playerspawn entities */
	for (entity a = world; (a = find(a, ::targetname, "game_playerspawn"));) {
		NSEntity t = (NSEntity)a;

		if (t.Trigger)
			t.Trigger(self, TRIG_TOGGLE);
	}

	/* the game and its triggers start when the player is ready to see it */
	trigger_auto_trigger();

	if (g_grMode.InIntermission() == true) {
		g_grMode.IntermissionToPlayer((NSClientPlayer)self);
	}
}

/** Run before game physics have taken place.
The `self` global refers to a single client, as this function is called
times the amount of players in a given game.
*/
void
PlayerPreThink(void)
{
	if (self.classname == "spectator") {
		//NSClientSpectator spec = (NSClientSpectator)self;
		//spec.PreFrame();
		return;
	}

	if (self.classname != "player") {
		return;
	}

#ifdef BOT_INCLUDED
	if (clienttype(self) == CLIENTTYPE_BOT) {
		((NSBot)self).PreFrame();
	}
#endif

	if (g_ents_initialized)
		g_grMode.PlayerPreFrame((NSClientPlayer)self);
}

/** Run after game physics have taken place.
The `self` global refers to a single client, as this function is called
times the amount of players in a given game.
*/
void
PlayerPostThink(void)
{
	if (self.classname == "spectator") {
		SpectatorThink();
		return;
	}

	if (self.classname != "player") {
		return;
	}

#ifdef BOT_INCLUDED
	if (clienttype(self) == CLIENTTYPE_BOT) {
		((NSBot)self).PostFrame();
	}
#endif

	if (g_ents_initialized) {
		player pl = (player)self;
		g_grMode.PlayerPostFrame((NSClientPlayer)self);
		pl.EvaluateEntity();
		forceinfokey(pl, "*score", ftos(pl.score));
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
	InitPrint("Setting Level-Change Parameters");

	if (g_ents_initialized)
		g_grMode.LevelChangeParms((NSClientPlayer)self);
}

/** Run whenever an input packet by a client has been received.

The `self` global is the entity having sent the input packet,
with the input_X globals being set to the appropriate data.
*/
void
SV_RunClientCommand(void)
{
	NSClient cl = (NSClient)self;

	if (self.classname != "player" && self.classname != "spectator")
		return;

	CheatersLament((NSClientPlayer)cl, input_angles, input_buttons, input_timelength);
	self.v_angle = input_angles;

	if (!Plugin_RunClientCommand()) {
		/* TODO */
	}

	/* FIXME: before a splitscreen player disconnects, it often sends
	   one last SV_RunClientCommand which causes an error if we don't
	   check these two methods here */
	if (cl.SharedInputFrame)
		cl.SharedInputFrame();
	if (cl.ServerInputFrame)
		cl.ServerInputFrame();

	if (self.gotData == false) {
		BreakModel_SendClientData(self);
		self.gotData = true;
	}
}

/** Any 'cmd' from the client get sent here and handled.
Unlike ConsoleCommmand() if you want to let the server engine
take over, you need to pass the string 'cmd' over via clientcommand().

Notable examples of client cmd's involve the chat system.
*/
void
SV_ParseClientCommand(string cmd)
{
	string newcmd = Plugin_ParseClientCommand(cmd);
	int argc;

	/* give the game-mode a chance to override us */
	if (g_ents_initialized)
		if (g_grMode.ClientCommand((NSClient)self, cmd) == true)
			return;

	argc = tokenize(cmd);

	switch (argv(0)) {
	case "say":
		if (argc == 2)
			g_grMode.ChatMessageAll((NSClient)self, argv(1));
		else
			g_grMode.ChatMessageAll((NSClient)self, substring(cmd, 5, -2));
		break;
	case "say_team":
		if (argc == 2)
			g_grMode.ChatMessageTeam((NSClient)self, argv(1));
		else
			g_grMode.ChatMessageTeam((NSClient)self, substring(cmd, 10, -2));
		break;
	case "spectate":
		if (self.classname != "player")
			break;

		player pl = (player)self;
		pl.MakeSpectator();
		break;
	case "play":
		if (self.classname != "spectator")
			break;
		spawnfunc_player();
		PutClientInServer();
		break;
	case "setpos":
		if (cvar("sv_cheats") == 1) {
			setorigin(self, stov(argv(1)));
		}
		break;
	case "timeleft":
		string msg;
		string timestring;
		float timeleft;
		timeleft = cvar("timelimit") - (time / 60);
		timestring = Util_TimeToString(timeleft);
		msg = sprintf("we have %s minutes remaining", timestring);
		bprint(PRINT_CHAT, msg);
		break;
	default:
		clientcommand(self, cmd);
	}
}

/** Called when the QC module gets loaded.
No entities exist yet and we are unable to allocate any in here.
So avoid calling spawn() related functions here. */
void
init(float prevprogs)
{
	InitPrint("Initializing Server Game");
	NSLog("Built: %s %s", __DATE__, __TIME__);
	NSLog("QCC: %s", __QCCVER__);

	Plugin_Init();

	Constants_Init();
	Sound_Init();
	PropData_Init();
	SurfData_Init();
	DecalGroups_Init();

	/* DO NOT EVER CHANGE THESE. */
	cvar_set("r_meshpitch", "1");
}

/** Called inside initents() to make sure the entities have their Respawn()
method called at the beginning of them having spawned.
*/
void
init_respawn(void)
{
	int endspawn = 0;

	if (g_ents_initialized)
		g_grMode.InitPostEnts();

	/* of all the map entities that we wanted to spawn, how many are left? */
	for (entity a = world; (a = findfloat(a, ::_mapspawned, true));) {
		endspawn++;
	}

	NSLog("...%i entities spawned (%i inhibited)", g_ent_spawned, g_ent_spawned - endspawn);

	InitEnd();

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
	/* sound shader init */
	Materials_Init();
	MOTD_Init();
	PMove_Init();

	/** compat... */

	Sound_Precache("Player.GaspLight");
	Sound_Precache("Player.GaspHeavy");
	Sound_Precache("Player.WaterEnter");
	Sound_Precache("Player.WaterExit");
	Sound_Precache("Player.Death");
	Sound_Precache("Player.Pain");
	Sound_Precache("Player.Wade");
	Sound_Precache("Player.Swim");
	Sound_Precache("Player.DenyWeaponSelection");
	Sound_Precache("Player.WeaponSelected");
	Sound_Precache("Player.FallDamage");
	Sound_Precache("Player.LightFall");

	Sound_Precache("damage_bullet.hit");
	Sound_Precache("SprayCan.Paint");
	Sound_Precache("step_ladder.left");
	Sound_Precache("step_ladder.right");

	if (!g_grMode) {
		Game_InitRules();
		forceinfokey(world, "mode", g_grMode.Title());
	}

	Game_Worldspawn();
	Decals_Init();
	Sentences_Init();

	/* TODO: Make sure every entity calls Respawn inside the constructor, then
	 * remove this */
	g_respawntimer = spawn();
	g_respawntimer.think = init_respawn;
	g_respawntimer.nextthink = time + 0.1f;

	/* menu background lock */
	if (cvar("sv_background") == 1) {
		forceinfokey(world, "background", "1");
		localcmd("sv_background 0\n");
	} else {
		forceinfokey(world, "background", "0");
	}

	/* the maxclients serverinfo key? yeah, that one lies to the client. so
	 * let's add our own that we can actually trust. */
	forceinfokey(world, "sv_playerslots", cvar_string("sv_playerslots"));

	Plugin_InitEnts();
	Mapcycle_Init();
	Vote_Init();
	ChangeTarget_Activate();

	g_ents_initialized = TRUE;

	/* engine hacks for dedicated servers */
	cvar_set("s_nominaldistance", "1536");

	/* other engine hacks */
	cvar_set("sv_nqplayerphysics", "0");

#ifdef BOT_INCLUDED
	BotLib_Init();
#endif
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
	player pl;

	/* some sv commands can only be executed by a player in-world */
	if ( !self ) {
		for ( other = world; ( other = find( other, classname, "player" ) ); ) {
			if ( clienttype( other ) == CLIENTTYPE_REAL ) {
				self = other;
				break;
			}
		}
	}

	if (!self) {
		for ( other = world; ( other = find( other, classname, "spectator" ) ); ) {
			if ( clienttype( other ) == CLIENTTYPE_REAL ) {
				self = other;
				break;
			}
		}
	}

	pl = (player)self;

	/* give the game-mode a chance to override us */
	if (g_ents_initialized)
		if (g_grMode.ConsoleCommand(pl, cmd) == TRUE)
			return (1);

	/* time to handle commands that apply to all games */
	tokenize(cmd);
	switch (argv(0)) {
	case "addBot":
		string botProfile = strtolower(argv(1));
		float teamValue = stof(argv(2));
		float spawnDelay = stof(argv(3));
		string newName = argv(4);
		Bot_AddBot_f(botProfile, teamValue, spawnDelay, newName);
		break;
	case "killAllBots":
		Bot_KillAllBots();
		break;
	case "resetAllBotsGoals":
		Bot_ResetAllBotsGoals();
		break;
	case "listBotProfiles":
		Bot_ListBotProfiles_f();
		break;
	case "killClass":
		string targetClass;
		targetClass = argv(1);

		if (targetClass)
		for (entity a = world; (a = find(a, ::classname, targetClass));) {
			NSEntity t = (NSEntity)a;
			t.Destroy();
		}
		break;
	case "killMovables":
		for (entity a = world; (a = findfloat(a, ::movetype, MOVETYPE_PHYSICS));) {
			NSEntity t = (NSEntity)a;
			t.Destroy();
		}
		break;
	case "trigger":
		string targ;
		targ = argv(1);

		if (targ)
		for (entity a = world; (a = find(a, ::targetname, targ));) {
			NSEntity t = (NSEntity)a;

			if (t.Trigger)
				t.Trigger(self, TRIG_TOGGLE);
		}
		break;
	case "input":
		float entNum = stof(argv(1));
		string inputName = argv(2);
		string inputData = argv(3);
		NSEntity inputTarget = (NSEntity)edict_num(entNum);

		if (inputTarget) {
			inputTarget.Input(self, inputName, inputData);
			print(sprintf("Sending input to %d, %S: %S\n", entNum, inputName, inputData));
		}
		break;
	case "listTargets":
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			if (a.targetname) {
				print(sprintf("%d: %s (%s)\n", num_for_edict(a), a.targetname, a.classname));
			}
		}
		break;
	case "teleport":
		static entity targetFinder;
		targetFinder = find(targetFinder, ::targetname, argv(1));

		/* try at least one more time to skip world */
		if (!targetFinder)
			targetFinder = find(targetFinder, ::targetname, argv(1));

		if (targetFinder)
			setorigin(pl, targetFinder.origin);
		break;
	case "teleportToClass":
		static entity finder;
		finder = find(finder, ::classname, argv(1));

		/* try at least one more time to skip world */
		if (!finder)
			finder = find(finder, ::classname, argv(1));

		if (finder)
			setorigin(pl, finder.origin);
		break;
	case "renetworkEntities":
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			NSEntity ent = (NSEntity)a;
			ent.SendFlags = -1;
		}
		break;
	case "respawnEntities":
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			NSEntity ent = (NSEntity)a;
			ent.Respawn();
		}
		break;
	case "spawn":
		NSEntity unit = EntityDef_CreateClassname(argv(1));
		makevectors(pl.v_angle);
		traceline(pl.origin, pl.origin + (v_forward * 1024), MOVE_NORMAL, pl);
		setorigin(unit, trace_endpos);
		break;
#ifdef BOT_INCLUDED
	case "way":
		Way_Cmd();
		break;
#endif
	case "listSoundDef":
		Sound_DebugList();
		break;
	default:
		return (0);
	}
	return (1);
}

/** Returns TRUE if the server can pause the server when the 'pause' command
is being executed.
*/
float
SV_ShouldPause(float newstatus)
{
	if (serverkeyfloat("background") == 1)
		return (0);

	if (cvar("pausable") == 1)
		return (1);

	if (cvar("sv_playerslots") > 1)
		return (0);

	return newstatus;
}

//#define REEDICT 1

/** Called by the engine when we're loading a savegame file.

This deals with the de and re-allocation of all map entities from
the passed file handle.
*/
void
SV_PerformLoad(float fh, float entcount, float playerslots)
{
	entity e = world;
	entity eold;
	string l;
	float n = 0;
	NSEntity loadent = __NULL__;
	int num_loaded = 0i;

	InitPrint("Loading Existing Save");
	g_isloading = true;

#if 0
	/* mark anything else for deletion */
	while ((e=nextent(e))) {
		if (edict_num(1) != e) {
			if (e.identity != 0) {
				e.think = Util_Destroy;
				e.nextthink = time + 0.05f;
			}
		}
	}
#endif

#ifdef REEDICT
	while ((e=nextent(e))) {
		if (edict_num(1) != e)
			if (e.identity) {
				NSEntity toRemove = (NSEntity)e;
				toRemove.Destroy();
			} else {
				remove(e);
			}
	}
#else
	e = world;
#endif

	/* read line per line of our file handle */
	while ((l=fgets(fh))) {
		float args = tokenize_console(l);

		if (!args)
			break;

		if (argv(0) == "ENTITY") {
			string cname;
			cname = argv(2);
#ifndef REEDICT
			n = stof(argv(1));
			e = edict_num(n);
			NSLog("Creating %s (edict %d)", cname, n);
#else
			entity e = spawn();
#endif
			loadent = __NULL__;

			__fullspawndata = fgets(fh);

			eold = self;
			self = e;

			/* check for entityDef first */
			if (EntityDef_SpawnClassname(cname)) {
				e.classname = cname;
				loadent = (NSEntity)e;
				self = eold;
			} else if (isfunction(strcat("spawnfunc_", cname))) {
				/* call the constructor if one is present, init the default fields */
				e.classname = cname;
				callfunction(strcat("spawnfunc_", cname));
				e.classname = cname;
				loadent = (NSEntity)e;
				self = eold;
			} else {
				NSError("Could not spawn %s", cname);
				if (e.identity) {
					NSEntity toRemove = (NSEntity)e;
					toRemove.Destroy();
				} else {
					remove(e);
				}
				self = eold;
				continue;
			}
		} else if (argv(0) == "{") {
		} else if (argv(0) == "}") {
			if (loadent) {
				loadent.RestoreComplete();
				num_loaded++;
				NSLog("completed %s (edict %d)", loadent.classname, n);
				loadent = __NULL__;
			}
		} else {
			if (loadent) {
				int c = tokenize(l);

				if (c == 2) {
					loadent.Restore(argv(0), argv(1));
					//print(sprintf("%s %s\n", argv(0), argv(1)));
				}
			}
		}
	}

	NSLog("...loaded %i entities", num_loaded);
	g_isloading = false;
}

/** Called when we are saving our game. We only get passed a file handle
to work with and dump entity data as well as some global info directly
into it.
*/
void
SV_PerformSave(float fh, float entcount, float playerslots)
{
	float i = 0;
	int num_saved = 0i;
	entity e;

	InitPrint("Performing Save");

	for (i = 0; i < entcount; i++) {
		NSEntity willsave;
		e = edict_num(i);

		if (e==world && i)
			continue;

		if (wasfreed(e))
			continue;

		if (e.identity == 0)
			continue;

		willsave = (NSEntity)e;
		fputs(fh, sprintf("ENTITY \"%d\" %S\n", i, willsave.classname));
		fputs(fh, "{\n");
		willsave.Save(fh);
		fputs(fh, "}\n");
		num_saved++;
	}
	fclose(fh);
	NSLog("saved %i entities", num_saved);
}

/** Called by the engine to check with us if a spawn function exists.

The `self` global refers to an already allocated entity, which we have
to remove in case we won't initialize it.
*/
void
CheckSpawn(void() spawnfunc)
{
	string desiredClass = self.classname;

	if (MapTweak_EntitySpawn(self)) {
		self._mapspawned = true;
		self.classname = desiredClass;
	} else if (EntityDef_SpawnClassname(desiredClass)) {
		self._mapspawned = true;
	} else if (spawnfunc) {
		spawnfunc();
		self.classname = desiredClass;
		self._mapspawned = true;
		g_ent_spawned++;
	} else {
		NSError("Unable to spawn %s", desiredClass);
		remove(self);
	}

	/* check if this entity was meant to spawn on the client-side only */
	if (self.identity) {
		NSEntity ent = (NSEntity)self;

		if (ent.CanSpawn(false) == false) {
			ent.Destroy();
			g_ent_spawned--;
		}
	}
}