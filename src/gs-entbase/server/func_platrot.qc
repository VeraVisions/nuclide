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

/*QUAKED func_platrot (0 .5 .8) ?
A vertically moving platform that rotates.

-------- KEYS --------
"targetname"     : Name
"noise1"         : Sound when moving
"noise2"         : Sound when stopped
"speed"          : Speed of rotation in u/s
"height"         : Vertical travel distance
"rotation"       : Rotation amount, in degrees

-------- NOTES --------

-------- HISTORY --------
This entity was introduced in Half-Life (1998).
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
func_platrot:NSRenderableEntity
{
	int m_iState;
	float m_flSpeed;
	float m_flHeight;
	string m_strNoise1;
	string m_strNoise2;
	float m_flRotation;

public:
	void func_platrot(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity,int);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void SpawnKey(string,string);

	virtual void Move(vector, vector, void(void));
	virtual void ArrivedUp(void);
	virtual void ArrivedDown(void);
	virtual void MoveToggle(void);
};

void
func_platrot::func_platrot(void)
{
	m_iState = 0i;
	m_flSpeed = 100.0f;
	m_flHeight = 0.0f;
	m_strNoise1 = __NULL__;
	m_strNoise2 = __NULL__;
	m_flRotation = 0.0f;
}

void
func_platrot::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iState", m_iState);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flHeight", m_flHeight);
	SaveString(handle, "m_strNoise1", m_strNoise1);
	SaveString(handle, "m_strNoise2", m_strNoise2);
	SaveFloat(handle, "m_flRotation", m_flRotation);
}

void
func_platrot::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iState":
		m_iState = ReadInt(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flHeight":
		m_flHeight = ReadFloat(strValue);
		break;
	case "m_strNoise1":
		m_strNoise1 = ReadString(strValue);
		break;
	case "m_strNoise2":
		m_strNoise2 = ReadString(strValue);
		break;
	case "m_flRotation":
		m_flRotation = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_platrot::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "height":
		m_flHeight = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "noise1":
		m_strNoise1 = strValue;
		break;
	case "noise2":
		m_strNoise2 = strValue;
		break;
	case "rotation":
		m_flRotation = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_platrot::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());

	m_iState = PLATSTATE_RAISED;
	ReleaseThink();
}

void
func_platrot::ArrivedUp(void)
{
	ClearVelocity();
	m_iState = PLATSTATE_RAISED;

	sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);

	if (m_strNoise2)
		sound(this, CHAN_WEAPON, m_strNoise2, 1.0f, ATTN_NORM);
}

void
func_platrot::ArrivedDown(void)
{
	ClearVelocity();
	m_iState = PLATSTATE_LOWERED;

	sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);

	if (m_strNoise2)
		sound(this, CHAN_WEAPON, m_strNoise2, 1.0f, ATTN_NORM);
}

void
func_platrot::Move(vector vecDest, vector vecADest, void() vFunc)
{
	vector vecDifference, vecADifference;
	float flTravel, fTravelTime;

	m_iState = PLATSTATE_DOWN;
	vecDifference = (vecDest - origin);
	vecADifference = vecADest - angles;
	flTravel = vlen(vecDifference);
	fTravelTime = (flTravel / m_flSpeed);
	SetThink(vFunc);

	if (fTravelTime < 0.1) {
		ClearVelocity();
		SetNextThink(0.1f);
		return;
	}

	
	SetAngularVelocity(vecADifference * (1.0f / fTravelTime));
	SetVelocity(vecDifference * (1.0f / fTravelTime));
	SetNextThink(ltime + fTravelTime);

	if (m_strNoise1)
		sound(this, CHAN_VOICE, m_strNoise1, 1.0f, ATTN_NORM);
}

void
func_platrot::MoveToggle(void)
{
	if (m_iState == PLATSTATE_RAISED) {
		Move(GetSpawnOrigin() - [0,0,m_flHeight], GetSpawnAngles() + [0, m_flRotation, 0], ArrivedDown);
	} else if (m_iState == PLATSTATE_LOWERED) {
		Move(GetSpawnOrigin(), GetSpawnAngles(), ArrivedUp);
	}
}

void
func_platrot::Trigger(entity act, int state)
{
	if (HasSpawnFlags(FNCPLAT_TRIGGER))
		return;
	
	switch (state) {
	case TRIG_OFF:
		Move(GetSpawnOrigin() - [0,0,m_flHeight], GetSpawnAngles() + [0, m_flRotation, 0], ArrivedDown);
		break;
	case TRIG_ON:
		Move(GetSpawnOrigin(), GetSpawnAngles(), ArrivedUp);
		break;
	default:
		MoveToggle();
	}
}

void
func_platrot::Touch(entity eToucher)
{
	if (eToucher.movetype != MOVETYPE_WALK) {
		return;
	}

	MoveToggle();
}
