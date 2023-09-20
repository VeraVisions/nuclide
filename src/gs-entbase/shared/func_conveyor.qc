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

typedef enumflags
{
	CONVEYOR_CHANGED_ORIGIN_X,
	CONVEYOR_CHANGED_ORIGIN_Y,
	CONVEYOR_CHANGED_ORIGIN_Z,
	CONVEYOR_CHANGED_ANGLES_X,
	CONVEYOR_CHANGED_ANGLES_Y,
	CONVEYOR_CHANGED_ANGLES_Z,
	CONVEYOR_CHANGED_MODELINDEX,
	CONVEYOR_CHANGED_SIZE,
	CONVEYOR_CHANGED_FRAME,
	CONVEYOR_CHANGED_SPAWNFLAGS,
	CONVEYOR_CHANGED_SOLIDMOVETYPE,
	CONVEYOR_CHANGED_VELOCITY,
	CONVEYOR_CHANGED_ANGULARVELOCITY,
	CONVEYOR_CHANGED_RENDERCOLOR,
	CONVEYOR_CHANGED_RENDERAMT,
	CONVEYOR_CHANGED_RENDERMODE,
	CONVEYOR_CHANGED_SPEED,
	CONVEYOR_CHANGED_MOVEDIR
} func_conveyor_changed_t;

#define SF_CONVEYOR_VISUAL	1
#define SF_CONVEYOR_NOTSOLID	2

/*!QUAKED func_conveyor (0 .5 .8) ? SF_CONVEYOR_VISUAL SF_CONVEYOR_NOTSOLID
# OVERVIEW
A conveyor belt entity. Texture will move along in the direction and speed of the conveyor.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.

# SPAWNFLAGS
- SF_CONVEYOR_VISUAL (1) : This conveyor does not affect entities physically.
- SF_CONVEYOR_NOTSOLID (2) : This conveyor is non-solid.

# TRIVIA
This entity was introduced in Quake II (1997).
*/
class
func_conveyor:NSRenderableEntity
{
	PREDICTED_FLOAT(m_flSpeed)
	PREDICTED_VECTOR(m_vecMoveDir)
	PREDICTED_FLOAT_N(spawnflags)

public:
	void(void) func_conveyor;

	virtual void Touch(entity);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual float SendEntity(entity,float);
	virtual void SetMovementDirection(void);
	virtual void Input(entity, string, string);
	virtual void SpawnKey(string,string);
	virtual void EvaluateEntity(void);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
#endif

};

void
func_conveyor::func_conveyor(void)
{
	m_flSpeed = 0.0f;
	m_vecMoveDir = [0.0f, 0.0f, 0.0f];
}

#ifdef SERVER
void
func_conveyor::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
}

void
func_conveyor::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_vecMoveDir":
		m_vecMoveDir = ReadVector(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_conveyor::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
func_conveyor::Respawn(void)
{
	if (!m_flSpeed)
		m_flSpeed = 100;

	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSP);
	SetModel(GetSpawnModel());

	Trigger(this, TRIG_ON);

	if (HasSpawnFlags(SF_CONVEYOR_NOTSOLID)) {
		SetSolid(SOLID_NOT);
		SetSkin(0);
	}
}

void
func_conveyor::SetMovementDirection(void)
{
	if (angles == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (angles == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(angles);
		m_vecMoveDir = v_forward;
	}
}

void 
func_conveyor::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_ON:
		m_flSpeed = fabs(m_flSpeed);
		break;
	case TRIG_OFF:
		m_flSpeed = -fabs(m_flSpeed);
		break;
	default:
		m_flSpeed = -m_flSpeed;
		break;
	}

	/* changes direction */
	glowmod[1] = 0.5;
	glowmod[2] = m_flSpeed / 1024;
	SetSendFlags(CONVEYOR_CHANGED_RENDERCOLOR);
}

void
func_conveyor::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "ToggleDirection":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	case "SetSpeed":
		m_flSpeed = stof(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}


