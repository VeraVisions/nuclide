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
	TP_ONCE,
	TP_STARTOFF
};

/*!QUAKED trigger_push (0 .5 .8) ? TP_ONCE TP_STARTOFF
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
*/
class
trigger_push:NSBrushTrigger
{
public:
	void trigger_push(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity,int);
	virtual void Touch(entity);
	virtual void SetMovementDirection(void);

private:
	vector m_vecMoveDir;
	float m_flSpeed;
};

void
trigger_push::trigger_push(void)
{
	m_vecMoveDir = [0,0,0];
	m_flSpeed = 100;
}

void
trigger_push::Save(float handle)
{
	super::Save(handle);
	SaveVector(handle, "m_vecMoveDir", m_vecMoveDir);
	SaveFloat(handle, "m_flSpeed", m_flSpeed);
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
	InitBrushTrigger();

	RestoreAngles();
	SetMovementDirection();
	ClearAngles();

	if (HasSpawnFlags(TP_STARTOFF)) {
		SetSolid(SOLID_NOT);
	}
}

void
trigger_push::Trigger(entity act, int state)
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
trigger_push::Touch(entity eToucher)
{
	eActivator = eToucher;

	switch(eToucher.movetype) {
	case MOVETYPE_NONE:
	case MOVETYPE_PUSH:
	case MOVETYPE_NOCLIP:
	case MOVETYPE_FOLLOW:
		return;
	}

	/* trigger_push is not supposed to work underwater */
	if (eToucher.waterlevel > 1)
		return;

	if (eToucher.solid != SOLID_NOT && eToucher.solid != SOLID_BSP) {
		vector vecPush;
		vecPush = (m_flSpeed * m_vecMoveDir);

		if (HasSpawnFlags(TP_ONCE)) {
			eToucher.velocity += vecPush;
			if (eToucher.velocity[2] > 0) {
				eToucher.flags &= ~FL_ONGROUND;
			}
			SetSolid(SOLID_NOT);
		} else {
			eToucher.basevelocity += vecPush;
		}
	}
}

void
trigger_push::SetMovementDirection(void)
{
	if (GetSpawnAngles() == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (angles == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(GetSpawnAngles());
		m_vecMoveDir = v_forward;
	}
}
