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

/*
=================
Predict_PreFrame

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on 
(so any non-networked state updates locally).
=================
*/
void
Predict_PreFrame(player pl)
{
	/* base player attributes/fields we're going to roll back */
	pl.net_origin = pl.origin;
	pl.net_velocity = pl.velocity;
	pl.net_flags = pl.flags;
	pl.net_gflags = pl.gflags;
	pl.net_jumptime = pl.jumptime;
	pl.net_teleport_time = pl.teleport_time;
	pl.net_viewzoom = pl.viewzoom;
	pl.net_punchangle = pl.punchangle;
	pl.net_w_attack_next = pl.w_attack_next;
	pl.net_w_idle_next = pl.w_idle_next;
	pl.net_weapontime = pl.weapontime;

	/* this is where a game/mod would decide to add more prediction rollback
	 * information. */
	pl.PredictPreFrame();

	/* run physics code for all the input frames which we've not heard back
	 * from yet. This continues on in Player_ReceiveEntity! */
	for (int i = pl.sequence + 1; i <= clientcommandframe; i++) {
		float flSuccess = getinputstate(i);
		if (flSuccess == FALSE) {
			continue;
		}

		if (i==clientcommandframe){
			CSQC_Input_Frame();
		}

		/* don't do partial frames, aka incomplete input packets */
		if (input_timelength == 0) {
			break;
		}

		/* this global is for our shared random number seed */
		input_sequence = i;

		/* run our custom physics */
		PMove_Run();
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
void
Predict_PostFrame(player pl)
{
	/* finally roll the values back */
	pl.origin = pl.net_origin;
	pl.velocity = pl.net_velocity;
	pl.flags = pl.net_flags;
	pl.gflags = pl.net_gflags;
	pl.jumptime = pl.net_jumptime;
	pl.teleport_time = pl.net_teleport_time;
	pl.viewzoom = pl.net_viewzoom;
	pl.punchangle = pl.net_punchangle;
	pl.w_attack_next = pl.net_w_attack_next;
	pl.w_idle_next = pl.net_w_idle_next;
	pl.weapontime = pl.net_weapontime;

	/* give the game/mod a chance to roll back its values too */
	pl.PredictPostFrame();

	/* update bounds */
	setorigin(pl, pl.origin);
}
