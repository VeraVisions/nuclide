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

/*QUAKED func_conveyor (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

STUB!
*/

#define SF_CONVEYOR_VISUAL		1
#define SF_CONVEYOR_NOTSOLID	2

class func_conveyor:CBaseTrigger
{
	float m_flSpeed;
	vector m_vecMoveDir;

	void(void) func_conveyor;

	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;
	virtual void(void) touch;
	virtual void(void) SetMovementDirection;
};

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
func_conveyor::touch(void)
{
	other.basevelocity = m_vecMoveDir * m_flSpeed;
}

/* TODO: Handle state? */
void 
func_conveyor::Trigger(entity act, int state)
{
	/* changes direction */
	m_flSpeed = -m_flSpeed;
}

void
func_conveyor::Respawn(void)
{
	m_vecMoveDir = [0,0,0];
	angles = m_oldAngle;

	SetMovementDirection();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);

	/* TODO: Apply some effect flag the engine handles? */
	if (!(spawnflags & SF_CONVEYOR_VISUAL)) {
	}

	if (spawnflags & SF_CONVEYOR_NOTSOLID) {
		SetSolid(SOLID_NOT);
		SetSkin(0);
	}

	if (m_flSpeed == 0)
		m_flSpeed = 100;

	SetAngles([0,0,0]);
}

void
func_conveyor::func_conveyor(void)
{
	CBaseTrigger::CBaseTrigger();
}
