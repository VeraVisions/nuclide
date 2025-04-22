/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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
ncMoverEntity::ncMoverEntity(void)
{
	m_vecPos1 = g_vec_null;
	m_vecPos2 = g_vec_null;
	m_vecPos3 = g_vec_null;
	m_vecPos4 = g_vec_null;
	m_moverState = MOVER_POS1;
	m_moverType = MOVERTYPE_LINEAR;
	m_iPortalState = 0i;
	m_bUseMoveDir = false;
}

#ifdef SERVER
void
ncMoverEntity::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "movedir":
		m_vecMoveDir = ReadVector(setValue);
		m_bUseMoveDir = true;
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
ncMoverEntity::Save(float handle)
{
	super::Save(handle);

	SaveVector(handle, "m_vecPos1", m_vecPos1);
	SaveVector(handle, "m_vecPos2", m_vecPos2);
	SaveVector(handle, "m_vecPos3", m_vecPos3);
	SaveVector(handle, "m_vecPos4", m_vecPos4);
	SaveFloat(handle, "m_moverState", m_moverState);
	SaveFloat(handle, "m_moverType", m_moverType);
	SaveInt(handle, "m_iPortalState", m_iPortalState);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
	SaveBool(handle, "m_bUseMoveDir", m_bUseMoveDir);
}

void
ncMoverEntity::Restore(string keyName, string setValue)
{
	switch (keyName) {
	case "m_vecPos1":
		m_vecPos1 = ReadVector(setValue);
		break;
	case "m_vecPos2":
		m_vecPos2 = ReadVector(setValue);
		break;
	case "m_vecPos3":
		m_vecPos3 = ReadVector(setValue);
		break;
	case "m_vecPos4":
		m_vecPos4 = ReadVector(setValue);
		break;
	case "m_moverState":
		m_moverState = ReadFloat(setValue);
		break;
	case "m_moverType":
		m_moverType = ReadFloat(setValue);
		break;
	case "m_iPortalState":
		m_iPortalState = ReadInt(setValue);
		break;
	case "m_vecMoveDir":
		m_vecMoveDir = ReadVector(setValue);
		break;
	case "m_bUseMoveDir":
		m_bUseMoveDir = ReadBool(setValue);
		break;
	default:
		super::Restore(keyName, setValue);
	}
}
#endif

vector
ncMoverEntity::GetDirectionalPosition(vector vecAngle, float flLip)
{
	vector vecMoveDir = g_vec_null;
	vector vecPos = g_vec_null;

	if (m_bUseMoveDir == true) {
		makevectors(m_vecMoveDir);
		vecMoveDir = v_forward;
	} else {
		/* editor angle */
		if (vecAngle == [0,-1,0]) {
			vecMoveDir = [0,0,1];
		} else if (vecAngle == [0,-2,0]) {
			vecMoveDir = [0,0,-1];
		} else {
			/* manually specified angle */
			makevectors(vecAngle);
			vecMoveDir = v_forward;
		}
	}

	vecPos = (GetSpawnVector("origin") + vecMoveDir * (fabs(vecMoveDir * size) - flLip));
	return vecPos;
}

vector
ncMoverEntity::GetDirectionalRotation(vector normalizedAngle, float travelDistance)
{
	vector vecMoveDir = normalizedAngle;
	vector outputVector;

	if (m_bUseMoveDir == true) {
		makevectors(m_vecMoveDir);
		vecMoveDir = v_forward;
	} 

	outputVector = (GetSpawnVector("angles") + (vecMoveDir * travelDistance));
	return (outputVector);
}

void
ncMoverEntity::SetMoverState(moverState_t val)
{
	m_moverState = val;
}

moverState_t
ncMoverEntity::GetMoverState(void)
{
	return m_moverState;
}

void
ncMoverEntity::SetMoverType(moverType_t val)
{
	m_moverType = val;
}

moverType_t
ncMoverEntity::GetMoverType(void)
{
	
	return m_moverType;
}

void
ncMoverEntity::SetMoverPosition1(vector val)
{
	m_vecPos1 = val;
}

vector
ncMoverEntity::GetMoverPosition1(void)
{
	return m_vecPos1;
}

void
ncMoverEntity::SetMoverPosition2(vector val)
{
	m_vecPos2 = val;
}

vector
ncMoverEntity::GetMoverPosition2(void)
{
	return m_vecPos2;
}

void
ncMoverEntity::SetMoverRotation1(vector val)
{
	m_vecPos3 = val;
}

vector
ncMoverEntity::GetMoverRotation1(void)
{
	return m_vecPos3;
}

void
ncMoverEntity::SetMoverRotation2(vector val)
{
	m_vecPos4 = val;
}

vector
ncMoverEntity::GetMoverRotation2(void)
{
	return m_vecPos4;
}

void
ncMoverEntity::MoveToPosition(vector vecDest, float flSpeed)
{
	MoveAndRotateToPosition(vecDest, GetAngles(), flSpeed);
}

