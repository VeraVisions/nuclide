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

void
ncSpectator::ncSpectator(void)
{
	flags |= FL_CLIENT;
	spec_mode = SPECMODE_FREE;
}

#ifdef SERVER
void
ncSpectator::Save(float handle)
{
	super::Save(handle);
}

void
ncSpectator::Restore(string strKey, string strValue)
{
	switch (strKey) {
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

bool
ncSpectator::IsRealSpectator(void)
{
	return (true);
}

bool
ncSpectator::IsDead(void)
{
	return (false);
}

bool
ncSpectator::IsPlayer(void)
{
	return (false);
}

bool
ncSpectator::IsFakeSpectator(void)
{
	return (false);
}

void
ncSpectator::ProcessInput(void)
{
#ifdef SERVER
	if (input_buttons & INPUT_PRIMARY) {
		InputNext();
	} else if (input_buttons & INPUT_SECONDARY) {
		InputPrevious();
	} else if (input_buttons & INPUT_JUMP) {
		InputMode();
	} else {
		spec_flags &= ~SPECFLAG_BUTTON_RELEASED;
	}
#endif
}

void
ncSpectator::WarpToTarget(void)
{
	entity b = edict_num(spec_ent);
	setorigin(this, b.origin);
}

void
ncSpectator::SharedInputFrame(void)
{
	SetSize(g_vec_null, g_vec_null);

	if (spec_mode == SPECMODE_FREE || spec_mode == SPECMODE_FREEOVERVIEW) {
		if (spec_mode == SPECMODE_FREEOVERVIEW) {
			input_angles[0] = 0.0f;
		}

		SetSolid(SOLID_NOT);
		SetMovetype(MOVETYPE_NOCLIP);
	} else {
		SetSolid(SOLID_NOT);
		SetMovetype(MOVETYPE_NONE);
	}
}

#ifdef SERVER
float
ncSpectator::SendEntity(entity ePVSent, float flChanged)
{
	if (this != ePVSent) {
		return (0);
	}

	if (clienttype(ePVSent) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_SPECTATOR);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], SPECFL_ORIGIN)
	SENDENTITY_COORD(origin[1], SPECFL_ORIGIN)
	SENDENTITY_COORD(origin[2], SPECFL_ORIGIN)

	SENDENTITY_FLOAT(velocity[0], SPECFL_VELOCITY)
	SENDENTITY_FLOAT(velocity[1], SPECFL_VELOCITY)
	SENDENTITY_FLOAT(velocity[2], SPECFL_VELOCITY)

	SENDENTITY_BYTE(spec_ent, SPECFL_TARGET)
	SENDENTITY_BYTE(spec_mode, SPECFL_MODE)
	SENDENTITY_BYTE(spec_flags, SPECFL_FLAGS)
	SENDENTITY_BYTE(movetype, SPECFL_TYPE)
	SENDENTITY_BYTE(solid, SPECFL_TYPE)

	return (1);
}

void
ncSpectator::ServerInputFrame(void)
{
	movetype = MOVETYPE_NOCLIP;

	if (spec_mode == SPECMODE_FREE) {
		runstandardplayerphysics(this);
	} else {
		WarpToTarget();
	}

	/* since we are not using Physics_Run(), we have to call this manually */
	ProcessInput();
}

#else
void
ncSpectator::ClientInputFrame(void)
{
	/* If we are inside a VGUI, don't let the client do stuff outside */
	if (VGUI_Active()) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}

	/* background maps have no input */
	if (serverkeyfloat("background") == 1) {
		input_impulse = 0;
		input_buttons = 0;
		input_movevalues = g_vec_null;
		return;
	}

	vector movementDir = vectorNormalize(input_movevalues);

	/* normalize movement values */
	if (movementDir[0] > 0)
		input_movevalues[0] = movementDir[0] * GetForwardSpeed();
	else
		input_movevalues[0] = movementDir[0] * GetBackSpeed();

	input_movevalues[1] = movementDir[1] * GetSideSpeed();
}

