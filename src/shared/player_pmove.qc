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
ncPlayer::Physics_Fall(float flDownforce)
{
	float minFallDistance = g_fallDamageDecl.GetFloat("minFallDistance");
	float maxFallDistance = g_fallDamageDecl.GetFloat("maxFallDistance");
	float minLandDistance = g_fallDamageDecl.GetFloat("minLandDistance");
	float punchAngleScale = g_fallDamageDecl.GetFloat("punchAngleScale");
	float punchSpringScale = g_fallDamageDecl.GetFloat("punchSpringScale");
	int fixedDamage = g_fallDamageDecl.GetInteger("damage");

	if (punchAngleScale > 0.0f) {
		/* apply some predicted punch to the player */
		if (flDownforce >= minFallDistance)
			m_punchAngle += [punchAngleScale,0,(input_sequence & 1) ? punchAngleScale : -punchAngleScale];
		else if (flDownforce >= minLandDistance)
			m_punchAngle += [punchAngleScale,0,0];
	} else if (punchSpringScale > 0.0f) {
		/* apply some predicted punch to the player */
		if (flDownforce >= minFallDistance)
			m_punchVelocity += [punchSpringScale,0,(input_sequence & 1) ? punchSpringScale : -punchSpringScale];
		else if (flDownforce >= minLandDistance)
			m_punchVelocity += [punchSpringScale,0,0];
	}


	/* basic server-side falldamage */
#ifdef SERVER
	/* if we've reached a fallheight of minFallDistance qu, start applying damage */
	if (flDownforce >= minFallDistance) {
		float finalDamage;

		if (fixedDamage != 0i) {
			finalDamage = fixedDamage;
		} else {
			/* distance of A to B decides how much of 100 HP dmg we get*/
			finalDamage = (flDownforce - minFallDistance) * (100 / (maxFallDistance - minFallDistance));
		}

		ncDict damageDecl = spawn(ncDict);
		damageDecl.AddKey("damage", itos((int)finalDamage));
		damageDecl.AddKey("noArmor", "1");
		Damage(this, world, damageDecl, 1.0, g_vec_null, GetOrigin() + [0,0, mins[2]]);
		remove(damageDecl);

		//Damage_Apply(this, world, fFallDamage, 0, DMG_FALL | DMG_SKIP_ARMOR);
		StartSoundDef(m_sndFall, CHAN_VOICE, true);
	} else if (flDownforce >= minLandDistance) {
		StartSoundDef(m_sndLandHard, CHAN_VOICE, true);
	} else {
		StartSoundDef(m_sndLandSoft, CHAN_VOICE, true);
	}
#endif
}

void
ncPlayer::Physics_Crouch(void)
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
			testMins = m_pmoveVars.GetCrouchMins();
			testMaxs = m_pmoveVars.GetCrouchMaxs();

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
				testMins = m_pmoveVars.GetProneMins();
				testMaxs = m_pmoveVars.GetProneMaxs();
				/*printf("Want to prone.\n");*/
			} else {
				testMins = m_pmoveVars.GetStandingMins();
				testMaxs = m_pmoveVars.GetStandingMaxs();
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
		mins = m_pmoveVars.GetCrouchMins();
		maxs = m_pmoveVars.GetCrouchMaxs();
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
ncPlayer::Physics_Prone(void)
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
			testMins = m_pmoveVars.GetProneMins();
			testMaxs = m_pmoveVars.GetProneMaxs();

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
				testMins = m_pmoveVars.GetCrouchMins();
				testMaxs = m_pmoveVars.GetCrouchMaxs();
				/*printf("Want to crouch.\n");*/
			} else {
				testMins = m_pmoveVars.GetStandingMins();
				testMaxs = m_pmoveVars.GetStandingMaxs();
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
		mins = m_pmoveVars.GetProneMins();
		maxs = m_pmoveVars.GetProneMaxs();
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
ncPlayer::Physics_Jump(void)
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
			velocity[2] += m_pmoveVars.pm_jumpheight;
	}
}

/* check if we're elligible to jump */
void
ncPlayer::Physics_CheckJump(float premove)
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
ncPlayer::Physics_SetViewParms(void)
{
	/* cheap operations */
	if (IsCrouching()) {
		view_ofs = m_pmoveVars.GetCrouchViewOffset();
	} else if (IsProne()) {
		view_ofs = m_pmoveVars.GetProneViewOffset();
	} else {
		view_ofs = m_pmoveVars.GetStandingViewOffset();
	}
}

