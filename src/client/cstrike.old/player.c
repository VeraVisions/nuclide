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

.float pmove_frame;

.vector netorigin;
.vector netangles;
.vector netvelocity;
.float netflags;
.float netpmove_flags;

void Player_ReadEntity(float flIsNew)
{
	player pl = (player)self;

	if (flIsNew == TRUE) {
		spawnfunc_player();
			
		pl.classname = "player";
		pl.solid = SOLID_SLIDEBOX;
		pl.drawmask = MASK_ENGINE;
		pl.customphysics = Empty;
		setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	}else {
        if (pl.entnum == player_localentnum) // FIXME: Splitscreen
        {
            pSeat = &g_seats[0];  //FIXME: splitscreen
            for (int i = pl.sequence+1; i <= servercommandframe; i++) {
                if (!getinputstate(i))
                    break;  //erk?... too old?
                input_sequence = i;
                QPhysics_Run(pl);
            }
        }
    }
	pl.sequence = servercommandframe;
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
	pl.activeweapon = readbyte();
	pl.health = readbyte();
	pl.movetype = readfloat();
	pl.view_ofs[2] = readfloat();
	pl.viewzoom = readfloat();
	pl.jumptime = readfloat();
	pl.teleport_time = readfloat();
	setorigin(pl, pl.origin);
}
