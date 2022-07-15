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

/* distance after which we take damage */
#ifndef PHY_FALLDMG_DISTANCE
	#define PHY_FALLDMG_DISTANCE 580
#endif

/* distance after which we'll receive 100 damage */
#ifndef PHY_FALLDMG_MAXDISTANCE
	#define PHY_FALLDMG_MAXDISTANCE 1024
#endif

#ifndef PHY_FALL_DISTANCE
	#define PHY_FALL_DISTANCE 400
#endif

#ifndef PHY_FALLDMG_TYPE
	#define PHY_FALLDMG_TYPE 1
#endif

#ifndef PHY_JUMP_HEIGHT
	#define PHY_JUMP_HEIGHT 240
#endif

#ifndef PHY_WATERJUMP_HEIGHT
	#define PHY_WATERJUMP_HEIGHT 350
#endif

#ifndef PHY_DIVESPEED_WATER
	#define PHY_DIVESPEED_WATER 100
#endif

#ifndef PHY_DIVESPEED_SLIME
	#define PHY_DIVESPEED_SLIME 80
#endif

#ifndef PHY_DIVESPEED_LAVA
	#define PHY_DIVESPEED_LAVA 50
#endif

void
NSClientPlayer::Physics_Fall(float flDownforce)
{
	/* apply some predicted punch to the player */
	if (flDownforce >= PHY_FALLDMG_DISTANCE)
		punchangle += [15,0,(input_sequence & 1) ? 15 : -15];
	else if (flDownforce >= PHY_FALL_DISTANCE)
		punchangle += [15,0,0];

	/* basic server-side falldamage */
#ifdef SERVER
	/* if we've reached a fallheight of PHY_FALLDMG_DISTANCE qu, start applying damage */
	if (flDownforce >= PHY_FALLDMG_DISTANCE) {
		float fFallDamage;

		/* 0 = basic quake style, 1 = 'realistic' HL style */
		if (PHY_FALLDMG_TYPE == 0)
			fFallDamage = 10;
		else if (PHY_FALLDMG_TYPE == 1) {
			/* distance of A to B decides how much of 100 HP dmg we get*/
			float flFallDist = PHY_FALLDMG_DISTANCE;
			float flMaxDist = PHY_FALLDMG_MAXDISTANCE;
			fFallDamage = (flDownforce - flFallDist) * (100 / (flMaxDist - flFallDist));
		}

		Damage_Apply(this, world, fFallDamage, 0, DMG_FALL | DMG_SKIP_ARMOR);
		Sound_Play(this, CHAN_VOICE, "player.fall");
	} else if (flDownforce >= PHY_FALL_DISTANCE) {
		Sound_Play(this, CHAN_VOICE, "player.lightfall");
	}
#endif
}

void
NSClientPlayer::Physics_Crouch(void)
{
	bool crouchfix = false;

	if (input_buttons & INPUT_BUTTON8) {
		AddFlags(FL_CROUCHING);
	} else {
		/* if we aren't holding down duck anymore and 'attempt' to stand up, prevent it */
		if (GetFlags() & FL_CROUCHING) {
			vector vecTest = [0, 0, PHY_HULL_MAX[2]];
			if (PMove_IsStuck(this, vecTest, PHY_HULL_MIN, PHY_HULL_MAX) == FALSE) {
				RemoveFlags(FL_CROUCHING);
				crouchfix = true;
			}
		} else {
			RemoveFlags(FL_CROUCHING);
		}
	}

	if (GetFlags() & FL_CROUCHING) {
		SetSize(PHY_HULL_CROUCHED_MIN, PHY_HULL_CROUCHED_MAX);
		view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		SetSize(PHY_HULL_MIN, PHY_HULL_MAX);

		if (crouchfix == true && PMove_IsStuck(this, [0,0,0], PHY_HULL_MIN, PHY_HULL_MAX)) {
			/* check if we can get unstuck by testing up to a few units up */
			for (int i = 0; i < 36; i++) {
				origin[2] += 1;
				if (PMove_IsStuck(this, [0,0,0], mins, maxs) == FALSE) {
					break;
				}
			}
		}
		SetOrigin(origin);
		view_ofs = PHY_VIEWPOS;
	}
}


void
NSClientPlayer::Physics_Jump(void)
{
	/* we're underwater... */
	if (WaterLevel() >= 2) {
		/* different water contents allow for different speeds */
		if (WaterLevel() == CONTENT_WATER)
			velocity[2] = PHY_DIVESPEED_WATER;
		else if (WaterLevel() == CONTENT_SLIME)
			velocity[2] = PHY_DIVESPEED_SLIME;
		else
			velocity[2] = PHY_DIVESPEED_LAVA;
	} else {
		/* standard jump here */
		if (GetFlags() & FL_ONGROUND)
			velocity[2] += PHY_JUMP_HEIGHT;
	}
}

