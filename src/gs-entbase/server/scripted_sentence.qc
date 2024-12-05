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

/*! \brief Server-Entity: Voice Acted Sequence Controller */
/*!QUAKED scripted_sentence (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Triggers a sound event on the client side associated with an entity in the
world. It'll enable mouth flapping and all sorts of other cool effects.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "entity" : Name of the entity that'll speak the sentence.
- "sentence" : Name of sentence from titles.txt.
- "pitch" : Desired sound pitch. May be overridden in the titles.txt entry.
- "delay" : Delay before it'll be triggered.
- "wait" : Delay before it can be triggered again? UNUSED RIGHT NOW.
- "listener" : The name of the entity we'll look at when speaking. Can be "player".
- "refire" : Additional time in seconds before the entity can be triggered again.
- "duration" : Time after which the target stops talking.

# INPUTS
- "BeginSentence" : Starts the sentence.

# OUTPUTS
- "OnBeginSentence" : Fired when the sentence starts.
- "OnEndSentence" : Fired when the sentence ends.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
scripted_sentence:ncPointTrigger
{
public:
	void scripted_sentence(void);
	
	/* overrides */
	virtual void Spawned(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);

	nonvirtual void AllowRefire(void);
	nonvirtual void SentenceEnded(void);

private:
	string m_strSpeaker;
	string m_strSentence;
	int m_iSentenceID;
	float m_flDelay;
	float m_flWait;
	float m_flPitch;
	float m_flDuration;
	string m_strListener;
	string m_strOnBeginSentence;
	string m_strOnEndSentence;
	float m_flRefire;
};

void
scripted_sentence::scripted_sentence(void)
{
	m_strSpeaker = __NULL__;
	m_strSentence = __NULL__;
	m_flDelay = 0.0f;
	m_flWait = 0.0f;
	m_flPitch = 0.0f;
	m_flDuration = 0.0f;
	m_strListener = __NULL__;
	m_strOnBeginSentence = __NULL__;
	m_strOnEndSentence = __NULL__;
	m_iSentenceID = 0i;
	m_flRefire = 0.0f;
}

void
scripted_sentence::Spawned(void)
{
	super::Spawned();

	m_iSentenceID = Sentences_GetID(m_strSentence);

	if (m_strOnBeginSentence)
		m_strOnBeginSentence = CreateOutput(m_strOnBeginSentence);
	if (m_strOnEndSentence)
		m_strOnEndSentence = CreateOutput(m_strOnEndSentence);
}

void
scripted_sentence::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSpeaker", m_strSpeaker);
	SaveString(handle, "m_strSentence", m_strSentence);
	SaveFloat(handle, "m_flDelay", m_flDelay);
	SaveFloat(handle, "m_flWait", m_flWait);
	SaveFloat(handle, "m_flPitch", m_flPitch);
	SaveFloat(handle, "m_flDuration", m_flDuration);
	SaveString(handle, "m_strListener", m_strListener);
	SaveString(handle, "m_strOnBeginSentence", m_strOnBeginSentence);
	SaveString(handle, "m_strOnEndSentence", m_strOnEndSentence);
	SaveInt(handle, "m_iSentenceID", m_iSentenceID);
	SaveFloat(handle, "m_flRefire", m_flRefire);
}

void
scripted_sentence::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSpeaker":
		m_strSpeaker = ReadString(strValue);
		break;
	case "m_strSentence":
		m_strSentence = ReadString(strValue);
		break;
	case "m_flDelay":
		m_flDelay = ReadFloat(strValue);
		break;
	case "m_flWait":
		m_flWait = ReadFloat(strValue);
		break;
	case "m_flPitch":
		m_flPitch = ReadFloat(strValue);
		break;
	case "m_flDuration":
		m_flDuration = ReadFloat(strValue);
		break;
	case "m_strListener":
		m_strListener = ReadString(strValue);
		break;
	case "m_strOnBeginSentence":
		m_strOnBeginSentence = ReadString(strValue);
		break;
	case "m_strOnEndSentence":
		m_strOnEndSentence = ReadString(strValue);
		break;
	case "m_iSentenceID":
		m_iSentenceID = ReadInt(strValue);
		break;
	case "m_flRefire":
		m_flRefire = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
scripted_sentence::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "entity":
		m_strSpeaker = setValue;
		break;
	case "sentence":
		m_strSentence = strtoupper(setValue);
		break;
	case "pitch":
		m_flPitch = ReadFloat(setValue);
		break;
	case "duration":
		m_flDuration = ReadFloat(setValue);
		break;
	case "wait":
		m_flWait = ReadFloat(setValue);
		break;
	case "listener":
		m_strListener = ReadString(setValue);
		break;
	case "delay":
		m_flDelay = ReadFloat(setValue);
		break;
	case "refire":
		m_flRefire = ReadFloat(setValue);
		break;
	case "OnBeginSentence":
		m_strOnBeginSentence = ReadString(setValue);
		break;
	case "OnEndSentence":
		m_strOnEndSentence = ReadString(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
scripted_sentence::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "BeginSentence":
		Trigger(entityActivator, TRIG_TOGGLE);
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
scripted_sentence::AllowRefire(void)
{
	EntLog("%S can now be refired.", targetname);
	m_iValue = 0;
}


void
scripted_sentence::SentenceEnded(void)
{
	ncTalkMonster targetMonster = __NULL__;

	EntLog("%S finished speaking.", m_strSpeaker);

	targetMonster = (ncTalkMonster)find(world, ::targetname, m_strSpeaker);

	/* it might not exist anymore... */
	if (targetMonster) {
		targetMonster.StopSound(CHAN_VOICE, true);
	}

	UseOutput(this, m_strOnEndSentence);

	if (m_flRefire > 0.0f) {
		ScheduleThink(AllowRefire, m_flRefire);
	} else {
		AllowRefire();
	}
}

void
scripted_sentence::Trigger(entity act, triggermode_t unused)
{
	entity spe;

	if (m_iValue == 1) {
		return;
	}

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
		NSError("Couldn't find %s!\n", m_strSpeaker);
		return;
	}

	EntLog("%s on %s", m_strSentence, m_strSpeaker);

	/* ensure this is set here, so when UseTargets() gets called
	   this entity will already be inaccessible. fixes ba_tram2. */
	m_iValue = 1;

	ncTalkMonster npc = (ncTalkMonster)spe;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SENTENCE);
	WriteEntity(MSG_MULTICAST, npc);
	WriteInt(MSG_MULTICAST, m_iSentenceID);
	msg_entity = npc;
	multicast(npc.origin, MULTICAST_PVS);
	npc.m_flNextSentence = time + m_flDuration;
	UseTargets(act, TRIG_TOGGLE, m_flDelay);

	/* I/O */
	/* Uncertain: Are we triggering the output on behalf of someone maybe? */
	UseOutput(this, m_strOnBeginSentence);
	ScheduleThink(SentenceEnded, m_flDuration);

	if (m_strListener) {
		if (m_strListener == "player") {
			npc.m_eLookAt = find(world, ::classname, "player");
		} else {
			npc.m_eLookAt = find(world, ::targetname, m_strListener);
		}
	}
}
