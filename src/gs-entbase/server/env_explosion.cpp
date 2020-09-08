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

/*QUAKED env_explosion (1 0 0) (-8 -8 -8) (8 8 8) ENVEXPLO_NODAMAGE ENVEXPLO_REPEATABLE ENVEXPLO_NOBALL ENVEXPLO_NOSMOKE ENVEXPLO_NODECAL ENVEXPLO_NOSPARKS
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"iMagnitude"    Magnitude of the explosion.

When triggered, creates an explosion at its location.
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

class env_explosion:CBaseTrigger
{
	int m_iMagnitude;
	float m_flMaxDelay;

	void(void) env_explosion;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
env_explosion::Trigger(entity act, int state)
{
	FX_Explosion(origin);

	if (!(spawnflags & ENVEXPLO_NODAMAGE)) {
		Damage_Radius(origin, this, m_iMagnitude, m_iMagnitude * 2.5f, TRUE, 0);
	}

	// TODO: Respawn after round instead?
	if (!(spawnflags & ENVEXPLO_REPEATABLE)) {
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
env_explosion::env_explosion(void)
{
	CBaseTrigger::CBaseTrigger();
}
