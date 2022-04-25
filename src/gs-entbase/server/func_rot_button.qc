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

/*QUAKED func_rot_button (0 .5 .8) ? FNCROTBUT_NONSOLID FNCROTBUT_REVERSE x x x FNCROTBUT_TOGGLE FNCROTBUT_XAXIS FNCROTBUT_YAXIS FNCROTBUT_TOUCHABLE
A button that rotates along a pivot point. Used for valves, spigots and alike.

-------- KEYS --------
"targetname" : Name
"target" : Name of the entity to trigger when opened
"speed" : How fast the button rotates when activated.
"health" : If non-zero, the button must be damaged to turn.
"wait" : Time to wait before button resets itself. -1 makes it stay set.
"distance" : Distance in degrees the button will rotate.

-------- SPAWNFLAGS --------
FNCROTBUT_NONSOLID : Don't do collision testing against this entity.
FNCROTBUT_REVERSE : Rotate the counter-clockwise.
FNCROTBUT_TOGGLE : Can only be activated via trigger, not player interaction.
FNCROTBUT_XAXIS : Rotate along the X-axis.
FNCROTBUT_YAXIS : Rotate along the Y-axis.

-------- NOTES --------
Please include an origin brush so that a pivot point will be defined.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	FNCROTBUT_NONSOLID,
	FNCROTBUT_REVERSE,
	FNCROTBUT_UNUSED1,
	FNCROTBUT_UNUSED2,
	FNCROTBUT_UNUSED3,
	FNCROTBUT_TOGGLE,
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

class func_rot_button:NSRenderableEntity
{
	vector m_vecMoveAngle;
	int m_iState;
	int m_iHealth;

	float m_flSpeed;
	float m_flDistance;
	float m_flReturnTime;

	void(void) func_rot_button;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(string, string) SpawnKey;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(void) Death;

	virtual void(void) ArrivedClosed;
	virtual void(void) ArrivedOpened;
	virtual void(void) TriggerTargets;
	virtual void(vector, void()) Rotate;
	virtual void(void) TurnToggle;
	virtual void(void) OnPlayerUse;
};

void
func_rot_button::Save(float handle)
{
	SaveVector(handle, "moveangle", m_vecMoveAngle);
	SaveInt(handle, "state", m_iState);
	SaveInt(handle, "health", m_iHealth);
	SaveFloat(handle, "speed", m_flSpeed);
	SaveFloat(handle, "distance", m_flDistance);
	SaveFloat(handle, "returntime", m_flReturnTime);
	super::Save(handle);
}

void
func_rot_button::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "moveangle":
		m_vecMoveAngle = ReadVector(strValue);
		break;
	case "state":
		m_iState = ReadInt(strValue);
		break;
	case "health":
		m_iHealth = ReadInt(strValue);
		break;
	case "speed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "distance":
		m_flDistance = ReadFloat(strValue);
		break;
	case "returntime":
		m_flReturnTime = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_rot_button::TriggerTargets(void)
{
	UseTargets(this, TRIG_TOGGLE, m_flDelay);
}

void
func_rot_button::ArrivedClosed(void)
{
	avelocity = [0,0,0];
	m_iState = ROTBTNSTATE_CLOSED;
	TriggerTargets();

	if (m_flReturnTime > 0.0f) {
		think = TurnToggle;
		nextthink = ltime + m_flReturnTime;
	}
}

void
func_rot_button::ArrivedOpened(void)
{
	avelocity = [0,0,0];
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
	avelocity = (vecAngleDifference * (1 / flTravelTime));

	think = vFunc;
	nextthink = (ltime + flTravelTime);
}

void
func_rot_button::OnPlayerUse(void)
{
	TurnToggle();
}

void
func_rot_button::Touch(entity eToucher)
{
	eActivator = eToucher;

	if (HasSpawnFlags(FNCROTBUT_TOUCHABLE))
		TurnToggle();
}

void
func_rot_button::TurnToggle(void)
{
	if (m_iState == ROTBTNSTATE_OPENED) {
		Rotate(m_vecMoveAngle, ArrivedClosed);
	} else if (m_iState == ROTBTNSTATE_CLOSED) {
		Rotate(GetSpawnAngles(), ArrivedOpened);

		/* in toggle mode, we trigger our targets every turn */
		if (HasSpawnFlags(FNCROTBUT_TOGGLE))
			TriggerTargets();
	}
}

void
func_rot_button::Death(void)
{
	takedamage = DAMAGE_NO;
	TurnToggle();
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
	PlayerUse = OnPlayerUse;
	
	m_iState = ROTBTNSTATE_OPENED;
	think = __NULL__;
	nextthink = 0.0f;

	if (m_iHealth > 0) {
		takedamage = DAMAGE_YES;
		health = m_iHealth;
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
	case "health":
		m_iHealth = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_rot_button::func_rot_button(void)
{
	super::NSRenderableEntity();
}
