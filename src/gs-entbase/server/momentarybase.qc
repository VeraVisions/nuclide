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

enum
{
	MOMENTARY_IDLE,
	MOMENTARY_ROTATING,
	MOMENTARY_RETURNING
};

class
NSMomentary:NSRenderableEntity
{
	entity m_eUser;
	vector m_vecMoveDir;
	vector m_vecPos1;
	vector m_vecPos2;
	vector m_vecDest;

	int m_iMoveState;

	/* map keys */
	float m_flDistance;
	float m_flSpeed;
	float m_flReturnspeed;

	void(void) NSMomentary;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;

	virtual void(int) SetMoveState;
	virtual void(void) MovementStateChanged;
	virtual float(void) GetProgress;
};

void
NSMomentary::NSMomentary(void)
{
	m_eUser = __NULL__;
	m_vecMoveDir = [0.0f, 0.0f, 0.0f];
	m_vecPos1 = [0.0f, 0.0f, 0.0f];
	m_vecPos2 = [0.0f, 0.0f, 0.0f];
	m_vecDest = [0.0f, 0.0f, 0.0f];
	m_iMoveState = 0i;
	m_flDistance = 0.0f;
	m_flSpeed = 0.0f;
	m_flReturnspeed = 0.0f;
}

void
NSMomentary::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_eUser", m_eUser);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
	SaveVector(handle, "m_vecPos1", m_vecPos1);
	SaveVector(handle, "m_vecPos2", m_vecPos2);
	SaveFloat(handle, "m_flDistance", m_flDistance);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flReturnspeed", m_flReturnspeed);
	SaveInt(handle, "m_iMoveState", m_iMoveState);
}

void
NSMomentary::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_eUser":
		m_eUser = ReadEntity(strValue);
		break;
	case "m_vecMoveDir":
		m_vecMoveDir = ReadVector(strValue);
		break;
	case "m_vecPos1":
		m_vecPos1 = ReadVector(strValue);
		break;
	case "m_vecPos2":
		m_vecPos2 = ReadVector(strValue);
		break;
	case "m_flDistance":
		m_flDistance = ReadFloat(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flReturnspeed":
		m_flReturnspeed = ReadFloat(strValue);
		break;
	case "m_iMoveState":
		m_iMoveState = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

float
NSMomentary::GetProgress(void)
{
	return 0.0f;
}

void
NSMomentary::MovementStateChanged(void)
{
	/* this is handled by the respective sub entity */
}

void
NSMomentary::SetMoveState(int status)
{
	if (m_iMoveState == status)
		return;

	m_iMoveState = status;
	MovementStateChanged();
}
