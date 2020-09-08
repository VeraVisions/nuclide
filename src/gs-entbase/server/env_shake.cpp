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

/*QUAKED env_shake (1 0.5 0) (-8 -8 -8) (8 8 8) EVS_GLOBAL
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"radius"        Radius of the quake/shake effect.
"amplitude"     Amplitude of the effect.
"duration"      Duration of the effect in seconds.
"frequency"     The frequency of the shake.

Causes an earthquake/shaking effect when triggered.
Affects all clients (radius ignored) when EVS_GLOBAL is set.
*/

#define EVS_GLOBAL 1

class env_shake:CBaseTrigger
{
	float m_flRadius;
	float m_flAmplitude;
	float m_flDuration;
	float m_flFrequency;

	void(void) env_shake;
	virtual void(entity act, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
env_shake::Trigger(entity act, int state)
{
	for (entity e = world; (e = find(e, ::classname, "player"));) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SHAKE);
		WriteFloat(MSG_MULTICAST, m_flRadius);
		WriteFloat(MSG_MULTICAST, m_flAmplitude);
		WriteFloat(MSG_MULTICAST, m_flDuration);
		WriteFloat(MSG_MULTICAST, m_flFrequency);
		msg_entity = e;
		multicast([0,0,0], MULTICAST_ONE_R);
	}
}

void
env_shake::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "radius":
		m_flRadius = stof(strValue);
		break;
	case "amplitude":
		m_flAmplitude = stof(strValue);
		break;
	case "duration":
		m_flDuration = stof(strValue);
		break;
	case "frequency":
		m_flFrequency = stof(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
env_shake::env_shake(void)
{
	CBaseTrigger::CBaseTrigger();
}
