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

/*QUAKED func_pendulum (0 .5 .8) ? FUNCPEND_STARTON x x FUNCPEND_NONSOLID FUNCPEND_RETURNONTRIGGER x FUNCPEND_XAXIS FUNCPEND_YAXIS
A brush that swings along a pivot point like a pendulum.

-------- KEYS --------
"targetname" : Name
"damp" : Dampening factor.
"distance" : Swinging distance in euler-angles.
"speed" : Speed at which it swings in units-per-second.

-------- SPAWNFLAGS --------
FUNCPEND_STARTON : Start swinging immediately.
FUNCPEND_NONSOLID : Don't do collision testing against this entity.
FUNCPEND_RETURNONTRIGGER : Once it gets triggered it'll return to its starting position.
FUNCPEND_XAXIS : Swing on the X-axis.
FUNCPEND_YAXIS : Swing on the Y-axis.

-------- NOTES --------
Please include an origin brush so that a pivot point will be defined.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	FUNCPEND_STARTON,
	FUNCPEND_UNUSED1,
	FUNCPEND_UNUSED2,
	FUNCPEND_NONSOLID,
	FUNCPEND_RETURNONTRIGGER,
	FUNCPEND_UNUSED3,
	FUNCPEND_XAXIS,
	FUNCPEND_YAXIS
};

class func_pendulum:NSRenderableEntity
{
	int m_iActive;
	float m_flProgress;
	float m_flDampening;
	float m_flDistance;

	void(void) func_pendulum;

	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(void) customphysics;
	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
func_pendulum::Save(float handle)
{
	SaveInt(handle, "active", m_iActive);
	SaveFloat(handle, "progress", m_flProgress);
	SaveFloat(handle, "dampening", m_flDampening);
	SaveFloat(handle, "distance", m_flDistance);
	super::Save(handle);
}

void
func_pendulum::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "active":
		m_iActive = ReadInt(strValue);
		break;
	case "progress":
		m_flProgress = ReadFloat(strValue);
		break;
	case "dampening":
		m_flDampening = ReadFloat(strValue);
		break;
	case "distance":
		m_flDistance = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
func_pendulum::customphysics(void)
{
	if (!m_iActive)
		return;

	m_flProgress += frametime;

	if (spawnflags & FUNCPEND_XAXIS)
		angles[2] = sin(m_flProgress);
	else if (spawnflags & FUNCPEND_YAXIS)
		angles[0] = sin(m_flProgress);
	else
		angles[1] = sin(m_flProgress);

	angles *= m_flDistance;
}

void
func_pendulum::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		m_iActive = 0;
		break;
	case TRIG_ON:
		m_iActive = 1;
		break;
	default:
		m_iActive = 1 - m_iActive;
	}

	if (m_iActive == 0 && spawnflags & FUNCPEND_RETURNONTRIGGER)
		angles = [0,0,0];
}

void
func_pendulum::Respawn(void)
{
	if (spawnflags & FUNCPEND_STARTON)
		m_iActive = TRUE;

	if (spawnflags & FUNCPEND_NONSOLID)
		SetSolid(SOLID_NOT);
	else
		SetSolid(SOLID_BSP);

	movetype = MOVETYPE_PUSH;
	SetModel(GetSpawnModel());
	SetOrigin(origin);
}

void
func_pendulum::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "damp":
		m_flDampening = stof(strValue);
		break;
	case "distance":
		m_flDistance = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_pendulum::func_pendulum(void)
{
	super::NSRenderableEntity();
}
