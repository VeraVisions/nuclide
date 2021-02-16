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

float(entity foo, float chanid) getchannellevel = #0;


/*
=================
ClientGame_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	Obituary_Init();
}

void
ClientGame_InitDone(void)
{
}

void
ClientGame_RendererRestart(string rstr)
{
	Obituary_Precache();

	FX_Blood_Init();
	FX_BreakModel_Init();
	FX_Explosion_Init();
	FX_GibHuman_Init();
	FX_Spark_Init();
	FX_Impact_Init();

	precache_model("sprites/640hud1.spr");
	precache_model("sprites/640hud2.spr");
	precache_model("sprites/640hud3.spr");
	precache_model("sprites/640hud4.spr");
	precache_model("sprites/640hud5.spr");
	precache_model("sprites/640hud6.spr");
	precache_model("sprites/hud640_01.spr");
	precache_model("sprites/hud640_02.spr");
	precache_model("sprites/hud640_04.spr");

	BEAM_TRIPMINE = particleeffectnum("weapon_tripmine.beam");
}
