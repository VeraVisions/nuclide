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

#define EVS_GLOBAL 1

/*! \brief Server-Entity: Earthquake Maker */
/*!QUAKED env_shake (1 .5 0) (-8 -8 -8) (8 8 8) GLOBAL
# OVERVIEW
Causes an earthquake/shaking effect when triggered.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "radius" : Radius of the quake/shake effect.
- "amplitude" : Amplitude of the effect.
- "duration" : Duration of the effect in seconds.
- "frequency" : The frequency of the shake.

# SPAWNFLAGS
- GLOBAL : Affect all clients, ignoring "radius" entirely.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
env_shake:ncPointTrigger
{
public:
	void env_shake(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);

	virtual void OnRemoveEntity(void);

private:
	float m_flRadius;
	float m_flAmplitude;
	float m_flDuration;
	float m_flFrequency;
};

void
env_shake::env_shake(void)
{
	m_flRadius = 0.0f;
	m_flAmplitude = 0.0f;
	m_flDuration = 0.0f;
	m_flFrequency = 0.0f;
}

void
env_shake::OnRemoveEntity(void)
{
	if (HasSpawnFlags(1)) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SHAKE);
		WriteFloat(MSG_MULTICAST, 1.0);
		WriteFloat(MSG_MULTICAST, m_flAmplitude);
		WriteFloat(MSG_MULTICAST, m_flFrequency);
		multicast([0,0,0], MULTICAST_ALL_R);
	}
}

void
env_shake::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flRadius", m_flRadius);
	SaveFloat(handle, "m_flAmplitude", m_flAmplitude);
	SaveFloat(handle, "m_flDuration", m_flDuration);
	SaveFloat(handle, "m_flFrequency", m_flFrequency);
}

void
env_shake::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_flRadius":
		m_flRadius = ReadFloat(setValue);
		break;
	case "m_flAmplitude":
		m_flAmplitude = ReadFloat(setValue);
		break;
	case "m_flDuration":
		m_flDuration = ReadFloat(setValue);
		break;
	case "m_flFrequency":
		m_flFrequency = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_shake::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "radius":
		m_flRadius = stof(setValue);
		break;
	case "amplitude":
		m_flAmplitude = stof(setValue);
		break;
	case "duration":
		m_flDuration = stof(setValue);
		break;
	case "frequency":
		m_flFrequency = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_shake::Trigger(entity act, triggermode_t state)
{
	if (HasSpawnFlags(EVS_GLOBAL)) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SHAKE);
		WriteFloat(MSG_MULTICAST, m_flDuration);
		WriteFloat(MSG_MULTICAST, m_flAmplitude);
		WriteFloat(MSG_MULTICAST, m_flFrequency);
		multicast([0,0,0], MULTICAST_ALL_R);
	} else {
		Client_ShakeOnce(origin, m_flRadius, m_flDuration, m_flFrequency, m_flAmplitude);
	}
}

void
env_shake::Input(entity theActivator, string inputName, string dataString)
{
	switch (inputName) {
	case "StartShake":
		Trigger(theActivator, TRIG_ON);
		break;
	default:
		super::Input(theActivator, inputName, dataString);
	}
}
