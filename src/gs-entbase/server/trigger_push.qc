/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED trigger_push (0 .5 .8) ? TP_ONCE TP_STARTOFF
Pushes anything in its volume into a direction of your choosing.

-------- KEYS --------
"targetname" : Name
"speed" : The speed (units per second) it'll apply to touchers.
"angles" : Sets the direction of the push.

-------- SPAWNFLAGS --------
TP_ONCE : Only emit a single push once before disabling itself.
TP_STARTOFF : Needs to be triggered first in order to function.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

enumflags
{
	TP_ONCE,
	TP_STARTOFF
};

class trigger_push:CBaseTrigger
{
	vector m_vecMoveDir;
	float m_flSpeed;

	void(void) trigger_push;

	virtual void(void) touch;
	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;
	virtual void(void) SetMovementDirection;
	virtual void(string, string) SpawnKey;
};

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

	angles = [0,0,0];
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
trigger_push::touch(void)
{
	eActivator = other;

	switch(other.movetype) {
	case MOVETYPE_NONE:
	case MOVETYPE_PUSH:
	case MOVETYPE_NOCLIP:
	case MOVETYPE_FOLLOW:
		return;
	}

	/* trigger_push is not supposed to work underwater */
	if (other.waterlevel > 1)
		return;

	if (other.solid != SOLID_NOT && other.solid != SOLID_BSP) {
		vector vecPush;
		vecPush = (m_flSpeed * m_vecMoveDir);

		if (spawnflags & TP_ONCE) {
			other.velocity += vecPush;
			if (other.velocity[2] > 0) {
				other.flags &= ~FL_ONGROUND;
			}
			Hide();
		} else {
			other.basevelocity += vecPush;
		}
	}
}

void
trigger_push::Respawn(void)
{
	InitBrushTrigger();
	SetMovementDirection();

	if (spawnflags & TP_STARTOFF) {
		SetSolid(SOLID_NOT);
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
trigger_push::trigger_push(void)
{
	m_flSpeed = 100;
	CBaseTrigger::CBaseTrigger();
}
