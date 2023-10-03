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
	ENVEXPLO_NODAMAGE,
	ENVEXPLO_REPEATABLE,
	ENVEXPLO_NOBALL,
	ENVEXPLO_NOSMOKE,
	ENVEXPLO_NODECAL,
	ENVEXPLO_NOSPARKS
};

/*!QUAKED env_explosion (1 .5 0) (-8 -8 -8) (8 8 8) ENVEXPLO_NODAMAGE ENVEXPLO_REPEATABLE ENVEXPLO_NOBALL ENVEXPLO_NOSMOKE ENVEXPLO_NODECAL ENVEXPLO_NOSPARKS
# OVERVIEW
When triggered, creates an explosion at its location.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "iMagnitude" : Magnitude of the explosion.

# SPAWNFLAGS
- ENVEXPLO_NODAMAGE (1) : Make this explosion purely decorative, without radius damage.
- ENVEXPLO_REPEATABLE (2) : Makes this explosion triggerable more than once.
- ENVEXPLO_NOBALL (4) : Spawn no fireball.
- ENVEXPLO_NOSMOKE (8) : Spawn no smoke.
- ENVEXPLO_NODECAL (16) : Leave no decal upon explosion.
- ENVEXPLO_NOSPARKS (32) : Don't spawn any sparks upon exploding.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
env_explosion:NSPointTrigger
{
public:
	void env_explosion(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);

private:
	int m_iMagnitude;
	float m_flMaxDelay;
	bool m_bEnabled;
};

void
env_explosion::env_explosion(void)
{
	m_iMagnitude = 0;
	m_flMaxDelay = 0.0f;
	m_bEnabled = true;
}

void
env_explosion::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iMagnitude", m_iMagnitude);
	SaveFloat(handle, "m_flMaxDelay", m_flMaxDelay);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
}

void
env_explosion::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iMagnitude":
		m_iMagnitude = ReadInt(strValue);
		break;
	case "m_flMaxDelay":
		m_flMaxDelay = ReadFloat(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_explosion::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "iMagnitude":
		m_iMagnitude = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_explosion::Respawn(void)
{
	m_bEnabled = true;
}

void
env_explosion::Trigger(entity act, triggermode_t state)
{
	pointparticles(particleeffectnum("fx_explosion.main"), origin, [0,0,0], 1);

	if (!HasSpawnFlags(ENVEXPLO_NODAMAGE)) {
		Damage_Radius(origin, this, m_iMagnitude, m_iMagnitude * 2.5f, TRUE, 0);
	}

	if (!HasSpawnFlags(ENVEXPLO_REPEATABLE)) {
		m_bEnabled = false;
	}
}
