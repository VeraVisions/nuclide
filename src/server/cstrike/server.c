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

void Game_StartFrame(void)
{
	if ((g_cs_alive_t + g_cs_alive_ct) == 0) {
		int iInGamePlayers = 0;
		for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
			iInGamePlayers++;
		}
		
		if ((iInGamePlayers > 0) && (g_cs_gamestate != GAME_COMMENCING && g_cs_gamestate != GAME_END)) {
			Timer_Begin(2, GAME_COMMENCING);
		} else if (iInGamePlayers == 0) {
			g_cs_gamestate = GAME_INACTIVE;
			g_cs_gametime = 0;
			g_cs_roundswon_t = 0;
			g_cs_roundswon_ct = 0;
			g_cs_roundsplayed = 0;
		} else {
			Timer_Update(); // Timer that happens once players have started joining
		}
	} else {
		Timer_Update(); // Normal gameplay timer
	}
}

float Game_ConsoleCmd(string cmd)
{
	return FALSE;
}

void Game_Worldspawn(void)
{
	precache_model("models/player/arctic/arctic.mdl");
	precache_model("models/player/gign/gign.mdl");
	precache_model("models/player/gsg9/gsg9.mdl");
	precache_model("models/player/guerilla/guerilla.mdl");
	precache_model("models/player/leet/leet.mdl");
	precache_model("models/player/sas/sas.mdl");
	precache_model("models/player/terror/terror.mdl");
	precache_model("models/player/urban/urban.mdl");
	precache_model("models/player/vip/vip.mdl");
	precache_sound("weapons/ric_metal-2.wav");

	Weapons_Init();

	clientstat(STAT_MONEY, EV_INTEGER, player::money);
	pointerstat(STAT_GAMETIME, EV_FLOAT, &g_cs_gametime);
	pointerstat(STAT_GAMESTATE, EV_INTEGER, &g_cs_gamestate);
}
