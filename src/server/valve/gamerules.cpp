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

var int autocvar_sv_playerkeepalive = TRUE;

void
HLGameRules::LevelDecodeParms(player pl)
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

	pl.ammo_9mm = parm12;
	pl.ammo_357 = parm13;
	pl.ammo_buckshot = parm14;
	pl.ammo_m203_grenade = parm15;
	pl.ammo_bolt = parm16;
	pl.ammo_rocket = parm17;
	pl.ammo_uranium = parm18;
	pl.ammo_handgrenade = parm19;
	pl.ammo_satchel = parm20;
	pl.ammo_tripmine = parm21;
	pl.ammo_snark = parm22;
	pl.ammo_hornet = parm23;

	pl.glock_mag = parm24;
	pl.mp5_mag = parm25;
	pl.python_mag = parm26;
	pl.shotgun_mag = parm27;
	pl.crossbow_mag = parm28;
	pl.rpg_mag = parm29;
	pl.satchel_chg = parm30;

	if (pl.flags & FL_CROUCHING) {
		setsize(pl, VEC_CHULL_MIN, VEC_CHULL_MAX);
	} else {
		setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	}
}

void
HLGameRules::LevelChangeParms(player pl)
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
	parm12 = pl.ammo_9mm;
	parm13 = pl.ammo_357;
	parm14 = pl.ammo_buckshot;
	parm15 = pl.ammo_m203_grenade;
	parm16 = pl.ammo_bolt;
	parm17 = pl.ammo_rocket;
	parm18 = pl.ammo_uranium;
	parm19 = pl.ammo_handgrenade;
	parm20 = pl.ammo_satchel;
	parm21 = pl.ammo_tripmine;
	parm22 = pl.ammo_snark;
	parm23 = pl.ammo_hornet;
	parm24 = pl.glock_mag;
	parm25 = pl.mp5_mag;
	parm26 = pl.python_mag;
	parm27 = pl.shotgun_mag;
	parm28 = pl.crossbow_mag;
	parm29 = pl.rpg_mag;
	parm30 = pl.satchel_chg;
}

void
HLGameRules::LevelNewParms(void)
{
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = parm10 = parm11 = parm12 = parm13 = parm14 =
	parm15 = parm16 = parm17 = parm18 = parm19 = parm20 = parm21 =
	parm22 = parm23 = parm24 = parm25 = parm26 = parm27 = parm28 =
	parm29 = parm30 = 0;
	parm64 = FL_CLIENT;
}

/* we check what fields have changed over the course of the frame and network
 * only the ones that have actually changed */
void
HLGameRules::PlayerPostFrame(player pl)
{
	Animation_PlayerUpdate();

	if (autocvar_sv_playerkeepalive)
		pl.SendFlags |= PLAYER_KEEPALIVE;

	if (pl.old_modelindex != pl.modelindex)
		pl.SendFlags |= PLAYER_MODELINDEX;

	if (pl.old_origin[0] != pl.origin[0])
		pl.SendFlags |= PLAYER_ORIGIN;

	if (pl.old_origin[1] != pl.origin[1])
		pl.SendFlags |= PLAYER_ORIGIN;

	if (pl.old_origin[2] != pl.origin[2])
		pl.SendFlags |= PLAYER_ORIGIN_Z;

	if (pl.old_angles[0] != pl.v_angle[0])
		pl.SendFlags |= PLAYER_ANGLES_X;

	if (pl.old_angles[1] != pl.angles[1])
		pl.SendFlags |= PLAYER_ANGLES_Y;

	if (pl.old_angles[2] != pl.angles[2])
		pl.SendFlags |= PLAYER_ANGLES_Z;

	if (pl.old_velocity[0] != pl.velocity[0])
		pl.SendFlags |= PLAYER_VELOCITY;

	if (pl.old_velocity[1] != pl.velocity[1])
		pl.SendFlags |= PLAYER_VELOCITY;

	if (pl.old_velocity[2] != pl.velocity[2])
		pl.SendFlags |= PLAYER_VELOCITY_Z;

	if (pl.old_flags != pl.flags)
		pl.SendFlags |= PLAYER_FLAGS;

	if (pl.old_activeweapon != pl.activeweapon)
		pl.SendFlags |= PLAYER_WEAPON;

	if (pl.old_items != pl.g_items)
		pl.SendFlags |= PLAYER_ITEMS;

	if (pl.old_health != pl.health)
		pl.SendFlags |= PLAYER_HEALTH;

	if (pl.old_armor != pl.armor)
		pl.SendFlags |= PLAYER_ARMOR;

	if (pl.old_movetype != pl.movetype)
		pl.SendFlags |= PLAYER_MOVETYPE;

	if (pl.old_viewofs != pl.view_ofs[2])
		pl.SendFlags |= PLAYER_VIEWOFS;

	if (pl.old_baseframe != pl.baseframe)
		pl.SendFlags |= PLAYER_BASEFRAME;

	if (pl.old_frame != pl.frame)
		pl.SendFlags |= PLAYER_FRAME;

	if (pl.old_a_ammo1 != pl.a_ammo1)
		pl.SendFlags |= PLAYER_AMMO1;

	if (pl.old_a_ammo2 != pl.a_ammo2)
		pl.SendFlags |= PLAYER_AMMO2;

	if (pl.old_a_ammo3 != pl.a_ammo3)
		pl.SendFlags |= PLAYER_AMMO3;

	pl.old_modelindex = pl.modelindex;
	pl.old_origin = pl.origin;
	pl.old_angles = pl.angles;
	pl.old_angles[0] = pl.v_angle[0];
	pl.old_velocity = pl.velocity;
	pl.old_flags = pl.flags;
	pl.old_activeweapon = pl.activeweapon;
	pl.old_items = pl.g_items;
	pl.old_health = pl.health;
	pl.old_armor = pl.armor;
	pl.old_movetype = pl.movetype;
	pl.old_viewofs = pl.view_ofs[2];
	pl.old_baseframe = pl.baseframe;
	pl.old_frame = pl.frame;
	pl.old_a_ammo1 = pl.a_ammo1;
	pl.old_a_ammo2 = pl.a_ammo2;
	pl.old_a_ammo3 = pl.a_ammo3;
}

void
HLGameRules::PlayerConnect(entity pl)
{
	entity a;
	bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));

	int playercount = 0;
	for (a = world; (a = find(a, ::classname, "player"));) {
		playercount++;
	}

	/* we're the first. respawn all entities? */	
	if (playercount == 0) {
		for (a = world; (a = findfloat(a, ::gflags, GF_CANRESPAWN));) {
			CBaseEntity caw = (CBaseEntity)a;
			caw.Respawn();
		}
		Nodes_Init();
	}
}

void
HLGameRules::PlayerDisconnect(entity pl)
{
	bprint(PRINT_HIGH, sprintf("%s disconnected\n", pl.netname));

	/* Make this unusable */
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NONE;
	pl.modelindex = 0;
	pl.health = 0;
	pl.takedamage = 0;
	pl.SendFlags = PLAYER_MODELINDEX;
}

void
HLGameRules::PlayerKill(player pl)
{
	Damage_Apply(pl, pl, pl.health, WEAPON_NONE, DMG_SKIP_ARMOR);
} 
