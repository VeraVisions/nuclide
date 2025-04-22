/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

/*! \brief Server-Entity: Valve, Lever, Rotating Button */
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

@ingroup serverentity
@ingroup brushentity
*/
class
func_rot_button:ncSurfacePropEntity
{
public:
	void func_rot_button(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Touch(entity);
	virtual void Death(entity, entity, int, vector, vector, int);
	virtual void OnPlayerUse(void);
	
	nonvirtual void ArrivedClosed(void);
	nonvirtual void ArrivedOpened(void);
	nonvirtual void TriggerTargets(void);
	nonvirtual void Rotate(vector, void());
	nonvirtual void TurnToggle(void);

private:
	vector m_rotatingButtonDestination;
	int m_rotatingButtonState;
	float m_rotatingButtonSpeed;
	float m_rotatingButtonDistance;
	float m_timeUntilReturn;
};

void
func_rot_button::func_rot_button(void)
{
	m_rotatingButtonDestination = [0.0f, 0.0f, 0.0f];
	m_rotatingButtonState = 0i;
	m_rotatingButtonSpeed = 0.0f;
	m_rotatingButtonDistance = 0.0f;
	m_timeUntilReturn = 0.0f;
}

void
func_rot_button::Save(float handle)
{
	super::Save(handle);

	SaveVector(handle, "rotatingButtonDestination", m_rotatingButtonDestination);
	SaveInt(handle, "rotatingButtonState", m_rotatingButtonState);
	SaveFloat(handle, "rotatingButtonSpeed", m_rotatingButtonSpeed);
	SaveFloat(handle, "rotatingButtonDistance", m_rotatingButtonDistance);
	SaveFloat(handle, "timeUntilReturn", m_timeUntilReturn);
}

void
func_rot_button::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "rotatingButtonDestination":
		m_rotatingButtonDestination = ReadVector(setValue);
		break;
	case "rotatingButtonState":
		m_rotatingButtonState = ReadInt(setValue);
		break;
	case "rotatingButtonSpeed":
		m_rotatingButtonSpeed = ReadFloat(setValue);
		break;
	case "rotatingButtonDistance":
		m_rotatingButtonDistance = ReadFloat(setValue);
		break;
	case "timeUntilReturn":
		m_timeUntilReturn = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
func_rot_button::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "distance":
		m_rotatingButtonDistance = stof(setValue);
		break;
	case "speed":
		m_rotatingButtonSpeed = stof(setValue);
		break;
	case "wait":
		m_timeUntilReturn = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
func_rot_button::Respawn(void)
{
	vector movementDir;

	super::Respawn();

	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	AddFlags(FL_FINDABLE_NONSOLID);
	MakeInvulnerable();
	PlayerUse = OnPlayerUse;
	ReleaseThink();

	m_rotatingButtonState = ROTBTNSTATE_OPENED;

	if (HasSpawnFlags(FNCROTBUT_NONSOLID)) {
		SetSolid(SOLID_NOT);
	} else {
		SetHealth(GetSpawnFloat("health"));

		if (GetHealth() > 0) {
			MakeVulnerable();
		}
	}

	if (HasSpawnFlags(FNCROTBUT_XAXIS)) {
		movementDir = [0,0,1];
	} else if (HasSpawnFlags(FNCROTBUT_YAXIS)) {
		movementDir = [0,1,0];
	} else {
		movementDir = [1,0,0];
	}

	if (HasSpawnFlags(FNCROTBUT_REVERSE)) {
		movementDir *= -1;
	}

	m_rotatingButtonDestination = movementDir * m_rotatingButtonDistance;
}

void
func_rot_button::TriggerTargets(void)
{
	UseTargets(this, TRIG_TOGGLE, GetTriggerDelay());
}

void
func_rot_button::ArrivedClosed(void)
{
	m_rotatingButtonState = ROTBTNSTATE_CLOSED;

	ClearVelocity();
	ReleaseThink();
	TriggerTargets();

	if (HasSpawnFlags(FNCROTBUT_NOAUTORETURN) == true) {
		return;
	}

	if (m_timeUntilReturn > 0.0f) {
		ScheduleThink(TurnToggle, m_timeUntilReturn);
	}
}

void
func_rot_button::ArrivedOpened(void)
{
	ClearVelocity();
	ReleaseThink();
	m_rotatingButtonState = ROTBTNSTATE_OPENED;
}

void
func_rot_button::Rotate(vector vecDest, void(void) vFunc)
{
	vector vecAngleDifference;
	float flTravelLength, flTravelTime;

	vecAngleDifference = (vecDest - angles);
	flTravelLength = vlen(vecAngleDifference);
	flTravelTime = (flTravelLength / m_rotatingButtonSpeed);

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
	eActivator = (ncEntity)eToucher;

	if (HasSpawnFlags(FNCROTBUT_TOUCHABLE)) {
		TurnToggle();
	}
}

void
func_rot_button::TurnToggle(void)
{
	if (m_rotatingButtonState == ROTBTNSTATE_OPENED) {
		Rotate(m_rotatingButtonDestination, ArrivedClosed);
	} else if (m_rotatingButtonState == ROTBTNSTATE_CLOSED) {
		if (m_timeUntilReturn == -1) {
			return;
		}

		Rotate(GetSpawnVector("angles"), ArrivedOpened);

		/* in toggle mode, we trigger our targets every turn */
		if (HasSpawnFlags(FNCROTBUT_NOAUTORETURN)) {
			TriggerTargets();
		}
	}
}

void
func_rot_button::Death(entity inflictor, entity attacker, int damage, vector dir, vector absImpactPos, int hitBody)
{
	MakeInvulnerable();
	TurnToggle();
}
