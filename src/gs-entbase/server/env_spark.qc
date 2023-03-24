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
	EVSPARK_STARTON
};

/*!QUAKED env_spark (1 .5 0) (-8 -8 -8) (8 8 8) x x x x x EVSPARK_TOGGLE EVSPARK_STARTON
# OVERVIEW
Creates a series (or just one) spark effect with sound when triggered.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "angles" : Sets the pitch, yaw and roll angles of the spark.
- "MaxDelay" : Delay between sparks when start-on (or toggle) is set

# SPAWNFLAGS
- EVSPARK_TOGGLE (32) : When triggered, it'll spark continously with "MaxDelay" dictating the interval.
- EVSPARK_STARTON (64) : Start sparking upon spawning, at least waiting til "MaxDelay" seconds has passed.

# NOTES
The spawnflags EVSPARK_TOGGLE and EVSPARK_STARTON are often used together.
Without them set, it'll of course only spark once whenever it's triggered.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
env_spark:NSPointTrigger
{
	float m_flMaxDelay;

public:
	void env_spark(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	nonvirtual void CreateSpark(void);
	nonvirtual void TimedSpark(void);

};

void
env_spark::env_spark(void)
{
	m_flMaxDelay = 0.0f;
}

void
env_spark::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flMaxDelay", m_flMaxDelay);
}

void
env_spark::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flMaxDelay":
		m_flMaxDelay = ReadFloat(strValue);
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

	Sound_Precache("env_spark.sfx");
}

void
env_spark::Respawn(void)
{
	if (m_flMaxDelay <= 0) {
		m_flMaxDelay = 1.0f;
	}

	if (HasSpawnFlags(EVSPARK_STARTON)) {
		Trigger(this, TRIG_ON);
	}
}

void
env_spark::Trigger(entity act, triggermode_t state)
{
	if (!HasSpawnFlags(EVSPARK_TOGGLE)) {
		CreateSpark();
		return;
	}

	switch (state) {
	case TRIG_OFF:
		ReleaseThink();
		break;
	case TRIG_ON:
		ScheduleThink(CreateSpark, (random() * m_flMaxDelay));
		break;
	default:
		if (IsThinking() == true) {
			Trigger(act, TRIG_OFF);
		} else {
			Trigger(act, TRIG_ON);
		}
	}
}

void
env_spark::CreateSpark(void)
{
	Sound_Play(this, CHAN_AUTO, "env_spark.sfx");
	FX_Spark(self.origin, self.angles);
}

void
env_spark::TimedSpark(void)
{
	CreateSpark();
	ScheduleThink(CreateSpark, (random() * m_flMaxDelay));
}