void
ncPlayer::Physics_WaterJump(void)
{
	vector vecStart;

	/* bit above waist height */
	vecStart = GetOrigin();
	vecStart[2] += 8;

	/* look 24 qu ahead for a surface */
	traceline(vecStart, vecStart + (anglesToForward(v_angle) * 24), MOVE_NORMAL, this);

	/* we've hit a surface */
	if (trace_fraction < 1.0) {
		/* let's check if we can potentially climb up */
		vecStart[2] += maxs[2];
		traceline(vecStart, vecStart + (anglesToForward(v_angle) * 24), MOVE_NORMAL, this);

		/* there's nothing preventing us from putting our hands up here */
		if (trace_fraction == 1.0) {
			velocity[2] = m_pmoveVars.pm_waterjumpheight;
			AddFlags(FL_WATERJUMP);
			RemoveFlags(FL_JUMPRELEASED);
			return;
		}
	}
}

/* handle your time underwater */
void
ncPlayer::Physics_WaterMove(void)
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
			if (m_timeUntilNextPainSFX < time) {
				Damage(world, world, g_lavaDamageDecl, 1.0f, g_vec_null, GetOrigin());
				m_timeUntilNextPainSFX = time + g_lavaDecl.GetFloat("dmgtime");
			}
		} else if (watertype == CONTENT_SLIME) {
			if (m_timeUntilNextPainSFX < time) {
				Damage(world, world, g_slimeDamageDecl, 1.0f, g_vec_null, GetOrigin());
				m_timeUntilNextPainSFX = time + g_slimeDecl.GetFloat("dmgtime");
			}
		}
	}

	/* we've just exited water */
	if (WaterLevel() != 3) {
		if (m_timeUnderwater < time) {
#warning Read sound from player decl
			StartSoundDef(m_sndAirGaspHeavy, CHAN_BODY, true);
		} else if (m_timeUnderwater < time + 9) {
			StartSoundDef(m_sndAirGaspLight, CHAN_BODY, true);
		}
#warning Read lung capacity for water from typeInfo water
		m_timeUnderwater = time + 12;
	} else if (m_timeUnderwater < time) {
		/* we've been underwater... for too long. */
		if (m_timeUntilNextPainSFX < time) {
			Damage(world, world, g_waterDamageDecl, 1.0f, g_vec_null, GetOrigin());
			m_timeUntilNextPainSFX = time + g_waterDecl.GetFloat("dmgtime");
		}
	}
#endif



	if (!WaterLevel()){
		if (GetFlags() & FL_INWATER) {
#ifdef SERVER
			StartSoundDef(m_sndWaterExit, CHAN_BODY, true);
#endif
			RemoveFlags(FL_INWATER);
		}
		return;
	}

	if (!(GetFlags() & FL_INWATER)) {
#ifdef SERVER
		StartSoundDef(m_sndWaterEnter, CHAN_BODY, true);
		m_timeUntilNextPainSFX = 0;
#endif
		AddFlags(FL_INWATER);
	}

	/* we might need to apply extra-velocity to get out of water-volumes */
	if (WaterLevel() >= 2) {
		Physics_WaterJump();
	}
}

float
ncPlayer::Physics_MaxSpeed(void)
{
	float wishSpeed = 0.0f;
	float runSpeed = m_pmoveVars.pm_runspeed;
	float maxStamina = m_pmoveVars.pm_stamina;
	float crouchSpeed = m_pmoveVars.pm_crouchspeed;
	float walkSpeed = m_pmoveVars.pm_walkspeed;
	float proneSpeed = m_pmoveVars.pm_pronespeed;
	float speedMod = 1.0f;

	if (m_activeWeapon) {
		speedMod = m_activeWeapon.PlayerSpeedMod();
	}

	if (CanSprint() && IsSprinting()) {
		if (m_currentStamina < maxStamina) {
			float slowDownThresh = m_pmoveVars.pm_staminathreshold;

			if ((m_currentStamina + slowDownThresh) > maxStamina) {
				float delta = (m_currentStamina + slowDownThresh) - maxStamina;
				/* change maxValue to something between 1.0 and 1.5 */
				runSpeed = lerp(runSpeed, walkSpeed, delta/slowDownThresh);
			}
		}

		wishSpeed = (m_currentStamina >= maxStamina) ? walkSpeed : runSpeed;
	} else if (IsCrouching()) {
		wishSpeed = crouchSpeed;
	} else if (IsProne()) {
		wishSpeed = proneSpeed;
	} else {
		wishSpeed = walkSpeed;
	}

	return wishSpeed * speedMod;
}

