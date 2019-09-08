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

/*
=================
Predict_PreFrame

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on 
(so any non-networked state updates locally).
=================
*/
void Predict_PreFrame(player pl)
{
	pl.netorigin = pl.origin;
	pl.netvelocity = pl.velocity;
	pl.netflags = pl.flags;
	pl.netjumptime = pl.jumptime;
	pl.netteleport_time = pl.teleport_time;
	pl.netviewzoom = pl.viewzoom;

#ifdef VALVE
	pl.net_w_attack_next = pl.w_attack_next;
	pl.net_w_idle_next = pl.w_idle_next;
	pl.net_ammo1 = pl.a_ammo1;
	pl.net_ammo2 = pl.a_ammo2;
	pl.net_ammo3 = pl.a_ammo3;
#endif
	pl.net_weapontime = pl.weapontime;

	//self.netpmove_flags = self.pmove_flags;

	//we want to predict an exact copy of the data in the new packet
	/*for (; self.pmove_frame <= servercommandframe; self.pmove_frame++) {
		float flSuccess = getinputstate(self.pmove_frame);*/
	for ( int i = pl.sequence + 1; i <= clientcommandframe; i++ ) {
		float flSuccess = getinputstate( i );
		input_sequence = i;
		if (flSuccess == FALSE) {
			continue;
		}

		if (i==clientcommandframe){
			CSQC_Input_Frame();
		}

		// Partial frames are the worst
		if (input_timelength == 0) {
			break;
		}
		QPhysics_Run(pl);
	}
}

/*
=================
Predict_PostFrame

We're part way through parsing new player data.
Rewind our pmove state back to before we started predicting. 
(to give consistent state instead of accumulating errors)
=================
*/
void Predict_PostFrame(player pl)
{
	pl.origin = pl.netorigin;
	pl.velocity = pl.netvelocity;
	pl.flags = pl.netflags;
	pl.jumptime = pl.netjumptime;
	pl.teleport_time = pl.netteleport_time;
	pl.viewzoom = pl.netviewzoom;
	
#ifdef VALVE
	pl.w_attack_next = pl.net_w_attack_next;
	pl.w_idle_next = pl.net_w_idle_next;
	pl.a_ammo1 = pl.net_ammo1;
	pl.a_ammo2 = pl.net_ammo2;
	pl.a_ammo3 = pl.net_ammo3;
#endif
	pl.weapontime = pl.net_weapontime;

	//self.pmove_flags = self.netpmove_flags;
	setorigin(pl, pl.origin);
	//self.pmove_frame = servercommandframe + 1;
}