void
func_conveyor::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, CONVEYOR_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, CONVEYOR_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, CONVEYOR_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, CONVEYOR_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, CONVEYOR_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, CONVEYOR_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, CONVEYOR_CHANGED_MODELINDEX)
	EVALUATE_FIELD(colormap, CONVEYOR_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, CONVEYOR_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, CONVEYOR_CHANGED_SOLIDMOVETYPE)
	EVALUATE_VECTOR(mins, 0, CONVEYOR_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, CONVEYOR_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, CONVEYOR_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, CONVEYOR_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, CONVEYOR_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, CONVEYOR_CHANGED_SIZE)
	EVALUATE_FIELD(frame, CONVEYOR_CHANGED_FRAME)
	EVALUATE_FIELD(spawnflags, CONVEYOR_CHANGED_SPAWNFLAGS)
	EVALUATE_VECTOR(velocity, 0, CONVEYOR_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, CONVEYOR_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, CONVEYOR_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, CONVEYOR_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, CONVEYOR_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, CONVEYOR_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_iRenderMode, CONVEYOR_CHANGED_RENDERMODE)
	EVALUATE_FIELD(m_iRenderFX, CONVEYOR_CHANGED_RENDERMODE)
	EVALUATE_VECTOR(m_vecRenderColor, 0, CONVEYOR_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 1, CONVEYOR_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(m_vecRenderColor, 2, CONVEYOR_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 0, CONVEYOR_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 1, CONVEYOR_CHANGED_RENDERCOLOR)
	EVALUATE_VECTOR(glowmod, 2, CONVEYOR_CHANGED_RENDERCOLOR)
	EVALUATE_FIELD(m_flRenderAmt, CONVEYOR_CHANGED_RENDERAMT)
	EVALUATE_FIELD(m_flSpeed, CONVEYOR_CHANGED_SPEED)
	EVALUATE_VECTOR(m_vecMoveDir, 0, CONVEYOR_CHANGED_MOVEDIR)
	EVALUATE_VECTOR(m_vecMoveDir, 1, CONVEYOR_CHANGED_MOVEDIR)
	EVALUATE_VECTOR(m_vecMoveDir, 2, CONVEYOR_CHANGED_MOVEDIR)
}

