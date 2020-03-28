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

/*
=================
Client_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void Client_Init(float apilevel, string enginename, float engineversion)
{
	precache_model("sprites/fexplo.spr");
	precache_model("sprites/muzzleflash1.spr");
	precache_sound("player/pl_pain2.wav");

	precache_model("sprites/iplayerred.spr");
	precache_model("sprites/iplayerblue.spr");
	precache_model("sprites/iplayervip.spr");
	precache_model("sprites/ihostage.spr");
	
	precache_model("models/pshell.mdl");
	precache_model("models/rshell.mdl");
	precache_model("models/rshell_big.mdl");
	precache_model("models/shotgunshell.mdl");
	precache_pic( sprintf( "overviews/%s.bmp", mapname ) );

	PARTICLE_SMOKEGRENADE = particleeffectnum("smokegren");

	Radio_InitSounds();
	CSQC_ConsoleCommand_Init();
	Overview_Init();

	pSeat.iOverview = FALSE;
}

void Client_InitDone(void)
{
	/* don't open this in singleplayer */
	if (serverkeyfloat("slots") > 1) {
		VGUI_ChooseTeam();
	}
}

void Game_RendererRestarted(string rstr)
{
	Overview_Init();
}
