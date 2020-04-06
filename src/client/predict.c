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
	pl.net_origin = pl.origin;
	pl.net_velocity = pl.velocity;
	pl.net_flags = pl.flags;
	pl.net_jumptime = pl.jumptime;
	pl.net_teleport_time = pl.teleport_time;
	pl.net_viewzoom = pl.viewzoom;
	pl.net_punchangle = pl.punchangle;
	pl.net_w_attack_next = pl.w_attack_next;
	pl.net_w_idle_next = pl.w_idle_next;
	pl.net_ammo1 = pl.a_ammo1;
	pl.net_ammo2 = pl.a_ammo2;
	pl.net_ammo3 = pl.a_ammo3;
	pl.net_weapontime = pl.weapontime;

	//self.netpmove_flags = self.pmove_flags;

	//we want to predict an exact copy of the data in the new packet
	/*for (; self.pmove_frame <= servercommandframe; self.pmove_frame++) {
		float flSuccess = getinputstate(self.pmove_frame);*/
	for ( int i = pl.sequence + 1; i <= clientcommandframe; i++ ) {
		if (!getinputstate(i)) {
			break;	//erk?... too old?
		}
		input_sequence = i;
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
	pl.origin = pl.net_origin;
	pl.velocity = pl.net_velocity;
	pl.flags = pl.net_flags;
	pl.jumptime = pl.net_jumptime;
	pl.teleport_time = pl.net_teleport_time;
	pl.viewzoom = pl.net_viewzoom;
	pl.punchangle = pl.net_punchangle;
	//pl.hook.origin = pl.net_hookpos;

	pl.w_attack_next = pl.net_w_attack_next;
	pl.w_idle_next = pl.net_w_idle_next;
	pl.a_ammo1 = pl.net_ammo1;
	pl.a_ammo2 = pl.net_ammo2;
	pl.a_ammo3 = pl.net_ammo3;

	pl.weapontime = pl.net_weapontime;

	//self.pmove_flags = self.netpmove_flags;
	setorigin(pl, pl.origin);
	//self.pmove_frame = servercommandframe + 1;
}
