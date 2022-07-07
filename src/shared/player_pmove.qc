/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

vector saved_input_movevalues;
int saved_input_buttons;

void
NSClientPlayer::Physics_Fall(float flDownforce)
{
	if (flDownforce > 580) {
#ifdef SERVER
		float fFallDamage = (flDownforce - 580) * (100 / (1024 - 580));
		Damage_Apply(this, world, fFallDamage, 0, DMG_FALL);
		Sound_Play(this, CHAN_VOICE, "player.fall");
#endif
		punchangle += [15,0,(input_sequence & 1) ? 15 : -15];
	} else if (flDownforce > 400) {
		punchangle += [15,0,0];
#ifdef SERVER
		Sound_Play(this, CHAN_VOICE, "player.lightfall");
#endif
	}
}

void
NSClientPlayer::Physics_Crouch(void)
{
	int iFixCrouch = FALSE;
	if (input_buttons & INPUT_BUTTON8) {
		flags |= FL_CROUCHING;
	} else {
		// If we aren't holding down duck anymore and 'attempt' to stand up, prevent it
		if (flags & FL_CROUCHING) {
			if (PMove_IsStuck(this, [0,0,36], PHY_HULL_MIN, PHY_HULL_MAX) == FALSE) {
				flags &= ~FL_CROUCHING;
				iFixCrouch = TRUE;
			}
		} else {
			flags &= ~FL_CROUCHING;
		}
	}

	if (flags & FL_CROUCHING) {
		setsize(this, PHY_HULL_CROUCHED_MIN, PHY_HULL_CROUCHED_MAX);
		view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		setsize(this, PHY_HULL_MIN, PHY_HULL_MAX);
		if (iFixCrouch && PMove_IsStuck(this, [0,0,0], PHY_HULL_MIN, PHY_HULL_MAX)) {
			for (int i = 0; i < 36; i++) {
				origin[2] += 1;
				if (PMove_IsStuck(this, [0,0,0], mins, maxs) == FALSE) {
					break;
				}
			}
		}
		setorigin(this, origin);
		view_ofs = PHY_VIEWPOS;
	}
}


void
NSClientPlayer::Physics_Jump(void)
{
	/* climb out of substances when underwater */
	if (waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		if (flags & FL_ONGROUND)
			velocity[2] += 240;
	}
}

/* check if we're elligible to jump */
void
NSClientPlayer::Physics_CheckJump(float premove)
{
	/* unset jump-key whenever it's not set */
	if (!(input_buttons & INPUT_BUTTON2)) {
		flags |= FL_JUMPRELEASED;
		return;
	}

	if (flags & FL_WATERJUMP)
		return;
	if (!(flags & FL_ONGROUND))
		return;

	if (!(infokey(this, "autojump") == "1"))
	if (!(flags & FL_JUMPRELEASED))
		return;

	if (input_buttons & INPUT_BUTTON2 && premove) {
		if (velocity[2] < 0) {
			velocity[2] = 0;
		}

		Physics_Jump();
		flags &= ~FL_ONGROUND;
		flags &= ~FL_JUMPRELEASED;
	}
}

/* establish the right size and camera position */
void
NSClientPlayer::Physics_SetViewParms(void)
{
	if (flags & FL_CROUCHING) {
		mins = PHY_HULL_CROUCHED_MIN;
		maxs = PHY_HULL_CROUCHED_MAX;
		view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		mins = PHY_HULL_MIN;
		maxs = PHY_HULL_MAX;
		view_ofs = PHY_VIEWPOS;
	}
	setsize(this, mins, maxs);
}

void
NSClientPlayer::Physics_WaterJump(void)
{
	vector vStart;
	vector vEnd;

	makevectors(angles);
	vStart = origin;
	vStart[2] = vStart[2] + 8; 
	v_forward[2] = 0;
	normalize(v_forward);
	vEnd = vStart + (v_forward * 24);
	traceline(vStart, vEnd, TRUE, this);

	if (trace_fraction < 1) {
		vStart[2] = vStart[2] + maxs[2];
		vEnd = vStart + (v_forward * 24);
		//movedir = trace_plane_normal * -50;
		traceline(vStart, vEnd, TRUE, this);
		
		if (trace_fraction == 1) {
			flags |= FL_WATERJUMP;
			velocity[2] = 350;
			flags &= ~FL_JUMPRELEASED;
			return;
		}
	}
}

