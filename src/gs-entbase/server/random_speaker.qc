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

/*!QUAKED random_speaker (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
This entity plays a .wav file at random intervals.

# KEYS
- "targetname" : Name
- "target" : Target when triggered
- "killtarget" : Target to kill when triggered
- "rsnoise" : Path to the sound file.
- "volume" : Volume to play the sound as (normalized, 0.0 - 1.0).
- "wait" : Minimum time for sound repetition in %.
- "random" : Random % of this added to wait.

# NOTES
To explain the math behind it:
The 'wait' key specifies the minimum time it waits to play itself again,
however we always add a bit of a random interval on top.
The random interval is a set percentage of the specified 'wait' time.
For example, if 'wait' is 10 and 'random' is 50, then it'll always be
a random interval between 10 and 15 seconds in total.

# TRIVIA
It was introduced in Gunman Chronicles (2000).
*/
class
random_speaker:NSPointTrigger
{
public:
	void random_speaker(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
	
	nonvirtual void PlaySample(void);
	nonvirtual void Enable(void);
	nonvirtual void Disable(void);

private:
	string m_strSample;
	float m_flVolume;
	float m_flMinPos;
	float m_flRandPercent;
};

void
random_speaker::random_speaker(void)
{
	m_strSample = __NULL__;
	m_flVolume = 1.0f;
	m_flMinPos = 0.0f;
	m_flRandPercent = 0.0f;
}

void
random_speaker::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSample", m_strSample);
	SaveFloat(handle, "m_flVolume", m_flVolume);
	SaveFloat(handle, "m_flMinPos", m_flMinPos);
	SaveFloat(handle, "m_flRandPercent", m_flRandPercent);
}

void
random_speaker::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strSample":
		m_strSample = ReadString(strValue);
		break;
	case "m_flVolume":
		m_flVolume = ReadFloat(strValue);
		break;
	case "m_flMinPos":
		m_flMinPos = ReadFloat(strValue);
		break;
	case "m_flRandPercent":
		m_flRandPercent = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
random_speaker::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "rsnoise":
		m_strSample = strValue;
		break;
	case "volume":
		m_flVolume = stof(strValue);
		break;
	case "wait":
		m_flMinPos = stof(strValue);
		break;
	case "random":
		m_flRandPercent = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
random_speaker::Respawn(void)
{
	InitPointTrigger();
	Disable();
}

void
random_speaker::Trigger(entity act, triggermode_t state)
{
	if (GetMaster(act) == FALSE)
		return;

	switch (state) {
	case TRIG_OFF:
		Disable();
		break;
	case TRIG_ON:
		Enable();
		break;
	default:
		if (m_iValue)
			Trigger(act, TRIG_OFF);
		else
			Trigger(act, TRIG_ON);
	}
}

void
random_speaker::PlaySample(void)
{
	sound(this, CHAN_VOICE, m_strSample, m_flVolume, ATTN_NONE);

	/* cue the next time we're playing this sample */
	Enable();
}

void
random_speaker::Enable(void)
{
	float r;

	m_iValue = 1;

	/* at least wait this amount */
	r = m_flMinPos;

	/* then take the specified percentage of 'wait', by random and add it */
	r += (m_flMinPos * (m_flRandPercent / 100)) * random();

	ScheduleThink(PlaySample, r);
	EntLog("%s playing %s in %d\n", targetname, m_strSample, r);
}

void
random_speaker::Disable(void)
{
	EntLog("Disabled %s playing %s\n", targetname, m_strSample);
	m_iValue = 0;
	ReleaseThink();
}
