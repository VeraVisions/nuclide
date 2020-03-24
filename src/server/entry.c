/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
	Game_ClientKill();
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
	Game_PutClientInServer();
}

void PlayerPreThink(void)
{
	Game_PlayerPreThink();
}

void PlayerPostThink(void)
{
	Game_PlayerPostThink();
}

void SetNewParms(void)
{
	Game_SetNewParms();
}

void SetChangeParms(void)
{
	Game_SetChangeParms();
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

	precache_sound("player/pl_metal1.wav");
	precache_sound("player/pl_metal2.wav");
	precache_sound("player/pl_metal3.wav");
	precache_sound("player/pl_metal4.wav");

	precache_sound("player/pl_duct1.wav");
	precache_sound("player/pl_duct2.wav");
	precache_sound("player/pl_duct3.wav");
	precache_sound("player/pl_duct4.wav");

	precache_sound("player/pl_dirt1.wav");
	precache_sound("player/pl_dirt2.wav");
	precache_sound("player/pl_dirt3.wav");
	precache_sound("player/pl_dirt4.wav");

	precache_sound("player/pl_slosh1.wav");
	precache_sound("player/pl_slosh2.wav");
	precache_sound("player/pl_slosh3.wav");
	precache_sound("player/pl_slosh4.wav");

	precache_sound("player/pl_tile1.wav");
	precache_sound("player/pl_tile2.wav");
	precache_sound("player/pl_tile3.wav");
	precache_sound("player/pl_tile4.wav");

	precache_sound("player/pl_grate1.wav");
	precache_sound("player/pl_grate2.wav");
	precache_sound("player/pl_grate3.wav");
	precache_sound("player/pl_grate4.wav");

	precache_sound("player/pl_ladder1.wav");
	precache_sound("player/pl_ladder2.wav");
	precache_sound("player/pl_ladder3.wav");
	precache_sound("player/pl_ladder4.wav");

	precache_sound("player/pl_step1.wav");
	precache_sound("player/pl_step2.wav");
	precache_sound("player/pl_step3.wav");
	precache_sound("player/pl_step4.wav");
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

