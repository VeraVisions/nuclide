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

class CSMultiplayerRules:HLGameRules
{
	virtual void(void) FrameStart;
	/* client */
	virtual void(player) PlayerSpawn;

	/* level transitions */
	virtual void(player) LevelDecodeParms;
};

void
CSMultiplayerRules::FrameStart(void)
{
	if ((g_cs_alive_t + g_cs_alive_ct) == 0) {
		int iInGamePlayers = 0;
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
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

void
CSMultiplayerRules::LevelDecodeParms(player pl)
{

}

void
CSMultiplayerRules::PlayerSpawn(player pl)
{
	pl.classname = "spectator";
	pl.health = 0;
	pl.armor = 0;
	pl.takedamage = DAMAGE_NO;
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NOCLIP;
	pl.SendEntity = Player_SendEntity;
	pl.flags = FL_CLIENT;
	pl.weapon = 0;
	pl.viewzoom = 1.0f;
	pl.model = 0;
	setsize (pl, [-16,-16,-16], [16,16,16]);
	pl.view_ofs = pl.velocity = [0,0,0];
	forceinfokey(pl, "*spec", "2");
	entity eTarget = world;

	Spawn_MakeSpectator();
	Spawn_ObserverCam();

	// Because we don't want to reset these when we die
	Money_AddMoney(pl, autocvar_mp_startmoney);
	
	pl.team = 0;
	forceinfokey(pl, "*team", "0"); 
}

void weaponbox_spawn(player pl)
{
}

void
CSEv_JoinT_f(float c)
{
	player pl = (player)self;
	pl.charmodel = c;
	CSEv_GamePlayerSpawn_f(pl.charmodel);
};

void
CSEv_JoinCT_f(float c)
{
	player pl = (player)self;
	pl.charmodel = c + 4;
	CSEv_GamePlayerSpawn_f(pl.charmodel);
}
