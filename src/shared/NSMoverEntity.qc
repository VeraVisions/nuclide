void
NSMoverEntity::NSMoverEntity(void)
{
	m_vecPos1 = g_vec_null;
	m_vecPos2 = g_vec_null;
	m_moverState = MOVER_POS1;
	m_moverType = MOVERTYPE_TRANSFORM;
	m_iPortalState = 0i;
}

#ifdef SERVER
void
NSMoverEntity::Save(float handle)
{
	super::Save(handle);

	SaveVector(handle, "m_vecPos1", m_vecPos1);
	SaveVector(handle, "m_vecPos2", m_vecPos2);
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
NSMoverEntity::SetPosition1(vector val)
{
	m_vecPos1 = val;
}

vector
NSMoverEntity::GetPosition1(void)
{
	return m_vecPos1;
}

void
NSMoverEntity::SetPosition2(vector val)
{
	m_vecPos2 = val;
}

vector
NSMoverEntity::GetPosition2(void)
{
	return m_vecPos2;
}

void
NSMoverEntity::MoveToPosition(vector vecDest, float flSpeed)
{
	vector vecDifference;
	float flTravel;
	float fTravelTime;

	/* selects which end method to trigger based on state. */
	static void MoveToPosition_Done(float travelTime) {
		if (m_moverState == MOVER_1TO2) {
			ScheduleThink(_ArrivedAtPosition2, travelTime);
		} else if (m_moverState == MOVER_2TO1) {
			ScheduleThink(_ArrivedAtPosition1, travelTime);
		}
		MoverStartsMoving();
		_PortalOpen();
	}

	/* selects which end positition to set based on state */
	static void MoveToPosition_SetDest(vector vecDest) {
		if (m_moverState == MOVER_POS2) {
			m_vecPos1 = vecDest;
			m_moverState = MOVER_2TO1;
		} else {
			m_moverState = MOVER_1TO2;
			m_vecPos2 = vecDest;
		}
	}

	/* abort if no speed is defined whatsoever */
	if (!flSpeed) {
		objerror("NSMoverEntity::MoveToPosition: No speed defined!");
		return;
	}

	/* set the appropriate attribute */
	MoveToPosition_SetDest(vecDest);

	/* if we're already there, don't bother and trigger it right now. */
	if (vecDest == GetOrigin()) {
		MoveToPosition_Done(0.0f);
		ClearVelocity();
		return;
	}

	/* calculate travel distance and time */
	vecDifference = (vecDest - GetOrigin());
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / flSpeed);

	/* schedule the movement and proceed to trigger the end after a certain time */
	MoveToPosition_Done(fTravelTime);
	SetVelocity(vecDifference * (1.0f / fTravelTime));
}

void
NSMoverEntity::MoveToReverse(float flSpeed)
{
	if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
		MoveToPosition(GetPosition1(), flSpeed);
	} else {
		MoveToPosition(GetPosition2(), flSpeed);
	}
}

void
NSMoverEntity::RotateToPosition(vector vDestAngle, float flSpeed)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	static void RotateToPosition_Done(float travelTime) {
		if (m_moverState == MOVER_1TO2) {
			ScheduleThink(_RotatedToPosition2, travelTime);
		} else if (m_moverState == MOVER_2TO1) {
			ScheduleThink(_RotatedToPosition1, travelTime);
		}
		MoverStartsMoving();
		_PortalOpen();
	}

	static void RotateToPosition_SetDest(vector vecDest) {
		if (m_moverState == MOVER_POS2) {
			m_vecPos1 = vecDest;
			m_moverState = MOVER_2TO1;
		} else {
			m_moverState = MOVER_1TO2;
			m_vecPos2 = vecDest;
		}
	}

	if (!flSpeed) {
		NSLog("NSMoverEntity::RotateToPosition: No speed defined!");
		Respawn();
		return;
	}

	RotateToPosition_SetDest(vDestAngle);
	vecAngleDifference = (vDestAngle - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / flSpeed);

	/* Avoid NAN hack */
	if (flTravelTime <= 0.0f) {
		if (m_moverState == MOVER_1TO2) {
			_RotatedToPosition2();
		} else if (m_moverState == MOVER_2TO1) {
			_RotatedToPosition1();
		}
	} else {
		SetAngularVelocity((vecAngleDifference * (1 / flTravelTime)));
		RotateToPosition_Done(flTravelTime);
	}
}

void
NSMoverEntity::RotateToReverse(float flSpeed)
{
	if ((GetMoverState() == MOVER_POS2) || (GetMoverState() == MOVER_1TO2)){
		RotateToPosition(GetPosition1(), flSpeed);
	} else {
		RotateToPosition(GetPosition2(), flSpeed);
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
NSMoverEntity::_ArrivedAtPosition1(void)
{
	SetOrigin(m_vecPos1);
	ClearVelocity();
	ReleaseThink();
	m_moverState = MOVER_POS1;
	_PortalClose();
	MoverFinishesMoving();
}

void
NSMoverEntity::_ArrivedAtPosition2(void)
{
	SetOrigin(m_vecPos2);
	ClearVelocity();
	ReleaseThink();
	m_moverState = MOVER_POS2;
	MoverFinishesMoving();
}

void
NSMoverEntity::_RotatedToPosition1(void)
{
	SetAngles(m_vecPos1);
	ClearVelocity();
	ReleaseThink();
	m_moverState = MOVER_POS1;
	_PortalClose();
	MoverFinishesMoving();
}

void
NSMoverEntity::_RotatedToPosition2(void)
{
	SetAngles(m_vecPos2);
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