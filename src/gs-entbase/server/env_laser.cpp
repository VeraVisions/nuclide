/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/*QUAKED env_laser (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"            Name
"target"                Target when triggered.
"killtarget"            Target to kill when triggered.

Shoots a frickin beam.
*/

enumflags
{
	ENVLAZ_STARTON,
	ENVLAZ_2,
	ENVLAZ_4,
	ENVLAZ_8,
	ENVLAZ_STARTSPARK,
	ENVLAZ_ENDSPARK,
	ENVLAZ_DECALEND
};

class env_laser:CBaseTrigger
{
	int m_iState;
	float m_flDPS;
	string m_strLaserDest;
	string m_strBeamTex;
	string m_strEndTex;

	void() env_laser;

	virtual void() think;
	virtual void() Trigger;
	virtual void() Respawn;
};

void env_laser::think(void)
{
	entity t;

	if (!m_iState) {
		return;
	} else {
		nextthink = time + 0.1;
	}

	t = (CBaseTrigger)find(world, CBaseEntity::m_strTargetName, m_strLaserDest);

	if (!t) {
		print("env_laser without valid target. Aborting\n");
		return;
	}

	traceline(origin, t.origin, FALSE, this);
	te_beam(world, origin, t.origin);

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, this, rint(m_flDPS), 0, DMG_GENERIC);
	}
}

void env_laser::Trigger(void)
{
	m_iState = 1 - m_iState;
	
	if (m_iState) {
		nextthink = time;
	} else {
		nextthink = 0.25;
	}
}

void env_laser::Respawn(void)
{
	if (spawnflags & ENVLAZ_STARTON) {
		m_iState = 1;
		nextthink = time + 0.1;
	}
}

void env_laser::env_laser(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "texture":
			m_strBeamTex = argv(i + 1);
			break;
		case "EndSprite":
			m_strEndTex = argv(i + 1);
			break;
		case "LaserTarget":
			m_strLaserDest = argv(i + 1);
			break;
		case "damage":
			m_flDPS = stof(argv(i + 1));
			break;
		default:
			break;
		}
	}

	CBaseTrigger::CBaseTrigger();
}
