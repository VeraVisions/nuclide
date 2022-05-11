/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

void
MultiplayerRules::FrameStart(void)
{
	if (cvar("mp_timelimit"))
	if (time >= (cvar("mp_timelimit") * 60)) {
		IntermissionStart();
	}

	IntermissionCycle();
}

void
MultiplayerRules::PlayerDeath(NSClientPlayer pl)
{
	Plugin_PlayerObituary(g_dmg_eAttacker, g_dmg_eTarget, g_dmg_iWeapon, g_dmg_iHitBody, g_dmg_iDamage);

	/* death-counter */
	pl.deaths++;
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	/* update score-counter */
	if (pl.flags & FL_CLIENT || pl.flags & FL_MONSTER)
	if (g_dmg_eAttacker.flags & FL_CLIENT) {
		if (pl == g_dmg_eAttacker)
			g_dmg_eAttacker.frags--;
		else
			g_dmg_eAttacker.frags++;
	}

	/* in DM we only care about the frags */
	if (cvar("mp_fraglimit"))
	if (g_dmg_eAttacker.frags >= cvar("mp_fraglimit")) {
		IntermissionStart();
	}

	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetSolid(SOLID_NOT);
	pl.SetModelindex(0);
	pl.takedamage = DAMAGE_NO;
	pl.gflags &= ~GF_FLASHLIGHT;
	pl.armor = pl.activeweapon = pl.g_items = 0;

	pl.think = PutClientInServer;
	pl.nextthink = time + 4.0f;
}

void
MultiplayerRules::PlayerSpawn(NSClientPlayer pp)
{
	player pl = (player)pp;
	/* this is where the mods want to deviate */
	entity spot;

	pl.classname = "player";
	pl.health = pl.max_health = 100;
	pl.takedamage = DAMAGE_YES;
	pl.solid = SOLID_SLIDEBOX;
	pl.movetype = MOVETYPE_WALK;
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;
	pl.model = "models/player.mdl";
	setmodel(pl, pl.model);

	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.velocity = [0,0,0];
	pl.gravity = __NULL__;
	pl.frame = 1;
	pl.SendFlags = UPDATE_ALL;
	pl.customphysics = Empty;
	pl.iBleeds = TRUE;
	forceinfokey(pl, "*spec", "0");
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	LevelNewParms();
	LevelDecodeParms(pl);

	spot = Spawn_SelectRandom("info_player_deathmatch");
	setorigin(pl, spot.origin);
	pl.angles = spot.angles;
	Weapons_RefreshAmmo(pl);

	Client_FixAngle(pl, pl.angles);
}

float
MultiplayerRules::ConsoleCommand(NSClientPlayer pp, string cmd)
{
	tokenize(cmd);

	switch (argv(0)) {
	case "bot_add":
		Bot_AddQuick();
		break;
	default:
		return (0);
	}

	return (1);
}
