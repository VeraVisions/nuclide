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
	EVSPARK_UNUSED1,
	EVSPARK_UNUSED2,
	EVSPARK_UNUSED3,
	EVSPARK_UNUSED4,
	EVSPARK_UNUSED5,
	EVSPARK_TOGGLE,
	EVSPARK_STARTON,
	EVSPARK_UNUSED6,
	EVSPARK_SILENT,
	EVSPARK_DIRECTIONAL
};

/*! \brief Server-Entity: Spark Maker */
/*!QUAKED env_spark (1 .5 0) (-8 -8 -8) (8 8 8) x x x x x TOGGLE START_ON
# OVERVIEW
Creates a series (or just one) spark effect with sound when triggered.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "angles" : Sets the pitch, yaw and roll angles of the spark.
- "MaxDelay" : Delay between sparks when start-on (or toggle) is set

# INPUTS
- "StartSpark" : Enables a continous spark emitter.
- "StopSpark" : Stops the ongoing spark emitter.
- "ToggleSpark" : Toggles the state of the spark emitter.
- "SparkOnce" : Creates a single spark effect, once.

# SPAWNFLAGS
- TOGGLE (32) : When triggered, it'll spark continously with "MaxDelay" dictating the interval.
- START_ON (64) : Start sparking upon spawning, at least waiting til "MaxDelay" seconds has passed.
- SILENT (256) : Do not play a sound.
- DIRECTIONAL (512) : Angles are respected to direct the spark.

# NOTES
The spawnflag START_ON (32) automatically enables the TOGGLE (64) flag
as well.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
env_spark:ncPointTrigger
{
public:
	void env_spark(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	nonvirtual void _TimedSpark(void);

	nonvirtual void StartSpark(void);
	nonvirtual void StopSpark(void);
	nonvirtual void ToggleSpark(void);
	nonvirtual void SparkOnce(void);

private:
	float m_flMaxDelay;
	int _m_iSparkParticle;
};

void
env_spark::env_spark(void)
{
	m_flMaxDelay = 0.0f;
	_m_iSparkParticle = 0i;
}

void
env_spark::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flMaxDelay", m_flMaxDelay);
	SaveInt(handle, "_m_iSparkParticle", _m_iSparkParticle);
}

void
env_spark::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flMaxDelay":
		m_flMaxDelay = ReadFloat(strValue);
		break;
	case "_m_iSparkParticle":
		_m_iSparkParticle = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_spark::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "MaxDelay":
		m_flMaxDelay = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_spark::Spawned(void)
{
	super::Spawned();

	Sound_Precache("DoSpark");
	_m_iSparkParticle = particleeffectnum("fx_spark.main");
}

void
env_spark::Respawn(void)
{
	InitPointTrigger();

	if (m_flMaxDelay <= 0) {
		m_flMaxDelay = 1.0f;
	}

	if (HasSpawnFlags(EVSPARK_STARTON)) {
		StartSpark();
	}

	if (HasSpawnFlags(EVSPARK_DIRECTIONAL) == false) {
		SetAngles([0,0,0]);
	}
}

void
env_spark::StartSpark(void)
{
	ScheduleThink(_TimedSpark, (random() * m_flMaxDelay));
}

void
env_spark::StopSpark(void)
{
	ReleaseThink();
}

void
env_spark::ToggleSpark(void)
{
	if (IsThinking() == true) {
		StopSpark();
	} else {
		StartSpark();
	}
}

void
env_spark::SparkOnce(void)
{
	if (HasSpawnFlags(EVSPARK_SILENT) == false) {
		StartSoundDef("DoSpark", CHAN_AUTO, true);
	}

	pointparticles(_m_iSparkParticle, origin, angles, 1);
}

void
env_spark::Trigger(entity act, triggermode_t state)
{
	if (!HasSpawnFlags(EVSPARK_TOGGLE) && !HasSpawnFlags(EVSPARK_STARTON)) {
		SparkOnce();
		return;
	}

	switch (state) {
	case TRIG_OFF:
		StopSpark();
		break;
	case TRIG_ON:
		StartSpark();
		break;
	default:
		ToggleSpark();
	}
}

void
env_spark::Input(entity theActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "StartSpark":
		StartSpark();
		break;
	case "StopSpark":
		StopSpark();
		break;
	case "ToggleSpark":
		ToggleSpark();
		break;
	case "SparkOnce":
		SparkOnce();
		break;
	default:
		super::Input(theActivator, inputName, dataField);
	}
}

void
env_spark::_TimedSpark(void)
{
	SparkOnce();
	ScheduleThink(_TimedSpark, (random() * m_flMaxDelay));
}
