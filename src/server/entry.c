/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* main is a qcc leftover */
void main(void)
{
}

void StartFrame(void)
{
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		CBaseEntity ent = (CBaseEntity)a;
		ent.ParentUpdate();
	}

	g_grMode.FrameStart();
	Vote_Frame();
}

void ClientConnect(float csqc_active)
{
	int playercount = 0;

	/* make sure you never change the classname. ever. */
	if (self.classname != "player") {
		spawnfunc_player();
	}

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

void ClientDisconnect(void)
{
	g_grMode.PlayerDisconnect((base_player)self);
}

void ClientKill(void)
{
	g_grMode.PlayerKill((base_player)self);
}

void SpectatorThink(void)
{
	Game_SpectatorThink();
}
void SpectatorConnect(void)
{
	Game_SpectatorConnect();
}
void SpectatorDisconnect(void)
{
	Game_SpectatorDisconnect();
}

void PutClientInServer(void)
{
	g_grMode.PlayerSpawn((base_player)self);

	/* activate all game_playerspawn entities */
	for (entity a = world; (a = find(a, ::targetname, "game_playerspawn"));) {
		CBaseTrigger t = (CBaseTrigger)a;

		if (t.Trigger)
			t.Trigger(self, TRIG_TOGGLE);
	}
}

void PlayerPreThink(void)
{
	g_grMode.PlayerPreFrame((base_player)self);
}

void PlayerPostThink(void)
{
	g_grMode.PlayerPostFrame((base_player)self);
}

void SetNewParms(void)
{
	iprint("Setting New Level Parameters");
	g_grMode.LevelNewParms();
}

void SetChangeParms(void)
{
	iprint("Setting Level-Change Parameters");
	g_grMode.LevelChangeParms((base_player)self);
}

void SV_RunClientCommand(void)
{
	if (!Plugin_RunClientCommand()) {
		Game_RunClientCommand();
	}
}

void SV_ParseClientCommand(string cmd)
{
	string newcmd = Plugin_ParseClientCommand(cmd);

	if (newcmd == __NULL__)
		Game_ParseClientCommand(cmd);
	else 
		Game_ParseClientCommand(newcmd);
}

void init(float prevprogs)
{
	iprint("Initializing Server-Module");
	Plugin_Init();
}

void init_respawn(void)
{
	iprint("Respawning Entities");
	g_grMode.InitPostEnts();

	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		CBaseEntity ent = (CBaseEntity)a;
		ent.Respawn();
	}
	remove(self);
}

void initents(void)
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
					hash_add(hashMaterials, strtolower(argv(1)), str2chr(argv(0), 0));
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
}

var int autocvar_sv_levelexec = 1;
void worldspawn(void)
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

float ConsoleCmd(string cmd)
{
	player pl = (player)self;

	/* give the game-mode a chance to override us */
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
	default:
		return FALSE;
	}
	return TRUE;
}

float SV_ShouldPause(float newstatus)
{
	if (serverkeyfloat("background") == 1) {
		return FALSE;
	}

	return newstatus;
}
