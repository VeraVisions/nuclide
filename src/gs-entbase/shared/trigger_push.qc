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
	PUSH_CHANGED_ORIGIN_X,
	PUSH_CHANGED_ORIGIN_Y,
	PUSH_CHANGED_ORIGIN_Z,
	PUSH_CHANGED_ANGLES_X,
	PUSH_CHANGED_ANGLES_Y,
	PUSH_CHANGED_ANGLES_Z,
	PUSH_CHANGED_MODELINDEX,
	PUSH_CHANGED_SIZE,
	PUSH_CHANGED_FRAME,
	PUSH_CHANGED_SPAWNFLAGS,
	PUSH_CHANGED_SOLIDMOVETYPE,
	PUSH_CHANGED_VELOCITY,
	PUSH_CHANGED_ANGULARVELOCITY,
	PUSH_CHANGED_RENDERCOLOR,
	PUSH_CHANGED_RENDERAMT,
	PUSH_CHANGED_RENDERMODE,
	PUSH_CHANGED_SPEED,
	PUSH_CHANGED_MOVEDIR
} trigger_push_changed_t;

enumflags
{
	TP_ONCE,
	TP_STARTOFF
};

/*! \brief Shared-Entity: Push Force Volume */
/*!QUAKED trigger_push (.5 .5 .5) ? TP_ONCE TP_STARTOFF
# OVERVIEW
Pushes anything in its volume into a direction of your choosing.

# KEYS
- "targetname" : Name
- "speed" : The speed (units per second) it'll apply to touchers.
- "angles" : Sets the direction of the push.

# SPAWNFLAGS
- TP_ONCE (1) : Only emit a single push once before disabling itself.
- TP_STARTOFF (2) : Needs to be triggered first in order to function.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup shared
@ingroup brushentity
*/
class
trigger_push:NSBrushTrigger
{
public:
	void trigger_push(void);

	virtual void Touch(entity);
	
#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity,triggermode_t);
	virtual void SetMovementDirection(void);
	virtual float SendEntity(entity,float);
	virtual void EvaluateEntity(void);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
#endif

private:
	PREDICTED_FLOAT(m_flSpeed)
	PREDICTED_VECTOR(m_vecMoveDir)
	PREDICTED_BOOL(m_bHasTarget)
};

void
trigger_push::trigger_push(void)
{
	m_vecMoveDir = [0,0,0];
	m_flSpeed = 100;
	m_bHasTarget = false;
}

#ifdef SERVER
void
trigger_push::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
	SaveBool(handle, "m_bHasTarget", m_bHasTarget);
}

void
trigger_push::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_vecMoveDir":
		m_vecMoveDir = ReadVector(strValue);
		break;
	case "m_flSpeed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "m_bHasTarget":
		m_bHasTarget = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
trigger_push::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
trigger_push::Respawn(void)
{
	static void JumpDestCheck(void) {
		/* this ent has a destination target */
		m_bHasTarget = false;
		if (target) {
			entity targetPos = find(world, ::targetname, target);

			if (targetPos) {
				m_bHasTarget = true;
				m_vecMoveDir = targetPos.origin;
			}
		}
	}
	InitBrushTrigger();

	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	if (HasSpawnFlags(TP_STARTOFF)) {
		SetSolid(SOLID_NOT);
	}

	if (target)
		ScheduleThink(JumpDestCheck, 0.5f);
}

void
trigger_push::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		SetSolid(SOLID_NOT);
		break;
	case TRIG_ON:
		SetSolid(SOLID_TRIGGER);
		break;
	default:
		SetSolid(solid == SOLID_NOT ? SOLID_TRIGGER : SOLID_NOT);
	}
}

