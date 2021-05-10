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
Predict_EntityUpdate

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on 
(so any non-networked state updates locally).
=================
*/
void
Predict_EntityUpdate(player pl, float new)
{
	/* this is a new client entity, let's set it up right */
	if (new || self.classname != "player") {
		spawnfunc_player();
		pl.classname = "player";
		
		if (pl.entnum == player_localentnum) {
			pl.solid = SOLID_SLIDEBOX;
			pl.movetype = MOVETYPE_NONE;
			pl.customphysics = Empty;
		} else {
			/* other players will act like missiles for interpolation purposes */
			pl.solid = SOLID_SLIDEBOX;
			pl.movetype = MOVETYPE_FLY;
			pl.customphysics = __NULL__;
		}

		pl.drawmask = MASK_ENGINE;
		setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
		return;
	}

	/* this is us, so we know about this clients' input_ fields */
	if (pl.entnum == player_localentnum) {
		/* run the player physics from the last approved servercommandframe to the current one */
		for (int i = pl.sequence+1; i <= servercommandframe; i++) {
			/* ...maybe the input state is too old? */
			if (!getinputstate(i)) {
				break;
			}
			input_sequence = i;
			PMove_Run();
		}
	}
	
}

/*
=================
Predict_PreFrame

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on 
(so any non-networked state updates locally).
=================
*/
void
Predict_PlayerPreFrame(player pl)
{
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
Predict_PlayerPostFrame(player pl)
{
	/* give the game/mod a chance to roll back its values too */
	pl.PredictPostFrame();

	/* update bounds */
	setorigin(pl, pl.origin);
}

/*
=================
Predict_PreFrame

We're part way through parsing new player data.
Propagate our pmove state to whatever the current frame before its stomped on 
(so any non-networked state updates locally).
=================
*/
void
Predict_SpectatorPreFrame(spectator pl)
{	
	pl.PreFrame();
}

/*
=================
Predict_SpectatorPostFrame

We're part way through parsing new player data.
Rewind our pmove state back to before we started predicting. 
(to give consistent state instead of accumulating errors)
=================
*/
void
Predict_SpectatorPostFrame(spectator pl)
{
	pl.PostFrame();
}
