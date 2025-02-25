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
	EVF_FADEDROM,
	EVF_MODULATE,
	EVF_ONLYUSER
};

/*! \brief Server-Entity: Fade In/Out Controller */
/*!QUAKED env_fade (1 .5 0) (-8 -8 -8) (8 8 8) EVF_FADEDROM EVF_MODULATE EVF_ONLYUSER
# OVERVIEW
Overlay that blinds/obscures players vision when triggered.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "rendercolor" : RGB8 Color of the fade effect.
- "renderamt" : A8 alpha value we'll hit at max.
- "duration" : Duration of the effect in seconds.
- "holdtime" : How long we'll hold on the max color/alpha.

# SPAWNFLAGS
- EVF_FADEDROM (1) : Inverts the fading animation.
- EVF_MODULATE (2) : Modulate tints the image after "rendercolor" instead of obscuring it.
- EVF_ONLYUSER (4) : Don't blind everyone, just the activator.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup pointentity
*/
class
env_fade:ncRenderableEntity
{
public:
	void env_fade(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
	virtual void SpawnKey(string,string);

private:
	float m_flFadeDuration;
	float m_flFadeHold;
};

void
env_fade::env_fade(void)
{
	m_flFadeDuration = 0.0f;
	m_flFadeHold = 0.0f;
}

void
env_fade::Save(float handle)
{
	super::Save(handle);
	SaveFloat(handle, "m_flFadeDuration", m_flFadeDuration);
	SaveFloat(handle, "m_flFadeHold", m_flFadeHold);
}

void
env_fade::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_flFadeDuration":
		m_flFadeDuration = ReadFloat(strValue);
		break;
	case "m_flFadeHold":
		m_flFadeHold = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_fade::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "duration":
		m_flFadeDuration = stof(strValue);
		break;
	case "holdtime":
		m_flFadeHold = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_fade::Trigger(entity eAct, triggermode_t iState)
{
	/* Half-Life ignores states entirely for env_fade's being triggered */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_FADE);
	WriteByte(MSG_MULTICAST, m_vecRenderColor[0]);
	WriteByte(MSG_MULTICAST, m_vecRenderColor[1]);
	WriteByte(MSG_MULTICAST, m_vecRenderColor[2]);
	WriteByte(MSG_MULTICAST, m_flRenderAmt);
	WriteFloat(MSG_MULTICAST, m_flFadeDuration);
	WriteFloat(MSG_MULTICAST, m_flFadeHold);
	WriteByte(MSG_MULTICAST, spawnflags);
	msg_entity = eAct;

	if (HasSpawnFlags(EVF_ONLYUSER))
		multicast([0,0,0], MULTICAST_ONE_R);
	else
		multicast([0,0,0], MULTICAST_ALL);
}

void
env_fade::Input(entity theActivator, string inputName, string dataString)
{
	switch (inputName) {
	case "Fade":
		Trigger(theActivator, TRIG_ON);
		break;
	default:
		super::Input(theActivator, inputName, dataString);
	}
}
