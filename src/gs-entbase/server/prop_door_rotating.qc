/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

class prop_door_rotating:CBaseTrigger
{
	vector m_vecDest1;
	vector m_vecDest2;
	float m_flDistance;
	float m_flSpeed;

	void(void) prop_door_rotating;

	virtual void(void) Respawn;
	virtual void(void) Interact;

	virtual void(vector, void(void)) Turn;
	virtual void(void) Opened;
	virtual void(void) Closed;
};

void
prop_door_rotating::Turn(vector vecDest, void(void) vFunc)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	if (!m_flSpeed) {
		dprint(sprintf("^1prop_door_rotating::^3RotToDest^7: No speed defined for %s!", targetname));
		prop_door_rotating::Respawn();
		return;
	}

	vecAngleDifference = (vecDest - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / m_flSpeed);
	avelocity = (vecAngleDifference * (1 / flTravelTime));
	think = vFunc;
	nextthink = (ltime + flTravelTime);
}

void
prop_door_rotating::Closed(void)
{
	avelocity = [0,0,0];
	angles = m_vecDest1;
	PlayerUse = Interact;
}

void
prop_door_rotating::Opened(void)
{
	avelocity = [0,0,0];
	angles = m_vecDest2;
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
	frame = 1;
	frame1time = 0.0f;
	SetSendFlags(BASEFL_CHANGED_FRAME);

	if (m_iValue)
		think = TurnAway;
	else
		think = TurnBack;

	nextthink = ltime + 0.25f;
	PlayerUse = __NULL__;
}

void
prop_door_rotating::Respawn(void)
{
	SetModel(m_oldModel);
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetOrigin(m_oldOrigin);
	PlayerUse = Interact;
	m_vecDest1 = m_oldAngle;
	m_vecDest2 = m_vecDest1 + [0, m_flDistance, 0];
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
prop_door_rotating::prop_door_rotating(void)
{
	m_flDistance = 90;
	m_flSpeed = 100;
	CBaseTrigger::CBaseTrigger();
}
