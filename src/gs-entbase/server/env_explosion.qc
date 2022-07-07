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

/*QUAKED env_explosion (1 0 0) (-8 -8 -8) (8 8 8) ENVEXPLO_NODAMAGE ENVEXPLO_REPEATABLE ENVEXPLO_NOBALL ENVEXPLO_NOSMOKE ENVEXPLO_NODECAL ENVEXPLO_NOSPARKS
When triggered, creates an explosion at its location.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"iMagnitude" : Magnitude of the explosion.

-------- SPAWNFLAGS --------
ENVEXPLO_NODAMAGE : Make this explosion purely decorative, without radius damage.
ENVEXPLO_REPEATABLE : Makes this explosion triggerable more than once.
ENVEXPLO_NOBALL : Spawn no fireball.
ENVEXPLO_NOSMOKE : Spawn no smoke.
ENVEXPLO_NODECAL : Leave no decal upon explosion.
ENVEXPLO_NOSPARKS : Don't spawn any sparks upon exploding.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
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

class env_explosion:NSPointTrigger
{
	int m_iMagnitude;
	float m_flMaxDelay;

	void(void) env_explosion;

	/* overrides */
	virtual void(float) Save;
	virtual void(string,string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
env_explosion::Save(float handle)
{
	SaveInt(handle, "magnitude", m_iMagnitude);
	SaveFloat(handle, "max_delay", m_flMaxDelay);
	super::Save(handle);
}

void
env_explosion::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "magnitude":
		m_iMagnitude = ReadInt(strValue);
		break;
	case "max_delay":
		m_flMaxDelay = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_explosion::Trigger(entity act, int state)
{
	FX_Explosion(origin);

	if (!HasSpawnFlags(ENVEXPLO_NODAMAGE)) {
		Damage_Radius(origin, this, m_iMagnitude, m_iMagnitude * 2.5f, TRUE, 0);
	}

	// TODO: Respawn after round instead?
	if (!HasSpawnFlags(ENVEXPLO_REPEATABLE)) {
		remove(this);
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
env_explosion::env_explosion(void)
{
}