/* check if we're elligible to jump */
void
NSClientPlayer::Physics_CheckJump(float premove)
{
	/* unset jump-key whenever it's not set */
	if (!(input_buttons & INPUT_BUTTON2)) {
		AddFlags(FL_JUMPRELEASED);
		return;
	}

	if (GetFlags() & FL_WATERJUMP)
		return;
	if (!(GetFlags() & FL_ONGROUND))
		return;

	/* if a player wants to be able to hold jump, let them */
	if (!(infokey(this, "autojump") == "1"))
	if (!(GetFlags() & FL_JUMPRELEASED))
		return;

	if (input_buttons & INPUT_BUTTON2 && premove) {
		if (velocity[2] < 0) {
			velocity[2] = 0;
		}

		Physics_Jump();
		RemoveFlags(FL_ONGROUND);
		RemoveFlags(FL_JUMPRELEASED);
	}
}

/* establish the right size and camera position */
void
NSClientPlayer::Physics_SetViewParms(void)
{
	if (GetFlags() & FL_CROUCHING) {
		mins = PHY_HULL_CROUCHED_MIN;
		maxs = PHY_HULL_CROUCHED_MAX;
		view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		mins = PHY_HULL_MIN;
		maxs = PHY_HULL_MAX;
		view_ofs = PHY_VIEWPOS;
	}

	SetSize(mins, maxs);
}

void
NSClientPlayer::Physics_WaterJump(void)
{
	vector vecStart;

	/* bit above waist height */
	vecStart = GetOrigin();
	vecStart[2] += 8;

	/* look 24 qu ahead for a surface */
	makevectors(v_angle);
	traceline(vecStart, vecStart + (v_forward * 24), MOVE_NORMAL, this);

	/* we've hit a surface */
	if (trace_fraction < 1.0) {
		/* let's check if we can potentially climb up */
		vecStart[2] += maxs[2];
		traceline(vecStart, vecStart + (v_forward * 24), MOVE_NORMAL, this);

		/* there's nothing preventing us from putting our hands up here */
		if (trace_fraction == 1.0) {
			velocity[2] = PHY_WATERJUMP_HEIGHT;
			AddFlags(FL_WATERJUMP);
			RemoveFlags(FL_JUMPRELEASED);
			return;
		}
	}
}

/* handle your time underwater */
void
NSClientPlayer::Physics_WaterMove(void)
{
	if (GetMovetype() == MOVETYPE_NOCLIP) {
		return;
	}

#ifdef SERVER
	if (GetHealth() < 0) {
		return;
	}

	/* we've just exited water */
	if (WaterLevel() != 3) {
		if (m_flUnderwaterTime < time) {
			Sound_Play(this, CHAN_BODY, "player.gasplight");
		} else if (m_flUnderwaterTime < time + 9) {
			Sound_Play(this, CHAN_BODY, "player.gaspheavy");
		}
		m_flUnderwaterTime = time + 12;
	} else if (m_flUnderwaterTime < time) {
		/* we've been underwater... for too long. */
		if (m_flPainTime < time) {
			Damage_Apply(this, world, 5, 0, DMG_DROWN);
			m_flPainTime = time + 1;
		}
	}
#endif

	if (!WaterLevel()){
		if (GetFlags() & FL_INWATER) {
#ifdef SERVER
			Sound_Play(this, CHAN_BODY, "player.waterexit");
#endif
			RemoveFlags(FL_INWATER);
		}
		return;
	}

#ifdef SERVER
	if (WaterLevel() == CONTENT_LAVA) {
		if (m_flPainTime < time) {
			Damage_Apply(this, world, 10 * WaterLevel(), 0, DMG_BURN);
			m_flPainTime = time + 0.2;
		}
	} else if (WaterLevel() == CONTENT_SLIME) {
		if (m_flPainTime < time) {
			Damage_Apply(this, world, 4 * WaterLevel(), 0, DMG_ACID);
			m_flPainTime = time + 1;
		}
	}
#endif

	if (!(GetFlags() & FL_INWATER)) {
#ifdef SERVER
		Sound_Play(this, CHAN_BODY, "player.waterenter");
		m_flPainTime = 0;
#endif
		AddFlags(FL_INWATER);
	}

	/* we might need to apply extra-velocity to get out of water-volumes */
	if (WaterLevel() >= 2) {
		Physics_WaterJump();
	}
}

float
NSClientPlayer::Physics_MaxSpeed(void)
{
	return (GetFlags() & FL_CROUCHING) ? 135 : 270;
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

	RemoveFlags(FL_FROZEN);
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

	RemoveFlags(FL_ONUSABLE);
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
