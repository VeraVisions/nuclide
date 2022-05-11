/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED scripted_sentence (1 0 0) (-8 -8 -8) (8 8 8)
Triggers a sound event on the client side associated with an entity in the
world. It'll enable mouth flapping and all sorts of other cool effects.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"entity" : Name of the entity that'll speak the sentence.
"sentence" : Name of sentence from titles.txt.
"pitch" : Desired sound pitch. May be overridden in the titles.txt entry.
"delay" : Delay before it'll be triggered? UNUSED RIGHT NOW.
"wait" : Delay before it can be triggered again? UNUSED RIGHT NOW.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class scripted_sentence:NSPointTrigger
{
	string m_strSpeaker;
	string m_strSentence;
	float m_flDelay;
	float m_flWait;
	float m_flPitch;
	float m_flDuration;

	void(void) scripted_sentence;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
	virtual void(entity, int) Trigger;
	virtual void(string, string) SpawnKey;
};

void
scripted_sentence::Save(float handle)
{
	SaveString(handle, "speaker", m_strSpeaker);
	SaveString(handle, "sentence", m_strSentence);
	SaveFloat(handle, "delay", m_flDelay);
	SaveFloat(handle, "wait", m_flWait);
	SaveFloat(handle, "pitch", m_flPitch);
	SaveFloat(handle, "duration", m_flDuration);
	super::Save(handle);
}

void
scripted_sentence::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "speaker":
		m_strSpeaker = ReadString(strValue);
		break;
	case "sentence":
		m_strSentence = ReadString(strValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "wait":
		m_flWait = ReadFloat(strValue);
		break;
	case "pitch":
		m_flPitch = ReadFloat(strValue);
		break;
	case "duration":
		m_flDuration = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
scripted_sentence::Trigger(entity act, int unused)
{
	entity spe;
	spe = find(world, ::targetname, m_strSpeaker);

	if (!spe) {
		/* time to look for a classname instead */
		float closest = 9999999;

		for (entity c = world; (c = find(c, ::classname, m_strSpeaker));) {
			float rad;
			rad = vlen(origin - c.origin);

			/* pick the closest entity */
			if (rad < closest) {
				spe = c;
				closest = rad;
			}
		}
	}

	if (!spe) {
		print(sprintf("^1scripted_sentence::^3Trigger^7: Couldn't find %s!\n", m_strSpeaker));
		return;
	}

	NSLog("^2scripted_sentence::^3Trigger^7: %s on %s", m_strSentence, m_strSpeaker);

	NSTalkMonster npc = (NSTalkMonster)spe;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, npc);
	WriteString(MSG_MULTICAST, m_strSentence);
	msg_entity = npc;
	multicast(npc.origin, MULTICAST_PVS);
	npc.m_flNextSentence = time + m_flDuration;
}

void
scripted_sentence::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "entity":
		m_strSpeaker = strValue;
		break;
	case "sentence":
		m_strSentence = strtoupper(strValue);
		break;
	case "pitch":
		m_flPitch = stof(strValue);
		break;
	case "duration":
		m_flDuration = stof(strValue);
		break;
	case "wait":
		m_flWait = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
scripted_sentence::scripted_sentence(void)
{
	super::NSPointTrigger();
}