void
trigger_push::SetMovementDirection(void)
{
	if (GetAngles() == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (GetAngles() == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(GetAngles());
		m_vecMoveDir = v_forward;
	}
}

void
trigger_push::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, PUSH_CHANGED_ORIGIN_X)
	EVALUATE_VECTOR(origin, 1, PUSH_CHANGED_ORIGIN_Y)
	EVALUATE_VECTOR(origin, 2, PUSH_CHANGED_ORIGIN_Z)
	EVALUATE_VECTOR(angles, 0, PUSH_CHANGED_ANGLES_X)
	EVALUATE_VECTOR(angles, 1, PUSH_CHANGED_ANGLES_Y)
	EVALUATE_VECTOR(angles, 2, PUSH_CHANGED_ANGLES_Z)
	EVALUATE_FIELD(modelindex, PUSH_CHANGED_MODELINDEX)
	EVALUATE_FIELD(solid, PUSH_CHANGED_SOLIDMOVETYPE)
	EVALUATE_FIELD(movetype, PUSH_CHANGED_SOLIDMOVETYPE)
	EVALUATE_VECTOR(mins, 0, PUSH_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 1, PUSH_CHANGED_SIZE)
	EVALUATE_VECTOR(mins, 2, PUSH_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 0, PUSH_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 1, PUSH_CHANGED_SIZE)
	EVALUATE_VECTOR(maxs, 2, PUSH_CHANGED_SIZE)
	EVALUATE_FIELD(frame, PUSH_CHANGED_FRAME)
	EVALUATE_VECTOR(velocity, 0, PUSH_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 1, PUSH_CHANGED_VELOCITY)
	EVALUATE_VECTOR(velocity, 2, PUSH_CHANGED_VELOCITY)
	EVALUATE_VECTOR(avelocity, 0, PUSH_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 1, PUSH_CHANGED_ANGULARVELOCITY)
	EVALUATE_VECTOR(avelocity, 2, PUSH_CHANGED_ANGULARVELOCITY)
	EVALUATE_FIELD(m_flSpeed, PUSH_CHANGED_SPEED)
	EVALUATE_VECTOR(m_vecMoveDir, 0, PUSH_CHANGED_MOVEDIR)
	EVALUATE_VECTOR(m_vecMoveDir, 1, PUSH_CHANGED_MOVEDIR)
	EVALUATE_VECTOR(m_vecMoveDir, 2, PUSH_CHANGED_MOVEDIR)
	EVALUATE_FIELD(m_bHasTarget, PUSH_CHANGED_MOVEDIR)
}

float
trigger_push::SendEntity(entity ePEnt, float flChanged)
{
	if (!modelindex)
		return (0);

	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_PUSH);

	/* optimisation */
	{
		/* we'll never network these if we aren't moving. */
		if (movetype == MOVETYPE_NONE) {
			flChanged &= ~PUSH_CHANGED_VELOCITY;
			flChanged &= ~PUSH_CHANGED_ANGULARVELOCITY;
		}
	}

	/* broadcast how much data is expected to be read */
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_COORD(origin[0], PUSH_CHANGED_ORIGIN_X)
	SENDENTITY_COORD(origin[1], PUSH_CHANGED_ORIGIN_Y)
	SENDENTITY_COORD(origin[2], PUSH_CHANGED_ORIGIN_Z)
	SENDENTITY_ANGLE(angles[0], PUSH_CHANGED_ANGLES_X)
	SENDENTITY_ANGLE(angles[1], PUSH_CHANGED_ANGLES_Y)
	SENDENTITY_ANGLE(angles[2], PUSH_CHANGED_ANGLES_Z)
	SENDENTITY_SHORT(modelindex, PUSH_CHANGED_MODELINDEX)
	SENDENTITY_BYTE(solid, PUSH_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_BYTE(movetype, PUSH_CHANGED_SOLIDMOVETYPE)
	SENDENTITY_COORD(mins[0], PUSH_CHANGED_SIZE)
	SENDENTITY_COORD(mins[1], PUSH_CHANGED_SIZE)
	SENDENTITY_COORD(mins[2], PUSH_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[0], PUSH_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[1], PUSH_CHANGED_SIZE)
	SENDENTITY_COORD(maxs[2], PUSH_CHANGED_SIZE)
	SENDENTITY_BYTE(frame, PUSH_CHANGED_FRAME)
	SENDENTITY_COORD(velocity[0], PUSH_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[1], PUSH_CHANGED_VELOCITY)
	SENDENTITY_COORD(velocity[2], PUSH_CHANGED_VELOCITY)
	SENDENTITY_COORD(avelocity[0], PUSH_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[1], PUSH_CHANGED_ANGULARVELOCITY)
	SENDENTITY_COORD(avelocity[2], PUSH_CHANGED_ANGULARVELOCITY)
	SENDENTITY_FLOAT(m_flSpeed, PUSH_CHANGED_SPEED)
	SENDENTITY_FLOAT(m_vecMoveDir[0], PUSH_CHANGED_MOVEDIR)
	SENDENTITY_FLOAT(m_vecMoveDir[1], PUSH_CHANGED_MOVEDIR)
	SENDENTITY_FLOAT(m_vecMoveDir[2], PUSH_CHANGED_MOVEDIR)
	SENDENTITY_BYTE(m_bHasTarget, PUSH_CHANGED_MOVEDIR)

	return true;
}
#endif