/* handle your time underwater */
void
NSClientPlayer::Physics_WaterMove(void)
{
	if (movetype == MOVETYPE_NOCLIP) {
		return;
	}

#ifdef SERVER
	if (health < 0) {
		return;
	}

	/* we've just exited water */
	if (waterlevel != 3) {
		if (underwater_time < time) {
			Sound_Play(this, CHAN_BODY, "player.gasplight");
		} else if (underwater_time < time + 9) {
			Sound_Play(this, CHAN_BODY, "player.gaspheavy");
		}
		underwater_time = time + 12;
	} else if (underwater_time < time) {
		/* we've been underwater... for too long. */
		if (pain_time < time) {
			Damage_Apply(this, world, 5, DMG_DROWN, 0);
			pain_time = time + 1;
		}
	}
#endif

	if (!waterlevel){
		if (flags & FL_INWATER) {
#ifdef SERVER
			Sound_Play(this, CHAN_BODY, "player.waterexit");
#endif
			flags &= ~FL_INWATER;
		}
		return;
	}

#ifdef SERVER
	if (watertype == CONTENT_LAVA) {
		if (pain_time < time) {
			pain_time = time + 0.2;
			Damage_Apply(this, world, 10*waterlevel, DMG_BURN, 0);
		}
	} else if (watertype == CONTENT_SLIME) {
		if (pain_time < time) {
			pain_time = time + 1;
			Damage_Apply(this, world, 4*waterlevel, DMG_ACID, 0);
		}
	}
#endif

	if (!(flags & FL_INWATER)) {
#ifdef SERVER
		Sound_Play(this, CHAN_BODY, "player.waterenter");
		pain_time = 0;
#endif
		flags |= FL_INWATER;
	}

	/* we might need to apply extra-velocity to get out of water-volumes */
	if (waterlevel >= 2) {
		Physics_WaterJump();
	}
}

float
NSClientPlayer::Physics_MaxSpeed(void)
{
	return (flags & FL_CROUCHING) ? 135 : 270;
}

void
NSClientPlayer::Physics_InputPreMove(void)
{
	NSVehicle veh = (NSVehicle)vehicle;

	/* when pressing the 'use' button, we also walk slower for precision */
	if (input_buttons & INPUT_BUTTON5) {
		input_movevalues *= 0.25;
	}

	/* move camera up (noclip, fly) when holding jump */
	if (input_buttons & INPUT_BUTTON2) {
		input_movevalues[2] = 240;
	}
	/* move camera down (noclip, fly) when holding crouching */
	if (input_buttons & INPUT_BUTTON8) {
		input_movevalues[2] = -240;
	}

	if (flags & FL_FROZEN || movetype == MOVETYPE_NONE) {
		input_movevalues = [0,0,0];
		input_buttons &= ~INPUT_BUTTON2;
	}

	/* suppress crouching in vehicles */
	if (veh)
		if (veh.CanDriverCrouch() == false)
			input_buttons &= ~INPUT_BUTTON8;
}

/* timers get processed here after physics are run */
void
NSClientPlayer::Physics_InputPostMove(void)
{
	float punch;
	/* timers, these are predicted and shared across client and server */
	w_attack_next = max(0, w_attack_next - input_timelength);
	w_idle_next = max(0, w_idle_next - input_timelength);
	weapontime += input_timelength;
	punch = max(0, 1.0f - (input_timelength * 4));
	punchangle[0] *= punch;
	punchangle[1] *= punch;
	punchangle[2] *= punch;

	/* player animation code */
	Animation_TimerUpdate((player)this, input_timelength);
	Animation_PlayerUpdate((player)this);

	flags &= ~FL_FROZEN;

	ClientInput();
}

/* the main physics routine, the head */
void
NSClientPlayer::Physics_Run(void)
{
	float flFallVel = (flags & FL_ONGROUND) ? 0 : -velocity[2];

	saved_input_movevalues = input_movevalues;
	saved_input_buttons = input_buttons;

	/* maxspeed changes when crouching, TODO: make this game-specific */
	maxspeed = Physics_MaxSpeed();

	/* give us a chance to manipulate input_ globals before running physics */
	Physics_InputPreMove();

	/* handle drowning and other environmental factors */
	Physics_WaterMove();

	/* grappling hook stuff */
#if 0
	if (pl.hook.skin == 1) {
		pl.velocity = (pl.hook.origin - pl.origin);
		pl.velocity = (pl.velocity * (1 / (vlen(pl.velocity) / 750)));
	}
#endif

	Physics_SetViewParms();

	Physics_Crouch();
	Physics_CheckJump(TRUE);

#ifdef CUSTOMPLAYERPHYSICS
	/* QuakeC powered physics (slow, but more customizable) */
	PMoveCustom_RunPlayerPhysics(this);
#else
	/* fast engine-side player physics */
	runstandardplayerphysics(this);
#endif

	Physics_CheckJump(FALSE);

	if (waterlevel != 0) {
		flFallVel = 0;
	}

	if ((flags & FL_ONGROUND) && movetype == MOVETYPE_WALK) {
		Physics_Fall(flFallVel);
	}

	input_movevalues = saved_input_movevalues;
	input_buttons = saved_input_buttons;
	Physics_InputPostMove();

	angles[0] = Math_FixDelta(angles[0]);
	angles[1] = Math_FixDelta(angles[1]);
	angles[2] = Math_FixDelta(angles[2]);

#ifdef SERVER
	/* Use Flagger */
	vector src, dest;
	makevectors(input_angles);
	src = origin + view_ofs;
	dest = src + v_forward * 64;
	traceline(src, dest, MOVE_NORMAL, this);

	flags &= ~FL_ONUSABLE;
	if (trace_ent.identity == 1) {
		NSEntity foo = (NSEntity)trace_ent;
		if (foo.PlayerUse) {
			flags |= FL_ONUSABLE;
		}
	}

	if (XR_Available(this)) {
		m_xrSpace.SetOrigin(origin);
		m_xrSpace.SetAngles(input_angles);
	} else {
		m_xrSpace.SetOrigin(origin + view_ofs);
		m_xrSpace.SetAngles(input_angles);
	}
#endif
}
