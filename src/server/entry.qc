/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

/*
=================
StartFrame

Called once every single frame.
=================
*/
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

/*
=================
ClientConnect

Called when the client-slot is being prepared for a player.
The client may not fully spawn into the world (yet), as they're still
loading or receiving packets.

The 'self' global is the connecting client in question.
=================
*/
void
ClientConnect(void)
{
	int playercount = 0;

	forceinfokey(self, "*team", "0");

#ifdef BOT_INCLUDED
	if (clienttype(self) == CLIENTTYPE_BOT) {
		spawnfunc_bot();
	} else
#endif

	/* make sure you never change the classname. ever. */
	if (self.classname != "player") {
		spawnfunc_player();
	}

	if (g_ents_initialized)
		g_grMode.PlayerConnect((base_player)self);

	for (entity a = world; (a = find(a, ::classname, "player"));)
		playercount++;

	/* we're the only one. respawn all entities */
	if (playercount == 1) {
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			NSEntity caw = (NSEntity)a;
			caw.Respawn();
		}
		Nodes_Init();
	}
}

/*
=================
ClientDisconnect

Called when a player leaves the server. At the end of the function the
client slot referred to by the 'self' global will be cleared.
This means the fields will still be accessible inside of this function.
=================
*/
void
ClientDisconnect(void)
{
	if (g_ents_initialized)
		g_grMode.PlayerDisconnect((base_player)self);
}

/*
=================
ClientKill

Called by the 'kill' command.
The 'self' global is the client issueing the command.
=================
*/
void
ClientKill(void)
{
	if (g_ents_initialized)
		g_grMode.PlayerKill((base_player)self);
}

/*
=================
SpectatorThink

Run every frame on every spectator.
The 'self' global refers to one of any given amount of spectators.
=================
*/
void
SpectatorThink(void)
{
	Game_SpectatorThink();

	if (self.classname == "spectator") {
		spectator spec = (spectator)self;
		spec.PreFrame();
		spec.PostFrame();
		return;
	}
}

/*
=================
SpectatorConnect

Called when a spectator joins the server.
The 'self' global is the connecting spectator in question.
=================
*/
void
SpectatorConnect(void)
{
	Game_SpectatorConnect();
	spawnfunc_spectator();
}

/*
=================
SpectatorDisconnect

Called when a spectator leaves the server.
The 'self' global is the leaving spectator in question.
Attributes cleared when this function is done executing.
=================
*/
void
SpectatorDisconnect(void)
{
	Game_SpectatorDisconnect();
}

/*
=================
PutClientInServer

Called when a player enters the game, having fully connected and loaded into
the session.
The 'self' global is the player in question.
The 'parmX' globals are also populated with any data carried over from
past levels for the player in question.
=================
*/
void
PutClientInServer(void)
{
	if (g_ents_initialized)
		g_grMode.PlayerSpawn((base_player)self);

	Plugin_PlayerEntered((base_player)self);

	/* activate all game_playerspawn entities */
	for (entity a = world; (a = find(a, ::targetname, "game_playerspawn"));) {
		NSEntity t = (NSEntity)a;

		if (t.Trigger)
			t.Trigger(self, TRIG_TOGGLE);
	}
}

/*
=================
PlayerPreThink

Run before physics have taken place.
The 'self' global refers to a single client, as this function is called
times the amount of players in a given game.
=================
*/
void
PlayerPreThink(void)
{
	if (self.classname == "spectator") {
		//spectator spec = (spectator)self;
		//spec.PreFrame();
		return;
	}

	if (self.classname != "player") {
		return;
	}

#ifdef BOT_INCLUDED
	if (clienttype(self) == CLIENTTYPE_BOT) {
		((bot)self).PreFrame();
	}
#endif

	if (g_ents_initialized)
		g_grMode.PlayerPreFrame((base_player)self);
}

/*
=================
PlayerPostThink

Run after physics have taken place.
The 'self' global refers to a single client, as this function is called
times the amount of players in a given game.
=================
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
		((bot)self).PostFrame();
	}
#endif

	if (g_ents_initialized) {
		player pl = (player)self;
		g_grMode.PlayerPostFrame((base_player)self);
		pl.EvaluateEntity();
	}
}

/*
=================
SetNewParms

Called when we spawn in a new map (both single and multiplayer) with no level
change ever having taken place.
The 'self' global does not refer to anything.
=================
*/
void
SetNewParms(void)
{
	print("--------- Setting New Level Parameters ----------\n");

	if (g_ents_initialized)
		g_grMode.LevelNewParms();
}

