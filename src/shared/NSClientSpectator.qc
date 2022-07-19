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

#ifdef SERVER
void
NSClientSpectator::Save(float handle)
{
	super::Save(handle);
}

void
NSClientSpectator::Restore(string strKey, string strValue)
{
	switch (strKey) {
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

bool
NSClientSpectator::IsRealSpectator(void)
{
	return (true);
}

bool
NSClientSpectator::IsDead(void)
{
	return (false);
}

bool
NSClientSpectator::IsPlayer(void)
{
	return (false);
}

bool
NSClientSpectator::IsFakeSpectator(void)
{
	return (false);
}

void
NSClientSpectator::ClientInput(void)
{
	if (input_buttons & INPUT_BUTTON0) {
		InputNext();
	} else if (input_buttons & INPUT_BUTTON3) {
		InputPrevious();
	} else if (input_buttons & INPUT_BUTTON2) {
		InputMode();
	} else {
		spec_flags &= ~SPECFLAG_BUTTON_RELEASED;
	}

	input_buttons = 0;
	//crossprint(sprintf("%d %d %d\n", spec_ent, spec_mode, spec_flags));
}

void
NSClientSpectator::WarpToTarget(void)
{
	entity b = edict_num(spec_ent);

	setorigin(this, b.origin);
}

#ifdef SERVER
float
NSClientSpectator::SendEntity(entity ePVSent, float flChangedFlags)
{
	if (this != ePVSent) {
		return (0);
	}

	if (clienttype(ePVSent) != CLIENTTYPE_REAL) {
		return (0);
	}

	WriteByte(MSG_ENTITY, ENT_SPECTATOR);
	WriteFloat(MSG_ENTITY, flChangedFlags);

	if (flChangedFlags & SPECFL_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flChangedFlags & SPECFL_VELOCITY) {
		WriteFloat(MSG_ENTITY, velocity[0]);
		WriteFloat(MSG_ENTITY, velocity[1]);
		WriteFloat(MSG_ENTITY, velocity[2]);
	}

	if (flChangedFlags & SPECFL_TARGET)
		WriteByte(MSG_ENTITY, spec_ent);

	if (flChangedFlags & SPECFL_MODE)
		WriteByte(MSG_ENTITY, spec_mode);

	if (flChangedFlags & SPECFL_FLAGS)
		WriteByte(MSG_ENTITY, spec_flags);

	return (1);
}

void
NSClientSpectator::RunClientCommand(void)
{
	runstandardplayerphysics(this);
	ClientInput();
}

#else
void
NSClientSpectator::ClientInputFrame(void)
{
	/* If we are inside a VGUI, don't let the client do stuff outside */
	if (VGUI_Active()) {
		input_impulse = 0;
		input_buttons = 0;
		return;
	}

	/* background maps have no input */
	if (serverkeyfloat("background") == 1)
		return;
}

void
NSClientSpectator::ReceiveEntity(float new, float fl)
{
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
				ClientInput();
			}

			/* any differences in things that are read below are now
			 * officially from prediction misses. */
		}
	}

	/* seed for our prediction table */
	sequence = servercommandframe;

	if (fl & SPECFL_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}

	if (fl & SPECFL_VELOCITY) {
		velocity[0] = readfloat();
		velocity[1] = readfloat();
		velocity[2] = readfloat();
	}

	if (fl & SPECFL_TARGET)
		spec_ent = readbyte();

	if (fl & SPECFL_MODE)
		spec_mode = readbyte();

	if (fl & SPECFL_FLAGS)
		spec_flags = readbyte();
};
float
NSClientSpectator::predraw(void)
{
	addentity(this);
	return (PREDRAW_NEXT);
}
#endif

