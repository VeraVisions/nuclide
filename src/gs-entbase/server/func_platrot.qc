/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

class func_platrot:NSRenderableEntity
{
	int m_iState;
	float m_flSpeed;
	float m_flHeight;
	string m_strNoise1;
	string m_strNoise2;
	float m_flRotation;

	void(void) func_platrot;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(void) ArrivedUp;
	virtual void(void) ArrivedDown;
	virtual void(vector, vector, void(void)) Move;
	virtual void(void) MoveToggle;
	virtual void(void) Respawn;
	virtual void(entity) Touch;
	virtual void(string, string) SpawnKey;
};

void
func_platrot::Save(float handle)
{
	SaveInt(handle, "state", m_iState);
	SaveFloat(handle, "speed", m_flSpeed);
	SaveFloat(handle, "height", m_flHeight);
	SaveString(handle, "noise1", m_strNoise1);
	SaveString(handle, "noise2", m_strNoise2);
	SaveFloat(handle, "rotation", m_flRotation);
	super::Save(handle);
}

void
func_platrot::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "state":
		m_iState = ReadInt(strValue);
		break;
	case "spped":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "height":
		m_flHeight = ReadFloat(strValue);
		break;
	case "noise1":
		m_strNoise1 = ReadString(strValue);
		break;
	case "noise2":
		m_strNoise2 = ReadString(strValue);
		break;
	case "rotation":
		m_flRotation = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_platrot::ArrivedUp(void)
{
	avelocity = velocity = [0,0,0];
	m_iState = PLATSTATE_RAISED;

	sound(this, CHAN_VOICE, "common/null.wav", 1.0f, ATTN_NORM);

	if (m_strNoise2)
		sound(this, CHAN_WEAPON, m_strNoise2, 1.0f, ATTN_NORM);
}

void
func_platrot::ArrivedDown(void)
{
	avelocity = velocity = [0,0,0];
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
	think = vFunc;

	if (fTravelTime < 0.1) {
		velocity = [0,0,0];
		nextthink = ltime + 0.1f;
		return;
	}

	avelocity = (vecADifference * (1.0f / fTravelTime));
	velocity = (vecDifference * (1.0f / fTravelTime));
	nextthink = (ltime + fTravelTime);

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

void
func_platrot::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());
	
	m_iState = PLATSTATE_RAISED;
	think = __NULL__;
	nextthink = 0.0f;
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
func_platrot::func_platrot(void)
{
	m_flSpeed = 100.0f;
	super::NSRenderableEntity();
}