void
ncSpectator::ReceiveEntity(float new, float flChanged)
{
	if (spec_mode == SPECMODE_FREE || spec_mode == SPECMODE_FREEOVERVIEW)
	if (new == FALSE) {
		/* Go through all the physics code between the last received frame
		 * and the newest frame and keep the changes this time around instead
		 * of rolling back, because we'll apply the new server-verified values
		 * right after anyway. */
		/* FIXME: splitscreen */
		if (entnum == player_localentnum) {
			/* FIXME: splitscreen */
			pSeat = &g_seats[0];

			for (int i = sequence+1; i <= servercommandframe; i++) {
				/* ...maybe the input state is too old? */
				if (!getinputstate(i)) {
					break;
				}
				input_sequence = i;
				runstandardplayerphysics(this);
				ProcessInput();
			}

			/* any differences in things that are read below are now
			 * officially from prediction misses. */
		}
	}

	/* seed for our prediction table */
	sequence = servercommandframe;

	READENTITY_COORD(origin[0], SPECFL_ORIGIN)
	READENTITY_COORD(origin[1], SPECFL_ORIGIN)
	READENTITY_COORD(origin[2], SPECFL_ORIGIN)

	READENTITY_FLOAT(velocity[0], SPECFL_VELOCITY)
	READENTITY_FLOAT(velocity[1], SPECFL_VELOCITY)
	READENTITY_FLOAT(velocity[2], SPECFL_VELOCITY)

	READENTITY_BYTE(spec_ent, SPECFL_TARGET)
	READENTITY_BYTE(spec_mode, SPECFL_MODE)
	READENTITY_BYTE(spec_flags, SPECFL_FLAGS)
	READENTITY_BYTE(movetype, SPECFL_TYPE)
	READENTITY_BYTE(solid, SPECFL_TYPE)

	if (flChanged & SPECFL_TARGET) {
		m_flLastSpecTargetChange = time;
	}
};

float
ncSpectator::predraw(void)
{
	addentity(this);
	return (PREDRAW_NEXT);
}
#endif

void
ncSpectator::InputNext(void)
{
	if (m_flDeathCam > time)
		return;

	if (spec_flags & SPECFLAG_BUTTON_RELEASED) {
		return;
	}

	if (spec_mode == SPECMODE_DEATHCAM && m_flDeathCam < time) {
		spec_mode = SPECMODE_THIRDPERSON;
		InputNext();
		return;
	} else if (spec_mode == SPECMODE_FREE) {
		spec_mode = SPECMODE_THIRDPERSON;
	} else if (spec_mode == SPECMODE_FREEOVERVIEW) {
		spec_mode = SPECMODE_CHASEOVERVIEW;
	}

	spec_flags |= SPECFLAG_BUTTON_RELEASED;

#if 0
	float max_edict;

	max_edict = serverkeyfloat("sv_playerslots");

	spec_ent++;

	if (spec_ent > max_edict)
		spec_ent = 1;

	print(sprintf("edict: %d\n", spec_ent));
#else
	float max_edict;
	float sep = spec_ent;
	float best = 0;
	ncClient cl;

	max_edict = serverkeyfloat("sv_playerslots");

	for (float i = 1; i <= max_edict; i++) {
		entity f;

		if (i <= sep && best == 0) {
			f = edict_num(i);
			if (f && f.classname == "player" && f != this) {
				cl = (ncClient)f;
				if (!cl.IsFakeSpectator())
					best = i;
			}
		}

		if (i > sep) {
			f = edict_num(i);
			if (f && f.classname == "player" && f != this) {
				cl = (ncClient)f;
				if (!cl.IsFakeSpectator()) {
					best = i;
					break;
				}
			}
		}
	}

	if (best == 0)
		return;

	spec_ent = best;
#endif

	WarpToTarget();

	if (spec_mode == SPECMODE_CHASEOVERVIEW)
		spec_mode = SPECMODE_CHASEOVERVIEW;
}

void
ncSpectator::InputPrevious(void)
{
	if (m_flDeathCam > time)
		return;

	if (spec_flags & SPECFLAG_BUTTON_RELEASED) {
		return;
	}

	if (spec_mode == SPECMODE_DEATHCAM && m_flDeathCam < time) {
		spec_mode = SPECMODE_THIRDPERSON;
		InputNext();
		return;
	} else if (spec_mode == SPECMODE_FREE) {
		spec_mode = SPECMODE_THIRDPERSON;
	} else if (spec_mode == SPECMODE_FREEOVERVIEW) {
		spec_mode = SPECMODE_CHASEOVERVIEW;
	}

	spec_flags |= SPECFLAG_BUTTON_RELEASED;

#if 0
	float max_edict;

	max_edict = serverkeyfloat("sv_playerslots");

	spec_ent--;

	if (spec_ent < 1)
		spec_ent = max_edict;
#else
	float max_edict;
	float sep = spec_ent;
	float best = 0;
	ncClient cl;

	max_edict = serverkeyfloat("sv_playerslots");

	for (float i = max_edict; i > 0; i--) {
		entity f;

		/* remember the first valid one here */
		if (i >= sep && best == 0) {
			f = edict_num(i);

			if (f && f.classname == "player") {
				cl = (ncClient)f;

				if (!cl.IsFakeSpectator())
					best = i;
			}
		}

		/* find the first good one and take it */
		if (i < sep) {
			f = edict_num(i);
			if (f && f.classname == "player") {
				cl = (ncClient)f;
				if (!cl.IsFakeSpectator()) {
					best = i;
					break;
				}
			}
		}
	}

	if (best == 0)
		return;

	spec_ent = best;
#endif


	WarpToTarget();

	if (spec_mode == SPECMODE_LOCKEDCHASE)
		spec_mode = SPECMODE_CHASEOVERVIEW;
}