/*
=================
SetChangeParms

Called whenever a single-player level change is about to happen, carrying
over data from one level to the next. This is not called with the 'map' command.

The 'self' global refers to a client that's partaking in the level-change.
Make sure we're saving important fields/attributes in the 'parmX' globals
allocated for every client.
=================
*/
void
SetChangeParms(void)
{
	print("--------- Setting Level-Change Parameters ----------\n");

	if (g_ents_initialized)
		g_grMode.LevelChangeParms((base_player)self);
}

/*
=================
SV_RunClientCommand

Run whenever an input packet by a client has been received.

The 'self' global is the entity having sent the input packet,
with the input_X globals being set to the appropriate data.
=================
*/
void
SV_RunClientCommand(void)
{
	if (self.classname == "spectator") {
		spectator spec = (spectator)self;
		spec.RunClientCommand();
	}

	if (self.classname != "player") {
		return;
	}

#ifdef BOT_INCLUDED
	/* wait a few seconds, as we may not have been spawned yet */
	if (clienttype(self) == CLIENTTYPE_BOT) {
		((bot)self).RunAI();
	}
#endif

	if (!Plugin_RunClientCommand()) {
		Game_RunClientCommand();
	}
}

/*
=================
SV_ParseClientCommand

Any 'cmd' from the client get sent here and handled.
Unlike ConsoleCommmand() if you want to let the server engine
take over, you need to pass the string 'cmd' over via clientcommand().

Notable examples of client cmd's involve the chat system.
=================
*/
void
SV_ParseClientCommand(string cmd)
{
	string newcmd = Plugin_ParseClientCommand(cmd);

	if (newcmd == __NULL__)
		Game_ParseClientCommand(cmd);
	else 
		Game_ParseClientCommand(newcmd);

	tokenize(cmd);

	switch (argv(0)) {
	case "spectate":
		if (self.classname != "player")
			break;
		ClientKill();
		spawnfunc_spectator();
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
	}
}

/*
=================
init

Called when the QC module gets loaded. No entities exist yet.
=================
*/
void
init(float prevprogs)
{
	print("--------- Initializing Server-Module ----------\n");
	Plugin_Init();
	PropData_Init();
	SurfData_Init();
}

/*
=================
init_respawn

Called inside initents() to make sure the entities have their Respawn()
method called at the beginning of them having spawned.
=================
*/
void
init_respawn(void)
{
	print("--------- Respawning Server Entities ----------\n");

	if (g_ents_initialized)
		g_grMode.InitPostEnts();

	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		NSEntity ent = (NSEntity)a;
		ent.Respawn();
	}
	remove(self);
}

/*
=================
initents

???
=================
*/
.string skyname;
void
initents(void)
{
	print("--------- Initializing Server Entities ----------\n");

	/* sound shader init */
	Sound_Init();

	/* only bother doing so on Half-Life BSP */
	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		HLMaterials_Init();
	}

	PMove_Init();

	/* TODO: turn these effects into sound shaders */
	precache_sound("weapons/explode3.wav");
	precache_sound("weapons/explode4.wav");
	precache_sound("weapons/explode5.wav");
	precache_sound("debris/glass1.wav");
	precache_sound("debris/glass2.wav");
	precache_sound("debris/glass3.wav");
	precache_sound("debris/wood1.wav");
	precache_sound("debris/wood2.wav");
	precache_sound("debris/wood3.wav");
	precache_sound("debris/metal1.wav");
	precache_sound("debris/metal2.wav");
	precache_sound("debris/metal3.wav");
	precache_sound("debris/flesh1.wav");
	precache_sound("debris/flesh2.wav");
	precache_sound("debris/flesh3.wav");
	precache_sound("debris/flesh5.wav");
	precache_sound("debris/flesh6.wav");
	precache_sound("debris/flesh7.wav");
	precache_sound("debris/concrete1.wav");
	precache_sound("debris/concrete2.wav");
	precache_sound("debris/concrete3.wav");

	Footsteps_Init();

	precache_sound("player/pl_fallpain3.wav");
	precache_sound("items/9mmclip1.wav");
	precache_sound("items/gunpickup2.wav");
	precache_sound("common/wpn_select.wav");
	precache_sound("common/wpn_denyselect.wav");
	precache_sound("player/sprayer.wav");
	precache_sound("items/flashlight1.wav");
	precache_sound("common/null.wav");

	Sound_Precache("player.gasplight");
	Sound_Precache("player.gaspheavy");
	Sound_Precache("player.waterenter");
	Sound_Precache("player.waterexit");
	Sound_Precache("damage_bullet.hit");

	Game_InitRules();
	Game_Worldspawn();
	Decals_Init();
	Sentences_Init();

	/* TODO: Make sure every entity calls Respawn inside the constructor, then
	 * remove this */
	entity respawntimer = spawn();
	respawntimer.think = init_respawn;
	respawntimer.nextthink = time + 0.1f;

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
}