#ifdef CLIENT
void
trigger_push::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], PUSH_CHANGED_ORIGIN_X)
	READENTITY_COORD(origin[1], PUSH_CHANGED_ORIGIN_Y)
	READENTITY_COORD(origin[2], PUSH_CHANGED_ORIGIN_Z)
	READENTITY_ANGLE(angles[0], PUSH_CHANGED_ANGLES_X)
	READENTITY_ANGLE(angles[1], PUSH_CHANGED_ANGLES_Y)
	READENTITY_ANGLE(angles[2], PUSH_CHANGED_ANGLES_Z)
	READENTITY_SHORT(modelindex, PUSH_CHANGED_MODELINDEX)
	READENTITY_BYTE(solid, PUSH_CHANGED_SOLIDMOVETYPE)
	READENTITY_BYTE(movetype, PUSH_CHANGED_SOLIDMOVETYPE)
	READENTITY_COORD(mins[0], PUSH_CHANGED_SIZE)
	READENTITY_COORD(mins[1], PUSH_CHANGED_SIZE)
	READENTITY_COORD(mins[2], PUSH_CHANGED_SIZE)
	READENTITY_COORD(maxs[0], PUSH_CHANGED_SIZE)
	READENTITY_COORD(maxs[1], PUSH_CHANGED_SIZE)
	READENTITY_COORD(maxs[2], PUSH_CHANGED_SIZE)
	READENTITY_BYTE(frame, PUSH_CHANGED_FRAME)
	READENTITY_COORD(velocity[0], PUSH_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[1], PUSH_CHANGED_VELOCITY)
	READENTITY_COORD(velocity[2], PUSH_CHANGED_VELOCITY)
	READENTITY_COORD(avelocity[0], PUSH_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[1], PUSH_CHANGED_ANGULARVELOCITY)
	READENTITY_COORD(avelocity[2], PUSH_CHANGED_ANGULARVELOCITY)
	READENTITY_FLOAT(m_flSpeed, PUSH_CHANGED_SPEED)
	READENTITY_FLOAT(m_vecMoveDir[0], PUSH_CHANGED_MOVEDIR)
	READENTITY_FLOAT(m_vecMoveDir[1], PUSH_CHANGED_MOVEDIR)
	READENTITY_FLOAT(m_vecMoveDir[2], PUSH_CHANGED_MOVEDIR)
	READENTITY_BYTE(m_bHasTarget, PUSH_CHANGED_MOVEDIR)

	if (flChanged & PUSH_CHANGED_SIZE)
		setsize(this, mins, maxs);

	setorigin(this, origin);
}

void
trigger_push_ReadEntity(bool new)
{
	float fl;

	trigger_push rend = (trigger_push)self;
	if (new) {
		spawnfunc_trigger_push();
	}

	fl = readfloat();
	rend.ReceiveEntity(new, fl);
}
#endif

void
trigger_push::Touch(entity eToucher)
{
#ifdef SERVER
	eActivator = (NSEntity)eToucher;
#endif

	switch(eToucher.movetype) {
	case MOVETYPE_NONE:
	case MOVETYPE_PUSH:
	case MOVETYPE_NOCLIP:
	case MOVETYPE_FOLLOW:
		return;
	}

	if (m_bHasTarget) {
		if (eToucher.flags & FL_ONGROUND)
		eToucher.velocity = Route_GetJumpVelocity(WorldSpaceCenter(), m_vecMoveDir, 1.0);
		return;
	}

	/* trigger_push is not supposed to work underwater */
	if (eToucher.waterlevel > 1)
		return;

	if (eToucher.solid != SOLID_NOT && eToucher.solid != SOLID_BSP) {
		vector vecPush;
		vecPush = (m_flSpeed * m_vecMoveDir);

		if (HasSpawnFlags(TP_ONCE)) {
			//crossprint(sprintf("one push %v (%v)\n", eToucher.basevelocity, eToucher.velocity));
			eToucher.velocity += vecPush;
			if (eToucher.velocity[2] > 0) {
				eToucher.flags &= ~FL_ONGROUND;
			}
			SetSolid(SOLID_NOT);
		} else {
			if (eToucher.flags & FL_ONGROUND) {
				eToucher.basevelocity = vecPush * 0.25;
				//crossprint(sprintf("basevel push %v (%v)\n", eToucher.basevelocity, eToucher.velocity));
			}
		}
	}
}