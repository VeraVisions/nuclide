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

/*! \brief Server-Entity: Redundant Sound Emitter #2 */
/*!QUAKED targ_speaker (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
This entity plays a sample upon triggering at a specified volume.

# KEYS
- "targetname" : Name
- "target" : Target when triggered
- "killtarget" : Target to kill when triggered
- "tsnoise" : Path to the sound file
- "volume" : Volume to play the sound as (normalized, 0.0 - 1.0)

# TRIVIA
It was introduced in Gunman Chronicles (2000).

It's not any more useful than an ambient_generic.
I suspect it's a carry-over from when Gunman was a Quake II mod, as
Quake/Quake II did not have an entity that allowed custom sound samples
to be played.

@ingroup server
@ingroup pointentity
*/
class
targ_speaker:NSPointTrigger
{
public:
	void targ_speaker(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);

private:
	string m_strSample;
	float m_flVolume;
};

void
targ_speaker::targ_speaker(void)
{
	m_strSample = __NULL__;
	m_flVolume = 0.0f;
}

void
targ_speaker::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSample", m_strSample);
	SaveFloat(handle, "m_flVolume", m_flVolume);
}

void
targ_speaker::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSample":
		m_strSample = ReadString(strValue);
		break;
	case "m_flVolume":
		m_flVolume = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
targ_speaker::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "noise":
	case "tsnoise":
		m_strSample = strValue;
		break;
	case "volume":
		m_flVolume = stof(strValue);
		break;
	default:
		break;
	}
}

void
targ_speaker::Respawn(void)
{
	InitPointTrigger();
}

void
targ_speaker::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == FALSE)
		return;

	sound(this, CHAN_AUTO, m_strSample, m_flVolume, ATTN_NORM);
	
}
