/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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
		StartSoundDef("Player.FallDamage", CHAN_VOICE, true);
	} else if (flDownforce >= PHY_FALL_DISTANCE) {
		StartSoundDef("Player.LightFall", CHAN_VOICE, true);
	}
#endif
}

void
NSClientPlayer::Physics_Crouch(void)
{
	bool crouchFix = false;
	vector testOrigin = origin;
	vector testMins = g_vec_null;
	vector testMaxs = g_vec_null;
	bool stateChanged = false;

	if (GetMovetype() != MOVETYPE_WALK)
		return;

	if (CanCrouch() && input_buttons & INPUT_CROUCH) {
		if (!IsCrouching()) {
			testMins = g_pmoveVars.GetCrouchMins();
			testMaxs = g_pmoveVars.GetCrouchMaxs();

			if (PMove_IsStuck(this, origin, testMins, testMaxs) == false) {
				AddVFlags(VFL_CROUCHING);
				stateChanged = true;
				/*printf("Now crouch.\n");*/
			}
		}
	} else {
		/* if we aren't ducking any longer, attempt to stand up */
		if (IsCrouching()) {
			/*printf("No longer crouch.\n");*/

			/* if they're going prone mode, we'll have to test that */
			if (input_buttons & INPUT_PRONE) {
				testMins = g_pmoveVars.GetProneMins();
				testMaxs = g_pmoveVars.GetProneMaxs();
				/*printf("Want to prone.\n");*/
			} else {
				testMins = g_pmoveVars.GetStandingMins();
				testMaxs = g_pmoveVars.GetStandingMaxs();
				/*printf("Want to stand.\n");*/
			}

			testOrigin[2] = (origin[2] + mins[2]) - testMins[2];

			/* will we fit here? if not, don't remove the CROUCH flag */
			if (PMove_IsStuck(this, testOrigin, testMins, testMaxs) == false) {
				RemoveVFlags(VFL_CROUCHING);
				stateChanged = true;
				/*printf("Fill fit.\n");*/
			} else if (PMove_IsStuck(this, testOrigin + [0,0,18], testMins, testMaxs) == false) {
				RemoveVFlags(VFL_CROUCHING);
				stateChanged = true;
				crouchFix = true;
				/*printf("Fill have to nudge up to 18 units.\n");*/
			}
		}
	}
	/* state didn't change, don't update size */
	if (!stateChanged)
		return;

	if (IsCrouching()) {
		mins = g_pmoveVars.GetCrouchMins();
		maxs = g_pmoveVars.GetCrouchMaxs();
		/*printf("State change finished.\n");*/
	} else {
		mins = testMins;
		maxs = testMaxs;

		if (crouchFix == true && PMove_IsStuck(this, testOrigin, testMins, testMaxs)) {
			/* check if we can get unstuck by testing up to a few units up */
			for (int i = 0; i < 18; i++) {
				if (PMove_IsStuck(this, testOrigin, testMins, testMaxs) == false) {
					/*printf("State change finished after %i units.\n", i);*/
					break;
				}
				testOrigin[2] += 1;
			}
		}
		SetOrigin(testOrigin);
	}
}

void
NSClientPlayer::Physics_Prone(void)
{
	bool proneFix = false;
	vector testOrigin = origin;
	vector testMins = g_vec_null;
	vector testMaxs = g_vec_null;
	bool stateChanged = false;

	if (GetMovetype() != MOVETYPE_WALK)
		return;

	if (CanProne() && input_buttons & INPUT_PRONE) {
		if (!IsProne()) {
			testMins = g_pmoveVars.GetProneMins();
			testMaxs = g_pmoveVars.GetProneMaxs();

			if (PMove_IsStuck(this, origin, testMins, testMaxs) == false) {
				AddVFlags(VFL_PRONE);
				stateChanged = true;
				/*printf("Now prone.\n");*/
			}
		}
	} else {
		/* if we aren't holding down duck anymore and 'attempt' to stand up, prevent it */
		if (IsProne()) {
			/*printf("No longer prone.\n");*/

			/* if they're going prone mode, we'll have to test that */
			if (input_buttons & INPUT_CROUCH) {
				testMins = g_pmoveVars.GetCrouchMins();
				testMaxs = g_pmoveVars.GetCrouchMaxs();
				/*printf("Want to crouch.\n");*/
			} else {
				testMins = g_pmoveVars.GetStandingMins();
				testMaxs = g_pmoveVars.GetStandingMaxs();
				/*printf("Want to stand.\n");*/
			}

			testOrigin[2] = (origin[2] + mins[2]) - testMins[2];

			/* will we fit? */
			if (PMove_IsStuck(this, testOrigin, testMins, testMaxs) == false) {
				RemoveVFlags(VFL_PRONE);
				stateChanged = true;
				/*printf("Will fit.\n");*/
			} else if (PMove_IsStuck(this, testOrigin + [0, 0, 18], testMins, testMaxs) == false) {
				RemoveVFlags(VFL_PRONE);
				proneFix = true;
				stateChanged = true;
				/*printf("Fill have to nudge up to 18 units.\n");*/
			}
		}
	}

	/* prevent expensive operations. */
	if (!stateChanged)
		return;

	if (IsProne()) {
		mins = g_pmoveVars.GetProneMins();
		maxs = g_pmoveVars.GetProneMaxs();
		/*printf("State change finished.\n");*/
	} else {
		mins = testMins;
		maxs = testMaxs;
		origin = testOrigin;

		if (proneFix == true && PMove_IsStuck(this, origin, mins, maxs)) {
			/* check if we can get unstuck by testing up to a few units up */
			for (int i = 1; i < 18; i++) {
				if (PMove_IsStuck(this, origin, mins, maxs) == false) {
					/*printf("State change finished after %i units.\n", i);*/
					break;
				}
				origin[2] += 1;
			}
		}
		SetOrigin(origin);
	}
}


