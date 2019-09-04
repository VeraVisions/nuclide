/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

//FOR DEBUGGING ONLY, remove when prediction is trusted (along with the extra network bloat).
static void warnifdiff(string name, __inout float expected, float got)
{
	//this should only fire from prediction misses.
	//this hopefully only happens when the server's anti-time-banking logic does its thing, or for things caused by other players/ents getting in the way.

	//if (expected != got)
		//print(sprintf("%s differs, expected %g, got %g\n", name, expected, got));

	//enable the following line if you want to see if it actually makes a difference.
	//expected = got;
}

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
	} else {
		int i;
		//FIXME: splitscreen
		if (pl.entnum == player_localentnum) {
			//FIXME: splitscreen
			pSeat = &seats[0];
			for (i = pl.sequence+1; i <= servercommandframe; i++) {
				if (!getinputstate(i)) {
					break;	//erk?... too old?
				}
				input_sequence = i;
				QPhysics_Run(pl);
			}

			/* any differences in things that are read below are now
			 * officially from prediction misses. */
		}
	}

	pl.sequence = servercommandframe; 
	pl.modelindex = readshort();	// TODO: make conditional
	pl.origin[0] = readcoord();
	pl.origin[1] = readcoord();
	pl.origin[2] = readcoord();	// TODO: make conditional
	pl.pitch = readfloat();
	pl.angles[1] = readfloat();
	pl.angles[2] = readfloat();
	pl.velocity[0] = readcoord();
	pl.velocity[1] = readcoord();
	pl.velocity[2] = readcoord();
	pl.flags = readfloat(); //make mostly conditional
	pl.activeweapon = readbyte(); // TODO: make conditional
	warnifdiff("weapontime", pl.weapontime, readfloat());	//remove
	pl.g_items = readfloat(); // TODO: make conditional
	pl.health = readbyte(); // TODO: make conditional
	pl.armor = readbyte(); // TODO: make conditional
	pl.movetype = readbyte(); // TODO: make conditional
	pl.view_ofs[2] = readfloat(); // TODO: make conditional
	pl.viewzoom = readfloat();	//remove? or make conditional
	warnifdiff("jumptime", pl.jumptime, readfloat());	//remove
	warnifdiff("teletime", pl.teleport_time, readfloat());	//remove
	
	pl.baseframe = readbyte();	// TODO: make conditional
	pl.frame = readbyte();		// TODO: make conditional

	pl.a_ammo1 = readbyte(); // TODO: make conditional
	pl.a_ammo2 = readbyte(); // TODO: make conditional
	pl.a_ammo3 = readbyte(); // TODO: make conditional
	warnifdiff("attack_next", pl.w_attack_next, readfloat());	//remove
	warnifdiff("idle_next", pl.w_idle_next, readfloat());	//remove
	setorigin( pl, pl.origin );
}
