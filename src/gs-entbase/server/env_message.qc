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

/*QUAKED env_message (1 0 0) (-8 -8 -8) (8 8 8) EMF_ONCE EMF_ALLPLAYERS
Displays a basic message or titles.txt entry.

-------- KEYS --------
"targetname" : Name
"target" : Target when triggered.
"killtarget" : Target to kill when triggered.
"message" : Message to send to players
"messagesound" : PCM sample to play when triggered. Leave empty if desired.
"messagevolume" : PCM sample volume. Only relevant when "messagesound" is set.
"messageattenuation" : PCM sample attenuation. Ditto.

-------- SPAWNFLAGS --------
EMF_ONCE : Removes itself after being triggered once.
EMF_ALLPLAYERS : Send the message to all clients instead of only the activator.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

enumflags
{
	EMF_ONCE,
	EMF_ALLPLAYERS
};

class
env_message:NSPointTrigger
{
	string m_strSound;
	float m_flVolume;
	int m_iAttenuation; /* FIXME: change this to a proper attenuation type */

public:
	void env_message(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	
	virtual void Play(entity,int);

};

void
env_message::env_message(void)
{
	m_strSound = __NULL__;
	m_flVolume = 1.0f;
	m_iAttenuation = 0i;
}

void
env_message::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSound", m_strSound);
	SaveFloat(handle, "m_flVolume", m_flVolume);
	SaveInt(handle, "m_iAttenuation", m_iAttenuation);
}

void
env_message::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSound":
		m_strSound = ReadString(strValue);
		break;
	case "m_flVolume":
		m_flVolume = ReadFloat(strValue);
		break;
	case "m_iAttenuation":
		m_iAttenuation = ReadInt(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_message::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "messagesound":
		m_strSound = strValue;
		break;
	case "messagevolume":
		m_flVolume = stof(strValue);
		break;
	case "messageattenuation":
		m_iAttenuation = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_message::Respawn(void)
{
	Trigger = Play;
}

void
env_message::Play(entity act, int state)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MESSAGE);
	WriteString(MSG_MULTICAST, m_strMessage);
	WriteString(MSG_MULTICAST, m_strSound);
	WriteFloat(MSG_MULTICAST, m_flVolume);
	WriteByte(MSG_MULTICAST, m_iAttenuation);

	if (!(act.flags & FL_CLIENT) || HasSpawnFlags(EMF_ALLPLAYERS)) {
		msg_entity = this;
		multicast(origin, MULTICAST_ALL);
	} else {
		msg_entity = act;
		multicast(origin, MULTICAST_ONE_R);
	}

	if (HasSpawnFlags(EMF_ONCE)) {
		Trigger = __NULL__;
	}
}

void
env_message_single(entity target, string msg)
{
	if (!msg)
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MESSAGE);

	if (substring(msg, 0, 1) != "#")
		WriteString(MSG_MULTICAST, msg);
	else
		WriteString(MSG_MULTICAST, substring(msg, 1, -1));

	WriteString(MSG_MULTICAST, "misc/talk.wav");
	WriteFloat(MSG_MULTICAST, 1.0);
	WriteByte(MSG_MULTICAST, ATTN_NORM);
	msg_entity = target;
	multicast([0,0,0], MULTICAST_ONE_R);
}

void
env_message_broadcast(string msg)
{
	if (!msg)
		return;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MESSAGE);

	if (substring(msg, 0, 1) != "#")
		WriteString(MSG_MULTICAST, msg);
	else
		WriteString(MSG_MULTICAST, substring(msg, 1, -1));

	WriteString(MSG_MULTICAST, "misc/talk.wav");
	WriteFloat(MSG_MULTICAST, 1.0);
	WriteByte(MSG_MULTICAST, ATTN_NORM);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);
}
