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

/*! \brief Server-Entity: Trigger-Based CD Track Changer */
/*!QUAKED trigger_cdaudio (.5 .5 .5) ?
# OVERVIEW
Switches the background music track when triggered.

# KEYS
- "targetname" : Name
- "health" : Music track to play.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup serverentity
@ingroup brushentity
*/

class
trigger_cdaudio:ncBrushTrigger
{
public:
	void trigger_cdaudio(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Touch(entity);

private:
	int m_iCDTrack;
};

void
trigger_cdaudio::trigger_cdaudio(void)
{
	m_iCDTrack = 0i;
}

void
trigger_cdaudio::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iCDTrack", m_iCDTrack);
}

void
trigger_cdaudio::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iCDTrack":
		m_iCDTrack = ReadInt(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
trigger_cdaudio::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "health":
		m_iCDTrack = stoi(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
		break;
	}
}

void
trigger_cdaudio::Respawn(void)
{
	InitBrushTrigger();
}

void
trigger_cdaudio::Trigger(entity act, triggermode_t unused)
{
	if (!(act.flags & FL_CLIENT)) {
		return;
	}

	EntLog("CD Track %i requested", m_iCDTrack);

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUSICTRACK);
	WriteByte(MSG_MULTICAST, m_iCDTrack);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL_R);

	Destroy();
}

void
trigger_cdaudio::Touch(entity eToucher)
{
	Trigger(eToucher, TRIG_TOGGLE);
}