void
NSClientPlayer::Physics_Jump(void)
{
	if (GetMovetype() != MOVETYPE_WALK)
		return;

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
			velocity[2] += g_pmoveVars.pm_jumpheight;
	}
}

/* check if we're elligible to jump */
void
NSClientPlayer::Physics_CheckJump(float premove)
{
	/* unset jump-key whenever it's not set */
	if (!(input_buttons & INPUT_JUMP)) {
		AddFlags(FL_JUMPRELEASED);
		return;
	}

	if (GetFlags() & FL_WATERJUMP)
		return;
	if (!(GetFlags() & FL_ONGROUND))
		return;

	/* if a player wants to be able to hold jump, let them */
	if (!(infokey(this, "autojump") == "1"))
		if (HasFlags(FL_JUMPRELEASED) == false)
			return;

	if (input_buttons & INPUT_JUMP && premove) {
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
	/* cheap operations */
	if (IsCrouching()) {
		view_ofs = g_pmoveVars.GetCrouchViewOffset();
	} else if (IsProne()) {
		view_ofs = g_pmoveVars.GetProneViewOffset();
	} else {
		view_ofs = g_pmoveVars.GetStandingViewOffset();
	}
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
			velocity[2] = g_pmoveVars.pm_waterjumpheight;
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

	if (WaterLevel() > 0) {
	if (watertype == CONTENT_LAVA) {
		if (m_flPainTime < time) {
			Damage_Apply(this, world, 10 * WaterLevel(), 0, DMG_BURN);
			m_flPainTime = time + 0.2;
		}
	} else if (watertype == CONTENT_SLIME) {
		if (m_flPainTime < time) {
			Damage_Apply(this, world, 4 * WaterLevel(), 0, DMG_ACID);
			m_flPainTime = time + 1;
		}
	}
	}

	/* we've just exited water */
	if (WaterLevel() != 3) {
		if (m_flUnderwaterTime < time) {
			StartSoundDef("Player.GaspHeavy", CHAN_BODY, true);
		} else if (m_flUnderwaterTime < time + 9) {
			StartSoundDef("Player.GaspLight", CHAN_BODY, true);
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
			StartSoundDef("Player.WaterExit", CHAN_BODY, true);
#endif
			RemoveFlags(FL_INWATER);
		}
		return;
	}

	if (!(GetFlags() & FL_INWATER)) {
#ifdef SERVER
		StartSoundDef("Player.WaterEnter", CHAN_BODY, true);
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
	float wishSpeed = 0.0f;
	float runSpeed = g_pmoveVars.pm_runspeed;
	float maxStamina = g_pmoveVars.pm_stamina;
	float crouchSpeed = g_pmoveVars.pm_crouchspeed;
	float walkSpeed = g_pmoveVars.pm_walkspeed;
	float proneSpeed = g_pmoveVars.pm_pronespeed;

	if (CanSprint() && IsSprinting()) {
		if (m_flStamina < maxStamina) {
			float slowDownThresh = g_pmoveVars.pm_staminathreshold;

			if ((m_flStamina + slowDownThresh) > maxStamina) {
				float delta = (m_flStamina + slowDownThresh) - maxStamina;
				/* change maxValue to something between 1.0 and 1.5 */
				runSpeed = lerp(runSpeed, walkSpeed, delta/slowDownThresh);
			}
		} 

		wishSpeed = runSpeed;
	} else if (IsCrouching()) {
		wishSpeed = crouchSpeed;
	} else if (IsProne()) {
		wishSpeed = proneSpeed;
	} else {
		wishSpeed = walkSpeed;
	}

	return wishSpeed;
}

void
NSClientPlayer::Physics_InputPreMove(void)
{
	NSVehicle currentVehicle = (NSVehicle)vehicle;
	bool canMove = true;
	bool canFire = true;

	/* find all the valid ways to freeze a player... */
	if (currentVehicle) {
		if (currentVehicle.PreventPlayerMovement() == true)
			canMove = false;
	}

	if (vv_flags & VFL_FROZEN || movetype == MOVETYPE_NONE) {
		canMove = false;
	}

	/* freeze in place */
	if (canMove == false) {
		input_movevalues = [0,0,0];
		input_buttons &= ~INPUT_JUMP;
	}

	/* freeze in place */
	if (vv_flags & VFL_NOATTACK) {
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons &= ~INPUT_RELOAD;
	}

	/* when pressing the 'use' button, we also walk slower for precision */
	if (input_buttons & INPUT_USE) {
		input_movevalues *= 0.5;
	}

	/* clamp movement values to max speed */
	{
		float wishSpeed = vlen(input_movevalues);

		if (wishSpeed > maxspeed) {
			wishSpeed = maxspeed;
		}

		input_movevalues = normalize(input_movevalues) * wishSpeed;
	}

	/* suppress crouching in vehicles */
	if (currentVehicle) {
		if (currentVehicle.CanDriverCrouch() == false) {
			input_buttons &= ~INPUT_CROUCH;
			input_buttons &= ~INPUT_PRONE;
		}
	}
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

	if (input_buttons & INPUT_SPRINT) {
		m_flStamina += input_timelength;
	} else {
		float toSubtract = input_timelength;
		toSubtract *= g_pmoveVars.pm_staminarate;
		m_flStamina = max(0, m_flStamina - toSubtract);
	}

	if (m_flStamina > g_pmoveVars.pm_stamina) {
		m_flStamina = g_pmoveVars.pm_stamina;
	}

	//printf("stamina: %f\n", m_flStamina);

	punch = max(0, 1.0f - (input_timelength * 4));
	punchangle[0] *= punch;
	punchangle[1] *= punch;
	punchangle[2] *= punch;

	/* player animation code */
	UpdatePlayerAnimation(input_timelength);
	ProcessInput();
}

/* the main physics routine, the head */
void
NSClientPlayer::Physics_Run(void)
{
	float flFallVel = (flags & FL_ONGROUND) ? 0 : -velocity[2];
	float flBaseVel =  basevelocity[2];
	bool wasOnGround = (flags & FL_ONGROUND) ? true : false;
	bool sprintFail = false;

	saved_input_movevalues = input_movevalues;
	saved_input_buttons = input_buttons;

	sprintFail = ((input_buttons & INPUT_CROUCH) || (input_buttons & INPUT_PRONE)) ? true : false;

	if (input_buttons & INPUT_SPRINT && sprintFail == false) {
		AddVFlags(VFL_SPRINTING);
	} else {
		RemoveVFlags(VFL_SPRINTING);
	}

	/* maxspeed changes when crouching, TODO: make this game-specific */
	maxspeed = Physics_MaxSpeed();

	/* give us a chance to manipulate input_ globals before running physics */
	Physics_InputPreMove();

	/* handle footsteps */
	Footsteps_Update();

	/* handle drowning and other environmental factors */
	Physics_WaterMove();

	/* grappling hook stuff, TODO: variable speeds */
	if (grapvelocity != g_vec_null) {
		velocity = (grapvelocity - origin);
		velocity = (velocity * (1 / (vlen(velocity) / 750)));
	}

	Physics_SetViewParms();

	Physics_Crouch();
	Physics_Prone();
	Physics_CheckJump(TRUE);

#ifdef CUSTOMPLAYERPHYSICS
	/* QuakeC powered physics (slow, but more customizable) */
	PMoveCustom_RunPlayerPhysics(this);
#else
	/* fast engine-side player physics */
	runstandardplayerphysics(this);
#endif

	Physics_CheckJump(FALSE);

	if (wasOnGround == false && (flags & FL_ONGROUND)) {
		if (waterlevel != 0) {
			flFallVel = 0;
		}
		Physics_Fall(flFallVel - flBaseVel);
	}

	input_movevalues = saved_input_movevalues;
	input_buttons = saved_input_buttons;
	Physics_InputPostMove();
	angles = fixAngle(angles);

#ifdef SERVER
	/* Use Flagger */
	vector src, dest;
	makevectors(input_angles);
	src = origin + view_ofs;
	dest = src + v_forward * 64;
	traceline(src, dest, MOVE_NORMAL, this);
	RemoveVFlags(VFL_ONUSABLE);

	if (trace_ent.identity == 1) {
		NSEntity foo = (NSEntity)trace_ent;

		if (foo.PlayerUse) {
			AddVFlags(VFL_ONUSABLE);
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
