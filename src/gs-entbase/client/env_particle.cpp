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

/*QUAKED env_particle (1 0 0) (-8 -8 -8) (8 8 8)
"message"    Particle material to use.
"wait"       Delay between emits.
"target"     Name of target, like an info_notnull (client-side)
"velocity"   Speed in units.
"count"      Number of particles to emit.

Client-side particle effect. Active at runtime, fully client-side.
Cannot be triggered.
*/

class env_particle:CBaseEntity
{
	entity m_eTarget;
	float m_flNextTime;
	float m_flPartID;
	float m_flVelocity;
	float m_flWait;
	int m_iCount;
	string m_strTarget;

	void() env_particle;
	virtual void() customphysics;
	virtual void(string, string) SpawnKey;
};

void env_particle::customphysics(void)
{
	vector vecPlayer;

#ifdef WASTES
	vecPlayer = viewClient.vecPlayerOrigin;
#else
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	vecPlayer = pSeat->vPlayerOrigin;
#endif
	
	if (checkpvs(vecPlayer, this) == FALSE) {
		return;
	}

	if (!m_flVelocity) {
		m_flVelocity = 1.0f;
	}

	if (m_flNextTime > time) {
		return;
	}

	if (m_strTarget) {
		m_eTarget = find(world, CBaseEntity::targetname, m_strTarget);
		makevectors(vectoangles(m_eTarget.origin - origin) * -1);
		angles = v_forward;
	}
	pointparticles(m_flPartID, origin, angles * m_flVelocity, m_iCount);
	m_flNextTime = time + m_flWait;
}

void env_particle::env_particle(void)
{
	drawmask = MASK_ENGINE;
	Init();
}

void env_particle::SpawnKey(string strField, string strKey)
{
	switch (strField) {
	case "message":
		m_flPartID = particleeffectnum(strKey);
		break;
	case "wait":
		m_flWait = stof(strKey);
		break;
	case "target":
		m_strTarget = strKey;
		break;
	case "velocity":
		m_flVelocity = stof(strKey);
		break;
	case "count":
		m_iCount = stoi(strKey);
		break;
	default:
		CBaseEntity::SpawnKey(strField, strKey);
	}
}
