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

/*QUAKED func_plat (0 .5 .8) ? FNCPLAT_TRIGGER
It's a simple elevator. It goes down... and back up.

-------- KEYS --------
"targetname" : Name
"speed" : Speed of the lift in units per second
"height" : Number of units the lift is supposed to move down

-------- TRIVIA --------
This entity was introduced in Quake (1996).
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

class
func_plat:NSRenderableEntity
{
	int m_iState;
	float m_flSpeed;
	float m_flHeight;

public:
	void func_plat(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity,int);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void SpawnKey(string,string);

	virtual void ArrivedUp(void);
	virtual void ArrivedDown(void);
	virtual void MoveToggle(void);
	virtual void Move(vector, void(void));
};

void
func_plat::func_plat(void)
{
	m_flSpeed = 100.0f;
	m_flHeight = 0.0f;
	m_iState = 0i;
}

void
func_plat::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "state", m_iState);
	SaveFloat(handle, "speed", m_flSpeed);
	SaveFloat(handle, "height", m_flHeight);
}

void
func_plat::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "state":
		m_iState = ReadInt(strValue);
		break;
	case "speed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "height":
		m_flHeight = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
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
		super::SpawnKey(strKey, strValue);
	}
}

void
func_plat::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	ClearAngles();

	m_iState = PLATSTATE_RAISED;
	ReleaseThink();
}

void
func_plat::ArrivedUp(void)
{
	ClearVelocity();
	m_iState = PLATSTATE_RAISED;
}

void
func_plat::ArrivedDown(void)
{
	ClearVelocity();
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
	SetThink(vFunc);

	if (fTravelTime < 0.1) {
		ClearVelocity();
		SetNextThink(0.1f);
		return;
	}

	SetVelocity(vecDifference * (1.0f / fTravelTime));
	SetNextThink(fTravelTime);
}

void
func_plat::MoveToggle(void)
{
	if (m_iState == PLATSTATE_RAISED) {
		Move(GetSpawnOrigin() - [0,0,m_flHeight], ArrivedDown);
	} else if (m_iState == PLATSTATE_LOWERED) {
		Move(GetSpawnOrigin(), ArrivedUp);
	}
}

void
func_plat::Trigger(entity act, int state)
{
	if (HasSpawnFlags(FNCPLAT_TRIGGER))
		return;
	
	switch (state) {
	case TRIG_OFF:
		Move(GetSpawnOrigin() - [0,0,m_flHeight], ArrivedDown);
		break;
	case TRIG_ON:
		Move(GetSpawnOrigin(), ArrivedUp);
		break;
	default:
		MoveToggle();
	}
}

void
func_plat::Touch(entity eToucher)
{
	if (eToucher.movetype != MOVETYPE_WALK) {
		return;
	}

	MoveToggle();
}