void
ncMoverEntity::MoveAndRotateToPosition(vector vecDest, vector vecAngle, float flSpeed)
{
	vector vecDifference;
	vector vecAngleDifference;
	float flTravel;
	float fTravelTime;

	/* selects which end method to trigger based on state. */
	static void MoveToRotPosition_Done(float travelTime) {
		if (m_moverState == MOVER_1TO2) {
			ScheduleThink(_ArrivedAtRotPosition2, travelTime);
		} else if (m_moverState == MOVER_2TO1) {
			ScheduleThink(_ArrivedAtRotPosition1, travelTime);
		}
		MoverStartsMoving();
		_PortalOpen();
	}

	/* selects which end positition to set based on state */
	static void MoveToRotPosition_SetDest(vector vecDest, vector vecAngle) {
		if (m_moverState == MOVER_POS2) {
			m_vecPos1 = vecDest;
			m_vecPos3 = vecAngle;
			m_moverState = MOVER_2TO1;
		} else {
			m_moverState = MOVER_1TO2;
			m_vecPos2 = vecDest;
			m_vecPos4 = vecAngle;
		}
	}

	/* abort if no speed is defined whatsoever */
	if (!flSpeed) {
		EntWarning("ncMoverEntity::MoveToPosition: No speed defined!");
		return;
	}

	/* set the appropriate attribute */
	MoveToRotPosition_SetDest(vecDest, vecAngle);

	/* calculate travel distance and time */
	vecDifference = (vecDest - GetOrigin());
	vecAngleDifference = (vecAngle - GetAngles());
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / flSpeed);

	/* if we won't move far enough, we may rotate? */
	if (!flTravel) {
		flTravel = vlen(vecAngleDifference);
		fTravelTime = (flTravel / flSpeed);
	}

	/* if we're already there, don't bother and trigger it right now. */
	if (fTravelTime <= 0.0) {
		if (m_moverState == MOVER_1TO2) {
			MoverStartsMoving();
			_ArrivedAtRotPosition2();
			MoverFinishesMoving();
		} else if (m_moverState == MOVER_2TO1) {
			MoverStartsMoving();
			_ArrivedAtRotPosition1();
			MoverFinishesMoving();
		}
		return;
	}

	/* schedule the movement and proceed to trigger the end after a certain time */
	SetVelocity(vecDifference * (1.0f / fTravelTime));
	SetAngularVelocity((vecAngleDifference * (1.0 / fTravelTime)));
	MoveToRotPosition_Done(fTravelTime);
}

void
ncMoverEntity::MoveToReverse(float flSpeed)
{
	if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
		MoveToPosition(GetMoverPosition1(), flSpeed);
	} else {
		MoveToPosition(GetMoverPosition2(), flSpeed);
	}
}

void
ncMoverEntity::RotateToPosition(vector vecAngle, float flSpeed)
{
	MoveAndRotateToPosition(GetOrigin(), vecAngle, flSpeed);
}

void
ncMoverEntity::RotateToReverse(float flSpeed)
{
	if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
		RotateToPosition(GetMoverRotation1(), flSpeed);
	} else {
		RotateToPosition(GetMoverRotation2(), flSpeed);
	}
}

bool
ncMoverEntity::IsMoving(void)
{
	switch (GetMoverState()) {
	case MOVER_POS1:
	case MOVER_POS2:
		return false;
		break;
	default:
		return true;
	}
}

void
ncMoverEntity::_PortalOpen(void)
{
	if (m_iPortalState == 1)
		return;


	m_iPortalState = 1;

#if 0
	setorigin(this, origin);
	openportal(this, AREAPORTAL_OPEN);
#else
#ifdef SERVER
	if (!STRING_SET(targetname)) {
		return;
	}

	for (func_areaportal portalChain = __NULL__; (portalChain = (func_areaportal)find(portalChain, ::classname, "func_areaportal"));) {
		portalChain.Trigger(this, TRIG_ON);
	}
#endif
#endif
}

void
ncMoverEntity::_PortalClose(void)
{
	if (m_iPortalState == 0)
		return;

	m_iPortalState = 0;
#if 0
	setorigin(this, origin);
	openportal(this, AREAPORTAL_CLOSED);
#else
#ifdef SERVER
	if (!STRING_SET(targetname)) {
		return;
	}

	for (func_areaportal portalChain = __NULL__; (portalChain = (func_areaportal)find(portalChain, ::classname, "func_areaportal"));) {
		portalChain.Trigger(this, TRIG_OFF);
	}
#endif
#endif
}


void
ncMoverEntity::_ArrivedAtRotPosition1(void)
{
	SetOrigin(m_vecPos1);
	SetAngles(m_vecPos3);
	ClearVelocity();
	ReleaseThink();
	m_moverState = MOVER_POS1;
	_PortalClose();
	MoverFinishesMoving();
}

void
ncMoverEntity::_ArrivedAtRotPosition2(void)
{
	SetOrigin(m_vecPos2);
	SetAngles(m_vecPos4);
	ClearVelocity();
	ReleaseThink();
	m_moverState = MOVER_POS2;
	MoverFinishesMoving();
}

void
ncMoverEntity::_BeginMoving(void)
{

}

void
ncMoverEntity::MoverStartsMoving(void)
{
}

void
ncMoverEntity::MoverFinishesMoving(void)
{
}