void
NSClientSpectator::InputNext(void)
{
	if (spec_flags & SPECFLAG_BUTTON_RELEASED)
		return;

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
	NSClient cl;

	max_edict = serverkeyfloat("sv_playerslots");

	for (float i = 1; i <= max_edict; i++) {
		entity f;

		if (i <= sep && best == 0) {
			f = edict_num(i);
			if (f && f.classname == "player" && f != this) {
				cl = (NSClient)f;
				if (!cl.IsFakeSpectator())
					best = i;
			}
		}

		if (i > sep) {
			f = edict_num(i);
			if (f && f.classname == "player" && f != this) {
				cl = (NSClient)f;
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
	spec_flags |= SPECFLAG_BUTTON_RELEASED;
	WarpToTarget();

	if (spec_mode == SPECMODE_FREE)
		spec_mode = SPECMODE_THIRDPERSON;
}

void
NSClientSpectator::InputPrevious(void)
{
	if (spec_flags & SPECFLAG_BUTTON_RELEASED)
		return;
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
	NSClient cl;

	max_edict = serverkeyfloat("sv_playerslots");

	for (float i = max_edict; i > 0; i--) {
		entity f;

		/* remember the first valid one here */
		if (i >= sep && best == 0) {
			f = edict_num(i);

			if (f && f.classname == "player") {
				cl = (NSClient)f;

				if (!cl.IsFakeSpectator())
					best = i;
			}
		}

		/* find the first good one and take it */
		if (i < sep) {
			f = edict_num(i);
			if (f && f.classname == "player") {
				cl = (NSClient)f;
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

	spec_flags |= SPECFLAG_BUTTON_RELEASED;

	WarpToTarget();

	if (spec_mode == SPECMODE_FREE)
		spec_mode = SPECMODE_THIRDPERSON;
}

void
NSClientSpectator::InputMode(void)
{
	if (spec_flags & SPECFLAG_BUTTON_RELEASED)
		return;

	NSClient f;
#ifdef CLIENT
	f = (NSClient)findfloat(world, ::entnum, spec_ent);
#else
	f = (NSClient)edict_num(spec_ent);
#endif

	if (f == this || f.classname != "player")
		spec_mode = SPECMODE_FREE;
	else {
		spec_mode++;

		if (spec_mode > SPECMODE_FIRSTPERSON)
			spec_mode = SPECMODE_FREE;
	}

	spec_flags |= SPECFLAG_BUTTON_RELEASED;
}

void
NSClientSpectator::PreFrame(void)
{
#ifdef CLIENT
	/* base player attributes/fields we're going to roll back */
	SAVE_STATE(origin);
	SAVE_STATE(velocity);
	SAVE_STATE(spec_ent);
	SAVE_STATE(spec_mode);
	SAVE_STATE(spec_flags);

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
		ClientInput();
	}
#endif

	SpectatorTrackPlayer();
}

void
NSClientSpectator::SpectatorTrackPlayer(void)
{
	if (spec_mode == SPECMODE_THIRDPERSON || spec_mode == SPECMODE_FIRSTPERSON ) {
		NSClient b;

	#ifdef CLIENT
		b = (NSClient)findfloat(world, ::entnum, spec_ent);
	#else
		b = (NSClient)edict_num(spec_ent);
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
NSClientSpectator::EvaluateEntity(void)
{
	/* check for which values have changed in this frame
	   and announce to network said changes */
	if (origin != origin_net)
		SetSendFlags(SPECFL_ORIGIN);

	if (velocity != velocity_net)
		SetSendFlags(SPECFL_VELOCITY);

	if (spec_ent != spec_ent_net)
		SetSendFlags(SPECFL_TARGET);

	if (spec_mode != spec_mode_net)
		SetSendFlags(SPECFL_MODE);

	if (spec_flags != spec_flags_net)
		SetSendFlags(SPECFL_FLAGS);

	SAVE_STATE(origin);
	SAVE_STATE(velocity);
	SAVE_STATE(spec_ent);
	SAVE_STATE(spec_mode);
	SAVE_STATE(spec_flags);
}
#endif

void
NSClientSpectator::PostFrame(void)
{
#ifdef CLIENT
	ROLL_BACK(origin);
	ROLL_BACK(velocity);
	ROLL_BACK(spec_ent);
	ROLL_BACK(spec_mode);
	ROLL_BACK(spec_flags);
#endif
}

void
NSClientSpectator::NSClientSpectator(void)
{
	flags |= FL_CLIENT;
}

#ifdef CLIENT
void
Spectator_ReadEntity(float new)
{
	NSClientSpectator spec = (NSClientSpectator)self;

	if (new || self.classname != "spectator") {
		spawnfunc_NSClientSpectator();
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