void
ncPlayer::Physics_InputPreMove(void)
{
	bool canMove = true;
	bool canFire = true;

#ifdef CLIENT
	if (vehicle_entnum == 0) {
		vehicle = __NULL__;
	}
	if (activeweapon == 0) {
		m_activeWeapon = __NULL__;
	}
	if (m_itemStart == 0) {
		m_itemList = __NULL__;
	}
#endif

	ncVehicle currentVehicle = (ncVehicle)vehicle;

	/* find all the valid ways to freeze a player... */
	if (currentVehicle) {
		if (currentVehicle.PreventPlayerMovement() == true)
			canMove = false;
	}

	if (m_nuclideFlags & VFL_FROZEN || movetype == MOVETYPE_NONE) {
		canMove = false;
	}

	/* freeze in place */
	if (canMove == false) {
		input_movevalues = [0,0,0];
		input_buttons &= ~INPUT_JUMP;
	}

	/* freeze in place */
	if (m_nuclideFlags & VFL_NOATTACK) {
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons &= ~INPUT_RELOAD;
	}

	/* when pressing the 'use' button, we also walk slower for precision */
	if (input_buttons & INPUT_USE) {
		input_movevalues *= 0.5f;
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
ncPlayer::Physics_InputPostMove(void)
{
	float punch;

	/* timers, these are predicted and shared across client and server */
	m_timeUntilNextAttack = max(0, m_timeUntilNextAttack - input_timelength);
	m_timeUntilReloaded = max(0, m_timeUntilReloaded - input_timelength);
	m_timeUntilNextIdle = max(0, m_timeUntilNextIdle - input_timelength);
	m_weaponAnimTime += input_timelength;

	if (input_buttons & INPUT_SPRINT) {
		m_currentStamina += input_timelength;
	} else {
		float toSubtract = input_timelength;
		toSubtract *= m_pmoveVars.pm_staminarate;
		m_currentStamina = max(0, m_currentStamina - toSubtract);
	}

	if (m_currentStamina > m_pmoveVars.pm_stamina) {
		m_currentStamina = m_pmoveVars.pm_stamina;
	}

	if (m_pmoveVars.pm_runfiring == 0 && input_buttons & INPUT_SPRINT) {
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons &= ~INPUT_SECONDARY;
		input_buttons &= ~INPUT_RELOAD;
	}

	//printf("stamina: %f\n", m_currentStamina);

	float flDamp;
	float flForce;
	if ( vlen( m_punchVelocity ) > 0.001 ) {
		m_punchAngle += m_punchVelocity * input_timelength;

		flForce = bound( 0, input_timelength * 65, 2 );
		flDamp = 1 - ( input_timelength * 9 );

		if ( flDamp < 0 ) {
			flDamp = 0;
		}
		m_punchVelocity *= flDamp;
		m_punchVelocity -= m_punchAngle * flForce;

		m_punchAngle[0] = bound( -89, m_punchAngle[0], 89 );
		m_punchAngle[1] = bound( -179, m_punchAngle[1], 179 );
		m_punchAngle[2] = bound( -89, m_punchAngle[2], 89 );
	} else if (vlen( m_punchAngle ) > 0.001) {

		punch = max(0, 1.0f - (input_timelength * 4));
		m_punchAngle[0] *= punch;
		m_punchAngle[1] *= punch;
		m_punchAngle[2] *= punch;
	}

	/* player animation code */
	UpdatePlayerAnimation(input_timelength);
	ProcessInput();
}

/* the main physics routine, the head */
void
ncPlayer::Physics_Run(void)
{
	float flFallVel = (flags & FL_ONGROUND) ? 0 : -velocity[2];
	float flBaseVel =  m_pmoveBaseVelocity[2];
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

	maxspeed = Physics_MaxSpeed();

#ifdef SERVER
	//printf("SERVER: %v; max: %f; fric: %f; grav: %f\n", input_movevalues, maxspeed, friction, gravity);
#else
	//printf("CLIENT: %v; max: %f; fric: %f; grav: %f\n", input_movevalues, maxspeed, friction, gravity);
#endif

	/* give us a chance to manipulate input_ globals before running physics */
	Physics_InputPreMove();

	/* handle footsteps */
	Footsteps_Update();

	/* handle drowning and other environmental factors */
	Physics_WaterMove();

	/* grappling hook stuff, TODO: variable speeds */
	if (m_pmoveHookVelocity != g_vec_null) {
		velocity = (m_pmoveHookVelocity - origin);
		velocity = (velocity * (1 / (vlen(velocity) / 750)));
	}

	Physics_SetViewParms();

	Physics_Crouch();
	Physics_Prone();
	Physics_CheckJump(TRUE);

	if (autocvar(pm_enginepmove, 0) > 0) {
		/* fast engine-side player physics */
		runstandardplayerphysics(this);
	} else {
		/* QuakeC powered physics (slow, but more customizable) */
		PMoveCustom_RunPlayerPhysics(this);
	}

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
		ncEntity foo = (ncEntity)trace_ent;

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