/*
=================
worldspawn

The first entity spawn function. You want to make sure to put anything in here
that'll affect subsequent initialization of map entities.

Any find() or similar function will not find any entity but 'world',
as they do not exist yet. Keep this in mind.
=================
*/
var int autocvar_sv_levelexec = 1;

void
worldspawn(void)
{
	print("--------- Initializing World ----------\n");
	lightstyle(0, "m");
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	lightstyle(4, "mamamamamama");
	lightstyle(5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	lightstyle(6, "nmonqnmomnmomomno");
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	lightstyle(9, "aaaaaaaazzzzzzzz");
	lightstyle(10, "mmamammmmammamamaaamammma");
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	Skill_Init();

	precache_model("models/error.vvm");

	if (autocvar_sv_levelexec)
		readcmd(sprintf("exec maps/%s.cfg\n", mapname));

	/* we need to flush this, so that any leftover serverinfo
	 * in the server-config gets overwritten */
	forceinfokey(world, "skyname", "");

	/* Set the default sky */
	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		if (!self.skyname) {
			self.skyname = "desert";
		}
		forceinfokey(world, "skyname", self.skyname);
	}
}

/*
=================
ConsoleCmd

Any command executed on the server (either tty, rcon or 'sv') gets
sent here first.

When returning FALSE the server will interpret the command.
Returning TRUE will mark the command as 'resolved'.
=================
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
	case "trigger_ent":
		string targ;
		targ = argv(1);

		if (targ)
		for (entity a = world; (a = find(a, ::targetname, argv(1)));) {
			NSEntity t = (NSEntity)a;

			if (t.Trigger)
				t.Trigger(self, TRIG_TOGGLE);
		}
		break;
	case "respawn_ents":
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			NSEntity ent = (NSEntity)a;
			ent.Respawn();
		}
		break;
#ifdef BOT_INCLUDED
	case "way":
		Way_Cmd();
		break;
#endif
	default:
		return (0);
	}
	return (1);
}

/*
=================
SV_ShouldPause

Returns TRUE if the server should pause the game-logic when the 'pause' command
is being executed.
=================
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

//#define REEDICT 0
void
SV_PerformLoad(float fh, float entcount, float playerslots)
{
	entity e;
	entity eold;
	string l;
	float n;
	NSEntity loadent = __NULL__;

	print("--------- Loading Existing Save ----------\n");

#ifdef REEDICT
	while ((e=nextent(e))) {
		if (edict_num(1) != e)
			remove(e);
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
#ifndef REEDICT
			n = stof(argv(1));
			e = edict_num(n);
			print(sprintf("Creating edict num %d\n", n));
#else
			entity e = spawn();
#endif
			cname = argv(2);
			loadent = __NULL__;

			__fullspawndata = fgets(fh);

			/* call the constructor if one is present, init the default fields */
			if (isfunction(strcat("spawnfunc_", cname))) {
				e.classname = cname;

				eold = self;
				self = e;
				callfunction(strcat("spawnfunc_", cname));
				e.classname = cname;
				loadent = (NSEntity)e;
				self = eold;
			} else {
				print(sprintf("Could not spawn %s\n", cname));
				remove(e);
				continue;
			}
		} else if (argv(0) == "{") {
		} else if (argv(0) == "}") {
			if (loadent) {
				loadent = __NULL__;
			}
		} else {
			if (loadent) {
				int c = tokenize(l);

				if (c == 2) {
					loadent.Restore(argv(0), argv(1));
				}
			}
		}
	}
}

void
SV_PerformSave(float fh, float entcount, float playerslots)
{
	float i = 0;
	entity e;

	print("--------- Performing Save ----------\n");

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
	}
	fclose(fh);
}

void
CheckSpawn(void() spawnfunc)
{
	if (spawnfunc)
		spawnfunc();
	else
		remove(self);
}
