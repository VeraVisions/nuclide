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

/*QUAKED momentary_rot_button (0 .5 .8) ? MRBFL_DOORHACK MRBFL_NOTUSE x x MRBFL_AUTORETURN x MRBFL_XAXIS MRBFL_YAXIS
"targetname"    Name

Trivia:
This entity was introduced in Half-Life (1998).
*/

enumflags
{
    MRBFL_DOORHACK,
    MRBFL_NOTUSE,
	MRBFL_UNUSED4,
	MRBFL_UNUSED8,
    MRBFL_AUTORETURN,
	MRBFL_UNUSED32,
	MRBFL_XAXIS,
    MRBFL_YAXIS
};

class momentary_rot_button:CBaseMomentary
{
	void(void) momentary_rot_button;

	virtual void(void) OnPlayerUse;
	virtual void(void) customphysics;
	virtual void(void) Respawn;
	virtual void(void) SetMovementDirection;
	virtual void(string, string) SpawnKey;
};

void
momentary_rot_button::OnPlayerUse(void)
{
	if (spawnflags & MRBFL_NOTUSE)
		return;

	m_eUser = eActivator;
}

void
momentary_rot_button::customphysics(void)
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

	angles[0] = Math_Lerp(m_vecPos1[0], m_vecPos2[0], m_flProgress);
	angles[1] = Math_Lerp(m_vecPos1[1], m_vecPos2[1], m_flProgress);
	angles[2] = Math_Lerp(m_vecPos1[2], m_vecPos2[2], m_flProgress);

	/* support for think/nextthink */
	if (think && nextthink > 0.0f) {
		if (nextthink < time) {
			nextthink = 0.0f;
			think();
		}
	}
}

void
momentary_rot_button::SetMovementDirection(void)
{
	if (spawnflags & MRBFL_XAXIS) {
		m_vecMoveDir = [0,0,1];
	} else if (spawnflags & MRBFL_YAXIS) {
		m_vecMoveDir = [1,0,0];
	} else {
		m_vecMoveDir = [0,1,0];
	}
}

void
momentary_rot_button::Respawn(void)
{
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);
	SetMovementDirection();
	SetAngles([0,0,0]);
	PlayerUse = OnPlayerUse;

	m_vecPos1 = [0,0,0];
	m_vecPos2 = m_oldAngle + m_vecMoveDir * m_flDistance;
}

void
momentary_rot_button::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "distance":
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
momentary_rot_button::momentary_rot_button(void)
{
	CBaseTrigger::CBaseTrigger();
}
