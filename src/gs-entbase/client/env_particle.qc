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

/*!QUAKED env_particle (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Client-side particle effect. Active at runtime, fully client-side.
Cannot be triggered. Repeats automatically.

# KEYS
- "message" : Particle material to use.
- "wait" : Delay between emits.
- "target" : Name of target, like an info_notnull (client-side)
- "velocity" : Speed in units.
- "count" : Number of particles to emit.

# TRIVIA
This entity was introduced in The Wastes (2018).
*/
class env_particle:NSEntity
{
public:
	void env_particle(void);
	
	virtual void Respawn(void);
	virtual void customphysics(void);
	virtual void SpawnKey(string,string);

private:
	entity m_eTarget;
	float m_flNextTime;
	float m_flPartID;
	float m_flVelocity;
	float m_flWait;
	int m_iCount;
	string m_strTarget;
};

void env_particle::customphysics(void)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;
	
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
		m_eTarget = find(world, ::targetname, m_strTarget);
		makevectors(vectoangles(m_eTarget.origin - origin) * -1);
		angles = v_forward;
	}
	pointparticles(m_flPartID, origin, angles * m_flVelocity, m_iCount);
	m_flNextTime = time + m_flWait;
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
		super::SpawnKey(strField, strKey);
	}
}

void
env_particle::Respawn(void)
{
	SetOrigin(GetSpawnOrigin());
	SetSize([0,0,0], [0,0,0]);
}

void env_particle::env_particle(void)
{
	isCSQC = true;
}
