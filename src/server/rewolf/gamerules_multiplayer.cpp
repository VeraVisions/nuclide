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

class HLMultiplayerRules:HLGameRules
{
	/* client */
	virtual void(player) PlayerSpawn;

	/* level transitions */
	virtual void(player) LevelDecodeParms;
};

void
HLMultiplayerRules::LevelDecodeParms(player pl)
{

}

void
HLMultiplayerRules::PlayerSpawn(player pl)
{
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
	string mymodel = infokey(pl, "model");

	if (mymodel) {
		mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
		if (whichpack(mymodel)) {
			pl.model = mymodel;
		}
	}
	setmodel(pl, pl.model);

	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.view_ofs = VEC_PLAYER_VIEWPOS;
	pl.velocity = [0,0,0];
	pl.gravity = __NULL__;
	pl.frame = 1;
	pl.SendEntity = Player_SendEntity;
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

void weaponbox_spawn(player pl)
{
}
