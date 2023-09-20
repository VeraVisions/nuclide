/*
 * Copyright (c) 2023 Vera Visions LLC.
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
NSMoverEntity::NSMoverEntity(void)
{
	m_vecPos1 = g_vec_null;
	m_vecPos2 = g_vec_null;
	m_vecPos3 = g_vec_null;
	m_vecPos4 = g_vec_null;
	m_moverState = MOVER_POS1;
	m_moverType = MOVERTYPE_LINEAR;
	m_iPortalState = 0i;
}

#ifdef SERVER
void
NSMoverEntity::Save(float handle)
{
	super::Save(handle);

	SaveVector(handle, "m_vecPos1", m_vecPos1);
	SaveVector(handle, "m_vecPos2", m_vecPos2);
	SaveVector(handle, "m_vecPos3", m_vecPos3);
	SaveVector(handle, "m_vecPos4", m_vecPos4);
	SaveFloat(handle, "m_moverState", m_moverState);
	SaveFloat(handle, "m_moverType", m_moverType);
	SaveInt(handle, "m_iPortalState", m_iPortalState);
}

void
NSMoverEntity::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecPos1":
		m_vecPos1 = ReadVector(strValue);
		break;
	case "m_vecPos2":
		m_vecPos2 = ReadVector(strValue);
		break;
	case "m_vecPos3":
		m_vecPos3 = ReadVector(strValue);
		break;
	case "m_vecPos4":
		m_vecPos4 = ReadVector(strValue);
		break;
	case "m_moverState":
		m_moverState = ReadFloat(strValue);
		break;
	case "m_moverType":
		m_moverType = ReadFloat(strValue);
		break;
	case "m_iPortalState":
		m_iPortalState = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}
#endif

vector
NSMoverEntity::GetDirectionalPosition(vector vecAngle, float flLip)
{
	vector vecMoveDir = g_vec_null;
	vector vecPos = g_vec_null;

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

	vecPos = (GetOrigin() + vecMoveDir * (fabs(vecMoveDir * size) - flLip));
	return vecPos;
}

vector
NSMoverEntity::GetDirectionalRotation(vector normalizedAngle, float travelDistance)
{
	vector vecMoveDir = normalizedAngle;
	return (GetAngles() + vecMoveDir * travelDistance);
}

void
NSMoverEntity::SetMoverState(moverState_t val)
{
	m_moverState = val;
}

moverState_t
NSMoverEntity::GetMoverState(void)
{
	return m_moverState;
}

void
NSMoverEntity::SetMoverType(moverType_t val)
{
	m_moverType = val;
}

moverType_t
NSMoverEntity::GetMoverType(void)
{
	
	return m_moverType;
}

void
NSMoverEntity::SetMoverPosition1(vector val)
{
	m_vecPos1 = val;
}

vector
NSMoverEntity::GetMoverPosition1(void)
{
	return m_vecPos1;
}

void
NSMoverEntity::SetMoverPosition2(vector val)
{
	m_vecPos2 = val;
}

vector
NSMoverEntity::GetMoverPosition2(void)
{
	return m_vecPos2;
}

void
NSMoverEntity::SetMoverRotation1(vector val)
{
	m_vecPos3 = val;
}

vector
NSMoverEntity::GetMoverRotation1(void)
{
	return m_vecPos3;
}

void
NSMoverEntity::SetMoverRotation2(vector val)
{
	m_vecPos4 = val;
}

vector
NSMoverEntity::GetMoverRotation2(void)
{
	return m_vecPos4;
}

void
NSMoverEntity::MoveToPosition(vector vecDest, float flSpeed)
{
	MoveAndRotateToPosition(vecDest, GetAngles(), flSpeed);
}

void
NSMoverEntity::MoveAndRotateToPosition(vector vecDest, vector vecAngle, float flSpeed)
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
		NSEntWarning("NSMoverEntity::MoveToPosition: No speed defined!");
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
	MoveToRotPosition_Done(fTravelTime);
	SetVelocity(vecDifference * (1.0f / fTravelTime));
	SetAngularVelocity((vecAngleDifference * (1.0 / fTravelTime)));
}

void
NSMoverEntity::MoveToReverse(float flSpeed)
{
	if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
		MoveToPosition(GetMoverPosition1(), flSpeed);
	} else {
		MoveToPosition(GetMoverPosition2(), flSpeed);
	}
}

void
NSMoverEntity::RotateToPosition(vector vecAngle, float flSpeed)
{
	MoveAndRotateToPosition(GetOrigin(), vecAngle, flSpeed);
}

void
NSMoverEntity::RotateToReverse(float flSpeed)
{
	if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
		RotateToPosition(GetMoverRotation1(), flSpeed);
	} else {
		RotateToPosition(GetMoverRotation2(), flSpeed);
	}
}

bool
NSMoverEntity::IsMoving(void)
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
NSMoverEntity::_PortalOpen(void)
{
	if (m_iPortalState == 1)
		return;

	m_iPortalState = 1;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_OPEN);
}

void
NSMoverEntity::_PortalClose(void)
{
	if (m_iPortalState == 0)
		return;

	m_iPortalState = 0;
	setorigin(this, origin);
	openportal(this, AREAPORTAL_CLOSED);
}


void
NSMoverEntity::_ArrivedAtRotPosition1(void)
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
NSMoverEntity::_ArrivedAtRotPosition2(void)
{
	SetOrigin(m_vecPos2);
	SetAngles(m_vecPos4);
	ClearVelocity();
	ReleaseThink();
	m_moverState = MOVER_POS2;
	MoverFinishesMoving();
}

void
NSMoverEntity::_BeginMoving(void)
{

}

void
NSMoverEntity::MoverStartsMoving(void)
{
}

void
NSMoverEntity::MoverFinishesMoving(void)
{
}