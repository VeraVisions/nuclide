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

/*
=================
Client_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
Client_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("chooseteam");
	registercommand("buy");

	/* radio */
	registercommand("radio1");
	registercommand("radio2");
	registercommand("radio3");

	registercommand("motd");
	registercommand("drop");
	registercommand("nightvision");

	/* pistols */
	registercommand("glock");
	registercommand("usp");
	registercommand("p228");
	registercommand("deagle");
	registercommand("fn57");
	registercommand("elites");

	/* shotties */
	registercommand("m3");
	registercommand("xm1014");

	/* smg */
	registercommand("tmp");
	registercommand("mac10");
	registercommand("mp5");
	registercommand("ump45");

	/* rifles */
	registercommand("p90");
	registercommand("ak47");
	registercommand("m4a1");
	registercommand("sg552");
	registercommand("aug");
	registercommand("scout");
	registercommand("sg550");
	registercommand("awp");
	registercommand("g3sg1");

	/* lonely */
	registercommand("m249");

	/* ammo */
	registercommand("primammo");
	registercommand("buyammo1");
	registercommand("secammo");
	registercommand("buyammo2");

	/* equipment */
	registercommand("vest");
	registercommand("vesthelm");
	registercommand("flash");
	registercommand("hegren");
	registercommand("vsgren");
	registercommand("defuser");
	registercommand("nvg");

	/* radio */
	registercommand("coverme");
	registercommand("takepoint");
	registercommand("holdpos");
	registercommand("regroup");
	registercommand("followme");
	registercommand("takingfire");
	registercommand("go");
	registercommand("fallback");
	registercommand("sticktog");
	registercommand("getinpos");
	registercommand("stormfront");
	registercommand("report");
	registercommand("roger");
	registercommand("enemyspot");
	registercommand("needbackup");
	registercommand("sectorclear");
	registercommand("inposition");
	registercommand("reportingin");
	registercommand("getout");
	registercommand("negative");
	registercommand("enemydown");
}

void
Client_InitDone(void)
{
	Textmenu_Call("TEAM_SELECT");
}

void
Game_RendererRestarted(string rstr)
{
	precache_model("sprites/640hud1.spr");
	precache_model("sprites/640hud2.spr");
	precache_model("sprites/640hud3.spr");
	precache_model("sprites/640hud4.spr");
	precache_model("sprites/640hud5.spr");
	precache_model("sprites/640hud6.spr");
	precache_model("sprites/640hud7.spr");
	precache_model("sprites/640hud10.spr");
	precache_model("sprites/640hud11.spr");
	precache_model("sprites/640hud12.spr");
	precache_model("sprites/640hud13.spr");
	precache_model("sprites/640hud14.spr");
	precache_model("sprites/640hud15.spr");
	precache_model("sprites/640hud16.spr");
	precache_model("sprites/bottom.spr");
	precache_model("sprites/bottom_left.spr");
	precache_model("sprites/bottom_right.spr");
	precache_model("sprites/left.spr");
	precache_model("sprites/radar640.spr");
	precache_model("sprites/right.spr");
	precache_model("sprites/sniper_scope.spr");
	precache_model("sprites/top.spr");
	precache_model("sprites/top_left.spr");
	precache_model("sprites/top_right.spr");
	BEAM_TRIPMINE = particleeffectnum("beam_tripmine");
}