void
ncSpectator::InputMode(void)
{
	if (spec_mode == SPECMODE_DEATHCAM && m_flDeathCam < time) {
		spec_mode = SPECMODE_THIRDPERSON;
		InputNext();
		return;
	}

	if (spec_flags & SPECFLAG_BUTTON_RELEASED) {
		return;
	}

	spec_flags |= SPECFLAG_BUTTON_RELEASED;

	ncClient f;
#ifdef CLIENT
	f = (ncClient)findfloat(world, ::entnum, spec_ent);
#else
	f = (ncClient)edict_num(spec_ent);
#endif

	if (f == this || f.classname != "player") {
		if (spec_mode != SPECMODE_FREE)
			spec_mode = SPECMODE_FREE;
		else
			spec_mode = SPECMODE_FREEOVERVIEW;
	} else {
		spec_mode++;

		if (spec_mode > SPECMODE_CHASEOVERVIEW)
			spec_mode = SPECMODE_LOCKEDCHASE;
	}
}

void
ncSpectator::PreFrame(void)
{
#ifdef CLIENT
	/* base player attributes/fields we're going to roll back */
	SAVE_STATE(origin)
	SAVE_STATE(velocity)
	SAVE_STATE(spec_ent)
	SAVE_STATE(spec_mode)
	SAVE_STATE(spec_flags)

	/* run physics code for all the input frames which we've not heard back
	 * from yet. This continues on in Player_ReceiveEntity! */
	for (int i = sequence + 1; i <= clientcommandframe; i++) {
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
		runstandardplayerphysics(this);
		ProcessInput();
	}
#endif

	SpectatorTrackPlayer();
}

void
ncSpectator::SpectatorTrackPlayer(void)
{
	if (spec_mode == SPECMODE_DEATHCAM
		|| spec_mode == SPECMODE_THIRDPERSON 
		|| spec_mode == SPECMODE_FIRSTPERSON
		|| spec_mode == SPECMODE_CHASEOVERVIEW
		|| spec_mode == SPECMODE_LOCKEDCHASE ) {
		ncClient b;

	#ifdef CLIENT
		b = (ncClient)findfloat(world, ::entnum, spec_ent);
	#else
		b = (ncClient)edict_num(spec_ent);
	#endif

		if (b && b.classname == "player")
		if (b.IsFakeSpectator()) {
			b = 0;
			spec_mode = SPECMODE_FREE;
			InputNext();
		}

		/* if the ent is dead... or not available in this current frame
		   just warp to the last 'good' one */
		if (b) {
			setorigin(this, b.origin);
			spec_org = b.origin;
		} else {
			setorigin(this, spec_org);
		}
	}
}

#ifdef SERVER
void
ncSpectator::EvaluateEntity(void)
{
	/* check for which values have changed in this frame
	   and announce to network said changes */
	EVALUATE_FIELD(origin, SPECFL_ORIGIN)
	EVALUATE_FIELD(velocity, SPECFL_VELOCITY)
	EVALUATE_FIELD(spec_ent, SPECFL_TARGET)
	EVALUATE_FIELD(spec_mode, SPECFL_MODE)
	EVALUATE_FIELD(spec_flags, SPECFL_FLAGS)
	EVALUATE_FIELD(movetype, SPECFL_TYPE)
	EVALUATE_FIELD(solid, SPECFL_TYPE)
}

void
ncSpectator::SpectatorDeathcam(ncRenderableEntity ourCorpse, ncEntity trackEntity, float waitTime)
{
	spec_ent = num_for_edict(ourCorpse);
	spec_mode = SPECMODE_DEATHCAM;
	m_flDeathCam = time + waitTime;
}
#endif

void
ncSpectator::PostFrame(void)
{
#ifdef CLIENT
	ROLL_BACK(origin)
	ROLL_BACK(velocity)
	ROLL_BACK(spec_ent)
	ROLL_BACK(spec_mode)
	ROLL_BACK(spec_flags)
#endif
}

#ifdef CLIENT
void
Spectator_ReadEntity(float new)
{
	ncSpectator spec = (ncSpectator)self;

	if (new || self.classname != "spectator") {
		spawnfunc_ncSpectator();
		spec.classname = "spectator";
		spec.solid = SOLID_NOT;
		spec.drawmask = MASK_ENGINE;
		spec.customphysics = Empty;
		setsize(spec, [0,0,0], [0,0,0]);
	}

	float flags = readfloat();
	spec.ReceiveEntity(new, flags);
}
#endif
