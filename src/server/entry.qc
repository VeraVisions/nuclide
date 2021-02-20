/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
	/* For entity parenting to work, we need to go through and run on every
	 * this method on every CBaseEntity class */
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		CBaseEntity ent = (CBaseEntity)a;
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
ClientConnect(float csqc_active)
{
	int playercount = 0;

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
			CBaseEntity caw = (CBaseEntity)a;
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
		CBaseTrigger t = (CBaseTrigger)a;

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
	if (self.classname != "player") {
		return;
	}

#ifdef BOT_INCLUDED
	if (clienttype(self) == CLIENTTYPE_BOT) {
		((bot)self).PostFrame();
	}
#endif

	if (g_ents_initialized)
		g_grMode.PlayerPostFrame((base_player)self);
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
	iprint("Setting New Level Parameters");

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
	iprint("Setting Level-Change Parameters");

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
	iprint("Initializing Server-Module");
	Plugin_Init();
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
	iprint("Respawning Entities");

	if (g_ents_initialized)
		g_grMode.InitPostEnts();

	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		CBaseEntity ent = (CBaseEntity)a;
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
void
initents(void)
{
	iprint("Initializing Entities");

	/* sound shader init */
	Sound_Init();

	if (serverkeyfloat("*bspversion") == BSPVER_HL) {
		/* load materials.txt because someone thought this was the best idea */
		filestream fileMaterial = fopen("sound/materials.txt", FILE_READ);
		hashMaterials = __NULL__;
		hashMaterials = hash_createtab(2, HASH_ADD);

		if (fileMaterial >= 0) {
			string sTemp;
			while ((sTemp = fgets(fileMaterial))) {
				/* tokenize and just parse this stuff in */
				if (tokenize_console(sTemp) == 2) {
					string mat_type;
					string tex_name;
					mat_type = strtoupper(argv(0));
					tex_name = Materials_FixName(strtolower(argv(1)));
					hash_add(hashMaterials, strtolower(argv(1)), str2chr(mat_type, 0));
				}
			}
			fclose(fileMaterial);
		} else {
			print("Failed to load sound/materials.txt!\n");
		}
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
	iprint("Initializing World");
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

	if (autocvar_sv_levelexec)
		readcmd(sprintf("exec maps/%s.cfg\n", mapname));
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
	pl = (player)self;

	/* give the game-mode a chance to override us */
	if (g_ents_initialized)
		if (g_grMode.ConsoleCommand(pl, cmd) == TRUE)
			return TRUE;

	/* time to handle commands that apply to all games */
	tokenize(cmd);
	switch (argv(0)) {
	case "trigger_ent":
		string targ;
		targ = argv(1);

		if (targ)
		for (entity a = world; (a = find(a, ::targetname, argv(1)));) {
			CBaseTrigger t = (CBaseTrigger)a;

			if (t.Trigger)
				t.Trigger(self, TRIG_TOGGLE);
		}
		break;
	case "respawn_ents":
		for (entity a = world; (a = findfloat(a, ::identity, 1));) {
			CBaseEntity ent = (CBaseEntity)a;
			ent.Respawn();
		}
		break;
#ifdef BOT_INCLUDED
	case "way":
		Way_Cmd();
		break;
#endif
	default:
		return FALSE;
	}
	return TRUE;
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
		return FALSE;

	if (cvar("pausable") == 1)
		return TRUE;

	if (cvar("sv_playerslots") > 1)
		return FALSE;

	return newstatus;
}