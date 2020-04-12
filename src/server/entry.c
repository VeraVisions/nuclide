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
	for (entity a = world; (a = findfloat(a, gflags, GF_CANRESPAWN));) {
		CBaseEntity ent = (CBaseEntity)a;
		ent.ParentUpdate();
	}

	Game_StartFrame();
	Vote_Frame();
}

void ClientConnect(float csqc_active)
{
	Game_ClientConnect();
}

void ClientDisconnect(void)
{
	Game_ClientDisconnect();
}

void ClientKill(void)
{
	player pl = (player)self;
	Game_ClientKill(pl);
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
	player pl;

	/* make sure you never change the classname. ever. */
	if (self.classname != "player") {
		spawnfunc_player();
	}

	pl = (player)self;
	Game_PutClientInServer(pl);
}

void PlayerPreThink(void)
{
	player pl = (player)self;
	Game_PlayerPreThink(pl);
}

void PlayerPostThink(void)
{
	player pl = (player)self;
	Game_PlayerPostThink(pl);
}

void SetNewParms(void)
{
	Gamerules_SetNewParms();
}

void SetChangeParms(void)
{
	player pl = (player)self;
	Gamerules_SetChangeParms(pl);
}

void SV_RunClientCommand(void)
{
	if (!Plugin_RunClientCommand()) {
		Game_RunClientCommand();
	}
}

void SV_ParseClientCommand(string cmd)
{
	if (!Plugin_ParseClientCommand(cmd)) {
		Game_ParseClientCommand(cmd);
	}
}

void init(float prevprogs)
{
	string sTemp;

	// Let's load materials.txt because someone thought this was the best idea
	filestream fileMaterial = fopen("sound/materials.txt", FILE_READ);
	hashMaterials = hash_createtab(2, HASH_ADD);

	if (fileMaterial >= 0) {
		while ((sTemp = fgets(fileMaterial))) {		
			// Tokenize and just parse this stuff in
			if (tokenize_console(sTemp) == 2) {
				hash_add(hashMaterials, strtolower(argv(1)), str2chr(argv(0), 0));
			}
		}
		fclose(fileMaterial);
		g_hlbsp_materials = TRUE;
	} else {
		error("Failed to load sound/materials.txt!\n");
		g_hlbsp_materials = FALSE;
	}

	PMove_Init();
	Plugin_Init();
}

void init_respawn(void)
{
	for (entity a = world; (a = findfloat(a, gflags, GF_CANRESPAWN));) {
		CBaseEntity ent = (CBaseEntity)a;
		ent.Respawn();
	}
	remove(self);
}

void initents(void)
{
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

	Sound_Precache("step_default.left");
	Sound_Precache("step_default.right");
	Sound_Precache("step_alien.left");
	Sound_Precache("step_alien.right");
	Sound_Precache("step_bloodyflesh.left");
	Sound_Precache("step_bloodyflesh.right");
	Sound_Precache("step_computer.left");
	Sound_Precache("step_computer.right");
	Sound_Precache("step_concrete.left");
	Sound_Precache("step_concrete.right");
	Sound_Precache("step_dirt.left");
	Sound_Precache("step_dirt.right");
	Sound_Precache("step_flesh.left");
	Sound_Precache("step_flesh.right");
	Sound_Precache("step_foliage.left");
	Sound_Precache("step_foliage.right");
	Sound_Precache("step_glass.left");
	Sound_Precache("step_glass.right");
	Sound_Precache("step_grate.left");
	Sound_Precache("step_grate.right");
	Sound_Precache("step_metal.left");
	Sound_Precache("step_metal.right");
	Sound_Precache("step_slosh.left");
	Sound_Precache("step_slosh.right");
	Sound_Precache("step_snow.left");
	Sound_Precache("step_snow.right");
	Sound_Precache("step_tile.left");
	Sound_Precache("step_tile.right");
	Sound_Precache("step_vent.left");
	Sound_Precache("step_vent.right");
	Sound_Precache("step_wood.left");
	Sound_Precache("step_wood.right");
	Sound_Precache("step_ladder.left");
	Sound_Precache("step_ladder.right");

	precache_sound("player/pl_fallpain3.wav");
	precache_sound("items/9mmclip1.wav");
	precache_sound("items/gunpickup2.wav");
	precache_sound("common/wpn_select.wav");
	precache_sound("common/wpn_denyselect.wav");
	precache_sound("player/sprayer.wav");
	precache_sound("items/flashlight1.wav");
	precache_sound("common/null.wav");

	Game_Worldspawn();
	Decals_Init();
	Sentences_Init();

	entity respawntimer = spawn();
	respawntimer.think = init_respawn;
	respawntimer.nextthink = time + 0.1f;
}

void worldspawn(void)
{
	lightstyle(0, "m");
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	lightstyle(4, "mamamamamama");
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	lightstyle(6, "nmonqnmomnmomomno");
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	lightstyle(9, "aaaaaaaazzzzzzzz");
	lightstyle(10, "mmamammmmammamamaaamammma");
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
}

float ConsoleCmd(string cmd)
{
	return Game_ConsoleCmd(cmd);
}

