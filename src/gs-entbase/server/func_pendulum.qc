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
	FUNCPEND_STARTON,
	FUNCPEND_UNUSED1,
	FUNCPEND_UNUSED2,
	FUNCPEND_NONSOLID,
	FUNCPEND_RETURNONTRIGGER,
	FUNCPEND_UNUSED3,
	FUNCPEND_XAXIS,
	FUNCPEND_YAXIS
};

/*! \brief Server-Entity: Swinging Pendulum */
/*!QUAKED func_pendulum (0 .5 .8) ? FUNCPEND_STARTON x x FUNCPEND_NONSOLID FUNCPEND_RETURNONTRIGGER x FUNCPEND_XAXIS FUNCPEND_YAXIS
# OVERVIEW
A brush that swings along a pivot point like a pendulum.

# KEYS
- "targetname" : Name
- "damp" : Dampening factor.
- "distance" : Swinging distance in euler-angles.
- "speed" : Speed at which it swings in units-per-second.

# SPAWNFLAGS
- FUNCPEND_STARTON (1) : Start swinging immediately.
- FUNCPEND_NONSOLID (8) : Don't do collision testing against this entity.
- FUNCPEND_RETURNONTRIGGER (16) : Once it gets triggered it'll return to its starting position.
- FUNCPEND_XAXIS (64) : Swing on the X-axis.
- FUNCPEND_YAXIS (128) : Swing on the Y-axis.

# NOTES
Please include an origin brush so that a pivot point will be defined.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/
class
func_pendulum:ncRenderableEntity
{
public:
	void func_pendulum(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void customphysics(void);

private:
	int m_iActive;
	float m_flProgress;
	float m_flDampening;
	float m_flDistance;
};

void
func_pendulum::func_pendulum(void)
{
	m_iActive = 0i;
	m_flProgress = 0.0f;
	m_flDampening = 0.0f;
	m_flDistance = 0.0f;
}

void
func_pendulum::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iActive", m_iActive);
	SaveFloat(handle, "m_flProgress", m_flProgress);
	SaveFloat(handle, "m_flDampening", m_flDampening);
	SaveFloat(handle, "m_flDistance", m_flDistance);
}

void
func_pendulum::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iActive":
		m_iActive = ReadInt(strValue);
		break;
	case "m_flProgress":
		m_flProgress = ReadFloat(strValue);
		break;
	case "m_flDampening":
		m_flDampening = ReadFloat(strValue);
		break;
	case "m_flDistance":
		m_flDistance = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
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
func_pendulum::Respawn(void)
{
	super::Respawn();

	if (HasSpawnFlags(FUNCPEND_STARTON))
		m_iActive = TRUE;

	if (HasSpawnFlags(FUNCPEND_NONSOLID))
		SetSolid(SOLID_NOT);
	else
		SetSolid(SOLID_BSP);

	SetMovetype(MOVETYPE_PUSH);
}

void
func_pendulum::Trigger(entity act, triggermode_t state)
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

	if (m_iActive == 0 && HasSpawnFlags(FUNCPEND_RETURNONTRIGGER))
		angles = [0.0f, 0.0f, 0.0f];
}

void
func_pendulum::customphysics(void)
{
	if (!m_iActive)
		return;

	m_flProgress += frametime;

	if (HasSpawnFlags(FUNCPEND_XAXIS))
		angles[2] = sin(m_flProgress);
	else if (HasSpawnFlags(FUNCPEND_YAXIS))
		angles[0] = sin(m_flProgress);
	else
		angles[1] = sin(m_flProgress);

	angles *= m_flDistance;
}
