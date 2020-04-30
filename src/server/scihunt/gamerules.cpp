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

var int autocvar_sh_insanity = 10;
var int autocvar_sv_playerkeepalive = TRUE;


void
SHMultiplayerRules::PlayerDeath(player pl)
{
	/* obituary networking */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	if (g_dmg_eAttacker.netname)
		WriteString(MSG_MULTICAST, g_dmg_eAttacker.netname);
	else
		WriteString(MSG_MULTICAST, g_dmg_eAttacker.classname);
	WriteString(MSG_MULTICAST, pl.netname);
	WriteByte(MSG_MULTICAST, g_dmg_iWeapon);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

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

	pl.movetype = MOVETYPE_NONE;
	pl.solid = SOLID_NOT;
	pl.takedamage = DAMAGE_NO;
	pl.flags &= ~FL_FLASHLIGHT;
	pl.armor = pl.activeweapon = pl.g_items = 0;

	pl.think = PutClientInServer;
	pl.nextthink = time + 4.0f;
	sound(pl, CHAN_AUTO, "fvox/flatline.wav", 1.0, ATTN_NORM);

	if (pl.health < -50) {
		pl.health = 0;
		FX_GibHuman(pl.origin);
		return;
	}

	pl.health = 0;

	/* Let's handle corpses on the clientside */
	entity corpse = spawn();
	setorigin(corpse, pl.origin + [0,0,32]);
	setmodel(corpse, pl.model);
	setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
	corpse.movetype = MOVETYPE_TOSS;
	corpse.solid = SOLID_TRIGGER;
	corpse.modelindex = pl.modelindex;
	corpse.frame = ANIM_DIESIMPLE;
	corpse.angles = pl.angles;
	corpse.velocity = pl.velocity;
}

void
SHMultiplayerRules::PlayerSpawn(player pl)
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

	spot = Spawn_SelectRandom("info_player_deathmatch");
	setorigin(pl, spot.origin);
	pl.angles = spot.angles;

	pl.g_items = ITEM_CROWBAR | ITEM_GLOCK | ITEM_SUIT;
	pl.activeweapon = WEAPON_GLOCK;
	pl.glock_mag = 18;
	pl.ammo_9mm = 44;
	Weapons_RefreshAmmo(pl);
	SHData_GetItems(pl);

	Client_FixAngle(pl, pl.angles);
}

void
SHMultiplayerRules::LevelDecodeParms(player pl)
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
SHMultiplayerRules::LevelChangeParms(player pl)
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
SHMultiplayerRules::LevelNewParms(void)
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
SHMultiplayerRules::PlayerPostFrame(player pl)
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

	pl.sh_insaneactive = bound(0.0f, pl.sh_insaneactive - frametime, pl.sh_insaneactive);

	if (pl.sh_insaneactive > 0.0f)
		pl.flags |= FL_RESERVED1;
	else {
		if (pl.flags & FL_RESERVED1) {
			bprint(PRINT_CHAT, sprintf("%s is no longer insane!\n", pl.netname));
		}
		pl.flags &= ~FL_RESERVED1;
	}
}

void
SHMultiplayerRules::PlayerConnect(entity pl)
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
SHMultiplayerRules::PlayerDisconnect(entity pl)
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
SHMultiplayerRules::PlayerKill(player pl)
{
	Damage_Apply(pl, pl, pl.health, WEAPON_NONE, DMG_SKIP_ARMOR);
}

void
SHMultiplayerRules::ScientistKill(player pl, entity sci)
{
	/* obituary networking */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	WriteString(MSG_MULTICAST, pl.netname);
	WriteString(MSG_MULTICAST, sci.netname);
	WriteByte(MSG_MULTICAST, g_dmg_iWeapon);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);
	pl.frags++;

	/*if (g_weapons[g_dmg_iWeapon].slot != 0)
		return;*/

	/* if this is our first kill in a while, or in the timer... */
	if (pl.sh_insanecount == 0 || pl.sh_insanetime > time) {
		pl.sh_insanecount++;
	} else {
		pl.sh_insanecount = 0;
	}

	if (pl.sh_insanecount >= autocvar_sh_insanity) {
		if (pl.sh_insaneactive <= 0.0f)
			bprint(PRINT_CHAT, sprintf("%s is going insane!\n", pl.netname));

		pl.sh_insaneactive += 3.0f;
		
		if (pl.sh_insaneactive > 60)
			pl.sh_insaneactive = 60;
	}

	/* timer gets touched every time */
	pl.sh_insanetime = time + 2.0f;
} 
