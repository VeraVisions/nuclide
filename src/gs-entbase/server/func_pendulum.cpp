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

/*QUAKED func_wall_toggle (0 .5 .8) ? FTW_STARTHIDDEN
"targetname"    Name

Brush that can be hidden and reappear when triggered.

If FTW_STARTHIDDEN is set, it'll start hidden.
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

class func_pendulum:CBaseTrigger
{
	int m_iActive;
	float m_flProgress;
	float m_flDampening;
	float m_flDistance;

	void(void) func_pendulum;

	virtual void(void) customphysics;
	virtual void(void) Respawn;
	virtual void(entity, int) Trigger;
};

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
	SetModel(m_oldModel);
	SetOrigin(origin);
}

void
func_pendulum::func_pendulum(void)
{
	CBaseTrigger::CBaseTrigger();

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "damp":
			m_flDampening = stof(argv(i+1));
			break;
		case "distance":
			m_flDistance = stof(argv(i+1));
			break;
		default:
			break;
		}
	}
}
