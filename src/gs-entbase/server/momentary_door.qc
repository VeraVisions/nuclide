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

/*QUAKED momentary_door (0 .5 .8) ?
Dynamic door that will move back down if it's not being used.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class
momentary_door:NSMomentary
{
	void(void) momentary_door;

	virtual void(string, string) SpawnKey;
	virtual void(void) Respawn;
	virtual void(void) SetMovementDirection;

	virtual void(void) MovementDone;
	virtual void(void) MovementStateChanged;
	virtual float(void) GetProgress;
};

void
momentary_door::momentary_door(void)
{
}

void
momentary_door::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "lip":
		m_flDistance = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "returnspeed":
		m_flReturnspeed = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
momentary_door::Respawn(void)
{
	RestoreAngles();
	SetMovementDirection();
	ClearAngles();
	ClearVelocity();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());

	m_vecPos1 = GetSpawnOrigin();
	m_vecPos2 = (m_vecPos1 + m_vecMoveDir * (fabs(m_vecMoveDir * size) - m_flDistance));
}

float
momentary_door::GetProgress(void)
{
	return (vlen(origin) / vlen(m_vecPos2));
}


void
momentary_door::MovementDone(void)
{
	m_vecDest = [0,0,0];
	ClearVelocity();
}

void
momentary_door::MovementStateChanged(void)
{
	vector vecDifference;
	float flTravelLength;
	float flTravelTime;
	float flSpeed;

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

	vecDifference = (m_vecDest - origin);
	flTravelLength = vlen(vecDifference);
	flTravelTime = (flTravelLength / m_flSpeed);

	if (flTravelTime < 0.1) {
		MovementDone();
		return;
	}

	ScheduleThink(MovementDone, flTravelTime);
	SetVelocity(vecDifference * (1.0f / flTravelTime));
}

void
momentary_door::SetMovementDirection(void)
{
	if (GetSpawnAngles() == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (GetSpawnAngles() == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(GetSpawnAngles());
		m_vecMoveDir = v_forward;
	}
}
