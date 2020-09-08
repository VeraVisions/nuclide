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

/*QUAKED func_plat (0 .5 .8) ? FNCPLAT_TRIGGER
"targetname"    Name
"speed"         Speed of the lift in units per second
"height"        Number of units the lift is supposed to move down

It's a simple elevator. It goes down... and back up.
*/

enumflags
{
	FNCPLAT_TRIGGER,
};

enum
{
	PLATSTATE_RAISED,
	PLATSTATE_LOWERED,
	PLATSTATE_UP,
	PLATSTATE_DOWN
};

class func_plat:CBaseTrigger
{
	int m_iState;

	float m_flSpeed;
	float m_flHeight;

	void(void) func_plat;
	virtual void(entity, int) Trigger;
	virtual void(void) ArrivedUp;
	virtual void(void) ArrivedDown;
	virtual void(vector, void(void)) Move;
	virtual void(void) MoveToggle;
	virtual void(void) Respawn;
	virtual void(void) touch;
	virtual void(string, string) SpawnKey;
};

void
func_plat::ArrivedUp(void)
{
	velocity = [0,0,0];
	m_iState = PLATSTATE_RAISED;
}

void
func_plat::ArrivedDown(void)
{
	velocity = [0,0,0];
	m_iState = PLATSTATE_LOWERED;
}

void
func_plat::Move(vector vecDest, void() vFunc)
{
	vector vecDifference;
	float flTravel, fTravelTime;

	m_iState = PLATSTATE_DOWN;
	vecDifference = (vecDest - origin);
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);
	think = vFunc;

	if (fTravelTime < 0.1) {
		velocity = [0,0,0];
		nextthink = ltime + 0.1f;
		return;
	}

	velocity = (vecDifference * (1.0f / fTravelTime));
	nextthink = (ltime + fTravelTime);
}

void
func_plat::MoveToggle(void)
{
	if (m_iState == PLATSTATE_RAISED) {
		Move(m_oldOrigin - [0,0,m_flHeight], ArrivedDown);
	} else if (m_iState == PLATSTATE_LOWERED) {
		Move(m_oldOrigin, ArrivedUp);
	}
}

void
func_plat::Trigger(entity act, int state)
{
	if (spawnflags & FNCPLAT_TRIGGER)
		return;
	
	switch (state) {
	case TRIG_OFF:
		Move(m_oldOrigin - [0,0,m_flHeight], ArrivedDown);
		break;
	case TRIG_ON:
		Move(m_oldOrigin, ArrivedUp);
		break;
	default:
		MoveToggle();
	}
}

void
func_plat::touch(void)
{
	if (other.movetype != MOVETYPE_WALK) {
		return;
	}

	MoveToggle();
}

void
func_plat::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	
	m_iState = PLATSTATE_RAISED;
	think = __NULL__;
	nextthink = 0.0f;
}

void
func_plat::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "height":
		m_flHeight = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
func_plat::func_plat(void)
{
	m_flSpeed = 100.0f;
	CBaseTrigger::CBaseTrigger();
}
