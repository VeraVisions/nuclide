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

/* after a level-change is done we need to pick up the scraps and fill the
 * info back in. */
void
Gamerules_DecodeChangeParms(player pl)
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
}

/* prepare the client-info for level-transition */
void
Gamerules_SetChangeParms(player pl)
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

/* yuck, whenever 'changelevel' does not happen. */
void
Gamerules_SetNewParms(void)
{
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = parm10 = parm11 = parm12 = parm13 = parm14 =
	parm15 = parm16 = parm17 = parm18 = parm19 = parm20 = parm21 =
	parm22 = parm23 = parm24 = parm25 = parm26 = parm27 = parm28 =
	parm29 = parm30 = 0;
}

/* called when the player first spawns/respawns */
void
Gamerules_Spawn(player pl)
{
	entity spot;

	if (cvar("sv_playerslots") == 1) {
		if (startspot != "") {
			Gamerules_DecodeChangeParms(pl);
			setorigin(pl, Landmark_GetSpot());
		} else {
			Gamerules_SetNewParms();
			spot = find(world, classname, "info_player_start");
			setorigin(pl, spot.origin);
			pl.fixangle = TRUE;
		}
	} else {
		Gamerules_SetNewParms();
		spot = Spawn_SelectRandom("info_player_deathmatch");
		setorigin(pl, spot.origin);
		pl.angles = spot.angles;
		pl.g_items |= ITEM_SUIT;
	}
	Client_FixAngle(pl, pl.angles);
}

void weaponbox_spawn(player pl)
{
	
}
