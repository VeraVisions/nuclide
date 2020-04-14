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

class HLSingleplayerRules:HLGameRules
{
	/* client */
	virtual void(player) PlayerSpawn;

	/* level transitions */
	virtual void(player) LevelChangeParms;
	virtual void(player) LevelDecodeParms;
};

void
HLSingleplayerRules::LevelDecodeParms(player pl)
{
	g_landmarkpos[0] = parm1;
	g_landmarkpos[1] = parm2;
	g_landmarkpos[2] = parm3;
	pl.angles[0] = parm4;
	pl.angles[1] = parm5;
	pl.angles[2] = parm6;
	pl.velocity[0] = parm7;
	pl.velocity[1] = parm8;
	pl.velocity[2] = parm9;
	pl.g_items = parm10;
	pl.activeweapon = parm11;
	pl.flags = parm64;

	pl.ammo_nail = parm12;
	pl.ammo_buckshot = parm13;
	pl.ammo_bolts = parm14;
	pl.ammo_xencandy = parm15;
	pl.ammo_satchel = parm16;
	
	pl.bradnailer_mag = parm17;
	pl.nailgun_mag = parm18;
	pl.shotgun_mag = parm19;
	pl.cmlwbr_mag = parm20;
	pl.xs_mag = parm21;
	pl.satchel_chg = parm22;

	if (pl.flags & FL_CROUCHING) {
		setsize(pl, VEC_CHULL_MIN, VEC_CHULL_MAX);
	} else {
		setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	}
}

void
HLSingleplayerRules::LevelChangeParms(player pl)
{
	parm1 = g_landmarkpos[0];
	parm2 = g_landmarkpos[1];
	parm3 = g_landmarkpos[2];
	parm4 = pl.angles[0];
	parm5 = pl.angles[1];
	parm6 = pl.angles[2];
	parm7 = pl.velocity[0];
	parm8 = pl.velocity[1];
	parm9 = pl.velocity[2];
	parm64 = pl.flags;
	parm10 = pl.g_items;
	parm11 = pl.activeweapon;
	parm12 = pl.ammo_nail;
	parm13 = pl.ammo_buckshot;
	parm14 = pl.ammo_bolts;
	parm15 = pl.ammo_xencandy;
	parm16 = pl.ammo_satchel;
	parm17 = pl.bradnailer_mag;
	parm18 = pl.nailgun_mag;
	parm19 = pl.shotgun_mag;
	parm20 = pl.cmlwbr_mag;
	parm21 = pl.xs_mag;
	parm22 = pl.satchel_chg;
}

void
HLSingleplayerRules::PlayerSpawn(player pl)
{
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

	/* this is where the mods want to deviate */
	entity spot;

	if (startspot != "") {
		dprint(sprintf("^3Gamerules_Spawn^7: Startspot is %s\n", startspot));
		LevelDecodeParms(pl);
		setorigin(pl, Landmark_GetSpot());
	} else {
		LevelNewParms();
		spot = find(world, ::classname, "info_player_start");
		setorigin(pl, spot.origin);
		pl.angles = spot.angles;
	}

	Weapons_RefreshAmmo(pl);
	Client_FixAngle(pl, pl.angles);
} 
