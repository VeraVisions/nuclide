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

enumflags
{
	FNCROTBUT_NONSOLID,
	FNCROTBUT_REVERSE,
	FNCROTBUT_UNUSED1,
	FNCROTBUT_UNUSED2,
	FNCROTBUT_UNUSED3,
	FNCROTBUT_NOAUTORETURN,
	FNCROTBUT_XAXIS,
	FNCROTBUT_YAXIS,
	FNCROTBUT_TOUCHABLE
};

enum
{
	ROTBTNSTATE_OPENED,
	ROTBTNSTATE_CLOSED,
	ROTBTNSTATE_OPENING,
	ROTBTNSTATE_CLOSING
};

/*!QUAKED func_rot_button (0 .5 .8) ? NONSOLID REVERSE x x x NOAUTORETURN XAXIS YAXIS TOUCHABLE
# OVERVIEW
A button that rotates along a pivot point. Used for valves, spigots and alike.

# KEYS
- "targetname" : Name
- "target" : Name of the entity to trigger when opened
- "speed" : How fast the button turns when activated.
- "health" : If non-zero, the button must be damaged to turn.
- "wait" : Time until the button turns back. A value of -1 makes it stay static.
- "distance" : Distance in degrees the button will rotate.

# SPAWNFLAGS
- NONSOLID (1) : Button won't have collision.
- REVERSE (2) : Rotates counter-clockwise.
- NOAUTORETURN (32) : Will not return by itself. 
- XAXIS (64) : Rotate along the X-axis.
- YAXIS (128) : Rotate along the Y-axis.

# NOTES
Please include an origin brush so that a pivot point will be defined.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
func_rot_button:NSSurfacePropEntity
{
public:
	void func_rot_button(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void Death(void);
	virtual void OnPlayerUse(void);
	
	nonvirtual void ArrivedClosed(void);
	nonvirtual void ArrivedOpened(void);
	nonvirtual void TriggerTargets(void);
	nonvirtual void Rotate(vector, void());
	nonvirtual void TurnToggle(void);

private:
	vector m_vecMoveAngle;
	int m_iState;
	float m_flSpeed;
	float m_flDistance;
	float m_flReturnTime;
};

void
func_rot_button::func_rot_button(void)
{
	m_vecMoveAngle = [0.0f, 0.0f, 0.0f];
	m_iState = 0i;
	m_flSpeed = 0.0f;
	m_flDistance = 0.0f;
	m_flReturnTime = 0.0f;
}

void
func_rot_button::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecMoveAngle", m_vecMoveAngle);
	SaveInt(handle, "m_iState", m_iState);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveFloat(handle, "m_flDistance", m_flDistance);
	SaveFloat(handle, "m_flReturnTime", m_flReturnTime);
}

void
func_rot_button::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecMoveAngle":
		m_vecMoveAngle = ReadVector(strValue);
		break;
	case "m_iState":
		m_iState = ReadInt(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_flDistance":
		m_flDistance = ReadFloat(strValue);
		break;
	case "m_flReturnTime":
		m_flReturnTime = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_rot_button::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "distance":
		m_flDistance = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "wait":
		m_flReturnTime = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_rot_button::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);

	if (HasSpawnFlags(FNCROTBUT_NONSOLID))
		SetSolid(SOLID_NOT);
	else
		SetSolid(SOLID_BSP);

	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());
	AddFlags(FL_FINDABLE_NONSOLID);
	PlayerUse = OnPlayerUse;

	m_iState = ROTBTNSTATE_OPENED;
	ReleaseThink();

	if (GetSpawnHealth() > 0) {
		SetTakedamage(DAMAGE_YES);
		SetHealth(GetSpawnHealth());
	}

	vector vecMoveDir;
	if (HasSpawnFlags(FNCROTBUT_XAXIS)) {
		vecMoveDir = [0,0,1];
	} else if (HasSpawnFlags(FNCROTBUT_YAXIS)) {
		vecMoveDir = [0,1,0];
	} else {
		vecMoveDir = [1,0,0];
	}

	if (HasSpawnFlags(FNCROTBUT_REVERSE)) {
		vecMoveDir *= -1;
	}

	m_vecMoveAngle = vecMoveDir * m_flDistance;
}

void
func_rot_button::TriggerTargets(void)
{
	UseTargets(this, TRIG_TOGGLE, m_flDelay);
}

void
func_rot_button::ArrivedClosed(void)
{
	ClearVelocity();
	ReleaseThink();

	m_iState = ROTBTNSTATE_CLOSED;
	TriggerTargets();

	if (HasSpawnFlags(FNCROTBUT_NOAUTORETURN) == true) {
		return;
	}

	if (m_flReturnTime > 0.0f) {
		ScheduleThink(TurnToggle, m_flReturnTime);
	}
}

void
func_rot_button::ArrivedOpened(void)
{
	ClearVelocity();
	ReleaseThink();
	m_iState = ROTBTNSTATE_OPENED;
}

void
func_rot_button::Rotate(vector vecDest, void(void) vFunc)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	vecAngleDifference = (vecDest - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / m_flSpeed);

	SetAngularVelocity(vecAngleDifference * (1 / flTravelTime));
	ScheduleThink(vFunc, flTravelTime);
}

void
func_rot_button::OnPlayerUse(void)
{
	TurnToggle();
}

void
func_rot_button::Touch(entity eToucher)
{
	eActivator = (NSEntity)eToucher;

	if (HasSpawnFlags(FNCROTBUT_TOUCHABLE))
		TurnToggle();
}

void
func_rot_button::TurnToggle(void)
{
	if (m_iState == ROTBTNSTATE_OPENED) {
		Rotate(m_vecMoveAngle, ArrivedClosed);
	} else if (m_iState == ROTBTNSTATE_CLOSED) {
		if (m_flReturnTime == -1) {
			return;
		}

		Rotate(GetSpawnAngles(), ArrivedOpened);

		/* in toggle mode, we trigger our targets every turn */
		if (HasSpawnFlags(FNCROTBUT_NOAUTORETURN))
			TriggerTargets();
	}
}

void
func_rot_button::Death(void)
{
	SetTakedamage(DAMAGE_NO);
	TurnToggle();
}