float
func_conveyor::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_CONVEYOR);

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~CONVEYOR_CHANGED_VELOCITY;
			flChanged &= ~CONVEYOR_CHANGED_ANGULARVELOCITY;
		}

		/* no rendermode means no extra fields */
		if (m_iRenderMode == RM_NORMAL && m_iRenderFX == RFX_NORMAL) {
			flChanged &= ~CONVEYOR_CHANGED_RENDERMODE;
			//flChanged &= ~CONVEYOR_CHANGED_RENDERCOLOR; /* glowmod needs this */
			flChanged &= ~CONVEYOR_CHANGED_RENDERAMT;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], CONVEYOR_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], CONVEYOR_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], CONVEYOR_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], CONVEYOR_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], CONVEYOR_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], CONVEYOR_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, CONVEYOR_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(colormap, CONVEYOR_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, CONVEYOR_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, CONVEYOR_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[0], CONVEYOR_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], CONVEYOR_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], CONVEYOR_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], CONVEYOR_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], CONVEYOR_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], CONVEYOR_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, CONVEYOR_CHANGED_FRAME)
	SENDENTITY_BYTE(spawnflags, CONVEYOR_CHANGED_SPAWNFLAGS)
	SENDENTITY_COORD(velocity[0], CONVEYOR_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], CONVEYOR_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], CONVEYOR_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], CONVEYOR_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], CONVEYOR_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], CONVEYOR_CHANGED_ANGULARVELOCITY)
	SENDENTITY_BYTE(m_iRenderMode, CONVEYOR_CHANGED_RENDERMODE)
	SENDENTITY_BYTE(m_iRenderFX, CONVEYOR_CHANGED_RENDERMODE)
	SENDENTITY_ANGLE(m_vecRenderColor[0], CONVEYOR_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[1], CONVEYOR_CHANGED_RENDERCOLOR)
	SENDENTITY_ANGLE(m_vecRenderColor[2], CONVEYOR_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	SENDENTITY_FLOAT(glowmod[0], CONVEYOR_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[1], CONVEYOR_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(glowmod[2], CONVEYOR_CHANGED_RENDERCOLOR)
	SENDENTITY_FLOAT(m_flRenderAmt, CONVEYOR_CHANGED_RENDERAMT)
	SENDENTITY_FLOAT(m_flSpeed, CONVEYOR_CHANGED_SPEED)
	SENDENTITY_FLOAT(m_vecMoveDir[0], CONVEYOR_CHANGED_MOVEDIR)
	SENDENTITY_FLOAT(m_vecMoveDir[1], CONVEYOR_CHANGED_MOVEDIR)
	SENDENTITY_FLOAT(m_vecMoveDir[2], CONVEYOR_CHANGED_MOVEDIR)

	return true;
}
#endif

#ifdef CLIENT
void
func_conveyor::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], CONVEYOR_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], CONVEYOR_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], CONVEYOR_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], CONVEYOR_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], CONVEYOR_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], CONVEYOR_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, CONVEYOR_CHANGED_MODELINDEX)
	READENTITY_BYTE(colormap, CONVEYOR_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, CONVEYOR_CHANGED_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, CONVEYOR_CHANGED_SOLIDMOVETYPE)
	READENTITY_COORD(mins[0], CONVEYOR_CHANGED_SIZE)
	READENTITY_COORD(mins[1], CONVEYOR_CHANGED_SIZE)
	READENTITY_COORD(mins[2], CONVEYOR_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], CONVEYOR_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], CONVEYOR_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], CONVEYOR_CHANGED_SIZE)
	READENTITY_BYTE(frame, CONVEYOR_CHANGED_FRAME)
	READENTITY_BYTE(spawnflags, CONVEYOR_CHANGED_SPAWNFLAGS)
	READENTITY_COORD(velocity[0], CONVEYOR_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], CONVEYOR_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], CONVEYOR_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], CONVEYOR_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], CONVEYOR_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], CONVEYOR_CHANGED_ANGULARVELOCITY)
	READENTITY_BYTE(m_iRenderMode, CONVEYOR_CHANGED_RENDERMODE)
	READENTITY_BYTE(m_iRenderFX, CONVEYOR_CHANGED_RENDERMODE)
	READENTITY_ANGLE(m_vecRenderColor[0], CONVEYOR_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[1], CONVEYOR_CHANGED_RENDERCOLOR)
	READENTITY_ANGLE(m_vecRenderColor[2], CONVEYOR_CHANGED_RENDERCOLOR)
	/* these need more precision for shader hacks... */
	READENTITY_FLOAT(glowmod[0], CONVEYOR_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[1], CONVEYOR_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(glowmod[2], CONVEYOR_CHANGED_RENDERCOLOR)
	READENTITY_FLOAT(m_flRenderAmt, CONVEYOR_CHANGED_RENDERAMT)
	READENTITY_FLOAT(m_flSpeed, CONVEYOR_CHANGED_SPEED)
	READENTITY_FLOAT(m_vecMoveDir[0], CONVEYOR_CHANGED_MOVEDIR)
	READENTITY_FLOAT(m_vecMoveDir[1], CONVEYOR_CHANGED_MOVEDIR)
	READENTITY_FLOAT(m_vecMoveDir[2], CONVEYOR_CHANGED_MOVEDIR)

	if (flChanged & CONVEYOR_CHANGED_SIZE)
		setsize(this, mins, maxs);

	setorigin(this, origin);
}
#endif

void
func_conveyor::Touch(entity eToucher)
{
	if (HasSpawnFlags(SF_CONVEYOR_VISUAL))
		return;

	eToucher.basevelocity = m_vecMoveDir * (m_flSpeed);
}
