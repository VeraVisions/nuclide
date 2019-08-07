/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Player_ReadEntity(float flIsNew)
{
	player pl = (player)self;
	if ( flIsNew == TRUE ) {
		spawnfunc_player();
		pl.classname = "player";
		pl.solid = SOLID_SLIDEBOX;
		pl.drawmask = MASK_ENGINE;
		pl.customphysics = Empty;
		setsize( pl, VEC_HULL_MIN, VEC_HULL_MAX );
		pl.set_model();
	}

	readshort();
	pl.origin[0] = readcoord();
	pl.origin[1] = readcoord();
	pl.origin[2] = readcoord();
	pl.pitch = readcoord();
	pl.angles[1] = readcoord();
	pl.angles[2] = readcoord();
	pl.velocity[0] = readcoord();
	pl.velocity[1] = readcoord();
	pl.velocity[2] = readcoord();
	pl.flags = readfloat();
	pl.activeweapon = readbyte();
	pl.g_items = readfloat();
	pl.health = readbyte();
	pl.armor = readbyte();
	pl.movetype = readfloat();
	pl.view_ofs[2] = readfloat();
	pl.viewzoom = readfloat();
	pl.jumptime = readfloat();
	pl.teleport_time = readfloat();
	
	if (pl.playertype == 0) {
		pl.baseframe = readbyte();
		pl.frame = readbyte();
	} else {
		readbyte();
		readbyte();
	}

	pl.a_ammo1 = readbyte();
	pl.a_ammo2 = readbyte();
	pl.a_ammo3 = readbyte();
	pl.w_attack_next = readfloat();
	pl.w_idle_next = readfloat();
	setorigin( pl, pl.origin );
}
