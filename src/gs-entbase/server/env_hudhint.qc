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

void env_hudhint_send(entity eActivator, string strMessage, int iFlags);

enumflags
{
	EHH_ALLPLAYERS
};

/*! \brief Server-Entity: Displays HUD Hint Messages */
/*!QUAKED env_hudhint (1 .5 0) (-8 -8 -8) (8 8 8) EHH_ALLPLAYERS
# OVERVIEW
Will display a hint message to the client who activates it.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "rendercolor" : RGB8 Color of the fade effect.
- "renderamt" : A8 alpha value we'll hit at max.
- "duration" : Duration of the effect in seconds.
- "holdtime" : How long we'll hold on the max color/alpha.

# SPAWNFLAGS
- EHH_ALLPLAYERS (1) : Send the hint notifcation to all connected clients.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
env_hudhint:ncPointTrigger
{
public:
	void env_hudhint(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);

private:
	string m_strMessage;
};

void
env_hudhint::env_hudhint(void)
{
	m_strMessage = __NULL__;
}

void
env_hudhint::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strMessage", m_strMessage);
}

void
env_hudhint::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strMessage":
		m_strMessage = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_hudhint::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "message":
		m_strMessage = setValue;
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_hudhint::Trigger(entity act, triggermode_t state)
{
	env_hudhint_send(act, m_strMessage, spawnflags);
}

void
env_hudhint_send(entity eAct, string strMessage, int iFlags)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_HUDHINT);
	WriteString(MSG_MULTICAST, strMessage);
	msg_entity = eAct;

	if (iFlags & EHH_ALLPLAYERS)
		multicast([0,0,0], MULTICAST_ALL);
	else
		multicast([0,0,0], MULTICAST_ONE_R);
}
