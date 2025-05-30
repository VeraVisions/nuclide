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

enumflags
{
	MRBFL_DOORHACK,
	MRBFL_NOTUSE,
	MRBFL_UNUSED4,
	MRBFL_UNUSED8,
	MRBFL_AUTORETURN,
	MRBFL_UNUSED32,
	MRBFL_XAXIS,
	MRBFL_YAXIS
};

/*! \brief Server-Entity: Momentary Rotating Door/Lever/Valve */
/*!QUAKED momentary_rot_button (0 .5 .8) ? MRBFL_DOORHACK MRBFL_NOTUSE x x MRBFL_AUTORETURN x MRBFL_XAXIS MRBFL_YAXIS
# OVERVIEW
Dyanmic button/wheel/lever that moves back into its original position when not
in use. It affects momentary_door.

# KEYS
- "targetname" : Name
- "distance" : Maximum distance it'll turn until it stops.
- "speed" : Speed at which it rotates/turns.
- "returnspeed" : Speed at which it returns to its original position.

# SPAWNFLAGS
- MRBFL_DOORHACK (1) : This entity will move along with another momentary_rot_button of the same name.
- MRBFL_NOTUSE (2) : Don't allow interaction via "use" key/button.
- MRBFL_AUTORETURN (16) : Rotate back to its original state when not being used.
- MRBFL_XAXIS (64) : Rotate along the X-axis.
- MRBFL_YAXIS (128) : Rotate along the Y-axis.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
momentary_rot_button:ncMomentary
{
public:
	void momentary_rot_button(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void OnPlayerUse(void);
	virtual void OnPlayerUnUse(void);
	virtual void Respawn(void);
	virtual void SetMovementDirection(void);
	virtual void SpawnKey(string,string);
	
	virtual void MovementDone(void);
	virtual void MovementStateChanged(void);
	virtual float GetProgress(void);

private:
	int m_iTurnDir;
};

void
momentary_rot_button::momentary_rot_button(void)
{
	m_iTurnDir = 0i;
	m_flReturnspeed = m_flSpeed = -1;
}

void
momentary_rot_button::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iTurnDir", m_iTurnDir);
}

void
momentary_rot_button::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iTurnDir":
		m_iTurnDir = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
momentary_rot_button::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "distance":
		m_flDistance = stof(setValue);
		break;
	case "speed":
		m_flSpeed = stof(setValue);
		break;
	case "returnspeed":
		m_flReturnspeed = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
momentary_rot_button::Respawn(void)
{
	super::Respawn();
	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	if (m_flSpeed == -1)
		m_flSpeed = 100;
	if (m_flReturnspeed == -1)
		m_flReturnspeed = m_flSpeed;

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);

	/* purely visual, can't use this */
	if (!HasSpawnFlags(MRBFL_NOTUSE)) {
		PlayerUse = OnPlayerUse;
		PlayerUseUnpressed = OnPlayerUnUse;
	}

	m_vecPos1 = [0,0,0];
	m_vecPos2 = m_vecMoveDir * m_flDistance;

	SetSkin(0);
	SetMoveState(MOMENTARY_IDLE);
}

float
momentary_rot_button::GetProgress(void)
{
	return (vlen(angles) / vlen(m_vecPos2));
}

void
momentary_rot_button::MovementDone(void)
{
	m_vecDest = avelocity = [0,0,0];
}

void
momentary_rot_button::MovementStateChanged(void)
{
	vector vecAngleDifference;
	float flTravelLength;
	float flTravelTime;
	float flSpeed = 0;

	switch (m_iMoveState) {
	case MOMENTARY_IDLE:
		MovementDone();
		return;
		break;
	case MOMENTARY_ROTATING:
		m_vecDest = m_vecPos2;
		flSpeed = m_flSpeed;
		break;
	case MOMENTARY_RETURNING:
		m_vecDest = m_vecPos1;
		flSpeed = m_flReturnspeed;
		break;
	}

	vecAngleDifference = (m_vecDest - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / flSpeed);

	/* Avoid NAN hack */
	if (flTravelTime <= 0.0f) {
		SetAngles(m_vecDest);
		MovementDone();
		ReleaseThink();
	} else {
		SetAngularVelocity(vecAngleDifference * (1 / flTravelTime));
		ScheduleThink(MovementDone, flTravelTime);
	}
}

void
momentary_rot_button::OnPlayerUse(void)
{
	int iEndState;

	m_eUser = eActivator;

	/* if we're not already rotating (or can only turn 1 way) */
	if (m_iTurnDir == 0 || HasSpawnFlags(MRBFL_AUTORETURN))
		iEndState = (MOMENTARY_ROTATING); /* always turning one way on auto-return */
	else
		iEndState = (MOMENTARY_RETURNING);

	/* apply the end state */
	SetMoveState(iEndState);

	m_iTurnDir = 1 - m_iTurnDir;

	for (entity e = world; (e = find(e, ::targetname, target));) { 
		ncMomentary b = (ncMomentary)e;
		b.SetMoveState(iEndState);
	}

	for (entity e = world; (e = find(e, ::targetname, targetname));) { 
		ncMomentary b = (ncMomentary)e;

		/* door hack: any entity with the same name as ours will follow our states */
		if (b.HasSpawnFlags(MRBFL_DOORHACK))
			b.SetMoveState(iEndState);
	}
}

void
momentary_rot_button::OnPlayerUnUse(void)
{
	int iEndState;

	m_eUser = world;

	/* instead of stopping, auto-return. */
	if (HasSpawnFlags(MRBFL_AUTORETURN))
		iEndState = (MOMENTARY_RETURNING);
	else
		iEndState = (MOMENTARY_IDLE);

	/* apply the end state */
	SetMoveState(iEndState);

	for (entity e = world; (e = find(e, ::targetname, target));) { 
		ncMomentary b = (ncMomentary)e;
		b.SetMoveState(iEndState);
	}

	for (entity e = world; (e = find(e, ::targetname, targetname));) {
		ncMomentary b = (ncMomentary)e;
		
		/* door hack: any entity with the same name as ours will follow our states */
		if (b.HasSpawnFlags(MRBFL_DOORHACK))
			b.SetMoveState(iEndState);
	}
}

void
momentary_rot_button::SetMovementDirection(void)
{
	if (HasSpawnFlags(MRBFL_XAXIS)) {
		m_vecMoveDir = [0,0,1];
	} else if (HasSpawnFlags(MRBFL_YAXIS)) {
		m_vecMoveDir = [1,0,0];
	} else {
		m_vecMoveDir = [0,1,0];
	}
}
