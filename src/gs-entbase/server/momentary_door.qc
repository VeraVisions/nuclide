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

/*QUAKED momentary_door (0 .5 .8) ?
Dynamic door that will move back down if it's not being used.

-------- KEYS --------
"targetname" : Name

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class momentary_door:CBaseMomentary
{
	void(void) momentary_door;

	virtual void(void) customphysics;
	virtual void(void) Respawn;
	virtual void(void) SetMovementDirection;
	virtual void(string, string) SpawnKey;
};

void
momentary_door::customphysics(void)
{
	entity e = find(world, ::targetname, target);
	CBaseMomentary bl = (CBaseMomentary)e;

	if (m_eUser != world) {
		base_player pl = (base_player)m_eUser;
		/* we need to check if the user has changed every frame. */
		if (!m_eUser.button5) {
			/* clear user */
			m_eUser = world;

			if (e) {
				bl.m_eUser = world;
			}
		} else {
			if (e) {
				bl.m_eUser = m_eUser;
			}

			m_flProgress += frametime;
		
			if (m_flProgress >= 1.0f)
				m_flProgress = 1.0f;
		}
	} else {
		m_flProgress = Math_Lerp(m_flProgress, 0.0f, frametime * 0.5);
	}

	origin[0] = Math_Lerp(m_vecPos1[0], m_vecPos2[0], m_flProgress);
	origin[1] = Math_Lerp(m_vecPos1[1], m_vecPos2[1], m_flProgress);
	origin[2] = Math_Lerp(m_vecPos1[2], m_vecPos2[2], m_flProgress);
	setorigin(this, origin);

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void
momentary_door::SetMovementDirection(void)
{
	if (m_oldAngle == [0,-1,0]) {
		m_vecMoveDir = [0,0,1];
	} else if (m_oldAngle == [0,-2,0]) {
		m_vecMoveDir = [0,0,-1];
	} else {
		makevectors(m_oldAngle);
		m_vecMoveDir = v_forward;
	}
}

void
momentary_door::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetMovementDirection();
	SetAngles([0,0,0]);

	m_vecPos1 = m_oldOrigin;
	m_vecPos2 = (m_vecPos1 + m_vecMoveDir * (fabs(m_vecMoveDir * size) - m_flDistance));
}

void
momentary_door::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "lip":
		m_flDistance = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "returnspeed":
		m_flReturnspeed = stof(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
momentary_door::momentary_door(void)
{
	CBaseTrigger::CBaseTrigger();
}
