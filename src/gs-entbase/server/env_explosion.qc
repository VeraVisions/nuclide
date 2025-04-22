/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

enum
{
	ENVEXPLO_NODAMAGE = 1,
	ENVEXPLO_REPEATABLE = 2,
	ENVEXPLO_NOSOUND = 64,
	ENVEXPLO_NOTUNDERWATER = 8192,
	ENVEXPLO_GENERICDAMAGE = 16384
};

/*! \brief Server-Entity: Explosion Creator */
/*!QUAKED env_explosion (1 .5 0) (-8 -8 -8) (8 8 8) NO_DAMAGE REPEATABLE x x x NO_SOUND
# OVERVIEW
When triggered, creates an explosion at its location.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "iMagnitude" : Magnitude of the explosion.
- "explosion_custom_effect" : Sets a custom explosion particle effect to appear.
- "explosion_custom_sound" : Sets a custom explosion sound to play.

# INPUTS
- "Explode" : Triggers the explosion effect.

# SPAWNFLAGS
- NO_DAMAGE (1) : Make this explosion purely decorative, without radius damage.
- REPEATABLE (2) : Makes this explosion triggerable more than once.
- NO_SOUND (64) : Do not play the sound effect.
- NOTUNDERWATER (8192) : Don't cause damage underwater.
- GENERIC_DAMAGE (16384) : Act as if damage wasn't caused by an explosion type, making gibbing more difficult - some games may ignore it however.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
env_explosion:ncPointTrigger
{
public:
	void env_explosion(void);
	
	/* overrides */
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);

	/** Returns the radius of the explosion. */
	nonvirtual float GetExplosionRadius(void);
	/** Returns the maximum damage the explosion delivers. */
	nonvirtual int GetExplosionDamage(void);

private:
	int m_explosionMagnitude;
	int m_explosionRadiusOverride;
	string m_explosionParticleFX;
	string m_sndExplosion;
	int m_explosionParticleID;
};

void
env_explosion::env_explosion(void)
{
	m_explosionMagnitude = 0i;
	m_explosionRadiusOverride = -1;

	m_explosionParticleFX = "fx_explosion.main";
	m_sndExplosion = "fx.explosion";
	m_explosionParticleID = 0i;
}

void
env_explosion::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "iMagnitude":
		m_explosionMagnitude = ReadInt(setValue);
		break;
	case "iRadiusOverride":
		m_explosionRadiusOverride = ReadFloat(setValue);
		break;
	case "explosion_custom_effect":
		m_explosionParticleFX = ReadString(setValue);
		break;
	case "explosion_custom_sound":
		m_sndExplosion = ReadString(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_explosion::Spawned(void)
{
	super::Spawned();

	m_explosionParticleID = particleeffectnum(m_explosionParticleFX);
	precache.Sound(m_sndExplosion);
}

void
env_explosion::Respawn(void)
{
	InitPointTrigger();
	SetValue(1i);
}

void
env_explosion::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_explosionMagnitude", m_explosionMagnitude);
	SaveFloat(handle, "m_explosionRadiusOverride", m_explosionRadiusOverride);
	SaveString(handle, "m_explosionParticleFX", m_explosionParticleFX);
	SaveString(handle, "m_sndExplosion", m_sndExplosion);
	SaveInt(handle, "m_explosionParticleID", m_explosionParticleID);
}

void
env_explosion::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_explosionMagnitude":
		m_explosionMagnitude = ReadInt(setValue);
		break;
	case "m_explosionRadiusOverride":
		m_explosionRadiusOverride = ReadFloat(setValue);
		break;
	case "m_explosionParticleFX":
		m_explosionParticleFX = ReadString(setValue);
		break;
	case "m_sndExplosion":
		m_sndExplosion = ReadString(setValue);
		break;
	case "m_explosionParticleID":
		m_explosionParticleID = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_explosion::Trigger(entity act, triggermode_t state)
{
	bool shouldDamage = true;

	if (GetValue(this) == false) {
		return;
	}

	if (HasSpawnFlags(ENVEXPLO_NOTUNDERWATER) == true && WaterLevel() > 0) {
		shouldDamage = false;
	} else if (HasSpawnFlags(ENVEXPLO_NODAMAGE) == true) {
		shouldDamage = false;
	}

	/* TODO: Should be pass the nearest surface normal? Just an idea. */
	pointparticles(m_explosionParticleID, GetOrigin(), [0,0,0], 1);

	if (HasSpawnFlags(ENVEXPLO_NOSOUND) == false) {
		StartSoundDef(m_sndExplosion, CHAN_BODY, true);
	}

	if (shouldDamage == true) {
		damageType_t damageType = DMG_EXPLODE;

		if (HasSpawnFlags(ENVEXPLO_GENERICDAMAGE) == true) {
			damageType = DMG_GENERIC;
		}

		combat.RadiusDamage(GetOrigin(), GetExplosionRadius(), 0i, GetExplosionDamage(), act, "");
	}

	if (HasSpawnFlags(ENVEXPLO_REPEATABLE) == false) {
		SetValue(0i);
	}
}

void
env_explosion::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "Explode":
		Trigger(entityActivator, TRIG_TOGGLE);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

float
env_explosion::GetExplosionRadius(void)
{
	return (m_explosionRadiusOverride == -1) ? (float)m_explosionMagnitude * 2.5f : m_explosionRadiusOverride;
}

int
env_explosion::GetExplosionDamage(void)
{
	return (m_explosionMagnitude);
}
