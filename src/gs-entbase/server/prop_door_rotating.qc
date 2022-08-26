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

#define PRPDRFL_OPEN		1
#define PRPDRFL_LOCKED		2048
#define PRPDRFL_SILENT		4096
#define PRPDRFL_USECLOSES	8192
#define PRPDRFL_NOALERT		16384
#define PRPDRFL_NOUSE		32768

class
prop_door_rotating:NSPointTrigger
{
	vector m_vecDest1;
	vector m_vecDest2;
	float m_flDistance;
	float m_flSpeed;

	void(void) prop_door_rotating;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) Respawn;

	virtual void(void) Interact;
	virtual void(vector, void(void)) Turn;
	virtual void(void) Opened;
	virtual void(void) Closed;
};

void
prop_door_rotating::prop_door_rotating(void)
{
	m_vecDest1 = [0.0f, 0.0f, 0.0f];
	m_vecDest2 = [0.0f, 0.0f, 0.0f];
	m_flDistance = 90;
	m_flSpeed = 100;
}

void
prop_door_rotating::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecDest1", m_vecDest1);
	SaveVector(handle, "m_vecDest2", m_vecDest2);
	SaveFloat(handle, "m_flDistance", m_flDistance);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
}

void
prop_door_rotating::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecDest1":
		m_vecDest1 = ReadVector(strValue);
		break;
	case "m_vecDest2":
		m_vecDest2 = ReadVector(strValue);
		break;
	case "m_flDistance":
		m_flDistance = ReadFloat(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
prop_door_rotating::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "distance":
		m_flDistance = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
prop_door_rotating::Respawn(void)
{
	SetModel(GetSpawnModel());
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetOrigin(GetSpawnOrigin());
	PlayerUse = Interact;
	m_vecDest1 = GetSpawnAngles();
	m_vecDest2 = m_vecDest1 + [0, m_flDistance, 0];
}

void
prop_door_rotating::Turn(vector vecDest, void(void) vFunc)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	if (!m_flSpeed) {
		NSLog("^1prop_door_rotating::^3RotToDest^7: No speed defined for %s!", targetname);
		prop_door_rotating::Respawn();
		return;
	}

	vecAngleDifference = (vecDest - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / m_flSpeed);
	SetAngularVelocity(vecAngleDifference * (1 / flTravelTime));
	ScheduleThink(vFunc, flTravelTime);
}

void
prop_door_rotating::Closed(void)
{
	ClearVelocity();
	ReleaseThink();
	SetAngles(m_vecDest1);
	PlayerUse = Interact;
}

void
prop_door_rotating::Opened(void)
{
	ClearVelocity();
	ReleaseThink();
	SetAngles(m_vecDest2);
	PlayerUse = Interact;
}

void
prop_door_rotating::Interact(void)
{
	static void TurnAway(void) {
		Turn(m_vecDest2, Opened);
	}
	static void TurnBack(void) {
		Turn(m_vecDest1, Closed);
	}

	m_iValue = 1 - m_iValue;

	SetFrame(1);
	SetSendFlags(BASEFL_CHANGED_FRAME);

	if (m_iValue)
		ScheduleThink(TurnAway, 0.25f);
	else
		ScheduleThink(TurnBack, 0.25f);

	PlayerUse = __NULL__;
}
