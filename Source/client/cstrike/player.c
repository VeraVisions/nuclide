/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

.float pmove_frame;

.vector netorigin;
.vector netangles;
.vector netvelocity;
.float netflags;
.float netpmove_flags;

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
	}

	pl.modelindex = readshort();
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
	pl.pmove_flags = readfloat();
	pl.weapon = readbyte();
	pl.health = readbyte();
	pl.movetype = readfloat();
	pl.view_ofs[2] = readfloat();
	pl.viewzoom = readfloat();
	setorigin( pl, pl.origin );
}
